# Gene-Annotation-And-Database-Creation-Pipeline

Build a local MySQL annotation database by integrating **Ensembl**, **UniProt**, and **NCBI Gene** for a given list of Ensembl *gene* stable IDs.

> This repository packages the coursework project as a clean, reproducible GitHub repo with docs, sample input, and the original script in `bin/`.

## What this does

- Validates a file of Ensembl **gene** IDs
- Fetches core metadata from **Ensembl** (REST)
- Fetches accessions, protein names, functions and sequences from **UniProt** (REST)
- Fetches gene summaries from **NCBI Gene** using **Entrez Direct** (`esearch` → `efetch` → `xtract`)
- Creates three MySQL tables and exports a **joined** view to `FINAL.tsv`

## Quickstart

```bash
# 1) Install prerequisites
#    See INSTALL.md

# 2) Make the script executable
chmod +x bin/Databases_Project.sh

# 3) Run it
./bin/Databases_Project.sh
# Point it to sample_inputs/genes_example.txt when prompted
```

Outputs:
- `Ensembl.txt`, `Uniprot.txt`, `NCBI.txt` (intermediate TSV files)
- MySQL tables: `ENSEMBL`, `UNIPROT`, `NCBI`
- `FINAL.tsv` – unified export of the joined tables

## Tables created

Below is a concise overview of the MySQL schema created by `bin/Databases_Project.sh`.

### ENSEMBL
| column          | type        | notes                 |
|-----------------|-------------|-----------------------|
| biotype         | VARCHAR(20) |                       |
| display_name    | VARCHAR(50) |                       |
| end             | INT         | genomic end position  |
| id              | VARCHAR(50) | **PRIMARY KEY**       |
| seq_region_name | VARCHAR(10) | chromosome/contig     |
| species         | VARCHAR(50) | e.g., *Mus musculus*  |
| start           | INT         | genomic start position|
| strand          | TINYINT     | -1 / 1                |

### UNIPROT
| column        | type          | notes           |
|---------------|---------------|-----------------|
| accession     | VARCHAR(20)   | **PRIMARY KEY** |
| gene_primary  | VARCHAR(100)  |                 |
| organism_name | VARCHAR(100)  |                 |
| cc_function   | TEXT          | functional note |
| Protein_Name  | TEXT          |                 |
| sequence      | TEXT          | AA sequence     |

### NCBI
| column           | type         | notes           |
|------------------|--------------|-----------------|
| symbol           | VARCHAR(50)  | **PRIMARY KEY** |
| Gene_description | TEXT         | gene summary    |


## Repo structure

```
DatabaseMaker2025/
├─ bin/
│  └─ Databases_Project.sh           # Original script
├─ docs/
│  ├─ Assignment_Report.pdf          # Final report (as submitted)
│  └─ Assignment_Spec.pdf            # Assignment instructions
├─ sample_inputs/
│  └─ genes_example.txt              # Ten example IDs
├─ INSTALL.md                        # How to install dependencies
├─ USAGE.md                          # How to run the script
├─ KNOWN_ISSUES.md                   # Caveats & quick fixes
├─ schema.sql                        # Generic schema example
├─ CONTRIBUTING.md
├─ CITATION.cff
├─ LICENSE
└─ .gitignore
```

## Requirements

- Linux/macOS with Bash, `wget`, `curl`
- **Entrez Direct** (`esearch`, `efetch`, `xtract`)
- MySQL client and access to a MySQL server

See **INSTALL.md** for one-liners.

## Notes & limitations

- Only Ensembl **gene** stable IDs are supported by the validator.
- UniProt/NCBI fields are hard-coded; adjust script & schema to change them.
- NCBI step requires Entrez Direct on your `PATH`.
- See **KNOWN_ISSUES.md** for any known issues.

## Citing

If you use this work, please cite via `CITATION.cff` (GitHub auto-detects this).

## License

MIT — see `LICENSE`.
