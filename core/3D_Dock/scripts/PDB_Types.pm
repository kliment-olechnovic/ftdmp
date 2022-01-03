# PDB utilities and data about legal names etc 
# Copyright (C) 1997-2000 Gidon Moont
# 
# Biomolecular Modelling Laboratory
# Imperial Cancer Research Fund
# 44 Lincoln's Inn Fields
# London WC2A 3PX
# 
# +44 (0)20 7269 3348
# http://www.bmm.icnet.uk/
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

package PDB_Types ;

#############

select STDOUT ;
$| = 1 ;

#############
#
# List of legal possible residue / base names

@legal_res_names = (

'ALA', 'ARG', 'ASN', 'ASP', 'CYS',	# twenty standard amino acids
'GLN', 'GLU', 'GLY', 'HIS', 'ILE',
'LEU', 'LYS', 'MET', 'PHE', 'PRO',
'SER', 'THR', 'TRP', 'TYR', 'VAL', 

'  A', '  C', '  G', '  T', '  U'	# common nucleic acids

) ;

#############
#
# List of corresponding numerical codes for each residue

%numerical_codes = (

'ALA' => ' 1' , 'ARG' => ' 2' , 'ASN' => ' 3' , 'ASP' => ' 4' ,
'CYS' => ' 5' , 'GLN' => ' 6' , 'GLU' => ' 7' , 'GLY' => ' 8' ,
'HIS' => ' 9' , 'ILE' => '10' , 'LEU' => '11' , 'LYS' => '12' ,
'MET' => '13' , 'PHE' => '14' , 'PRO' => '15' , 'SER' => '16' ,
'THR' => '17' , 'TRP' => '18' , 'TYR' => '19' , 'VAL' => '20' ,

'ASX' => '21' , 'GLX' => '22' ,

'XXX' => ' 0' ,

'  A' => '41' , '  C' => '42' , '  G' => '43' , '  T' => '44' , '  U' => '45' ,

) ;

#############
#
# List of corresponding one letter codes for each residue

%one_letter_codes = (

'ALA' => 'A' , 'ARG' => 'R' , 'ASN' => 'N' , 'ASP' => 'D' ,
'CYS' => 'C' , 'GLN' => 'Q' , 'GLU' => 'E' , 'GLY' => 'G' ,
'HIS' => 'H' , 'ILE' => 'I' , 'LEU' => 'L' , 'LYS' => 'K' ,
'MET' => 'M' , 'PHE' => 'F' , 'PRO' => 'P' , 'SER' => 'S' ,
'THR' => 'T' , 'TRP' => 'W' , 'TYR' => 'Y' , 'VAL' => 'V' ,

'ASX' => 'B' , 'GLX' => 'Z' ,

'XXX' => 'X' ,

'  A' => 'a' , '  C' => 'c' , '  G' => 'g' , '  T' => 't' , '  U' => 'u' ,

) ;

#############
#
# List of number of (non-hydrogen) atoms expected per residue

%atoms_per_residue = (

'ALA' => ' 5' , 'ARG' => '11' , 'ASN' => ' 8' , 'ASP' => ' 8' ,
'CYS' => ' 6' , 'GLN' => ' 9' , 'GLU' => ' 9' , 'GLY' => ' 4' ,
'HIS' => '10' , 'ILE' => ' 8' , 'LEU' => ' 8' , 'LYS' => ' 9' ,
'MET' => ' 8' , 'PHE' => '11' , 'PRO' => ' 7' , 'SER' => ' 6' ,
'THR' => ' 7' , 'TRP' => '14' , 'TYR' => '12' , 'VAL' => ' 7' ,

'xxx' => ' 0' , # for first test in each file

'XXX' => '50' , # for those residues I have no information on

# these are patently dumby values for now...
'  A' => '99' , '  C' => '99' , '  G' => '99' , '  T' => '99' , '  U' => '99' ,

) ;

#############
#
# List of legal possible atom names

