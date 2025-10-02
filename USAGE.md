# Usage

1) Make the script executable:

```bash
chmod +x bin/Databases_Project.sh
```

2) Prepare an input file containing Ensembl *gene* stable IDs (one per line). You can start with:

```
sample_inputs/genes_example.txt
```

3) Run the script and follow the prompts:

```bash
./bin/Databases_Project.sh
```

You will be asked to:
- confirm starting the script,
- provide the input file name (e.g. `sample_inputs/genes_example.txt`),
- enter MySQL username and password,
- choose a database name to create.

## Outputs

- `Ensembl.txt`, `Uniprot.txt`, `NCBI.txt` intermediate TSVs in the working directory
- A MySQL database with three tables: `ENSEMBL`, `UNIPROT`, `NCBI`
- A joined export: `FINAL.tsv`

## How it works (high level)

- **Validate Ensembl IDs** (genes only) and read them from your input file
- **Query Ensembl** REST API for core metadata
- **Query UniProt** REST API for accession, gene, protein, function and sequence
- **Query NCBI** Gene via E-utilities (esearch → efetch XML → xtract to TSV)
- **Create MySQL schema** and bulk-load TSVs
- **LEFT JOIN** the three tables and export a unified view to `FINAL.tsv`

See `README.md` for full details and limitations.
