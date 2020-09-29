-- Q2. Wet World

-- I assumed that for a monitor to "use" a dive site, they must have both
-- privilege and a listed booking fee for that site. E.g. If a monitor
-- has privilege at a site but doesn't have a listed booking fee for that
-- site, they are not considered to "use" that site.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema, public;
DROP TABLE IF EXISTS Q2 CASCADE;

CREATE TABLE Q2 (
	monitor_id INT,
	email VARCHAR(30),
	average_booking_fee REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS MonitorAverageRatings CASCADE;
DROP VIEW IF EXISTS MaxSiteRatingPerMonitor CASCADE;
DROP VIEW IF EXISTS HighRatingMonitors CASCADE;
DROP VIEW IF EXISTS HighRatingMonitorsAverageFee CASCADE;


-- Define views for your intermediate steps here:
-- Finds average ratings for monitors.
CREATE VIEW MonitorAverageRatings AS
SELECT monitor_id, AVG(rating) AS average_rating
FROM Bookings JOIN MonitorRatings ON Bookings.id = MonitorRatings.booking_id
GROUP BY monitor_id;

-- Finds highest site rating per monitor.
CREATE VIEW MaxSiteRatingPerMonitor AS
SELECT MonitorPriceList.monitor_id, MAX(SiteRatings.rating) AS max_rating
FROM (SiteRatings JOIN MonitorPriceList
	ON SiteRatings.site_id = MonitorPriceList.site_id)
	JOIN MonitorPrivileges
	ON MonitorPriceList.monitor_id = MonitorPrivileges.monitor_id
	AND SiteRatings.site_id = MonitorPrivileges.site_id
GROUP BY MonitorPriceList.monitor_id;

-- Finds monitors who have a higher average rating than the highest rating
-- of a site they use.
CREATE VIEW HighRatingMonitors AS
SELECT MonitorAverageRatings.monitor_id
FROM MonitorAverageRatings JOIN MaxSiteRatingPerMonitor
	ON MonitorAverageRatings.monitor_id = MaxSiteRatingPerMonitor.monitor_id
WHERE MonitorAverageRatings.average_rating
	> MaxSiteRatingPerMonitor.max_rating;

-- Finds the average booking fee of the higher-rating-than-site monitors.
CREATE VIEW HighRatingMonitorsAverageFee AS
SELECT HighRatingMonitors.monitor_id, AVG(price) AS average_fee
FROM MonitorPriceList JOIN HighRatingMonitors
	ON MonitorPriceList.monitor_id = HighRatingMonitors.monitor_id
GROUP BY HighRatingMonitors.monitor_id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO Q2
SELECT Monitors.id AS monitor_id, Monitors.email,
	HighRatingMonitorsAverageFee.average_fee
FROM HighRatingMonitorsAverageFee JOIN Monitors
	ON HighRatingMonitorsAverageFee.monitor_id = Monitors.id;


