-- Q1. Wet World

-- I assumed that having a monitor who will supervise a group for a type
-- of dive at a site means that the monitor has a listed booking fee for
-- that type of dive at that site.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema, public;
DROP TABLE IF EXISTS Q1 CASCADE;

CREATE TABLE Q1 (
	num_open INT,
	num_cave INT,
	num_30_meter INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS SitesWithOpen CASCADE;
DROP VIEW IF EXISTS SitesWithCave CASCADE;
DROP VIEW IF EXISTS SitesWith30Meter CASCADE;
DROP VIEW IF EXISTS SupervisedOpenDives CASCADE;
DROP VIEW IF EXISTS SupervisedCaveDives CASCADE;
DROP VIEW IF EXISTS Supervised30MeterDives CASCADE;
DROP VIEW IF EXISTS NumberOpenSites CASCADE;
DROP VIEW IF EXISTS NumberCaveSites CASCADE;
DROP VIEW IF EXISTS Number30MeterSites CASCADE;


-- Define views for your intermediate steps here:
-- Finds sites with open water dives.
CREATE VIEW SitesWithOpen AS
SELECT id FROM DiveSites WHERE has_open = TRUE;

-- Finds sites with cave dives.
CREATE VIEW SitesWithCave AS
SELECT id FROM DiveSites WHERE has_cave = TRUE;

-- Finds sites with deeper than 30 meter dives.
CREATE VIEW SitesWith30Meter AS
SELECT id FROM DiveSites WHERE has_30_meter = TRUE;

-- Finds sites with open water dives that have available monitors.
CREATE VIEW SupervisedOpenDives AS
SELECT SitesWithOpen.id
FROM (SitesWithOpen JOIN MonitorPriceList
	ON SitesWithOpen.id = MonitorPriceList.site_id)
	JOIN MonitorPrivileges
	ON MonitorPriceList.monitor_id = MonitorPrivileges.monitor_id
	AND SitesWithOpen.id = MonitorPrivileges.site_id
WHERE MonitorPriceList.dive_type = 'open'
GROUP BY SitesWithOpen.id;

-- Finds sites with cave dives that have available monitors.
CREATE VIEW SupervisedCaveDives AS
SELECT SitesWithCave.id
FROM (SitesWithCave JOIN MonitorPriceList
	ON SitesWithCave.id = MonitorPriceList.site_id)
	JOIN MonitorPrivileges
	ON MonitorPriceList.monitor_id = MonitorPrivileges.monitor_id
	AND SitesWithCave.id = MonitorPrivileges.site_id
WHERE MonitorPriceList.dive_type = 'cave'
GROUP BY SitesWithCave.id;

-- Finds sites with deeper than 30 meter dives that have available monitors.
CREATE VIEW Supervised30MeterDives AS
SELECT SitesWith30Meter.id
FROM (SitesWith30Meter JOIN MonitorPriceList
	ON SitesWith30Meter.id = MonitorPriceList.site_id)
	JOIN MonitorPrivileges
	ON MonitorPriceList.monitor_id = MonitorPrivileges.monitor_id
	AND SitesWith30Meter.id = MonitorPrivileges.site_id
WHERE MonitorPriceList.dive_type = '30_meter'
GROUP BY SitesWith30Meter.id;

-- Counts the number of sites with available open water dives.
CREATE VIEW NumberOpenSites AS
SELECT count(id) AS numOpenSites
FROM SupervisedOpenDives;

-- Counts the number of sites with available cave dives.
CREATE VIEW NumberCaveSites AS
SELECT count(id) AS numCaveSites
FROM SupervisedCaveDives;

-- Counts the number of sites with available deeper than 30 meter dives.
CREATE VIEW Number30MeterSites AS
SELECT count(id) AS num30MeterSites
FROM Supervised30MeterDives;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO Q1
SELECT *
FROM NumberOpenSites, NumberCaveSites, Number30MeterSites;

