-- 1. Выведите название самолетов, которые имеют менее 50 посадочных мест

select  a.model
from aircrafts a
join (
select aircraft_code, count(seat_no) from seats
group by aircraft_code
) s on a.aircraft_code = s.aircraft_code
where count < 50
group by a.aircraft_code

-- 2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

with recursive r as (
	select min(date_trunc('month', book_date)) as x
	from bookings
union
select x + interval '1 month' as x
from r
where x < (select max(date_trunc('month', book_date)) from bookings))
select x::date, coalesce(b.sum, 0), lag(coalesce(b.sum, 0)) over (order by x),
round(((coalesce(b.sum, 0) - lag(coalesce(b.sum, 0)) over (order by x)) / lag(coalesce(b.sum, 0)) over (order by x)) * 100, 2)   as diff
from r
left join (
	select date_trunc('month', book_date), sum(total_amount)
	from bookings
	group by 1) b on b.date_trunc = r.x
order by 1


-- 3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg. 

SELECT s.aircraft_code, s.fare_conditions
FROM aircrafts a
join(SELECT aircraft_code, array_agg(distinct fare_conditions) AS fare_conditions
	FROM seats
	GROUP BY aircraft_code) s ON s.aircraft_code = a.aircraft_code
where 'Business' != all(s.fare_conditions)
 	

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


-- 5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
-- Выведите в результат названия аэропортов и процентное отношение.
-- Решение должно быть через оконную функцию.
 
select distinct a1.airport_name as departure_airport_name, a2.airport_name as arrival_airport_name,
	(count(*) over (partition by departure_airport, arrival_airport) * 1.0 /
	count(flight_id) over ()) * 100 as percentage
from flights f
join airports a1 on a1.airport_code = f.departure_airport
join airports a2 on a2.airport_code = f.arrival_airport



--  6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7

select t.operator_code, count(*)
from (select substring(contact_data ->> 'phone', 3, 3) as operator_code
	from tickets ) t
group by 1



-- 7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
-- До 50 млн - low
-- От 50 млн включительно до 150 млн - middle
-- От 150 млн включительно - high
-- Выведите в результат количество маршрутов в каждом полученном классе

select g.routes_class, count(*)
from (select sum,
	case 
		when sum < 50000000 then 'low'
		when sum >= 50000000 and sum < 150000000 then 'middle'
		else 'high'
	end routes_class
	from (select f.departure_airport, f.arrival_airport, sum(amount)
		from ticket_flights
		join flights f using(flight_id)
		group by 1, 2)
	) g
group by 1


--  8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых 
	
	select percentile_cont(0.5) within group(order by amount),
	ticket_no, flight_id, amount
	from ticket_flights
	group by 2, 3, 4
	
	select percentile_cont(0.5) within group(order by amount)
	from ticket_flights
	
	select r.* from (select *, row_number()  over (order by amount) from ticket_flights) r
	where row_number ='13400'
	
	
	
	
	
	
--	9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
-- Для поиска расстояния между двумя точками на поверхности Земли используется модуль earthdistance.
-- Для работы модуля earthdistance необходимо предварительно установить модуль cube.
-- Установка модулей происходит через команду: create extension название_модуля. 
	
	
	
	
	
	
	-- Percentile_Disc