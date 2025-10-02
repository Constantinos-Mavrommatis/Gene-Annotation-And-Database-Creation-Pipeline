# Installation & Environment

This project runs on Linux/macOS with Bash and a reachable MySQL server.

## Prerequisites

- Bash (>= 4.0)
- `wget`, `curl`
- **NCBI Entrez Direct (edirect)** tools: `esearch`, `efetch`, `xtract`
- MySQL client (>= 8.0)
- Network access to your MySQL server

### Ubuntu/Debian quick install

```bash
sudo apt-get update
sudo apt-get install -y wget curl mysql-client
# Install Entrez Direct
sh -c "$(wget -qO- https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
# Add to PATH for current shell
export PATH=$PATH:$HOME/edirect
```

## Verify tools

```bash
bash --version
wget --version
curl --version
esearch -version
mysql --version
```
