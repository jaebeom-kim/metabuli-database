#!/bin/bash

METABULI=$1
DBDIR=$2
GTDB_TAX_DIR=$3
METABULI_SOURCE_DIR=$4
THREADS=$5

if [ -z "$METABULI" ] || [ -z "$DBDIR" ] || [ -z "$GTDB_TAX_DIR" ] || [ -z "$METABULI_SOURCE_DIR" ] || [ -z "$THREADS" ]; then
    echo "Usage: $0 <METABULI> <DBDIR> <GTDB_TAX_DIR> <METABULI_SOURCE_DIR> <THREADS>"
    exit 1
fi

grep -v "eny-yuan" $DBDIR/gtdb_downloaded_files.txt > $DBDIR/gtdb_downloaded_files_filtered.txt


$METABULI build \
    --gtdb 1 \
    $DBDIR/gtdb-db \
    $DBDIR/gtdb_downloaded_files_filtered.txt \
    $GTDB_TAX_DIR/taxid.map \
    --taxonomy-path $GTDB_TAX_DIR \
    --space-mask 11101110111 \
    --custom-metamer $METABULI_SOURCE_DIR/data/reduced_15_pattern.txt \
    --syncmer 1 \
    --smer-len 6 \
    --threads $THREADS \
    > $DBDIR/build.log 
