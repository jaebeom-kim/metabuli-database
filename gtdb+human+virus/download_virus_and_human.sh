#!/bin/bash

DBDIR=$1
if [ -z "$DBDIR" ]; then
    echo "Usage: $0 <DBDIR>"
    exit 1
fi


mkdir -p $DBDIR/other-genomes

aria2c -x 16 -s 16 -j 16 https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz $DBDIR/other-genomes
aria2c -x 16 -s 16 -j 16 https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna.gz $DBDIR/other-genomes

find $DBDIR/other-genomes -type f -name "*.fna.gz" > $DBDIR/other_downloaded_files.txt