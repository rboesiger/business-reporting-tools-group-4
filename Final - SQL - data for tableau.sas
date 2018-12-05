libname d "/home/victorernoult0/Reporting Tools/Final project/Data";


FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/airlines.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV 
	OUT=d.airlines;
	GETNAMES=YES;
	
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/airports.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=d.airports;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/flights.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=d.flights;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/weather.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=d.weather;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/planes.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=d.planes;
	GETNAMES=YES;
RUN;

							*/ ------------------------------------------------ */;
							*/ ----- Finding out the airlines of interest ----- */;
							*/ ------------------------------------------------ */;

data d.flights_modified;
	set d.flights;
	if arr_delay < 0 then arr_delay = 0;
run;

*/ Exploration of number of flights per Airline/*;
proc sql;
	create table d.nflights_per_airline as 
	select a.name as Airline, count(*) as n_flights
	from d.airlines as a, d.flights as f
	where a.carrier=f.carrier
	group by a.name
	order by n_flights desc;
quit;

*/ Exploration of average delay per airline */;
proc sql;
	create table d.avg_delay_per_airline as 
	select a.carrier as Carrier, a.name as Airline, 
	mean(f.arr_delay) as mean_delay, median(f.arr_delay) as median_delay
	from d.airlines as a, d.flights_modified as f
	where a.carrier=f.carrier
	group by a.carrier, a.name
	order by mean_delay desc;
quit;

*/ => Worst airline delay-wise : ExpressJet Airlines (EV) // Best airline : US Airways (US)
Taking into account the number of flights as well, 
EV & US have the most extreme delays while keeping a relevant size/*;

							*/ ------------------------------------------------------ */;
							*/ ----- Summary statistics about selected airlines ----- */;
							*/ ------------------------------------------------------ */;

*/ Number of flights, number of delays & percentage */;
proc sql;
	create table d.nflights as 
	select f.carrier as carrier, count(*) as number_of_flights, d.delays as number_of_delays, (d.delays/count(*))*100 as percentage_delayed_flights
	from d.flights as f, 
	(select carrier, count(*) as delays from d.flights where arr_delay > 0 and carrier in ("EV", "US") group by carrier) as d
	where f.carrier in ("EV", "US") and f.carrier = d.carrier
	group by f.carrier
	order by percentage_delayed_flights;
quit;


*/ Airports most served by the companies */;
proc sql outobs = 5;
	create table d.airports_EV as 
	select f.carrier as carrier, a.name as airport, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="EV"
	group by a.name, f.carrier
	order by number_of_flights desc;
quit;

proc sql outobs = 5;
	create table d.airports_US as 
	select f.carrier as carrier, a.name as airport, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="US"
	group by a.name, f.carrier
	order by number_of_flights desc;
quit;


*/ Principal areas served */;
proc sql;
	create table d.areas_EV as 
	select f.carrier as carrier, a.tzone as area, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="EV"
	group by a.tzone, f.carrier
	order by number_of_flights desc;
quit;

proc sql;
	create table d.areas_US as 
	select f.carrier as carrier, a.tzone as area, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="US"
	group by a.tzone, f.carrier
	order by number_of_flights desc;
quit;


*/ Most popular models */;
proc sql outobs = 3;
	create table d.models_EV as 
	select f.carrier as carrier, p.model as model, p.manufacturer as manufacturer, count(*) as n_flights
	from d.flights as f, d.planes as p
	where f.tailnum = p.tailnum and f.carrier="EV"
	group by f.carrier, p.model, p.manufacturer
	order by n_flights desc;
quit;

proc sql outobs = 3;
	create table d.models_US as 
	select f.carrier as carrier, p.model as model, p.manufacturer as manufacturer, count(*) as n_flights
	from d.flights as f, d.planes as p
	where f.tailnum = p.tailnum and f.carrier="US"
	group by f.carrier, p.model, p.manufacturer
	order by n_flights desc;
quit;


							*/ ---------------------------------------------------------------------- */;
							*/ ----- Exploring relationships between delays and other variables ----- */;
							*/ ---------------------------------------------------------------------- */;


data d.flights_modified;
	set d.flights;
	if arr_delay < 0 then arr_delay = 0;
	if distance < 500 then distancegroup = 1;
	else if distance < 1000 then distancegroup = 2;
	else if distance < 1500 then distancegroup = 3;
	else if distance < 2000 then distancegroup = 4;
	else if distance < 2500 then distancegroup = 5;
	else if distance < 3000 then distancegroup = 6;
	else if distance < 3500 then distancegroup = 7;
	else if distance < 4000 then distancegroup = 8;
	else if distance < 4500 then distancegroup = 9;
	else distancegroup = 10;
	If arr_delay > 0 then delayed = 1;
	else delayed = 0;
	
run;


* investigating the differences between the airports;
Proc SQL;
Create table d.airport_differences as
Select		origin, carrier, mean(dep_delay) as AverageDepDelay , mean(arr_delay) as AverageArrDelay , sum(delayed) / count(flight) as PercentageOfDelayedFlights 
From		d.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2
Order by	3, 1;
Quit;



* investigating the delay in regards to the distancegroups;
Proc SQL;
Select		distancegroup, carrier, mean(arr_delay) as AverageDelay, sum(delayed) / count(flight) as PercentageOfDelayedFlights 
From		d.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US' 
Group by	2, 1;
Quit;



* investigating the delay in regards to the destination;
Proc SQL;
Create table d.destination_differences as
Select		Distinct A.carrier, A.dest , sum(A.arr_delay) as SumDelay, (sum(A.delayed) / count(A.flight)) * 100 as PercentageOfDelayedFlights, B.lat, B.lon 
From		d.FLIGHTS_MODIFIED as A Left Outer join d.AIRPORTS as B
On		A.dest = B.faa
Where		carrier = 'EV'
Group by	1, 2;
Quit;



* investigating the delay in regards to the months;
Proc SQL;
Create table d.monthly_difference as
Select		carrier, month, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights  
From		d.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;



* investigating the delay in regards to the day (can we figure out the weekday?);
Proc SQL;
Select		carrier, day, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights 
From		d.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;  



* investigating the delay in regards to the departure delay;
Proc SQL;
Select		carrier, dep_delay, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights 
From		d.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;
 
proc sql;
Create table d.ev_planes as
select C.name, B.model, count(Distinct B.tailnum) as NumberOfPlanes 
from d.Airlines as C, d.Planes as B, d.Flights_modified as D
where C.carrier = D.carrier and D.tailnum = B.tailnum and C.carrier = 'EV'
group by 1, 2
order by 1;
quit;

proc sql;
select A.model, (sum(B.delayed) / count(B.flight)) * 100 as PersentageOfFlightsDelayed, count(B.flight) as NumberOfFlights 
from d.Planes as A, d.Flights_modified as B
where A.tailnum = B.tailnum
group by A.model
order by 2 Desc ;
quit;


