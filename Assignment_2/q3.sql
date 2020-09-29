-- Q3. North AND South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS usCities CASCADE;
DROP VIEW IF EXISTS canadaCities CASCADE;
DROP VIEW IF EXISTS canadaUSPairs CASCADE;
DROP VIEW IF EXISTS usCanadaPairs CASCADE;

DROP VIEW IF EXISTS canadaUSDirect CASCADE;
DROP VIEW IF EXISTS canadaUSDirectAll CASCADE;
DROP VIEW IF EXISTS canadaUSOneCon CASCADE;
DROP VIEW IF EXISTS canadaUSOneConAll CASCADE;
DROP VIEW IF EXISTS canadaUSTwoCon CASCADE;
DROP VIEW IF EXISTS canadaUSTwoConAll CASCADE;
DROP VIEW IF EXISTS canadaToUS CASCADE;

DROP VIEW IF EXISTS usCanadaDirect CASCADE;
DROP VIEW IF EXISTS usCanadaDirectAll CASCADE;
DROP VIEW IF EXISTS usCanadaOneCon CASCADE;
DROP VIEW IF EXISTS usCanadaOneConAll CASCADE;
DROP VIEW IF EXISTS usCanadaTwoCon CASCADE;
DROP VIEW IF EXISTS usCanadaTwoConAll CASCADE;
DROP VIEW IF EXISTS usToCanada CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW canadaCities AS
SELECT city AS canadaCity, code AS canadaCode
FROM Airport
WHERE country = 'Canada';

CREATE VIEW usCities AS
SELECT city AS usCity, code AS usCode
FROM Airport
WHERE country = 'USA';

CREATE VIEW canadaUSPairs AS
SELECT DISTINCT canadaCity, usCity
FROM usCities, canadaCities;

CREATE VIEW usCanadaPairs AS
SELECT DISTINCT uscity, canadaCity
FROM usCities, canadaCities;

-- Canada to US
CREATE VIEW canadaUSDirect AS
SELECT canadaCity, usCity, s_arv
FROM (Flight JOIN canadaCities ON outbound = canadaCode)
JOIN usCities ON inbound = usCode
WHERE date(s_dep) = '2020-04-30' AND date(s_arv) = '2020-04-30';

CREATE VIEW canadaUSDirectAll AS
SELECT canadaCity, usCity, count(s_arv) AS direct,
min(s_arv) AS earliestDirect
FROM canadaUSDirect NATURAL RIGHT JOIN canadaUSPairs
GROUP BY canadaCity, usCity;

CREATE VIEW canadaUSOneCon AS
SELECT canadaCity, usCity, F2.s_arv
FROM ((Flight F1 JOIN Flight F2 ON F1.inbound = F2.outbound)
JOIN canadaCities ON F1.outbound = canadaCode)
JOIN usCities ON F2.inbound = usCode
WHERE date(F1.s_dep) = '2020-04-30' AND date(F2.s_arv) = '2020-04-30'
AND (F2.s_dep - F1.s_arv) > '00:30:00';

CREATE VIEW canadaUSOneConAll AS
SELECT canadaCity, usCity, count(s_arv) AS one_con,
min(s_arv) AS earliestOneCon
FROM canadaUSOneCon NATURAL RIGHT JOIN canadaUSPairs
GROUP BY canadaCity, usCity;

CREATE VIEW canadaUSTwoCon AS
SELECT canadaCity, usCity, F3.s_arv
FROM (((Flight F1 JOIN Flight F2 ON F1.inbound = F2.outbound)
JOIN Flight F3 ON F2.inbound = F3.outbound)
JOIN canadaCities ON F1.outbound = canadaCode)
JOIN usCities ON F3.inbound = usCode
WHERE date(F1.s_dep) = '2020-04-30' AND date(F3.s_arv) = '2020-04-30'
AND (F2.s_dep - F1.s_arv) > '00:30:00' AND (F3.s_dep - F2.s_arv) > '00:30:00';

CREATE VIEW canadaUSTwoConAll AS
SELECT canadaCity, usCity, count(s_arv) AS two_con,
min(s_arv) AS earliestTwoCon
FROM canadaUSTwoCon NATURAL RIGHT JOIN canadaUSPairs
GROUP BY canadaCity, usCity;

CREATE VIEW canadaToUS AS
SELECT canadaCity AS outbound, usCity AS inbound, direct, one_con, two_con,
least(earliestDirect, earliestOneCon, earliestTwoCon) AS earliest
FROM canadaUSDirectAll NATURAL FULL JOIN canadaUSOneConAll
NATURAL FULL JOIN canadaUSTwoConAll;

-- US to Canada
CREATE VIEW usCanadaDirect AS
SELECT usCity, canadaCity, s_arv
FROM (Flight JOIN usCities ON outbound = usCode)
JOIN canadaCities ON inbound = canadaCode
WHERE date(s_dep) = '2020-04-30' AND date(s_arv) = '2020-04-30';

CREATE VIEW usCanadaDirectAll AS
SELECT usCity, canadaCity, count(s_arv) AS direct,
min(s_arv) AS earliestDirect
FROM usCanadaDirect NATURAL RIGHT JOIN usCanadaPairs
GROUP BY usCity, canadaCity;

CREATE VIEW usCanadaOneCon AS
SELECT usCity, canadaCity, F2.s_arv
FROM ((Flight F1 JOIN Flight F2 ON F1.inbound = F2.outbound)
JOIN usCities ON F1.outbound = usCode)
JOIN canadaCities ON F2.inbound = canadaCode
WHERE date(F1.s_dep) = '2020-04-30' AND date(F2.s_arv) = '2020-04-30'
AND (F2.s_dep - F1.s_arv) > '00:30:00';

CREATE VIEW usCanadaOneConAll AS
SELECT usCity, canadaCity, count(s_arv) AS one_con,
min(s_arv) AS earliestOneCon
FROM usCanadaOneCon NATURAL RIGHT JOIN usCanadaPairs
GROUP BY usCity, canadaCity;

CREATE VIEW usCanadaTwoCon AS
SELECT usCity, canadaCity, F3.s_arv
FROM (((Flight F1 JOIN Flight F2 ON F1.inbound = F2.outbound)
JOIN Flight F3 ON F2.inbound = F3.outbound)
JOIN usCities ON F1.outbound = usCode)
JOIN canadaCities ON F3.inbound = canadaCode
WHERE date(F1.s_dep) = '2020-04-30' AND date(F3.s_arv) = '2020-04-30'
AND (F2.s_dep - F1.s_arv) > '00:30:00' AND (F3.s_dep - F2.s_arv) > '00:30:00';

CREATE VIEW usCanadaTwoConAll AS
SELECT usCity, canadaCity, count(s_arv) AS two_con,
min(s_arv) AS earliestTwoCon
FROM usCanadaTwoCon NATURAL RIGHT JOIN usCanadaPairs
GROUP BY usCity, canadaCity;

CREATE VIEW usToCanada AS
SELECT usCity AS outbound, canadaCity AS inbound, direct, one_con, two_con,
least(earliestDirect, earliestOneCon, earliestTwoCon) AS earliest
FROM usCanadaDirectAll NATURAL FULL JOIN usCanadaOneConAll
NATURAL FULL JOIN usCanadaTwoConAll;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3

(SELECT * FROM canadaToUS) UNION (SELECT * FROM usToCanada);
