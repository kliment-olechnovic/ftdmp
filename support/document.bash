#!/bin/bash

cd $(dirname "$0")/..

TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

cat README.md > $TMPLDIR/documentation.markdown

cat > $TMPLDIR/include_in_header.html << 'EOF'
<style type="text/css">
a { color: #0000CC; }
td { padding-right: 1em; }
pre { background-color: #DDDDDD; padding: 1em; }
div#TOC > ul > li > ul > li ul { display: none; }
</style>
EOF

pandoc $TMPLDIR/documentation.markdown -f markdown -t html --metadata title="FTDMP version 1.0" -M document-css=false --wrap=none --toc -H $TMPLDIR/include_in_header.html -s -o ./index.html

