# Lamal pipeline

The Lamal pipeline downloads, normalizes, and imports Swiss mandatory health-insurance premium data. Premiums from 2011 through 2027 are supported.

## Generate the dataset

From the repository root, follow the Docker or manual setup in the [main README](../../README.md). The pipeline downloads historical archives and the latest CH/EU premium files, normalizes them, and writes output CSVs to `build/export`.

## Process files you already downloaded

Place each year's CH and EU premium files in `build/datasource/<year>/` as `Praemien_CH.csv` and `Praemien_EU.csv`. Then run:

```bash
cd datasets/Lamal/build/utils
python3 process.py
```

Complete year folders are discovered automatically, including years missing from the generated `config.json`. The standardized output is written to `datasets/Lamal/build/export`.

## Source data

- Premium CSVs and historical archives: [opendata.swiss health-insurance premiums](https://opendata.swiss/en/dataset/health-insurance-premiums)
- Swiss gazetteer: [swisstopo official gazetteer](https://www.swisstopo.admin.ch/de/amtliches-ortschaftenverzeichnis)
- Insurer registry: [BAG list of authorized health insurers](https://www.bag.admin.ch/de/verzeichnisse-der-zugelassenen-kranken-und-rueckversicherer)
- Premium-region assignments: [BAG premium regions](https://www.bag.admin.ch/de/krankenversicherung-praemienregionen)

The supporting files in `build/datasource` use the formats expected by the processing and import scripts. The premium-region lookup is versioned by year (currently `region2027.csv`).

## Import into MariaDB or MySQL

After generating the CSVs, start MariaDB/MySQL and run the import script from `datasets/Lamal/build`:

```bash
mysql -u lamal -p lamal < CreateAndImportData.sql
```
