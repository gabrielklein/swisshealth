# Lamal

This instruction is for linux platforms. It can probably be adapted easily to other platforms.

You have to ways to prepare data.
Either regenerate the data in the export folder, or simply use pregenerated data.
If you are new to the project, just use "exported data"

# Why do we need to pre-process data?

Sadly the data is not always in the same format.
Sometime the name is different, sometime they use UTF-8, sometime latin-1, the enums are different.

This script will generate a unique format.

Please notify my if you see any errors.

# You want to regenerate the data

If you have no reason to regenerate the data, just use "export.7z"

Download and prepare raw data

1) Go in the "datasource" folder.
2) Download data from https://opendata.swiss/fr/dataset/health-insurance-premiums and unzip it in different folders called 2011, 2012, ... 2024.
3) Fix some issues with names if necessary.
4) You have a file called "config.json", verify that all names are well defined and at the right position.

Process data
1) You need "pandas" and "numpy", on ubuntu/debian - sudo apt-get install python3-pandas python3-numpy
2) You may need other libraries, please send me a mail if I forgot any.
3) python3 process.py
4) Data should be available in the export folder

# Import data in your mariadb or mysql database

If you haven't generated the "export" folder. Un7zip the "export.7z" folder.
Copy all content of this folder to the /tmp folder.
Make all data available to mysql process using : chmod 777 /tmp/*.csv

You can import all data in a mysql/mariadb database using this script.
Connect to mysql and run the following commands: CreateAndImportData.sql