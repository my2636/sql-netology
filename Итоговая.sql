-- 4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, 
-- учитывая только те самолеты, которые летали пустыми 
-- и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
-- В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог. 

 Использованы лишние данные, которые не имеют отношения к вопросу.
Разберитесь для чего в рамках оконной функции используются операторы partition by и order by и как они работают.

select awc.departure_airport, awc.actual_departure::date, awc.s_count, sum
from (select f.departure_airport, f.actual_departure::date, s1.s_count, 
	sum(s1.s_count) over (partition by f.departure_airport, f.actual_departure::date order by s1.s_count),
	count(*) over (partition by f.departure_airport, f.actual_departure::date) as d_count
from flights f
join (select aircraft_code, count(s.seat_no) as s_count
	from seats s
	group by 1) s1 using(aircraft_code)
left join (select flight_id, count(t.passenger_id) as p_count
	from boarding_passes bp
	join tickets t using(ticket_no)
	group by 1) t1 using(flight_id)
where f.status in ('Departed', 'Arrived') and t1.p_count is null) awc
where awc.d_count > 1


select *
from airports a 
join flights f on f.departure_airport = a.airport_code
join (select aircraft_code, count(s.seat_no) as s_count
	from seats s
	group by 1) s1 using(aircraft_code)
	
