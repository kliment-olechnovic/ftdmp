(*
 * Copyright (c) 1997-1999, 2003 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *)

(* $Id: to_c.ml,v 1.26 2003/03/16 23:43:46 stevenj Exp $ *)

let cvsid = "$Id: to_c.ml,v 1.26 2003/03/16 23:43:46 stevenj Exp $"

open Expr
open Asched
open List

(* Here, we have routines for outputting the C source code for FFTW
   using the abstract syntax tree (AST), symbolic expressions,
   etcetera, produced by the rest of the generator. *)

let foldr_string_concat l = fold_right (^) l ""

(* output the command line *)
let cmdline () =
  fold_right (fun a b -> a ^ " " ^ b) (Array.to_list Sys.argv) ""

let paranoid_alignment_check () =
  if !Magic.alignment_check then
    "ASSERT_ALIGNED_DOUBLE;\n" 
  else
    ""

(***********************************
 * C program structure 
 ***********************************)
type c_decl = Decl of string * string
type c_ast =
    Asch of annotated_schedule
  | For of c_ast * c_ast * c_ast * c_ast
  | If of c_ast * c_ast
  | Block of (c_decl list) * (c_ast list)
  | Binop of string * expr * expr
  | Expr_assign of expr * expr
  | Stmt_assign of expr * expr
  | Comma of c_ast * c_ast

type c_fcn = Fcn of string * string * (c_decl list) * c_ast

let real = "fftw_real"


(*
 * traverse a a function and return a list of all expressions,
 * in the execution order
 *)
let rec fcn_to_expr_list =
  let rec acode_to_expr_list = function
      AInstr (Assign (_, x)) -> [x]
    | ASeq (a, b) -> 
	(asched_to_expr_list a) @ (asched_to_expr_list b)
    | _ -> []
  and asched_to_expr_list (Annotate (_, _, _, _, code)) =
    acode_to_expr_list code
  and ast_to_expr_list = function
      Asch a -> asched_to_expr_list a
    | Block (_, a) -> flatten (map ast_to_expr_list a)
    | For (_, _, _, body) ->  ast_to_expr_list body
    | If (_, body) ->  ast_to_expr_list body
    | _ -> []
	  
  in fun (Fcn (_, _, _, body)) -> ast_to_expr_list body 


(***************** Extracting Operation Counts ***************)

let count_stack_vars =
  let rec count_acode = function
    | ASeq (a, b) -> max (count_asched a) (count_asched b)
    | _ -> 0
  and count_asched (Annotate (_, _, decl, _, code)) =
    (length decl) + (count_acode code)
  and count_ast = function
    | Asch a -> count_asched a
    | Block (d, a) -> (length d) + (Util.max_list (map count_ast a))
    | For (_, _, _, body) -> count_ast body
    | If (_, body) -> count_ast body
    | _ -> 0
  in function (Fcn (_, _, _, body)) -> count_ast body

let count_memory_acc f =
  let rec count_var v =
    if (Variable.is_input v) or (Variable.is_output v)
	then 1
	else 0
  and count_acode = function
    | AInstr (Assign (v, _)) -> count_var v
    | ASeq (a, b) -> (count_asched a) + (count_asched b)
    | _ -> 0
  and count_asched = function
      Annotate (_, _, _, _, code) -> count_acode code
  and count_ast = function
    | Asch a -> count_asched a
    | Block (_, a) -> (Util.sum_list (map count_ast a))
    | Comma (a, b) -> (count_ast a) + (count_ast b)
    | For (_, _, _, body) -> count_ast body
    | If (_, body) -> count_ast body
    | _ -> 0
  and count_acc_expr_func acc = function
    | Var v -> acc + (count_var v)
    | Plus a -> fold_left count_acc_expr_func acc a
    | Times (a, b) -> fold_left count_acc_expr_func acc [a; b]
    | Uminus a -> count_acc_expr_func acc a
    | _ -> acc
  in let (Fcn (typ, name, args, body)) = f
  in (count_ast body) + 
    fold_left count_acc_expr_func 0 (fcn_to_expr_list f)

