#!/bin/bash

function print_help_and_exit
{
cat >&2 << 'EOF'

'ftdmp-form-capri-answer' forms CAPRI answer from ordered list of files

Options:
    --input-brk               string  *  input .brk file path
    --output                  string  *  output file path
    --authors                 string  *  authors string
    --align-sel               string     selection of atoms copy to align
    --rename-chains           string     chain renaming rule to apply
    --help | -h                          flag to display help message and exit

Standard input:
    list of structure files
    
Examples:

	(echo file1.pdb ; echo file2.pdb) \
	| ftdmp-form-capri-answer \
	  --input-brk input/capri.brk --output output/answer.pdb \
	  --align-sel '[-chain A]' --rename-chains 'C=E,D=F'

EOF
exit 1
}

if [ -z "$1" ]
then
	print_help_and_exit
fi

if [ -z "$FTDMPDIR" ]
then
	export FTDMPDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
	export PATH="${FTDMPDIR}/core/voronota-js_release:${FTDMPDIR}:${PATH}"
fi

command -v voronota-js &> /dev/null || { echo >&2 "Error: 'voronota-js' executable not in binaries path"; exit 1; }

BRKFILE=""
OUTFILE=""
AUTHORS=""
ALIGN_SEL=""
RENAME_CHAINS=""
HELP_MODE="false"

while [[ $# > 0 ]]
do
	OPTION="$1"
	OPTARG="$2"
	shift
	case $OPTION in
	--input-brk)
		BRKFILE="$OPTARG"
		shift
		;;
	--output)
		OUTFILE="$OPTARG"
		shift
		;;
	--authors)
		AUTHORS="$OPTARG"
		shift
		;;
	--align-sel)
		ALIGN_SEL="$OPTARG"
		shift
		;;
	--rename-chains)
		RENAME_CHAINS="$OPTARG"
		shift
		;;
	-h|--help)
		HELP_MODE="true"
		;;
	*)
		echo >&2 "Error: invalid command line option '$OPTION'"
		exit 1
		;;
	esac
done

if [ "$HELP_MODE" == "true" ]
then
	print_help_and_exit
fi

if [ -z "$BRKFILE" ]
then
	echo >&2 "Error: input .brk file path not provided"
	exit 1
fi

if [ -z "$OUTFILE" ]
then
	echo >&2 "Error: output file path not provided"
	exit 1
fi

if [ -z "$AUTHORS" ]
then
	echo >&2 "Error: authors not provided"
	exit 1
fi

if [ ! -s "$BRKFILE" ]
then
	echo >&2 "Error: input .brk file '$BRKFILE' does not exist"
	exit 1
fi

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

cat > "${TMPLDIR}/input"

if [ ! -s "${TMPLDIR}/input" ]
then
	echo >&2 "Error: no input data in stdin"
	exit 1
fi

while read -r INFILE
do
	if [ ! -s "$INFILE" ]
	then
		echo >&2 "Error: input structure file '$INFILE' does not exist"
		exit 1
	fi
done < "${TMPLDIR}/input"

NUMBER_OF_MODELS="$(cat "${TMPLDIR}/input" | wc -l)"

{
cat << EOF
var params={}
params.align_sel='$ALIGN_SEL';
params.rename_chains='$RENAME_CHAINS';
params.outprefix='${TMPLDIR}/';
var input_files=[];
EOF

cat "${TMPLDIR}/input" | awk -v q="'" '{print "input_files.push(" q $1 q ");"}'

cat << 'EOF'
for(var i=0;i<input_files.length;i++)
{
	voronota_import("-file", input_files[i], "-title", "model"+i);
	voronota_assert_full_success("Failed to import model file '"+input_files[i]+"'");
}

voronota_pick_objects();

if(params.align_sel)
{
	voronota_tmalign_many("-target", "model0", "-target-sel", params.align_sel, "-model-sel", params.align_sel);
	voronota_assert_full_success("Failed to run tmalign using provided selections");
}

if(params.rename_chains)
{
	voronota_set_chain_name("-chain-name", params.rename_chains);
	voronota_assert_full_success("Failed to rename chains");
}

for(var i=0;i<input_files.length;i++)
{
	voronota_export_atoms("-on-objects", "model"+i, "-file", params.outprefix+"model"+(i+1), "-as-pdb", "-pdb-ter");
	voronota_assert_full_success("Failed to export atoms");
}

EOF
} | voronota-js --no-setup-defaults

if [ ! -s "${TMPLDIR}/model1" ] || [ ! -s "${TMPLDIR}/model${NUMBER_OF_MODELS}" ]
then
	echo >&2 "Error: failed to prepare model files"
	exit 1
fi

mkdir -p "$(dirname "$OUTFILE")"

{
cat "$BRKFILE" | egrep '^HEADER|^COMPND'

echo "AUTHOR    $AUTHORS"

cat "$BRKFILE" | egrep '^REMARK|^SEQRES'

seq 1 "$NUMBER_OF_MODELS" \
| while read MODELNUM
do
	echo "   $MODELNUM" | sed 's/.*\(....\)$/MODEL \1/'
	echo "PARENT     N/A"
	cat "${TMPLDIR}/model${MODELNUM}"
	echo "ENDMDL"
done

echo "END"
} \
> "$OUTFILE"

