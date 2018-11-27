libname nyc "/home/victorernoult0/Reporting Tools/Final project/Data";

FILENAME REFFILE '/home/victorernoult0/Reporting Tools/Final project/Data/airlines.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV 
	OUT=nyc.airlines;
	GETNAMES=YES;
	
RUN;

FILENAME REFFILE '/home/victorernoult0/Reporting Tools/Final project/Data/airports.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=nyc.airports;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/victorernoult0/Reporting Tools/Final project/Data/flights.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=nyc.flights;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/victorernoult0/Reporting Tools/Final project/Data/weather.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=nyc.weather;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/victorernoult0/Reporting Tools/Final project/Data/planes.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=nyc.planes;
	GETNAMES=YES;
RUN;