let build_fma = function
  | [a; Times (b, c)] -> Some (a, b, c)
  | [Times (b, c); a] -> Some (a, b, c)
  | [a; Uminus (Times (b, c))] -> Some (a, b, c)
  | [Uminus (Times (b, c)); a] -> Some (a, b, c)
  | _ -> None

let rec count_flops_expr_func (adds, mults, fmas) = function
  | Plus [] -> (adds, mults, fmas)
  | Plus a -> (match build_fma a with
      None ->
	let (newadds, newmults, newfmas) = 
	  fold_left count_flops_expr_func (adds, mults, fmas) a
	in (newadds + (length a) - 1, newmults, newfmas)
    | Some (a, b, c) ->
	let (newadds, newmults, newfmas) = 
	  fold_left count_flops_expr_func (adds, mults, fmas) [a; b; c]
	in  (newadds, newmults, newfmas + 1))
  | Times (a,b) -> 
      let (newadds, newmults, newfmas) = 
	fold_left count_flops_expr_func (adds, mults, fmas) [a; b]
      in (newadds, newmults + 1, newfmas)
  | Uminus a -> count_flops_expr_func (adds, mults, fmas) a
  | _ -> (adds, mults, fmas)

let count_flops f = 
    fold_left count_flops_expr_func (0, 0, 0) (fcn_to_expr_list f)

let arith_complexity f =
  let (a, m, fmas) = count_flops f
  and v = count_stack_vars f
  and mem = count_memory_acc f
  in (a, m, fmas, v, mem)

(* print the operation costs *)
let print_cost f =
  let Fcn (_, name, _, _) = f 
  and (a, m, fmas, v, mem) = arith_complexity f
  in
  "/*\n"^
  " * This function contains " ^
  (string_of_int (a + fmas)) ^ " FP additions, "  ^
  (string_of_int (m + fmas)) ^ " FP multiplications,\n" ^
  " * (or, " ^
  (string_of_int a) ^ " additions, "  ^
  (string_of_int m) ^ " multiplications, " ^
  (string_of_int fmas) ^ " fused multiply/add),\n" ^
  " * " ^ (string_of_int v) ^ " stack variables, and " ^
  (string_of_int mem) ^ " memory accesses\n" ^
  " */\n"

(***************** Extracting Constants ***************)

(* add a new key & value to a list of (key,value) pairs, where
   the keys are floats and each key is unique up to almost_equal *)

let add_float_key_value list_so_far k = 
  if exists (fun k2 -> Number.equal k k2) list_so_far then
    list_so_far
  else
    k :: list_so_far

(* find all constants in a given expression *)
let rec expr_to_constants = function
  | Num n -> [n]
  | Plus a -> flatten (map expr_to_constants a)
  | Times (a, b) -> (expr_to_constants a) @ (expr_to_constants b)
  | Uminus a -> expr_to_constants a
  | _ -> []

let extract_constants f =
  let constlist = flatten (map expr_to_constants (fcn_to_expr_list f))
  in let unique_constants = fold_left add_float_key_value [] constlist
  in let use_define () = foldr_string_concat
      (map (function n ->
	"#define " ^
	(Number.unparse n) ^ " " ^ 
	"FFTW_KONST(" ^ (Number.to_string n) ^ ")\n")
	 unique_constants)
  and use_const () = foldr_string_concat
      (map (function n ->
	"static const " ^ real ^ " " ^
	(Number.unparse n) ^ " = " ^ 
	"FFTW_KONST(" ^ (Number.to_string n) ^ ");\n")
	 unique_constants)
  in 
  if !Magic.inline_konstants then 
    use_define () ^ "\n\n"
  else
    use_const () ^ "\n\n"

(******************* Unparsing the Abstract Syntax Tree *******************)

