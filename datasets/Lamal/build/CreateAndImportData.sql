USE lamal;

-- =========================
-- Delete tables
-- =========================
DROP TABLE IF EXISTS assurance, communes, region, lamal, lamallight, lamallightrank;
DROP TABLE IF EXISTS assurance_raw, communes_raw, region_raw, lamal_raw;

-- =========================
-- Insurance tables
-- =========================
CREATE TABLE assurance(
    id INTEGER NOT NULL,
    assuranceId INTEGER NOT NULL,
    useless VARCHAR(1),
    name VARCHAR(255) NOT NULL,
    commune VARCHAR(255) NOT NULL
);

CREATE TABLE communes(
    id INTEGER NOT NULL,
    localite VARCHAR(28) NOT NULL,
    npa INTEGER NOT NULL,
    npaplus INTEGER NOT NULL,
    commune VARCHAR(31) NOT NULL,
    ofsId INTEGER NOT NULL,
    canton VARCHAR(5),
    `long` FLOAT NOT NULL,
    lat FLOAT NOT NULL,
    langue VARCHAR(16) NOT NULL
);

CREATE TABLE region(
    id INTEGER NOT NULL,
    canton VARCHAR(2) NOT NULL,
    ofsId INTEGER NOT NULL,
    communaute VARCHAR(27) NOT NULL,
    region INTEGER NOT NULL
);

CREATE TABLE lamal(
    id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    assuranceId INTEGER NOT NULL,
    canton VARCHAR(5) NOT NULL,
    pays VARCHAR(2) NOT NULL,
    region INT NOT NULL,
    age3 VARCHAR(3) NOT NULL,
    accident INT NOT NULL,
    franchise INTEGER NOT NULL,
    prime FLOAT NOT NULL,
    isBaseP INT NOT NULL,
    isBaseF INT NOT NULL,
    age VARCHAR(2) NOT NULL,
    tarifDesc VARCHAR(255) NOT NULL,
    tarifTyp VARCHAR(255) NOT NULL,
    tarif VARCHAR(255) NOT NULL
);

-- =========================
-- Raw tables (to fix data)
-- =========================
CREATE TABLE assurance_raw(
    id TEXT, assuranceId TEXT, useless TEXT, name TEXT, commune TEXT
);

CREATE TABLE communes_raw(
    id TEXT, localite TEXT, npa TEXT, npaplus TEXT, commune TEXT,
    ofsId TEXT, canton TEXT, `long` TEXT, lat TEXT, langue TEXT
);

CREATE TABLE region_raw(
    id TEXT, canton TEXT, ofsId TEXT, communaute TEXT, region TEXT
);

CREATE TABLE lamal_raw(
    id TEXT, year TEXT, assuranceId TEXT, canton TEXT, pays TEXT,
    region TEXT, age3 TEXT, accident TEXT, franchise TEXT, prime TEXT,
    isBaseP TEXT, isBaseF TEXT, age TEXT, tarifDesc TEXT, tarifTyp TEXT, tarif TEXT
);

-- =========================
-- Import data in raw.
-- =========================
LOAD DATA INFILE '/var/lib/mysql/export/assurances.csv'
INTO TABLE assurance_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql/export/communes.csv'
INTO TABLE communes_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql/export/communeseu.csv'
INTO TABLE communes_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql/export/region.csv'
INTO TABLE region_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/var/lib/mysql/export/lamal.csv'
INTO TABLE lamal_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =========================
-- Cleanup data
-- =========================

-- Helper: patrones
-- INT:    '^[0-9]+$'
-- FLOAT:  '^[0-9]+(\\.[0-9]+)?$'

INSERT INTO assurance (id, assuranceId, useless, name, commune)
SELECT
  CAST(id AS UNSIGNED),
  CAST(assuranceId AS UNSIGNED),
  NULLIF(useless,''),
  COALESCE(name,''),
  COALESCE(commune,'')
FROM assurance_raw
WHERE id REGEXP '^[0-9]+$'
  AND assuranceId REGEXP '^[0-9]+$'
  AND COALESCE(name,'') <> ''
  AND COALESCE(commune,'') <> '';

INSERT INTO communes (id, localite, npa, npaplus, commune, ofsId, canton, `long`, lat, langue)
SELECT
  CAST(id AS UNSIGNED),
  COALESCE(localite,''),
  CAST(npa AS UNSIGNED),
  CAST(npaplus AS UNSIGNED),
  COALESCE(commune,''),
  CAST(ofsId AS UNSIGNED),
  COALESCE(canton,''),
  CAST(`long` AS DECIMAL(11,6)),
  CAST(lat AS DECIMAL(11,6)),
  COALESCE(langue,'')
