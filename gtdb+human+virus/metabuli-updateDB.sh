#!/bin/bash

METABULI=$1
DBDIR=$2
NCBI_TAX_DIR=$3
ACC2TAXID_FILE=$4
THREADS=$5

GTDB_DB_DIR=$DBDIR/gtdb-db
OUTPUT_DIR=$DBDIR/gtdb+human+virus
ADD_GENOME_LIST=$DBDIR/other_downloaded_files.txt

if [ -z "$METABULI" ] || [ -z "$DBDIR" ] || [ -z "$NCBI_TAX_DIR" ] || [ -z "$ACC2TAXID_FILE" ] || [ -z "$THREADS" ]; then
    echo "Usage: $0 <METABULI> <DBDIR> <NCBI_TAX_DIR> <ACC2TAXID_FILE> <THREADS>"
    exit 1
fi

# Check if GTDB database exists
if [ ! -d "$GTDB_DB_DIR" ]; then
    echo "GTDB database not found in $GTDB_DB_DIR. Please run the building script first."
    exit 1
fi

# Check if ADD_GENOME_LIST exists
if [ ! -f "$ADD_GENOME_LIST" ]; then
    echo "Additional genome list not found in $ADD_GENOME_LIST. Please run the downloading script first."
    exit 1
fi


$METABULI createnewtaxalist \
    $GTDB_DB_DIR \
    $ADD_GENOME_LIST \
    $NCBI_TAX_DIR \
    $ACC2TAXID_FILE \
    $OUTPUT_DIR \

mkdir -p $OUTPUT_DIR

# Get Homo sapiens tax ID from $OUTPUT_DIR/newtaxa.tsv
HOMO_SAPIENS_TAX_ID=$(grep "Homo sapiens" $OUTPUT_DIR/newtaxa.tsv | cut -f1)

$METABULI updateDB \
    $OUTPUT_DIR \
    $ADD_GENOME_LIST \
    $OUTPUT_DIR/newtaxa.accession2taxid \
    $GTDB_DB_DIR \
    --new-taxa $OUTPUT_DIR/newtaxa.tsv \
    --threads $THREADS \
    --no-mask-taxa $HOMO_SAPIENS_TAX_ID \
    > $OUTPUT_DIR/updateDB.log
