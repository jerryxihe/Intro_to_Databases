-- This sample data is heavily based on the given data.txt, with
-- minor changes and placeholders to avoid NULL values.

INSERT INTO Divers VALUES
(1, 'Michael', 'Blah', '1967-03-15', 'PADI', 'michael@dm.org'),
(2, 'Dwight', 'Schrute', '1999-01-01', 'NAUI', 'dwight@dm.org'),
(3, 'Jim', 'Halpert', '1999-01-01', 'NAUI', 'jim@dm.org'),
(4, 'Pam', 'Beesly', '1999-01-01', 'NAUI', 'pam@dm.org'),
(5, 'Andy', 'Bernard', '1973-10-10', 'PADI', 'andy@dm.org'),
(6, 'Phyllis', 'Blah', '1999-01-01', 'NAUI', 'dwight@dm.org'),
(7, 'Oscar', 'Blah', '1999-01-01', 'NAUI', 'dwight@dm.org');

INSERT INTO Monitors VALUES
(1, 'Maria', 'Blah', 'maria@dm.org', 10, 5, 5),
(2, 'John', 'Blah', 'john@dm.org', 15, 15, 15),
(3, 'Ben', 'Blah', 'ben@dm.org', 15, 5, 5);

INSERT INTO DiveSites VALUES
(1, 'Bloody Bay Marine Park', 'Little Cayman', 10, 10, 10, 10, 10,
TRUE, TRUE, TRUE, 5, NULL, 10, NULL, FALSE, FALSE, FALSE, FALSE),
(2, 'Widow Maker''s Cave', 'Montego Bay', 20, 10, 10, 10, 10,
TRUE, TRUE, TRUE, 3, NULL, 5, NULL, FALSE, FALSE, FALSE, FALSE),
(3, 'Crystal Bay', 'Crystal Bay', 15, 10, 10, 10, 10,
TRUE, TRUE, TRUE, NULL, NULL, 5, 20, FALSE, FALSE, FALSE, FALSE),
(4, 'Batu Bolong', 'Batu Bolong', 15, 10, 10, 10, 10,
TRUE, TRUE, TRUE, 10, NULL, NULL, 30, FALSE, FALSE, FALSE, FALSE);

INSERT INTO MonitorPriceList VALUES
(1, 1, 'night', 'cave', 25),
(1, 2, 'morning', 'open', 10),
(1, 2, 'morning', 'cave', 20),
(1, 3, 'afternoon', 'open', 15),
(1, 4, 'morning', 'cave', 30),
(2, 1, 'morning', 'cave', 15),
(3, 2, 'morning', 'cave', 20);

INSERT INTO MonitorPrivileges VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 3),
(3, 2);

INSERT INTO Bookings VALUES
(1, 1, 1, 2, '2019-07-20', 'morning', 'open', '1234567812345678',
'2019-06-20', 0, 0, 0, 0),
(2, 1, 1, 2, '2019-07-21', 'morning', 'cave', '1234567812345678',
'2019-06-20', 0, 0, 0, 0),
(3, 1, 2, 1, '2019-07-22', 'morning', 'cave', '1234567812345678',
'2019-06-20', 0, 0, 0, 0),
(4, 1, 1, 1, '2019-07-22', 'night', 'cave', '1234567812345678',
'2019-06-20', 0, 0, 0, 0),
(5, 5, 1, 3, '2019-07-22', 'afternoon', 'open', '8765432187654321',
'2019-06-20', 0, 0, 0, 0),
(6, 5, 3, 2, '2019-07-23', 'morning', 'cave', '8765432187654321',
'2019-06-20', 0, 0, 0, 0),
(7, 5, 3, 2, '2019-07-24', 'morning', 'cave', '8765432187654321',
'2019-06-20', 0, 0, 0, 0);

INSERT INTO BookedDivers VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 1),
(2, 2),
(2, 3),
(3, 1),
(3, 3),
(4, 1),
(5, 5),
(5, 1),
(5, 2),
(5, 3),
(5, 4),
(5, 6),
(5, 7),
(6, 5),
(7, 5);

INSERT INTO SiteRatings VALUES
(3, 1, 3),
(2, 2, 0),
(4, 2, 1),
(3, 2, 2),
(5, 3, 4),
(4, 3, 5),
(1, 3, 2),
(7, 3, 3);

INSERT INTO MonitorRatings VALUES
(1, 1, 2),
(1, 2, 0),
(1, 3, 5),
(5, 5, 1),
(5, 6, 0),
(5, 7, 2);

