# Known Issues & Tips

### 1) Dependencies on `edirect`
The NCBI step requires `esearch`, `efetch`, `xtract` to be on your `PATH`. Install instructions are in `INSTALL.md`.

### 2) Ensembl gene IDs only
Validation currently accepts *gene* stable IDs (e.g., ENSMUSG...). Other feature types are not supported.

### 3) Ensembl JSON vs text
The script fetches Ensembl in a text-like representation for easier parsing. Richer fields available in JSON are not consumed.

### 4) Field choices are hard-coded
UniProt and NCBI fields are fixed in the script. Changing fields requires editing the script and database schema accordingly.
