libname infos 'C:\Users\rboesiger\Documents\GitHub\business-reporting-tools-group-4';

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/airlines.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV 
	OUT=infos.airlines;
	GETNAMES=YES;
	
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/airports.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=infos.airports;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/flights.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=infos.flights;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/weather.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=infos.weather;
	GETNAMES=YES;
RUN;

FILENAME REFFILE 'C:\Users\rboesiger\Documents\GitHub\BusinessReportingTools\Group_assignment/planes.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=infos.planes;
	GETNAMES=YES;
RUN;

data infos.flights_modified;
	set infos.flights;
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
Select		origin, carrier, mean(arr_delay) as AverageDelay , sum(delayed) / count(flight) as PercentageOfDelayedFlights 
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2
Order by	3, 1;
Quit;



* investigating the delay in regards to the distancegroups;
Proc SQL;
Select		distancegroup, carrier, mean(arr_delay) as AverageDelay, sum(delayed) / count(flight) as PercentageOfDelayedFlights 
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US' 
Group by	2, 1;
Quit;



* investigating the delay in regards to the destination;
Proc SQL;
Select		carrier, dest , mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights 
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;



* investigating the delay in regards to the months;
Proc SQL;
Select		carrier, month, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights  
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;



* investigating the delay in regards to the day (can we figure out the weekday?);
Proc SQL;
Select		carrier, day, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights 
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;  



* investigating the delay in regards to the departure delay;
Proc SQL;
Select		carrier, dep_delay, mean(arr_delay) as AverageDelay, (sum(delayed) / count(flight)) * 100 as PercentageOfDelayedFlights, count(flight) as NumberOfFlights 
From		INFOS.FLIGHTS_MODIFIED
Where		carrier = 'EV' OR carrier = 'US'
Group by	1, 2;
Quit;
 
