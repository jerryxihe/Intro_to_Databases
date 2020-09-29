-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date AS day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5

WITH RECURSIVE flightHopping AS (
(SELECT 1 AS i, Flight.inbound AS currentAirport, Flight.s_arv AS arrivalTime
FROM Flight
WHERE date(s_dep) = (SELECT day FROM day)
AND outbound = 'YYZ')
	
UNION ALL

(SELECT i + 1 AS i, Flight.inbound AS currentAirport,
Flight.s_arv AS arrivalTime
FROM flightHopping INNER JOIN Flight
ON Flight.outbound = flightHopping.currentAirport
WHERE Flight.s_dep >= flightHopping.arrivalTime
AND (Flight.s_dep - flightHopping.arrivalTime) <= '24:00:00'
AND i < (SELECT n FROM n))
)

SELECT currentAirport AS destination, i AS num_flights FROM flightHopping;
