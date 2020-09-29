-- Wet World Schema.

-- The constraint that no monitor may book more than two dives per 24 hour
-- period cannot be enforced without the use of assertions or triggers.

-- The constraint that the number of divers on a dive doesn't exceed the
-- monitor or dive site's max diver number cannot be enforced without the
-- use of assertions or triggers.

-- The constraint that a diver is 16 or older AT THE TIME OF A DIVE cannot
-- be enforced without the use of assertions or triggers. We can only check
-- that a diver is 16 or older when he/she is added to the Divers table:
-- CHECK (birthday < (CURRENT_DATE - INTERVAL '16 year'))

drop schema if exists wetworldschema cascade;
create schema wetworldschema;
set search_path to wetworldschema;

CREATE TYPE certification AS ENUM ('NAUI', 'CMAS', 'PADI');
CREATE TABLE Divers (
	id INT PRIMARY KEY,
	-- The first name of the diver.
	firstname VARCHAR(50) NOT NULL,
	-- The surname of the diver.
	surname VARCHAR(50) NOT NULL,
	-- The birthday of the diver.
	birthday DATE NOT NULL,
	-- Which open-water certification the diver has.
	certification certification NOT NULL,
	-- The email of the diver.
	email VARCHAR(30) NOT NULL
);

CREATE TABLE Monitors (
	id INT PRIMARY KEY,
	-- The first name of the monitor.
	firstname VARCHAR(50) NOT NULL,
	-- The surname of the monitor.
	surname VARCHAR(50) NOT NULL,
	-- The email of the monitor.
	email VARCHAR(30) NOT NULL,
	-- Max group size for open water dives.
	max_group_open INT NOT NULL,
	-- Max group size for cave dives.
	max_group_cave INT NOT NULL,
	-- Max group size for deeper than 30 meter dives.
	max_group_30_meter INT NOT NULL
);

CREATE TABLE DiveSites (
	id INT PRIMARY KEY,
	-- The name of the dive site.
	name VARCHAR(50) NOT NULL,
	-- The location of the dive site.
	location VARCHAR(50) NOT NULL,
	-- The diver's fee the dive site charges.
	diver_fee DECIMAL NOT NULL,
	
	-- NOTE: The following capacities are based on the specifications
	-- of the assignment handout.
	-- The max number of divers allowed on site during daylight hours.
	max_daylight INT NOT NULL,
	-- The max number of divers allowed on site for night, cave, or deeper
	-- than 30 meter dives.
	max_night INT NOT NULL,
	max_cave INT NOT NULL,
	max_30_meter INT NOT NULL,
	-- Check that night, cave, or deeper than 30 meter dives have smaller
	-- maxima.
	CHECK(max_daylight >= max_night),
	CHECK(max_daylight >= max_cave),
	CHECK(max_daylight >= max_30_meter),
	-- Whether or not the site provides open, cave, or beyond 30 meter
	-- diving.
	has_open BOOLEAN NOT NULL,
	has_cave BOOLEAN NOT NULL,
	has_30_meter BOOLEAN NOT NULL,
	-- Fees for additional items. If the site doesn't have the items, then
	-- the fee is NULL. We can't have the fee be 0 if the site doesn't have
	-- the items because the items could be offered for a "fee" of $0.
	mask_fee DECIMAL,
	regulator_fee DECIMAL,
	fins_fee DECIMAL,
	computer_fee DECIMAL,
	-- Additional free service availability
	has_video BOOLEAN NOT NULL,
	has_snacks BOOLEAN NOT NULL,
	has_showers BOOLEAN NOT NULL,
	has_towels BOOLEAN NOT NULL
);

CREATE TYPE dive_time AS ENUM ('morning', 'afternoon', 'night');
CREATE TYPE dive_type AS ENUM ('open', 'cave', '30_meter');
CREATE TABLE MonitorPriceList (
	-- Monitor ID and site ID for a specific monitor price.
	monitor_id INT NOT NULL REFERENCES Monitors,
	site_id INT NOT NULL REFERENCES DiveSites,
	-- Dive information for a specific monitor price.
	dive_time dive_time NOT NULL,
	dive_type dive_type NOT NULL,
	-- Price that the monitor charges for a specific dive session.
	price INT NOT NULL,
	PRIMARY KEY (monitor_id, site_id, dive_time, dive_type)
);

-- NOTE: This table is necessary since a monitor may have prices for sites
-- they are not priveleged at (i.e. Maria and Batu Bolong from data.txt).
CREATE TABLE MonitorPrivileges (
	-- Monitor ID and site ID for the privelege.
	monitor_id INT NOT NULL REFERENCES Monitors,
	site_id INT NOT NULL REFERENCES DiveSites,
	-- Ensure monitor-site pairs are unique.
	PRIMARY KEY (monitor_id, site_id)
);

CREATE TABLE Bookings (
	id INT PRIMARY KEY,
	-- The diver ID of the lead diver.
	lead_diver_id INT NOT NULL REFERENCES Divers,
	-- The monitor ID for the dive.
	monitor_id INT NOT NULL REFERENCES Monitors,
	-- The dive site ID for the dive.
	site_id INT NOT NULL REFERENCES DiveSites,
	-- The date of the dive.
	diving_date DATE NOT NULL,
	-- Dive information for a booking.
	dive_time dive_time NOT NULL,
	dive_type dive_type NOT NULL,
	-- Credit card information (use strings since arithmetic on credit
	-- card numbers is meaningless)
	credit_card CHAR(16) NOT NULL,
	-- The date and time the booking was made.
	booking_timestamp TIMESTAMP NOT NULL,
	-- Check that booked date is after the booking date.
	CHECK(diving_date >= DATE(booking_timestamp)),
	-- Which and how many additional items the group wants.
	masks_wanted INT NOT NULL,
	regulators_wanted INT NOT NULL,
	fins_wanted INT NOT NULL,
	computers_wanted INT NOT NULL,
	UNIQUE(lead_diver_id, diving_date, dive_time)
);

CREATE TABLE BookedDivers (
	-- Booking ID of a dive.
	booking_id INT NOT NULL REFERENCES Bookings,
	-- Diver ID of a diver going on the booked dive.
	diver_id INT NOT NULL REFERENCES Divers,
	PRIMARY KEY (booking_id, diver_id)
);

CREATE TABLE SiteRatings (
	-- Diver ID of a diver rating a site.
	diver_id INT NOT NULL REFERENCES Divers,
	-- Site ID of the site getting rated.
	site_id INT NOT NULL REFERENCES DiveSites,
	-- Rating the diver gave the site.
	rating INT NOT NULL CHECK (rating >= 0 AND rating <= 5),
	PRIMARY KEY (diver_id, site_id)
);

CREATE TABLE MonitorRatings (
	-- Diver ID of the lead diver rating a monitor.
	lead_diver_id INT NOT NULL REFERENCES Divers,
	-- Booking ID of the dive with the monitor getting reviewed.
	booking_id INT NOT NULL REFERENCES Bookings,
	-- Rating the diver gave the monitor.
	rating INT NOT NULL CHECK (rating >= 0 AND rating <= 5),
	PRIMARY KEY (lead_diver_id, booking_id)
);

