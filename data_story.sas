libname d "/home/victorernoult0/Reporting Tools/Final project/Data";
libname out "/home/victorernoult0/Reporting Tools/Final project/Data/Output";

							*/ ----- Finding out the airlines of interest ----- */;

data d.flights_modified;
	set d.flights;
	if arr_delay < 0 then arr_delay = 0;
run;

*/ Exploration of number of flights per Airline/*;
proc sql;
	create table out.nflights_per_airline as 
	select a.name as Airline, count(*) as n_flights
	from d.airlines as a, d.flights as f
	where a.carrier=f.carrier
	group by a.name
	order by n_flights desc;
quit;

*/ Exploration of average delay per airline */;
proc sql;
	create table out.avg_delay_per_airline as 
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

							*/ ----- Summary statistics about selected airlines ----- */;

*/ Number of flights, number of delays & percentage */;
proc sql;
	create table out.nflights as 
	select f.carrier as carrier, count(*) as number_of_flights, d.delays as number_of_delays, (d.delays/count(*))*100 as percentage_delayed_flights
	from d.flights as f, 
	(select carrier, count(*) as delays from d.flights where arr_delay > 0 and carrier in ("EV", "US") group by carrier) as d
	where f.carrier in ("EV", "US") and f.carrier = d.carrier
	group by f.carrier
	order by percentage_delayed_flights;
quit;


*/ Airports most served by the companies */;
proc sql outobs = 5;
	create table out.airports_EV as 
	select f.carrier as carrier, a.name as airport, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="EV"
	group by a.name, f.carrier
	order by number_of_flights desc;
quit;

proc sql outobs = 5;
	create table out.airports_US as 
	select f.carrier as carrier, a.name as airport, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="US"
	group by a.name, f.carrier
	order by number_of_flights desc;
quit;


*/ Principal areas served */;
proc sql;
	create table out.areas_EV as 
	select f.carrier as carrier, a.tzone as area, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="EV"
	group by a.tzone, f.carrier
	order by number_of_flights desc;
quit;

proc sql;
	create table out.areas_US as 
	select f.carrier as carrier, a.tzone as area, count(*) as number_of_flights
	from d.flights as f, d.airports as a
	where f.dest = a.faa and f.carrier ="US"
	group by a.tzone, f.carrier
	order by number_of_flights desc;
quit;


*/ Most popular models */;
proc sql outobs = 3;
	create table out.models_EV as 
	select f.carrier as carrier, p.model as model, p.manufacturer as manufacturer, count(*) as n_flights
	from d.flights as f, d.planes as p
	where f.tailnum = p.tailnum and f.carrier="EV"
	group by f.carrier, p.model, p.manufacturer
	order by n_flights desc;
quit;

proc sql outobs = 3;
	create table out.models_US as 
	select f.carrier as carrier, p.model as model, p.manufacturer as manufacturer, count(*) as n_flights
	from d.flights as f, d.planes as p
	where f.tailnum = p.tailnum and f.carrier="US"
	group by f.carrier, p.model, p.manufacturer
	order by n_flights desc;
quit;

							*/ ----- Relationship between delay & distance ----- */;


