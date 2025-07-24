# 🇨🇭 Lamal|Tarmed – Swiss Health Insurance Data Analysis

This project automates the **download**, **standardization**, **database import**, and **data representation** of Switzerland Health insurances related-data from open sources like [opendata.swiss](https://opendata.swiss). It processes all available data o the current year and prepares it for use in analytics or dashboards.

---

## ⚙️ Stack

- 🐍 Python 3.10 + Pipenv
- 🐬 MariaDB 11.3
- 🐳 Docker & Docker Compose
- 📦 CSV-based datasets from [opendata.swiss](https://opendata.swiss)
- 🐍📊 Datasette library for exploring and publishing data

---

## 🏗️ Project structure

The idea is to have full and useful pipelines inside the "datasets" directory. Each directory contains all the needed instructions for

1. Downloading the needed files / databases for building a dataset
2. Cooking the dataset, mixing and transforming data
3. Loading the dataset into a database
4. Representing the data using Datasette as an analysis tool

## 🔁 Current pipelines

1. Lamal
2. Tarmed (in progress)

## 🚀 Quickstart (Dockerized)

The easiest way to run everything is using Docker Compose. It handles dataset generation and database provisioning automatically.


### 1. Build and start the system:

#### Launch full stack (Dataset building, )
```bash
docker compose --profile PIPELINE_NAME up -d
```

f.e: `docker compose --profile Lamal up -d`

What this does:
- Downloads all raw data files
- Unzips and cleans them
- Standardizes everything into `.csv` format. You can find the results (the raw CSV Files) in build/export of the pipeline directory
- Starts a MariaDB container
- Imports the data using

---

## ⚗️ Environment Configuration

All important variables are declared in `.dataset.env`. of your pipeline directory. Example:

```.dataset.env
# Dataset archive URLs
export DATASET_ARCHIVES="Archiv_Praemien_2011.zip|https://...;Archiv_Praemien_2012.zip|https://...;..."
export DATASET_LAST_YEAR="2025"
export DATASET_LAST_URL_CH="https://..."
export DATASET_LAST_URL_EU="https://..."
```

On the .env file of the main directory, you can also find some environment variables for configuring docker compose vars. :

```.env
# DB Credentials
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=lamal
MYSQL_USER=lamal
MYSQL_PASSWORD=lamal
```

---

## 🔧 Manual Mode (without Docker)

If you want to build the dataset without Docker, follow this instructions:

### 1. Install dependencies

```bash
sudo apt-get install python3 python3-pip unzip
# Go to your build dataset directory (cd datasets/Lamal/build)
pip install pipenv
pipenv install
```

### 2. Run the pipeline

```bash
pipenv run bash utils/generate_dataset.sh
```

### 3. Launch MariaDB locally and import the data

- Start a local MariaDB/MySQL instance.
- Modify the paths inside CreateAndImportData.sql for pointing to the export directory
  ```
- Run the import script manually:
  ```bash
  mysql -u lamal -p lamal < CreateAndImportData.sql
  ```

---

## 🧠 Why preprocess the data?

Swiss federal health data is inconsistent:
- Different encodings (UTF-8, latin-1)
- Column names change over time
- Values and enums are not standardized

This pipeline ensures all years conform to a unified schema for further processing.
