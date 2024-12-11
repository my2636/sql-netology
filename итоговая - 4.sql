-- 4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, 
-- учитывая только те самолеты, которые летали пустыми 
-- и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
-- В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог. 

Использованы лишние данные, которые не имеют отношения к вопросу.
Разберитесь для чего в рамках оконной функции используются операторы partition by и order by и как они работают.

речь о лишних таблицах, которые используете просто так


select awc.departure_airport, awc.actual_departure::date, awc.s_count, sum
from (select f.departure_airport, f.actual_departure::date, s1.s_count, 
	sum(s1.s_count) over (partition by f.departure_airport, f.actual_departure::date order by f.departure_airport, f.actual_departure, s1.s_count),
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

flights f - f.departure_airport, f.actual_departure::date
seats s - aircraft_code, count(s.seat_no)
boarding_passes bp - flight_id
tickets t - t.passenger_id

Не верная работа с получением пустых самолетов, так как билеты не имеют отношения к вопросу.
Не верные джойны по неуникальным значениям.
Разберитесь, что такое группировка, для чего она используется и как работает.

select c.departure_airport, c.actual_departure::date, count, 
	sum(count) over (partition by c.departure_airport, c.actual_departure::date order by c.actual_departure)
from (select f.departure_airport, f.actual_departure, count(s.seat_no), 
	count(*) over (partition by f.departure_airport, f.actual_departure::date) as count2
	from flights f
	left join ticket_flights tf using(flight_id)
	join seats s using(aircraft_code)
	where tf.flight_id is null and f.status in ('Departed', 'Arrived')
	group by 1, 2
	) c
where c.count2 > 1

select a.airport_code, f.actual_departure::date, s_count
from airports a 
join flights f on f.departure_airport = a.airport_code
join (select aircraft_code, count(s.seat_no) as s_count
	from seats s
	group by 1) s1 using(aircraft_code)
where f.status in ('Departed', 'Arrived')
group by 1, 2, 3


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