#!/bin/bash
DBDIR=$1
MIN_COMPLETENESS=$2
MAX_CONTAMINATION=$3

if [ -z "$DBDIR"  ] || [ -z "$MIN_COMPLETENESS" ] || [ -z "$MAX_CONTAMINATION" ]; then
    echo "Usage: $0 <DBDIR> <MIN_COMPLETENESS> <MAX_CONTAMINATION>"
    exit 1
fi

# Filter based on metadata
# Get the column number of "ncbi_assembly_level", "checkm2_completeness", and "checkm2_contamination"
assembly_level_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^ncbi_assembly_level$' | cut -d: -f1)
checkm_completeness_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^checkm2_completeness$' | cut -d: -f1)
checkm_contamination_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^checkm2_contamination$' | cut -d: -f1)
sp_rep_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^gtdb_representative$' | cut -d: -f1)
# assembly_accession_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^ncbi_genbank_assembly_accession$' | cut -d: -f1)

# If checkm2 completeness and contamination are not found, use checkm completeness and contamination
if [ -z "$checkm_completeness_col" ]; then
    checkm_completeness_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^checkm_completeness$' | cut -d: -f1)
fi

if [ -z "$checkm_contamination_col" ]; then
    checkm_contamination_col=$(head -1 $DBDIR/gtdb_metadata.tsv | tr '\t' '\n' | grep -n '^checkm_contamination$' | cut -d: -f1)
fi

awk -v assembly_level_col="$assembly_level_col" \
    -v checkm_completeness_col="$checkm_completeness_col" \
    -v checkm_contamination_col="$checkm_contamination_col" \
    -v min_comp="$MIN_COMPLETENESS" \
    -v max_cont="$MAX_CONTAMINATION" \
    -v sp_rep_col="$sp_rep_col" \
    -F '\t' \
    '{ if (($checkm_contamination_col < max_cont) && ($checkm_completeness_col > min_comp) && ($sp_rep_col == "t")) \
        {
            print substr($1, 4)
        } 
    }' \
    $DBDIR/gtdb_metadata.tsv > $DBDIR/filtered_assembly_accession.tsv

awk -F '.' '{print $1}' $DBDIR/filtered_assembly_accession.tsv > $DBDIR/filtered_assembly_accession_no_version.tsv

grep "GCF" $DBDIR/filtered_assembly_accession_no_version.tsv > $DBDIR/filtered_assembly_accession_no_version_refseq.tsv
grep "GCA" $DBDIR/filtered_assembly_accession_no_version.tsv > $DBDIR/filtered_assembly_accession_no_version_genbank.tsv

# Download Genbank assembly summary
aria2c -x 16 -j 16 -s 16 \
    https://ftp.ncbi.nlm.nih.gov/genomes/genbank/archaea/assembly_summary.txt \
    -d $DBDIR
mv $DBDIR/assembly_summary.txt $DBDIR/assembly_summary_archaea_gb.txt

aria2c -x 16 -j 16 -s 16 \
    https://ftp.ncbi.nlm.nih.gov/genomes/genbank/bacteria/assembly_summary.txt \
    -d $DBDIR
mv $DBDIR/assembly_summary.txt $DBDIR/assembly_summary_bacteria_gb.txt

# Download RefSeq assembly summary
aria2c -x 16 -j 16 -s 16 \
    https://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/assembly_summary.txt \
    -d $DBDIR
mv $DBDIR/assembly_summary.txt $DBDIR/assembly_summary_archaea_rs.txt

aria2c -x 16 -j 16 -s 16 \
    https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt \
    -d $DBDIR
mv $DBDIR/assembly_summary.txt $DBDIR/assembly_summary_bacteria_rs.txt


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
aria2c -x 16 -j 16 -s 16 -i $DBDIR/ftp_path_genomic_fna.txt -d $DBDIR/gtdb-genomes
find $DBDIR/gtdb-genomes -type f -name "*.fna.gz" > $DBDIR/gtdb_downloaded_files.txt