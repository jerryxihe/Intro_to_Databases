-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_Class seat_Class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS arrived CASCADE;
DROP VIEW IF EXISTS allDomesticFlights CASCADE;
DROP VIEW IF EXISTS allInternationalFlights CASCADE;
DROP VIEW IF EXISTS takeoffCountries CASCADE;
DROP VIEW IF EXISTS landingCountries CASCADE;
DROP VIEW IF EXISTS allDomesticFlights CASCADE;
DROP VIEW IF EXISTS allInternationalFlights CASCADE;
DROP VIEW IF EXISTS fourOrMoreDomesticDelays CASCADE;
DROP VIEW IF EXISTS tenOrMoreDomesticDelays CASCADE;
DROP VIEW IF EXISTS sevenOrMoreInternationalDelays CASCADE;
DROP VIEW IF EXISTS twelveOrMoreInternationalDelays CASCADE;
DROP VIEW IF EXISTS fourOrMoreDomesticDelayRefunds CASCADE;
DROP VIEW IF EXISTS tenOrMoreDomesticDelayRefunds CASCADE;
DROP VIEW IF EXISTS sevenOrMoreInternationalDelayRefunds CASCADE;
DROP VIEW IF EXISTS twelveOrMoreInternationalDelayRefunds CASCADE;
DROP VIEW IF EXISTS refunds CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW arrived AS
SELECT flight_id
FROM Arrival;

CREATE VIEW takeoffCountries AS
SELECT Flight.id, Airport.country AS takeoffCountry
FROM Airport JOIN Flight
ON Airport.code = Flight.outbound
JOIN arrived
ON Flight.id = arrived.flight_id;

CREATE VIEW landingCountries AS
SELECT Flight.id, Airport.country AS landingCountry
FROM Airport JOIN Flight
ON Airport.code = Flight.outbound
JOIN arrived
ON Flight.id = arrived.flight_id;

CREATE VIEW allDomesticFlights AS
SELECT takeoffCountries.id
FROM takeoffCountries NATURAL JOIN landingCountries
WHERE takeoffCountries.takeoffCountry = landingCountries.landingCountry;

CREATE VIEW allInternationalFlights AS
SELECT takeoffCountries.id
FROM takeoffCountries NATURAL JOIN landingCountries
WHERE takeoffCountries.takeoffCountry != landingCountries.landingCountry;

CREATE VIEW fourOrMoreDomesticDelays AS
SELECT Flight.id, Arrival.datetime AS actualArrival
FROM allDomesticFlights JOIN Departure
ON Departure.flight_id = allDomesticFlights.id
JOIN Arrival ON Arrival.flight_id = allDomesticFlights.id
NATURAL JOIN Flight
WHERE (Departure.datetime - s_dep) >= '4:00:00'
AND (Departure.datetime - s_dep) < '10:00:00'
AND Arrival.datetime - s_arv > (Departure.datetime - s_dep) * 0.5;

CREATE VIEW tenOrMoreDomesticDelays AS
SELECT Flight.id, Arrival.datetime AS actualArrival
FROM allDomesticFlights JOIN Departure
ON Departure.flight_id = allDomesticFlights.id
JOIN Arrival ON Arrival.flight_id = allDomesticFlights.id
NATURAL JOIN Flight
WHERE (Departure.datetime - s_dep) >= '10:00:00'
AND Arrival.datetime - s_arv > (Departure.datetime - s_dep) * 0.5;

CREATE VIEW sevenOrMoreInternationalDelays AS
SELECT Flight.id, Arrival.datetime AS actualArrival
FROM allInternationalFlights JOIN Departure
ON Departure.flight_id = allInternationalFlights.id
JOIN Arrival ON Arrival.flight_id = allInternationalFlights.id
NATURAL JOIN Flight
WHERE (Departure.datetime - s_dep) >= '7:00:00'
AND (Departure.datetime - s_dep) < '12:00:00'
AND Arrival.datetime - s_arv > (Departure.datetime - s_dep) * 0.5;

CREATE VIEW twelveOrMoreInternationalDelays AS
SELECT Flight.id, Arrival.datetime AS actualArrival
FROM allInternationalFlights JOIN Departure
ON Departure.flight_id = allInternationalFlights.id
JOIN Arrival ON Arrival.flight_id = allInternationalFlights.id
NATURAL JOIN Flight
WHERE (Departure.datetime - s_dep) >= '12:00:00'
AND Arrival.datetime - s_arv > (Departure.datetime - s_dep) * 0.5;

CREATE VIEW fourOrMoreDomesticDelayRefunds AS
SELECT Booking.flight_id, extract(year FROM actualArrival) AS year,
seat_class, sum(price) * 0.35 AS refunds
FROM fourOrMoreDomesticDelays JOIN Booking
ON fourOrMoreDomesticDelays.id = Booking.flight_id
GROUP BY Booking.flight_id, year, seat_class;

CREATE VIEW tenOrMoreDomesticDelayRefunds AS
SELECT Booking.flight_id, extract(year FROM actualArrival) AS year,
seat_class, sum(price) * 0.5 AS refunds
FROM tenOrMoreDomesticDelays JOIN Booking
ON tenOrMoreDomesticDelays.id = Booking.flight_id
GROUP BY Booking.flight_id, year, seat_class;

CREATE VIEW sevenOrMoreInternationalDelayRefunds AS
SELECT Booking.flight_id, extract(year FROM actualArrival) AS year,
seat_class, sum(price) * 0.35 AS refunds
FROM sevenOrMoreInternationalDelays JOIN Booking
ON sevenOrMoreInternationalDelays.id = Booking.flight_id
GROUP BY Booking.flight_id, year, seat_class;

CREATE VIEW twelveOrMoreInternationalDelayRefunds AS
SELECT Booking.flight_id, extract(year FROM actualArrival) AS year,
seat_class, sum(price) * 0.5 AS refunds
FROM twelveOrMoreInternationalDelays JOIN Booking
ON twelveOrMoreInternationalDelays.id = Booking.flight_id
GROUP BY Booking.flight_id, year, seat_class;

CREATE VIEW refunds AS
(SELECT * FROM fourOrMoreDomesticDelayRefunds)
UNION
(SELECT * FROM tenOrMoreDomesticDelayRefunds)
UNION
(SELECT * FROM sevenOrMoreInternationalDelayRefunds)
UNION
(SELECT * FROM twelveOrMoreInternationalDelayRefunds);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2

SELECT airline, name, year, seat_class, sum(refunds) AS refund
FROM Flight JOIN refunds ON Flight.id = refunds.flight_id
JOIN Airline ON Flight.airline = Airline.code
GROUP BY airline, name, year, seat_class, year;
