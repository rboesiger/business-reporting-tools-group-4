libname nyc "/home/victorernoult0/Reporting Tools/Final project/Data";

data nyc.flights_modified;
	set nyc.flights;
	if arr_delay < 0 then arr_delay = 0;
run;

*/ Exploration of number of flights per Airline/*;
proc sql;
	select a.name as Airline, count(*) as n_flights
	from nyc.airlines as a, nyc.flights as f
	where a.carrier=f.carrier
	group by a.name
	order by n_flights desc;
quit;

proc sql;
	select a.carrier as Carrier, a.name as Airline, 
	mean(f.arr_delay) as mean_delay, median(f.arr_delay) as median_delay
	from nyc.airlines as a, nyc.flights_modified as f
	where a.carrier=f.carrier
	group by a.carrier, a.name
	order by mean_delay desc;
quit;

*/ => Worst airline delay-wise : ExpressJet Airlines (EV) // Best airline : US Airways (US)
Taking into account the number of flights as well, 
EV & US have the most extreme delays while keeping a relevant size/*;

