import pandas
import os
import shutil
from prime import Prime
from IPython.display import display
from datetime import datetime

# Cleanup folders
print("Delete and create export folder")
shutil.rmtree("export", ignore_errors=True)
os.mkdir("export")

# Load configuration and data
print("Load config and data")
config = Prime.loadConfig()
assurances = pandas.read_csv("../datasource/assurances.csv", sep="\t", encoding="utf8")
region = pandas.read_csv("../datasource/region2024.csv", sep=",", encoding="utf8")
communes = pandas.read_csv("../datasource/PLZO_CSV_WGS84.csv", sep=";", encoding="utf8")
communeseu = pandas.read_csv("../datasource/communeseu.csv", sep=";", encoding="utf8")

# Load "primes"
fl = []
for filePrime in config["primes"]:
    prime = Prime(filePrime)
    fl.append(prime.dfCH)
    fl.append(prime.dfEU)

# Generate data and save files
print("Generating data")
merge = pandas.concat(fl, axis=0)
print("* Lamal.csv")
merge.to_csv("../export/lamal.csv", encoding="utf-8")
print("* Assurances.csv")
assurances.to_csv("../export/assurances.csv", encoding="utf-8")
print("* Region.csv")
region.to_csv("../export/region.csv", encoding="utf-8")
print("* Communes.csv")
communes.to_csv("../export/communes.csv", encoding="utf-8")
print("* CommunesEU.csv")
communeseu.to_csv("../export/communeseu.csv", encoding="utf-8")

dts = datetime.now().strftime("%Y-%m-%d %Hh%M")
with open("../export/Generated " + dts + ".txt", mode="w") as f:
    f.write("Generated the "+dts)

# Finished
print("Success, data is now in the export folder")
