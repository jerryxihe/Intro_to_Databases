-- Q3. Wet World

-- I assumed that how full a site is and a site's capacity is calculated
-- per day: https://piazza.com/class/k41sgwxi3z31k8?cid=863
-- I also assumed that the monitor fee is applied per booking, not per
-- diver.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema, public;
DROP TABLE IF EXISTS Q3 CASCADE;

CREATE TABLE Q3 (
	half_full_or_less_average_fee REAL,
	more_than_half_full_average_fee REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CapacitiesPerDay CASCADE;
DROP VIEW IF EXISTS DiversPerDay CASCADE;
DROP VIEW IF EXISTS HalfFullOrLess CASCADE;
DROP VIEW IF EXISTS MoreThanHalfFull CASCADE;
DROP VIEW IF EXISTS NumberDiversPerBooking CASCADE;
DROP VIEW IF EXISTS MonitorFeePerBooking CASCADE;
DROP VIEW IF EXISTS IndividualDivingFeePerBooking CASCADE;
DROP VIEW IF EXISTS TotalDivingFeesPerBooking CASCADE;
DROP VIEW IF EXISTS ExtraFeesPerBooking CASCADE;
DROP VIEW IF EXISTS TotalFeesPerBooking CASCADE;
DROP VIEW IF EXISTS HalfFullOrLessAverageFee CASCADE;
DROP VIEW IF EXISTS MoreThanHalfFullAverageFee CASCADE;


-- Define views for your intermediate steps here:
-- Finds the capacity of a dive site per day.
CREATE VIEW CapacitiesPerDay AS
SELECT DiveSites.id AS site_id,
-- The following capacity formula is from the Piazza post:
-- https://piazza.com/class/k41sgwxi3z31k8?cid=863
	2 * max_daylight + max_night AS capacity_per_day
FROM DiveSites;

-- Finds the number of divers per day.
CREATE VIEW DiversPerDay AS
SELECT Bookings.site_id, Bookings.diving_date,
COUNT(BookedDivers.diver_id) + 1 AS divers_per_day
FROM BookedDivers JOIN Bookings ON BookedDivers.booking_id = Bookings.id
GROUP BY Bookings.site_id, Bookings.diving_date;

-- Finds the sites that are half full or less on average.
CREATE VIEW HalfFullOrLess AS
SELECT DiversPerDay.site_id
FROM CapacitiesPerDay JOIN DiversPerDay
ON CapacitiesPerDay.site_id = DiversPerDay.site_id
GROUP BY DiversPerDay.site_id, CapacitiesPerDay.capacity_per_day
HAVING SUM(DiversPerDay.divers_per_day) / COUNT(DiversPerDay.diving_date)
	<= CapacitiesPerDay.capacity_per_day / 2;

 -- Finds the sites that are more than half full on average.
CREATE VIEW MoreThanHalfFull AS
SELECT DiversPerDay.site_id
FROM CapacitiesPerDay JOIN DiversPerDay
ON CapacitiesPerDay.site_id = DiversPerDay.site_id
GROUP BY DiversPerDay.site_id, CapacitiesPerDay.capacity_per_day
HAVING SUM(DiversPerDay.divers_per_day) / COUNT(DiversPerDay.diving_date)
	> CapacitiesPerDay.capacity_per_day / 2;

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
	
-- Finds the extra fees per booking.
CREATE VIEW ExtraFeesPerBooking AS
SELECT Bookings.id AS booking_id,
	COALESCE(DiveSites.mask_fee, 0)
		* Bookings.masks_wanted
		+ COALESCE(DiveSites.regulator_fee, 0)
		* Bookings.regulators_wanted
		+ COALESCE(DiveSites.fins_fee, 0)
		* Bookings.fins_wanted
		+ COALESCE(DiveSites.computer_fee, 0)
		* Bookings.computers_wanted
	AS extra_fee
	FROM DiveSites JOIN Bookings ON DiveSites.id = Bookings.site_id;

-- Finds the total fees per booking.
CREATE VIEW TotalFeesPerBooking AS
SELECT MonitorFeePerBooking.booking_id, TotalDivingFeesPerBooking.site_id,
	MonitorFeePerBooking.monitor_fee
		+ TotalDivingFeesPerBooking.total_diver_fee
		+ ExtraFeesPerBooking.extra_fee AS total_fee
FROM (MonitorFeePerBooking JOIN TotalDivingFeesPerBooking
	ON MonitorFeePerBooking.booking_id
		= TotalDivingFeesPerBooking.booking_id)
	JOIN ExtraFeesPerBooking
	ON MonitorFeePerBooking.booking_id = ExtraFeesPerBooking.booking_id;
 
 -- Finds the average fee for sites that are half full or less on average.
 CREATE VIEW HalfFullOrLessAverageFee AS
 SELECT AVG(TotalFeesPerBooking.total_fee) AS half_full_or_less_average_fee
 FROM TotalFeesPerBooking JOIN HalfFullOrLess
	ON TotalFeesPerBooking.site_id = HalfFullOrLess.site_id;
 
 -- Finds the average fee for sites that are more than half full on average.
 CREATE VIEW MoreThanHalfFullAverageFee AS
 SELECT AVG(TotalFeesPerBooking.total_fee) AS more_than_half_full_average_fee
 FROM TotalFeesPerBooking JOIN MoreThanHalfFull
	ON TotalFeesPerBooking.site_id = MoreThanHalfFull.site_id;
	

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO Q3
SELECT COALESCE(half_full_or_less_average_fee, 0),
	COALESCE(more_than_half_full_average_fee, 0)
FROM HalfFullOrLessAverageFee, MoreThanHalfFullAverageFee;


