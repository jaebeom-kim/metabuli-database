# gtdb+human+virus

## 1. Download GTDB HQ genomes

```bash
./download_gtdb_metadata.sh <DBDIR>
./download_gtdb_hq_genomes.sh <DBDIR> 90 5
```
Genomes are stored in `<DBDIR>/gtdb-genomes` and a file of path to the genomes is stored in `<DBDIR>/gtdb_downloaded_files.txt`.


## 2. Download GTDB taxonomy


[https://github.com/shenwei356/gtdb-taxdump/releases](https://github.com/shenwei356/gtdb-taxdump/releases)

<GTDB_TAX_DIR> is the directory of unzipped GTDB taxdump, which contains `nodes.dmp` and `names.dmp`.


## 3. Build Metabuli database

```bash
./metabuli-build.sh <METABULI_PATH> <DBDIR> <GTDB_TAX_DIR>

```





## 2. Download human virus genomes

```bash
./download_virus_and_human.sh <DBDIR>
```
Genomes are stored in `<DBDIR>/other-genomes` and a file of path to the genomes is stored in `<DBDIR>/other_downloaded_files.txt`.

## 3. Combine GTDB HQ and human virus genomes

```bash
cat $DBDIR/downloaded_files.txt $DBDIR/other_downloaded_files.txt > $DBDIR/all_genome_files.txt
```



## 5. Donwload NCBI taxonomy

[https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz](https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz)

[https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz](https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz)

## 6. 