@legal_atom_names = ( 

' N  ', ' CA ', ' C  ', ' O  ',		# amino acid backbone
' CB ',					# amino acid carbons
' CD ', ' CD1', ' CD2',
' CE ', ' CE1', ' CE2', ' CE3',
' CG ', ' CG1', ' CG2',
' CH2',
' CZ ', ' CZ2', ' CZ3',

' OD ', ' OD1', ' OD2',			# amino acid oxygens
' OE1', ' OE2',
' OG ', ' OG1', ' OG2',
' OH ',

' ND1', ' ND2',				# amino acid nitrogens
' NE ', ' NE1', ' NE2',
' NH1', ' NH2',
' NZ ',
' SD ', ' SG ',				# amino acid sulphurs

' P  ', ' O1P', ' O2P',			# DNA backbone
' C1*', ' C2*', ' C3*', ' C4*', ' C5*',
' O2*', ' O3*', ' O4*', ' O5*',
' C1\'', ' C2\'', ' C3\'', ' C4\'', ' C5\'',	# other version - may be wrong - but its used
' O2\'', ' O3\'', ' O4\'', ' O5\'',
' N1 ', ' N2 ', ' N3 ', ' N4 ', ' N5 ', # base nitrogens
' N6 ', ' N7 ', ' N8 ', ' N9 ',
' C2 ', ' C4 ', ' C5 ',	' C5M',		# base carbons
' C6 ', ' C7 ', ' C8 ',
' O2 ', ' O4 ', ' O6 '			# base oxygens

) ;

#############
#
# List of corresponding numerical codes for each atom on a given residue
#
# taken from "Novel Knowledge-based Mean Force Potential at Atomic Level"
#   - Melo and Feytmans - JMB (1997) 256 , 207--222
#
# not used at the moment to assign, but to check legality of atom type
# for residue type

@atom_type_key = (

# dud to cope with arrays starting at zero
  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 , }  , # dud to cope with arrays starting at zero

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  6 , }  , # alanine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  8 ,
    ' CD ' => 37 ,
    ' NE ' => 36 ,
    ' CZ ' => 21 ,
    ' NH1' => 22 ,
    ' NH2' => 22 , }  , # arginine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 33 ,
    ' OD1' => 34 ,
    ' ND2' => 18 , }  , # asparagine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 27 ,
    ' OD1' => 28 ,
    ' OD2' => 28 , }  , # aspartic acid

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' => 29 ,
    ' SG ' => 19 , }  , # cystine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  8 ,
    ' CD ' => 33 ,
    ' OE1' => 34 ,
    ' NE2' => 18 , }  , # glutamine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  8 ,
    ' CD ' => 27 ,
    ' OE1' => 28 ,
    ' OE2' => 28 , }  , # glutamic acid

  { ' N  ' =>  3 ,
    ' CA ' =>  2 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 , }  , # glycine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 23 ,
    ' CD2' => 24 ,
    ' NE2' => 25 ,
    ' CE1' => 26 ,
    ' ND1' => 38 , }  , # histidine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  7 ,
    ' CG1' =>  8 ,
    ' CD1' =>  6 ,
    ' CG2' =>  6 , }  , # isoleucine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  7 ,
    ' CD1' =>  6 ,
    ' CD2' =>  6 , }  , # leucine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  8 ,
    ' CD ' =>  8 ,
    ' CE ' => 35 ,
    ' NZ ' => 20 , }  , # lysine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 29 ,
    ' SD ' =>  9 ,
    ' CE ' => 30 , }  , # methionine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 11 ,
    ' CD1' => 12 ,
    ' CD2' => 12 ,
    ' CE1' => 12 ,
    ' CE2' => 12 ,
    ' CZ ' => 12 , }  , # phenylalanine

  { ' N  ' => 10 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' =>  8 ,
    ' CD ' => 32 , }  , # proline

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' => 15 ,
    ' OG ' => 16 , }  , # serine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' => 17 ,
    ' OG1' => 16 ,
    ' CG2' =>  6 , }  , # threonine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 13 ,
    ' CD1' => 24 ,
    ' NE1' => 39 ,
    ' CD2' => 11 ,
    ' CE2' => 14 ,
    ' CE3' => 12 ,
    ' CZ2' => 12 ,
    ' CZ3' => 12 ,
    ' CH2' => 12 , }  , # tryptophan

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  8 ,
    ' CG ' => 11 ,
    ' CD1' => 12 ,
    ' CD2' => 12 ,
    ' CE1' => 12 ,
    ' CE2' => 12 ,
    ' CZ ' => 31 ,
    ' OH ' => 40 , }  , # tyrosine

  { ' N  ' =>  3 ,
    ' CA ' =>  1 ,
    ' C  ' =>  4 ,
    ' O  ' =>  5 ,
    ' CB ' =>  7 ,
    ' CG1' =>  6 ,
    ' CG2' =>  6 , }  , # valine

) ;
