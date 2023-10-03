import pandas
import numpy as np
import json
from IPython.display import display


# Load and process primes per day
class Prime:
    __filePrime = {}
    dfEU = {}
    dfCH = {}

    # Load configuration file
    def loadConfig():
        f = open("datasource/config.json")
        config = json.load(f)
        f.close()
        return config

    def __dropCol(df, name):
        if df.get(name) is None:
            pass
        else:
            df.drop(name, inplace=True, axis=1)

    def __renCol(df, oldName, newName):
        if df.get(newName) is None:
            if df.get(oldName) is None:
                pass
            else:
                df.rename(columns={oldName: newName}, inplace=True)

    def __checkCol(df, name):
        if df.get(name) is None:
            display(df)
            raise Exception("Field " + name + " is missing")

    def displayDistinct(df, name, isCH):
        print("Values of (ch=", isCH, ") ", name)
        if df.get(name) is None:
            display(df)
            print("Field ", name, " is missing")
            # raise Exception("Field " + name + " is missing")
        else:
            print(df[name].unique())

    def __cleanFranchise(df):
        df.replace(
            {
                "Franchise": {
                    "KIN": "0",
                    "JUG": "300",
                    "ERW": "300",
                    "FRA-0": "0",
                    "FRA-100": "100",
                    "FRA-200": "200",
                    "FRA-300": "300",
                    "FRA-400": "400",
                    "FRA-500": "500",
                    "FRA-600": "600",
                    "FRA-1000": "1000",
                    "FRA-1500": "1500",
                    "FRA-2000": "2000",
                    "FRA-2500": "2500",
                }
            },
            inplace=True,
        )

    def __cleanUnfalleinschluss(df):
        df.replace(
            {
                "Unfalleinschluss": {
                    "05": "1",
                    "06": "0",
                    "MIT-UNF": "1",
                    "OHN-UNF": "0",
                }
            },
            inplace=True,
        )

    def __cleanAltersklasse(df):
        df.replace(
            {
                "Altersklasse": {
                    "0": "KIN",
                    "19": "JUG",
                    "26": "ERW",
                    "AKL-KIN": "KIN",
                    "AKL-JUG": "JUG",
                    "AKL-ERW": "ERW",
                }
            },
            inplace=True,
        )

    def __cleanRegion(df):
        df.replace(
            {
                "Region": {
                    "PR-REG CH0": "0",
                    "PR-REG CH1": "1",
                    "PR-REG CH2": "2",
                    "PR-REG CH3": "3",
                    "PR-REG EU0": "0",
                    "PR-REG EU1": "1",
                    "PR-REG EU2": "2",
                    "PR-REG EU3": "3",
                }
            },
            inplace=True,
        )
        df["Region"].fillna(0)

    def __cleanKanton(df):
        # Replace
        #  ['A' 'B' 'BG' 'CY' 'CZ' 'D' 'DK' 'E' 'EST' 'F' 'FIN' 'GB' 'GR' 'H' 'I'
        # 'IRL' 'IS' 'L' 'LT' 'LV' 'M' 'N' 'NL' 'P' 'PL' 'RO' 'S' 'SK' 'SLO']
        # With
        # ['EU AT' 'EU BE' 'EU BG' 'EU CY' 'EU CZ' 'EU DE' 'EU DK' 'EU EE' 'EU ES'
        # 'EU FI' 'EU FR' 'EU GB' 'EU GR' 'EU HU' 'EU IE' 'EU IS' 'EU IT' 'EU LT'
        # 'EU LU' 'EU LV' 'EU MT' 'EU NL' 'EU NO' 'EU PL' 'EU PT' 'EU RO' 'EU SE'
        # 'EU SI' 'EU SK']
        df.replace(
            {
                "Kanton": {
                    "A": "EU AT",  # Österreich Autriche
                    "B": "EU BE",  # Belgien Belgique
                    "BG": "EU BG",  # Bulgarien Bulgarie
                    "CY": "EU CY",  # Zypern Chypre
                    "CZ": "EU CZ",  # Tschechische Republik République tchèque
                    "D": "EU DE",  # Deutschland Allemagne
                    "DK": "EU DK",  # Dänemark Danemark
                    "E": "EU ES",  # Spanien Espagne
                    "EST": "EU EE",  # Estland Estonie
                    "F": "EU FR",  # Frankreich France
                    "FIN": "EU FI",  # Finnland Finlande
                    "GB": "EU GB",  # Grossbritannien Grande-Bretagne
                    "GR": "EU GR",  # Griechenland Grèce
                    "H": "EU HU",  # Ungarn Hongrie
                    "I": "EU IT",  # Italien Italie
                    "IRL": "EU IE",  # Irland Irlande
                    "IS": "EU IS",  # Island Islande
                    "L": "EU LU",  # Luxemburg Luxembourg
                    "LT": "EU LT",  # Litauen Lituanie
                    "LV": "EU LV",  # Lettland Lettonie
                    "M": "EU MT",  # Malta Malte
                    "N": "EU NO",  # Norwegen Norvège
                    "NL": "EU NL",  # Niederlande Pays-Bas
                    "P": "EU PT",  # Portugal Portugal
                    "PL": "EU PL",  # Polen Pologne
                    "RO": "EU RO",  # Rumänien Roumanie
                    "S": "EU SE",  # Schweden Suède
                    "SK": "EU SK",  # Slowakische Republik République slovaque
                    "SLO": "EU SI",  # Slowenien Slovénie
                    # Kroatien Croatie HR
                }
            },
            inplace=True,
        )

    def __cleanData(self, year, df, isCH):
        # Remove latest line if it contains "CH"
        if df.get("C_ID") is not None:
            if df.get("C_ID")[len(df) - 1] == "CH":
                df.drop(df[df["C_ID"] == "CH"].index, inplace=True)

        # Drop these fields (not usefull)
        Prime.__dropCol(df, "JAHR")
        Prime.__dropCol(df, "EJAHR")
        Prime.__dropCol(df, "Geschäftsjahr")
        Prime.__dropCol(df, "Erhebungsjahr")
        Prime.__dropCol(df, "isBASE_V")
        Prime.__dropCol(df, "IstTaetig")
        Prime.__dropCol(df, "V_SORT_NR")
        Prime.__dropCol(df, "Sort")
        Prime.__dropCol(df, "Franchisestufe")
        Prime.__dropCol(df, "V2_TYP")
        Prime.__dropCol(df, "isBASE_V2")
        Prime.__dropCol(df, "F_STUFE")

        df.insert(1, "Year", year)

        # Assurance
        Prime.__renCol(df, "G_ID", "Versicherer")
        Prime.__checkCol(df, "Versicherer")
        # Canton VD, AG, or EU AT, A
        Prime.__renCol(df, "Land", "Kanton")
        Prime.__renCol(df, "C_ID", "Kanton")
        Prime.__checkCol(df, "Kanton")
        # Before 2014, EU was "A", "B", ...
        if not isCH and df["Kanton"][0] == "A":
            Prime.__cleanKanton(df)
        # CH or EU
        Prime.__renCol(df, "C_GRP", "Hoheitsgebiet")
        if (df.get("Hoheitsgebiet")) is None:
            if isCH:
                df.insert(2, "Hoheitsgebiet", "CH")
            else:
                df.insert(2, "Hoheitsgebiet", "EU")
        Prime.__renCol(df, "C_GRP", "Hoheitsgebiet")
        Prime.__checkCol(df, "Hoheitsgebiet")
        # 0,1,2,3
        Prime.__renCol(df, "R_ID", "Region")
        Prime.__checkCol(df, "Region")
        Prime.__cleanRegion(df)
        # Altersklasse
        Prime.__renCol(df, "M_ID", "Altersklasse")
        Prime.__checkCol(df, "Altersklasse")
        Prime.__cleanAltersklasse(df)
        # Unfalleinschluss
        Prime.__renCol(df, "VAR_ID", "Unfalleinschluss")
        Prime.__checkCol(df, "Unfalleinschluss")
        Prime.__cleanUnfalleinschluss(df)
        # Franchise
        if isCH:
            Prime.__renCol(df, "F", "Franchise")
            Prime.__checkCol(df, "Franchise")
            Prime.__cleanFranchise(df)
        else:
            # Les primes a l'étranger sont toujours à 300.-
            # Meme pour les enfants
            Prime.__dropCol(df, "Franchise")
            df.insert(7, "Franchise", "300")
        # Prime
        Prime.__renCol(df, "P", "Prime")
        Prime.__renCol(df, "Prämie", "Prime")
        Prime.__checkCol(df, "Prime")
        # isBaseP"1": ist Grundprämie (OKP mit Unfall)
        Prime.__renCol(df, "isBASE_P", "isBaseP")
        if (df.get("isBaseP")) is None:
            Prime.__renCol(df, "isBASE_V2", "isBaseP")
        if (df.get("isBaseP")) is None:
            if not isCH:
                df.insert(7, "isBaseP", 1)
        Prime.__checkCol(df, "isBaseP")

        # isBaseF "1": ist Grundfranchise ( 300 bzw. 0 Franken)
        Prime.__renCol(df, "isBASE_F", "isBaseF")
        if (df.get("isBaseF")) is None:
            if not isCH:
                df.insert(7, "isBaseF", 1)
        Prime.__checkCol(df, "isBaseF")

        # Altersuntergruppe
        if (df.get("Altersuntergruppe")) is None:
            Prime.__renCol(df, "V2_ID", "Altersuntergruppe")
        df["Altersuntergruppe"] = df["Altersuntergruppe"].replace(
            "", np.nan, regex=True
        )
        df["Altersuntergruppe"].fillna(df["Altersklasse"], inplace=True)
        df.replace(
            {
                "Altersuntergruppe": {
                    "JUG": "J1",
                    "ERW": "E1",
                }
            },
            inplace=True,
        )
        Prime.__checkCol(df, "Altersuntergruppe")

        # Tarifbezeichnung
        # Callmed Telefonmodell     Grundversicherung Callmed Telefonmodell Hausarztversicherung
        Prime.__renCol(df, "V_KBEZ", "Tarifbezeichnung")
        if (df.get("Tarifbezeichnung")) is None:
            if not isCH:
                df.insert(7, "Tarifbezeichnung", "")
        Prime.__checkCol(df, "Tarifbezeichnung")

        # Tariftyp
        Prime.__renCol(df, "V_TYP", "Tariftyp")
        Prime.__renCol(df, "Tarif-Typ", "Tariftyp")
        if (df.get("Tariftyp")) is None:
            Prime.__renCol(df, "V_ID", "Tariftyp")
        if (df.get("Tariftyp")) is None:
            if not isCH:
                df.insert(7, "Tariftyp", "BASE")
        df.replace(
            {
                "Tariftyp": {
                    "DIV": "TAR-DIV",
                    "Base": "TAR-BASE",
                    "BASE": "TAR-BASE",
                    "HAM_RDS": "TAR-HAM",
                    "HMO": "TAR-HMO",
                }
            },
            inplace=True,
        )
        Prime.__checkCol(df, "Tariftyp")

        # display(df)
        if (df.get("Tarif")) is None:
            if not (df.get("Tarifbezeichnung")) is None:
                df.insert(7, "Tarif", df.get("Tarifbezeichnung"))

        # Sometime we use V_ID, sometime not...
        Prime.__dropCol(df, "V_ID")

        # Assurance sous forme d'un int 8, 32, 57, ...
        # Prime.__dropCol(df, "Versicherer")
        # Canton AG, AI, SO
        # Prime.__dropCol(df, "Kanton")
        # Pays CH EU
        # Prime.__dropCol(df, "Hoheitsgebiet")
        # Region de prime, 0, 1, 2, 3
        # Prime.__dropCol(df, "Region")
        # Classe d'age KIN, JUG, ERW
        # Prime.__dropCol(df, "Altersklasse")
        # Inclus accident 0, 1
        # Prime.__dropCol(df, "Unfalleinschluss")
        # Franchise 0 100 200 300 400 500 2500
        # Prime.__dropCol(df, "Franchise")
        # Prime 34.6 165.3
        # Prime.__dropCol(df, "Prime")
        # 0 1   "1": ist Grundprämie (OKP mit Unfall)
        # Prime.__dropCol(df, "isBaseP")
        # 0 1   "1": ist Grundfranchise ( 300 bzw. 0 Franken)
        # Prime.__dropCol(df, "isBaseF")
        # Groupe d'age J1 E1 K1 K2
        # Prime.__dropCol(df, "Altersuntergruppe")
        # Description du tarif Gesundheitspraxisversicherung T3
        # Prime.__dropCol(df, "Tarifbezeichnung")
        # ['TAR-HAM' 'TAR-DIV' 'TAR-BASE' 'TAR-HMO']
        # Prime.__dropCol(df, "Tariftyp")
        # 'PrimaPharma' 'HAS' 'HAS_N' 'PHARMAMED' 'HAM' 'Telmed' 'Casa' 'sanmed24'
        # Prime.__dropCol(df, "Tarif")

        # display(df)
        df = df.reindex(
            columns=[
                "Year",
                "Versicherer",
                "Kanton",
                "Hoheitsgebiet",
                "Region",
                "Altersklasse",
                "Unfalleinschluss",
                "Franchise",
                "Prime",
                "isBaseP",
                "isBaseF",
                "Altersuntergruppe",
                "Tarifbezeichnung",
                "Tariftyp",
                "Tarif",
            ]
        )

        # Prime.displayDistinct(df, "Tarif", isCH)

        return df

    def __init__(self, filePrime):
        self.__filePrime = filePrime

        print("Loading file: ", filePrime["year"])
        dty = {
            "R_ID": "str",
            "M_ID": "str",
            "VAR_ID": "str",
            "isBASE_P": "str",
            "isBASE_F": "str",
        }
        dfCH = pandas.read_csv(
            "datasource/" + filePrime["path_ch"],
            sep=filePrime["sep"],
            encoding=filePrime["encoding_ch"],
            dtype=dty,
            keep_default_na=False,
        )
        dfEU = pandas.read_csv(
            "datasource/" + filePrime["path_eu"],
            sep=filePrime["sep"],
            encoding=filePrime["encoding_eu"],
            dtype=dty,
            keep_default_na=False,
        )

        self.dfCH = self.__cleanData(filePrime["year"], dfCH, True)
        self.dfEU = self.__cleanData(filePrime["year"], dfEU, False)