FROM communes_raw
WHERE id REGEXP '^[0-9]+$'
  AND npa REGEXP '^[0-9]+$'
  AND npaplus REGEXP '^[0-9]+$'
  AND ofsId REGEXP '^[0-9]+$'
  AND `long` REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
  AND lat   REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
  AND COALESCE(localite,'') <> ''
  AND COALESCE(commune,'') <> ''
  AND COALESCE(langue,'') <> '';

CREATE INDEX idx_communes_ofsId ON communes(ofsId);

INSERT INTO region (id, canton, ofsId, communaute, region)
SELECT
  CAST(id AS UNSIGNED),
  COALESCE(canton,''),
  CAST(ofsId AS UNSIGNED),
  COALESCE(communaute,''),
  CAST(region AS UNSIGNED)
FROM region_raw
WHERE id REGEXP '^[0-9]+$'
  AND ofsId REGEXP '^[0-9]+$'
  AND region REGEXP '^[0-9]+$'
  AND COALESCE(canton,'') <> ''
  AND COALESCE(communaute,'') <> '';

CREATE INDEX idx_region_ofsId ON region(ofsId);

INSERT INTO lamal (
    id, year, assuranceId, canton, pays, region, age3, accident, franchise,
    prime, isBaseP, isBaseF, age, tarifDesc, tarifTyp, tarif
)
SELECT
  CAST(id AS UNSIGNED),
  CAST(year AS UNSIGNED),
  CAST(assuranceId AS UNSIGNED),
  COALESCE(canton,''),
  COALESCE(pays,''),
  CAST(region AS UNSIGNED),
  COALESCE(age3,''),
  CAST(accident AS UNSIGNED),
  CAST(franchise AS UNSIGNED),
  CAST(prime AS DECIMAL(10,4)),
  CAST(isBaseP AS UNSIGNED),
  CAST(isBaseF AS UNSIGNED),
  COALESCE(age,''),
  COALESCE(tarifDesc,''),
  COALESCE(tarifTyp,''),
  COALESCE(tarif,'')
FROM lamal_raw
WHERE id REGEXP '^[0-9]+$'
  AND year REGEXP '^[0-9]+$'
  AND assuranceId REGEXP '^[0-9]+$'
  AND region REGEXP '^[0-9]+$'
  AND accident REGEXP '^[0-9]+$'
  AND franchise REGEXP '^[0-9]+$'
  AND prime REGEXP '^[0-9]+(\\.[0-9]+)?$'
  AND isBaseP REGEXP '^[0-9]+$'
  AND isBaseF REGEXP '^[0-9]+$'
  AND COALESCE(canton,'') <> ''
  AND COALESCE(pays,'') <> ''
  AND COALESCE(age3,'') <> ''
  AND COALESCE(age,'') <> '';

-- =========================
-- Add indexes
-- =========================

-- Be sure id is unique on lamal and recreate it
ALTER TABLE lamal DROP COLUMN id;
ALTER TABLE lamal ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE INDEX idx_selectprof ON lamal(canton,region,age,accident,franchise,year);

ALTER TABLE `assurance` ADD INDEX(`assuranceId`);

-- =========================
-- Add table "lamallight" to speedup requests
-- =========================

DROP TABLE IF EXISTS lamallight;
CREATE TABLE lamallight LIKE lamal;
INSERT INTO
    lamallight
SELECT
    *
FROM
    lamal;
    
ALTER TABLE
    lamallight DROP COLUMN tarifDesc,
    DROP COLUMN tarifTyp,
    DROP COLUMN assuranceId,
    DROP COLUMN age3,
    DROP COLUMN isBaseF,
    DROP COLUMN isBaseP,
    DROP COLUMN tarif,
    DROP COLUMN pays;

ALTER TABLE `lamallight` ADD INDEX(`canton`);

DROP TABLE IF EXISTS lamallightrank;

CREATE TABLE lamallightrank AS
SELECT s.id, s.rank
FROM (
    SELECT
        id,
        year,
        canton,
        region,
        accident,
        franchise,
        age,
        prime,
        ROW_NUMBER() OVER (
            PARTITION BY year, canton, region, accident, franchise, age
            ORDER BY prime ASC
        ) AS rank
    FROM lamallight
) s;

DELETE FROM lamallight
WHERE id IN (
    SELECT id
    FROM lamallightrank
    WHERE rank >= 2
);

-- =========================
-- Optimize tables
-- =========================

optimize table assurance;
optimize table communes;
optimize table lamal;
optimize table lamallight;
optimize table lamalrank;
optimize table region;

-- You may drop temporary tables.
-- DROP TABLE IF EXISTS assurance_raw, communes_raw, region_raw, lamal_raw;
