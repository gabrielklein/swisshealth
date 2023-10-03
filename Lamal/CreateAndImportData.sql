

# Replace XXXXXXXXXXXXXXXXXXXXXX with your password.
# The data will be imported in the database called "lamal"
# Works with MySQL and MariaDB - could probably be adapted to other databases.
# Copy first data from the export folder to "/tmp/" and chmod 777 /tmp/*.csv to give access to mysql.
# Depending on your usage, don't hesitate to create other indexes as we have lot of data.


# Create database
CREATE DATABASE lamal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# Create user
CREATE USER 'lamal'@'localhost' IDENTIFIED BY 'XXXXXXXXXXXXXXXXXXXXXX';
GRANT ALL PRIVILEGES ON lamal.* TO lamal@localhost;



# ---------------------------
use lamal

# Create and import data
DROP TABLE IF EXISTS assurance;

CREATE TABLE assurance(
    id INTEGER NOT NULL,
    assuranceId INTEGER NOT NULL,
    useless VARCHAR(1),
    name VARCHAR(255) NOT NULL,
    commune VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS communes;

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
    langue VARCHAR(2) NOT NULL
);

DROP TABLE IF EXISTS region;

CREATE TABLE region(
    id INTEGER NOT NULL,
    canton VARCHAR(2) NOT NULL,
    ofsId INTEGER NOT NULL,
    communaute VARCHAR(27) NOT NULL,
    region INTEGER NOT NULL
);

DROP TABLE IF EXISTS lamal;

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


LOAD DATA INFILE '/tmp/assurances.csv'  INTO TABLE assurance FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE '/tmp/communes.csv' INTO TABLE communes FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/tmp/communeseu.csv' INTO TABLE communes FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
ALTER TABLE `communes` ADD INDEX(`ofsId`); 

LOAD DATA INFILE '/tmp/region.csv' INTO TABLE region FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
ALTER TABLE `region` ADD INDEX(`ofsId`); 

LOAD DATA INFILE '/tmp/lamal.csv' INTO TABLE lamal FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

ALTER TABLE lamal DROP COLUMN id;
ALTER TABLE `lamal` ADD `id` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`); 


DROP TABLE IF EXISTS lamallight;
CREATE TABLE lamallight LIKE lamal;
INSERT INTO
    lamallight
SELECT
    *
FROM
    lamal;

# Optimize lamal
CREATE INDEX idx_selectprof ON lamal(canton,region,age,accident,franchise,year);

# Optimize lamallight
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

delete from
    lamallight
where
    id in (
        select
            s.id
        from
            (
                select
                    id,
                    year,
                    canton,
                    region,
                    accident,
                    franchise,
                    age,
                    prime,
                    row_number() over (
                        partition by year,
                        canton,
                        region,
                        accident,
                        franchise,
                        age
                        order by
                            prime asc
                    ) as "rank"
                from
                    lamallight
            ) s
        where
            s.rank > 1
    );


ALTER TABLE `assurance` ADD INDEX(`assuranceId`); 


# Be sure that all tables are optimized
optimize table assurance;
optimize table communes;
optimize table lamal;
optimize table lamallight;
optimize table region;


