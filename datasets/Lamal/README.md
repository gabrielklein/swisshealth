# Lamal

Theses instructions are for the Lamal Pipeline

# Why do we need to pre-process data?

Sadly the data is not always in the same format.
Sometime the name is different, sometime they use UTF-8, sometime latin-1, the enums are different.

This pipeline would build the dataset in an right format

Please notify my if you see any errors.

# Generate data

Please follow the instructions on the main README.md to generate data in a full-automated way.

# You want to regenerate the data (manual way)

Download and prepare raw data

1) Go in the "datasource" folder.
2) Download data from https://opendata.swiss/fr/dataset/health-insurance-premiums and unzip it in different folders called 2011, 2012, ... 2025.
3) Fix some issues with names if necessary.

Process data
1) You need "pandas" and "numpy", on ubuntu/debian - sudo apt-get install python3-pandas python3-numpy python3-ipython
2) You may need other libraries, please send me a mail if I forgot any.
3) python3 utils/process.py
4) Data should be available in the export folder

# Import data in your mariadb or mysql database (manual way)

If you haven't generated the "export" folder. Un7zip the "export.7z" folder.
Copy all content of this folder to the /tmp folder.
Make all data available to mysql process using : chmod 777 /tmp/*.csv

You can import all data in a mysql/mariadb database using this script.
Connect to mysql and run the following sql requests one after the other: CreateAndImportData.sql
