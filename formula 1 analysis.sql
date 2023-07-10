CREATE TABLE Drivers(
	driverid SERIAL PRIMARY KEY,
	driverRef VARCHAR(70),
	number VARCHAR(10),
	code VARCHAR(6),
	forename VARCHAR(50),
	surename VARCHAR(50),
	dob DATE,
	nationality VARCHAR(50),
	url VARCHAR(300)

)



CREATE TABLE lap_times(
	raceid SERIAL,
	driverid SERIAL,
	lap SERIAL,
	position SERIAL,
	time VARCHAR(255),
	miliseconds BIGINT
)

CREATE TABLE circuits (
	circuitid SERIAL,
	circuitref VARCHAR(255),
	name VARCHAR(255),
	location VARCHAR(100),
	country VARCHAR(100),
	lat real,
	lng real,
	alt VARCHAR(50),
	url VARCHAR(100)

)


CREATE TABLE races(
	raceid SERIAL,
	year smallint, 
	round smallint, 
	circuitid smallint,
	name VARCHAR(255),
	dates DATE,
	start_time VARCHAR(20),
	url VARCHAR(300),
	fp1_date VARCHAR(20),
	fp1_time VARCHAR(20),
	fp2_date VARCHAR(20),
	fp2_time VARCHAR(20),
	fp3_date VARCHAR(20),
	fp3_time VARCHAR(20),
	quali_date VARCHAR(20),
	quali_time VARCHAR(20),
	sprint_date VARCHAR(20),
	sprint_time VARCHAR(20)

)

CREATE TABLE results (
	resultid SERIAL,
	raceid serial,
	driverid serial,
	constructorid serial,
	numbers VARCHAR(20),
	grid SERIAL,
	positions VARCHAR(20),
	positionText VARCHAR(20),
	positionOrder VARCHAR(20),
	points real,
	laps serial,
	lap_time VARCHAR(100),
	miliseconds VARCHAR(20),
	fastestLap VARCHAR(20),
	ranking VARCHAR(20),
	fastestLapTime VARCHAR(20),
	fastestLapSpeed VARCHAR(20),
	statusid serial
)

CREATE TABLE constructors (
	constructorid SERIAL,
	constructorRef VARCHAR(100),
	name_constructor VARCHAR(100),
	nationality_constructor VARCHAR(100),
	url_cons VARCHAR(255)

)

CREATE TABLE sprint_results (
	resultid SERIAL,
	raceid SERIAL,
	driverid SERIAL,
	constructorsid SERIAL,
	driver_number SERIAL,
	grid SERIAL,
	positions VARCHAR(20),
	

)

CREATE TABLE constructor_results (
	constructor_result_id SERIAL,
	raceid SERIAL,
	constructorid SERIAL,
	points REAL,
	status VARCHAR(100)
	

)

CREATE TABLE constructor_standings (
	constructor_standings_id SERIAL,
	raceid SERIAL,
	constructorid SERIAL,
	points REAL,
	position_constructor SERIAL,
	position_text VARCHAR(20),
	wins SERIAL

)

CREATE TABLE driver_standings (
	driver_standings_id SERIAL,
	raceid SERIAL,
	driverid SERIAL,
	points_drier_earned REAL,
	driver_position SERIAL,
	position_text VARCHAR(20),
	driver_wins SERIAL

)

CREATE TABLE qualifying (
	qualifyid SERIAL,
	raceid serial,
	driverid serial,
	constructorid serial,
	driver_number serial,
	qualifying_position serial, 
	q1 VARCHAR(30),
	q2 VARCHAR(30),
	q3 VARCHAR(30)

)

most amount of points:

select drivers.surename, SUM(results.points) as total_points 
from results JOIN drivers ON results.driverid = drivers.driverid GROUP BY drivers.surename ORDER BY total_points DESC


who has the most fastest lap?

select drivers.surename ,COUNT(results.fastestlaptime) AS total_fastest 
from results JOIN drivers ON results.driverid = drivers.driverid 
GROUP BY drivers.surename ORDER BY total_fastest DESC

which driver holds the lap records per circuits?

SELECT c.name AS circuit_name, d.forename || ' ' || d.surename AS driver_name, lt.time AS lap_record_time
FROM circuits c
JOIN races r ON c.circuitid = r.circuitid
JOIN lap_times lt ON r.raceid = lt.raceid
JOIN drivers d ON lt.driverid = d.driverid
WHERE lt.miliseconds = (
  SELECT MIN(miliseconds)
  FROM lap_times
  WHERE raceid = r.raceid
)


which constructors constribute to the most fastest lap?

SELECT circuit_name, driver_name, constructor_name, fastest_lap_time
FROM (
  SELECT c.name AS circuit_name, d.forename || ' ' || d.surename AS driver_name, co.name_constructor AS constructor_name,
    lt.time AS fastest_lap_time,
    ROW_NUMBER() OVER (PARTITION BY c.circuitid ORDER BY lt.miliseconds) AS rn
  FROM circuits c
  JOIN races r ON c.circuitid = r.circuitid
  JOIN lap_times lt ON r.raceid = lt.raceid
  JOIN drivers d ON lt.driverid = d.driverid
  JOIN results res ON r.raceid = res.raceid AND d.driverid = res.driverid
  JOIN constructors co ON res.constructorid = co.constructorid
) AS subquery
WHERE rn = 1 ORDER BY constructor_name;

which driver has the most pole position?

SELECT d.forename || ' ' || d.surname AS driver_name, COUNT(*) AS pole_positions
FROM qualifying q
JOIN drivers d ON q.driverid = d.driverid
WHERE q.qualifying_position = 1
GROUP BY q.driverid, driver_name
ORDER BY COUNT(*) DESC
LIMIT 1;

which constructors won the most championships?

SELECT c.name_constructor AS constructor_name, COUNT(*) AS championship_wins
FROM constructor_standings cs
JOIN constructors c ON cs.constructorid = c.constructorid
WHERE cs.position_constructor = 1
GROUP BY cs.constructorid, constructor_name
ORDER BY COUNT(*) DESC;

drivers with the most fastest lap from all the circuits grouped

SELECT driver_name, COUNT(*) AS fastest_lap_count
FROM (
  SELECT c.name AS circuit_name, CONCAT(d.forename, ' ', d.surname) AS driver_name, lt.miliseconds,
    ROW_NUMBER() OVER (PARTITION BY c.circuitid ORDER BY lt.miliseconds) AS rn
  FROM circuits c
  JOIN races r ON c.circuitid = r.circuitid
  JOIN lap_times lt ON r.raceid = lt.raceid
  JOIN drivers d ON lt.driverid = d.driverid
) AS subquery
WHERE rn = 1
GROUP BY driver_name
ORDER BY COUNT(*) DESC;





