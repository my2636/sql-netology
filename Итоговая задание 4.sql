-- 4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
-- В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог. 

select awc.departure_airport, awc.actual_departure::date, awc.s_count, sum
from (select f.departure_airport, f.actual_departure::date, s1.s_count, 
	sum(s1.s_count) over (partition by f.departure_airport, f.actual_departure::date order by f.actual_departure, s1.s_count),
	count(*) over (partition by f.departure_airport, f.actual_departure::date) as d_count
from flights f
left join boarding_passes bp using(flight_id)
join (select aircraft_code, count(s.seat_no) as s_count
	from seats s
	group by 1) s1 using(aircraft_code)
where f.status in ('Departed', 'Arrived') and bp.flight_id is null) awc
where awc.d_count > 1