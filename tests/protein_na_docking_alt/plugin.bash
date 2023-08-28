#!/bin/bash

INFILE="$1"
OUTFILE="$2"

{
echo numofzeroes
cat "$INFILE" | grep -o '0' | wc -l
} \
> "$OUTFILE"
