#!/bin/bash
DBDIR=$1
MIN_COMPLETENESS=$2
MAX_CONTAMINATION=$3

if [ -z "$DBDIR"  ] || [ -z "$MIN_COMPLETENESS" ] || [ -z "$MAX_CONTAMINATION" ]; then
    echo "Usage: $0 <DBDIR> <MIN_COMPLETENESS> <MAX_CONTAMINATION>"
    exit 1
fi

# Get ftp path for each filtered assembly accession

grep -f $DBDIR/filtered_assembly_accession_no_version_genbank.tsv $DBDIR/assembly_summary_archaea_gb.txt \
    | awk -F '\t' '{ n = split($20, parts, "/"); if (n > 1) print $20 parts[n-1]"_genomic.fna.gz" }'  > $DBDIR/ftp_path_genomic_fna.txt

grep -f $DBDIR/filtered_assembly_accession_no_version_genbank.tsv $DBDIR/assembly_summary_bacteria_gb.txt \
    | awk -F '\t' '{ n = split($20, parts, "/"); if (n > 1) print $20 parts[n-1]"_genomic.fna.gz" }' >> $DBDIR/ftp_path_genomic_fna.txt

grep -f $DBDIR/filtered_assembly_accession_no_version_refseq.tsv $DBDIR/assembly_summary_archaea_rs.txt \
    | awk -F '\t' '{ n = split($20, parts, "/"); if (n > 1) print $20 parts[n-1]"_genomic.fna.gz" }' >> $DBDIR/ftp_path_genomic_fna.txt

grep -f $DBDIR/filtered_assembly_accession_no_version_refseq.tsv $DBDIR/assembly_summary_bacteria_rs.txt \
    | awk -F '\t' '{ n = split($20, parts, "/"); if (n > 1) print $20 parts[n-1]"_genomic.fna.gz" }' >> $DBDIR/ftp_path_genomic_fna.txt

# Download genomes
mkdir -p $DBDIR/gtdb-genomes
aria2c -x 4 -j 4 -s 4 -i $DBDIR/ftp_path_genomic_fna.txt -d $DBDIR/gtdb-genomes
find $DBDIR/gtdb-genomes -type f -name "*.fna.gz" > $DBDIR/gtdb_downloaded_files.txt
