-- Q4. Wet World

-- I assumed that I do not need to account for additional item fees in
-- this query.
-- I also assumed that the monitor fee is applied per booking, not per
-- diver.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema, public;
DROP TABLE IF EXISTS Q4 CASCADE;

CREATE TABLE Q4 (
	site_id VARCHAR(50),
	site_name VARCHAR(50),
	highest REAL,
	lowest REAL,
	average REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS NumberDiversPerBooking CASCADE;
DROP VIEW IF EXISTS MonitorFeePerBooking CASCADE;
DROP VIEW IF EXISTS IndividualDivingFeePerBooking CASCADE;
DROP VIEW IF EXISTS TotalDivingFeesPerBooking CASCADE;
DROP VIEW IF EXISTS TotalFeesPerBooking CASCADE;


-- Define views for your intermediate steps here:
-- Finds the number of divers per booking.
CREATE VIEW NumberDiversPerBooking AS
SELECT BookedDivers.booking_id, COUNT(diver_id) AS number_divers
FROM BookedDivers 
GROUP BY BookedDivers.booking_id;

-- Finds the monitor fee per booking.
CREATE VIEW MonitorFeePerBooking AS
SELECT Bookings.id AS booking_id, MonitorPriceList.price AS monitor_fee
FROM MonitorPriceList JOIN Bookings
	ON MonitorPriceList.monitor_id = Bookings.monitor_id
	AND MonitorPriceList.dive_time = Bookings.dive_time
	AND MonitorPriceList.dive_type = Bookings.dive_type
	AND MonitorPriceList.site_id = Bookings.site_id;
	
-- Finds the individual diver fee per booking.
CREATE VIEW IndividualDivingFeePerBooking AS
SELECT Bookings.id AS booking_id, DiveSites.diver_fee, Bookings.site_id
FROM (NumberDiversPerBooking JOIN Bookings
	ON NumberDiversPerBooking.booking_id = Bookings.id)
	JOIN DiveSites ON Bookings.site_id = DiveSites.id;
	
-- Finds the total diver fees per booking.
CREATE VIEW TotalDivingFeesPerBooking AS
SELECT NumberDiversPerBooking.booking_id AS booking_id,
	IndividualDivingFeePerBooking.site_id,
	NumberDiversPerBooking.number_divers *
	IndividualDivingFeePerBooking.diver_fee AS total_diver_fee
FROM IndividualDivingFeePerBooking JOIN NumberDiversPerBooking
	ON IndividualDivingFeePerBooking.booking_id
		= NumberDiversPerBooking.booking_id;

-- Finds the total fees per booking.
CREATE VIEW TotalFeesPerBooking AS
SELECT MonitorFeePerBooking.booking_id, TotalDivingFeesPerBooking.site_id,
	MonitorFeePerBooking.monitor_fee
		+ TotalDivingFeesPerBooking.total_diver_fee AS total_fee
FROM MonitorFeePerBooking JOIN TotalDivingFeesPerBooking
	ON MonitorFeePerBooking.booking_id
		= TotalDivingFeesPerBooking.booking_id;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO Q4
SELECT TotalFeesPerBooking.site_id, DiveSites.name AS site_name,
	MAX(TotalFeesPerBooking.total_fee) AS highest,
	MIN(TotalFeesPerBooking.total_fee) AS lowest,
	AVG(TotalFeesPerBooking.total_fee) AS average
FROM DiveSites JOIN TotalFeesPerBooking
	ON DiveSites.id = TotalFeesPerBooking.site_id
GROUP BY TotalFeesPerBooking.site_id, DiveSites.name;


