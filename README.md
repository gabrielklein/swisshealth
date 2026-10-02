# 🇨🇭 Lamal – Swiss Health Insurance Data Analysis

This project downloads and standardizes Swiss health-insurance data, imports it into MariaDB, and prepares it for analytics. The Lamal pipeline currently includes premium data from 2011 through 2027.

---

## ⚙️ Stack

- 🐍 Python 3.10 + Pipenv
- 🐬 MariaDB 11.3
- 🐳 Docker & Docker Compose
- 📦 CSV-based datasets from [opendata.swiss](https://opendata.swiss)

---

## 🏗️ Project structure

Each directory under `datasets` contains the instructions and files for a complete data pipeline:

1. Downloading the needed files / databases for building a dataset
2. Cooking the dataset, mixing and transforming data
3. Loading the dataset into a database

## 🔁 Current pipelines

1. Lamal

## 🚀 Quickstart (Dockerized)

The easiest way to run everything is using Docker Compose. It handles dataset generation and database provisioning automatically.


### Build and start the Lamal pipeline

```bash
docker compose --profile Lamal up -d
```

This downloads and prepares the source data, writes standardized CSV files to `datasets/Lamal/build/export`, then starts MariaDB and imports the files.

---

## ⚗️ Environment Configuration

The Lamal download settings are in `datasets/Lamal/build/.dataset.env`. The latest premium year and its CH/EU download URLs are configurable there; they are currently set to 2027.

```.dataset.env
# Historical archive URLs
export DATASET_ARCHIVES="Archiv_Praemien_2011.zip|https://...;..."
# Current premium CSVs
export DATASET_LAST_YEAR="2027"
export DATASET_LAST_URL_CH="https://..."
export DATASET_LAST_URL_EU="https://..."
```

The root `.env` file contains the MariaDB credentials used by Docker Compose:

```.env
# DB Credentials
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=lamal
MYSQL_USER=lamal
MYSQL_PASSWORD=lamal
```

---

## 🔧 Manual Mode (without Docker)

To build the dataset without Docker:

### 1. Install dependencies

```bash
sudo apt-get install python3 python3-pip unzip pipenv
cd datasets/Lamal/build
pipenv install
```

### 2. Run the pipeline

```bash
pipenv run bash utils/generate_dataset.sh
```

To process source files already downloaded, run `python3 process.py` from `datasets/Lamal/build/utils`. Complete year folders containing both CH and EU CSVs are picked up automatically.

### 3. Launch MariaDB locally and import the data

- Start a local MariaDB/MySQL instance.
- Run the import script manually:
  ```bash
  cd datasets/Lamal/build
  mysql -u lamal -p lamal < CreateAndImportData.sql
  ```

---

## 🧠 Why preprocess the data?

Swiss federal health data changes format over time. Encodings, column names, and coded values can differ between years, so the pipeline normalizes them into one schema.
