# 🇨🇭 Lamal – Swiss Health Insurance Premiums Pipeline

This project automates the **download**, **standardization**, and **database import** of LAMal health insurance premiums from Switzerland. It processes all available data from 2011 to 2025 and prepares it for use in analytics or dashboards.

---

## ⚙️ Stack

- 🐍 Python 3.10 + Pipenv
- 🐬 MariaDB 11.3
- 🐳 Docker & Docker Compose
- 📦 CSV-based datasets from [opendata.swiss](https://opendata.swiss)

---

## 🚀 Quickstart (Dockerized)

The easiest way to run everything is using Docker Compose. It handles dataset generation and database provisioning automatically.

### 1. Build and start the system:

```bash
docker-compose build
docker-compose up -d
```

What this does:
- Downloads all raw data files
- Unzips and cleans them
- Standardizes everything into `.csv` format
- Starts a MariaDB container
- Imports the data using `CreateAndImportData.sql`

---

## ⚗️ Environment Configuration

All important variables are declared in `.env`. Example:

```env
# Dataset archive URLs
export DATASET_ARCHIVES="Archiv_Praemien_2011.zip|https://...;Archiv_Praemien_2012.zip|https://...;..."
export DATASET_LAST_YEAR="2025"
export DATASET_LAST_URL_CH="https://..."
export DATASET_LAST_URL_EU="https://..."

# DB Credentials
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=lamal
MYSQL_USER=lamal
MYSQL_PASSWORD=lamal
```

---

## 🔧 Manual Mode (without Docker)

If you want to run it locally instead of via Docker:

### 1. Install dependencies

```bash
sudo apt-get install python3 python3-pip unzip
pip install pipenv
pipenv install
```

### 2. Run the pipeline

```bash
pipenv run bash generate_dataset.sh
pipenv run python process.py
```

### 3. Launch MariaDB locally and import the data

- Start a local MariaDB/MySQL instance.
- Copy `export/*.csv` to `/tmp` and make sure they are world-readable:
  ```bash
  chmod 777 /tmp/*.csv
  ```
- Run the import script manually:
  ```bash
  mysql -u lamal -p lamal < CreateAndImportData.sql
  ```

---

## 🧠 Why preprocess the data?

Swiss federal health premium data is inconsistent:
- Different encodings (UTF-8, latin-1)
- Column names change over time
- Values and enums are not standardized

This pipeline ensures all years conform to a unified schema for further processing.
