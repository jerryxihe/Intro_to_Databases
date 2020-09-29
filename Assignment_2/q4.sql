-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS departedFlightID CASCADE;
DROP VIEW IF EXISTS planeCapacities CASCADE;
DROP VIEW IF EXISTS flightCapacities CASCADE;
DROP VIEW IF EXISTS flightFilled CASCADE;
DROP VIEW IF EXISTS filledPercentage CASCADE;
DROP VIEW IF EXISTS veryLow CASCADE;
DROP VIEW IF EXISTS low CASCADE;
DROP VIEW IF EXISTS fair CASCADE;
DROP VIEW IF EXISTS normal CASCADE;
DROP VIEW IF EXISTS high CASCADE;
DROP VIEW IF EXISTS planeHistogram CASCADE;
DROP VIEW IF EXISTS tailNumberAirline CASCADE;


-- Define views for your intermediate steps here:
-- (flight_id)
CREATE VIEW departedFlightID AS
SELECT flight_id
FROM Departure;

-- (tail_number, capacity)
CREATE VIEW planeCapacities AS
SELECT tail_number, Plane.capacity_economy + Plane.capacity_business +
Plane.capacity_first as capacity
FROM Plane;

-- (Flight.id, capacity, tail_number)
CREATE VIEW flightCapacities AS
SELECT Flight.id, capacity, tail_number
FROM planeCapacities JOIN Flight ON planeCapacities.tail_number =
Flight.plane;

-- (flight_id, filled)
CREATE VIEW flightFilled AS
SELECT flight_id, count(*) as filled
FROM Booking NATURAL JOIN departedFlightID
GROUP BY flight_id;

-- (flight_id, percentage, tail_number)
CREATE VIEW filledPercentage AS
SELECT flight_id, CAST(filled AS FLOAT)/capacity * 100 as percentage,
tail_number
FROM flightCapacities JOIN flightFilled ON flightCapacities.id = flight_id;

-- (flight_id, very_low)
CREATE VIEW veryLow AS
SELECT count(*) as very_low, flight_id
FROM filledPercentage
WHERE percentage < 20
GROUP BY flight_id;

-- (flight_id, low)
CREATE VIEW low AS
SELECT count(*) as low, flight_id
FROM filledPercentage
WHERE percentage >= 20 AND percentage < 40
GROUP BY flight_id;

-- (flight_id, fair)
CREATE VIEW fair AS
SELECT count(*) as fair, flight_id
FROM filledPercentage
WHERE percentage >= 40 AND percentage < 60
GROUP BY flight_id;

-- (flight_id, normal)
CREATE VIEW normal AS
SELECT count(*) as normal, flight_id
FROM filledPercentage
WHERE percentage >= 60 AND percentage < 80
GROUP BY flight_id;

-- (flight_id, high)
CREATE VIEW high AS
SELECT count(*) as high, flight_id
FROM filledPercentage
WHERE percentage >= 80
GROUP BY flight_id;

-- (plane, very_low, low, fair, normal, high)
CREATE VIEW planeHistogram AS
SELECT plane, count(very_low) as very_low, count(low) as low,
count(fair) as fair, count(normal) as normal, count(high) as high
FROM Flight LEFT JOIN (veryLow NATURAL FULL JOIN low NATURAL FULL JOIN fair
NATURAL FULL JOIN normal NATURAL FULL JOIN high) ON Flight.id = flight_id
GROUP BY plane;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4

-- (airline, tail_number, very_low, low, fair, normal, high)
SELECT airline, tail_number, very_low, low, fair, normal, high
FROM planeHistogram JOIN Plane ON plane = tail_number;