(* make an unparser, given a variable unparser *)
let make_c_unparser unparse_var =

  let rec unparse_expr =
    let rec unparse_plus = function
	[] -> ""
      | (Uminus a :: b) -> " - " ^ (parenthesize a) ^ (unparse_plus b)
      | (a :: b) -> " + " ^ (parenthesize a) ^ (unparse_plus b)
    and parenthesize x = match x with
    | (Var _) -> unparse_expr x
    | (Integer _) -> unparse_expr x
    | (Num _) -> unparse_expr x
    | _ -> "(" ^ (unparse_expr x) ^ ")"
				      
    in function
	Var x -> unparse_var x
      | Num n -> Number.unparse n
      | Integer n -> (string_of_int n)
      | Plus [] -> "0.0 /* bug */"
      | Plus [a] -> " /* bug */ " ^ (unparse_expr a)
      | Plus (a::b) -> (parenthesize a) ^ (unparse_plus b)
      | Times (a, b) -> (parenthesize a) ^ " * " ^ (parenthesize b)
      | Uminus a -> "- " ^ (parenthesize a)

  and unparse_decl = function
      Decl (a, b) -> a ^ " " ^ b ^ ";\n"

  and unparse_assignment (Assign (v, x)) =
    (unparse_var v) ^ " = " ^ (unparse_expr x) ^ ";\n"

  and unparse_annotated force_bracket = 
    let rec unparse_code = function
	ADone -> ""
      | AInstr i -> unparse_assignment i
      | ASeq (a, b) -> 
	  (unparse_annotated false a) ^ (unparse_annotated false b)
    and declare_variables = function
	[] -> ""
      | v :: l when Variable.is_temporary v -> 
	  (real ^ " " ^ (unparse_var v) ^ ";\n") ^ (declare_variables l)
      | s :: l -> (declare_variables l) 
    in function
	Annotate (_, _, decl, _, code) ->
	  if (not force_bracket) && (Util.null decl) then 
	    unparse_code code
	  else "{\n" ^
	    (declare_variables decl) ^
	    paranoid_alignment_check() ^
	    (unparse_code code) ^
	    "}\n"

  and unparse_ast = function
      Asch a -> (unparse_annotated true a)
    | For (a, b, c, d) ->
	"for (" ^
	unparse_ast a ^ "; " ^ unparse_ast b ^ "; " ^ unparse_ast c
	^ ")" ^ unparse_ast d
    | If (a, d) ->
	"if (" ^
	unparse_ast a 
	^ ")" ^ unparse_ast d
    | Block (d, s) ->
	if (s == []) then ""
	else 
	  "{\n"                                      ^ 
          foldr_string_concat (map unparse_decl d)   ^ 
          foldr_string_concat (map unparse_ast s)    ^
          "}\n"      
    | Binop (op, a, b) -> (unparse_expr a) ^ op ^ (unparse_expr b)
    | Expr_assign (a, b) -> (unparse_expr a) ^ " = " ^ (unparse_expr b)
    | Stmt_assign (a, b) -> (unparse_expr a) ^ " = " ^ (unparse_expr b) ^ ";\n"
    | Comma (a, b) -> (unparse_ast a) ^ ", " ^ (unparse_ast b)


  and unparse_function = function
    Fcn (typ, name, args, body) ->
      let rec unparse_args = function
	  [Decl (a, b)] -> a ^ " " ^ b 
	| (Decl (a, b)) :: s -> a ^ " " ^ b  ^ ", "
	    ^  unparse_args s
	| [] -> ""
      in 
      (typ ^ " " ^ name ^ "(" ^ unparse_args args ^ ")\n" ^
       unparse_ast body)

  in function tree ->
    "/* Generated by: " ^ (cmdline ()) ^ "*/\n\n" ^
    (print_cost tree) ^
    (extract_constants tree) ^
    "/*\n" ^
    " * Generator Id's : \n" ^
    " * " ^ Exprdag.cvsid ^ "\n" ^
    " * " ^ Fft.cvsid ^ "\n" ^
    " * " ^ cvsid ^ "\n" ^
    " */\n\n" ^
    (unparse_function tree)
		

