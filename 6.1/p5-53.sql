from 
on 
join 
where 
group by 
having 
over
select

функция(аргументы) over (partition by arg1, arg2 ... order by arg1, arg2 ...)

cust_id	amount
1		2
1		7
1		4
1		5
2		1
2		6
2		7
2		2

cust_id sum(amount) group by cust_id
1		18
2		16

cust_id	amount	sum(amount) over (partition by cust_id)
1		2		18
1		7		18
1		4		18
1		5		18
2		1		16
2		6		16
2		7		16
2		2		16

============= оконные функции =============

1. Вывести ФИО пользователя и название третьего фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze --2418 15
select r.customer_id, f.title
from (
	select customer_id, array_agg(rental_id)
	from (
		select *
		from rental
		order by customer_id, rental_date) t
	group by customer_id) t 
join rental r on r.rental_id = t.array_agg[5]
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

explain analyze --2108.40 11
select t.customer_id, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) t 
join inventory i on i.inventory_id = t.inventory_id
join film f on f.film_id = i.film_id
where row_number = 5

explain analyze --2108.40 18
select t.customer_id, f.title
from (
	select *, nth_value(rental_id, 5) over (partition by customer_id order by rental_date)
	from rental) t 
join inventory i on i.inventory_id = t.inventory_id
join film f on f.film_id = i.film_id
where nth_value = rental_id

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж 
каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

explain analyze --1999.92 35
with cte as (
	select c.customer_id, concat(c.last_name, ' ', c.first_name), f.film_id, f.title, p.amount
	from customer c
	join rental r on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	join payment p on r.rental_id = p.rental_id)
select cte.*, t.avg
from (
	select customer_id, avg(amount)
	from cte 
	group by customer_id) t
join cte on t.customer_id = cte.customer_id

explain analyze --2629 33
select c.customer_id, concat(c.last_name, ' ', c.first_name), f.film_id, f.title, p.amount,
	avg(p.amount) over (partition by c.customer_id)
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on r.rental_id = p.rental_id

select c.customer_id, concat(c.last_name, ' ', c.first_name), f.film_id, f.title, p.amount,
	avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (),
	sum(p.amount) over (partition by f.film_id),
	count(i.inventory_id) over (partition by c.customer_id, f.film_id),
	min(p.amount) over (partition by c.customer_id)
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on r.rental_id = p.rental_id

explain analyze --689.84  7
select customer_id, sum(amount),
sum(amount) * 100 / (select sum(amount) from payment)
from payment 
group by customer_id

explain analyze --377.71  4.5
select customer_id, sum(amount),
	sum(amount) * 100 / sum(sum(amount)) over ()
from payment 
group by customer_id

--не рабочий запрос
select customer_id, sum(sum(amount))
from payment 
group by customer_id

-- формирование накопительного итога

select customer_id, payment_date, amount,
	sum(amount) over (partition by date_trunc('month', payment_date) order by payment_date)
from payment 

select customer_id, payment_date::date, amount,
	sum(amount) over (partition by date_trunc('month', payment_date) order by payment_date::date)
from payment 

select customer_id, payment_date::date, amount,
	count(payment_id) over (partition by date_trunc('month', payment_date) order by payment_date::date)
from payment 

select customer_id, payment_date, amount,
	avg(amount) over (partition by date_trunc('month', payment_date) order by payment_date)
from payment 

-- работа функций lead и lag

дата вылета | дата прилета
дата вылета | дата прилета

select customer_id, payment_date, 
	lag(amount) over (partition by customer_id order by payment_date),
	amount,
	lead(amount) over (partition by customer_id order by payment_date)
from payment 

select customer_id, payment_date, 
	lag(amount, 5) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 5) over (partition by customer_id order by payment_date)
from payment 

select customer_id, payment_date, 
	lag(amount, 5, 0.) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 5, 0.) over (partition by customer_id order by payment_date)
from payment 

--ложный запрос
select date_trunc('month', payment_date), sum(amount),
	sum(amount) - lag(sum(amount), 1, 0.) over (order by date_trunc('month', payment_date))
from payment 
group by date_trunc('month', payment_date)

-- работа с рангами и порядковыми номерами

row_number - сковзная нумерация
dense_rank - получение общих рангов по одинаковым знаменателем с увеличением на + 1
rank - получение общих рангов по одинаковым знаменателем с увеличением на значение предыдущего ранга + кол-во значений в предыдущем ранге

select customer_id, payment_date::date,
	row_number() over (order by payment_date::date),
	dense_rank() over (order by payment_date::date),
	rank() over (order by payment_date::date)
from payment 

1	1	1
23	2	2
456	3	4

-- last_value / first_value / nth_value

--получить ифномарцию по первой аренде пользователя

explain analyze --2393.73 29
select distinct customer_id, 
	first_value(rental_id) over (partition by customer_id order by rental_date),
	first_value(rental_date) over (partition by customer_id order by rental_date),
	first_value(inventory_id) over (partition by customer_id order by rental_date),
	first_value(return_date) over (partition by customer_id order by rental_date),
	first_value(staff_id) over (partition by customer_id order by rental_date),
	first_value(last_update) over (partition by customer_id order by rental_date)
from rental 

explain analyze --1511.31 6.5
select distinct on (customer_id) * 
from rental 
order by customer_id, rental_date

explain analyze --1952.52 16 
select *
from (
	select *, first_value(rental_id) over (partition by customer_id order by rental_date)
	from rental) t 
where rental_id = first_value

explain analyze --806.30 5.5
select *
from rental r
where (customer_id, rental_date) in (
	select customer_id, min(rental_date)
	from rental 
	group by customer_id)

last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ
last_value / nth_value - ВОЗВРАЩАЕТ ТО, ЧТО ВЫ НЕ ОЖИДАЕТЕ, ЖЕЛАТЕЛЬНО НЕ ИСПОЛЬЗОВАТЬ

--ложный запрос.
select * --16 020
from (
	select *, last_value(rental_id) over (partition by customer_id order by rental_date desc)
	from rental) t 
where rental_id = last_value

explain analyze --2072.85 15
select * --599
from (
	select *, last_value(rental_id) over (partition by customer_id)
	from (
		select *
		from rental 
		order by customer_id, rental_date desc) t ) t
where rental_id = last_value

select * --599
from (
	select *, last_value(rental_id) over (partition by customer_id order by rental_date desc 
		rows between unbounded preceding and unbounded following)
	from rental) t 
where rental_id = last_value

select customer_id, payment_date, amount,
	avg(amount) over (partition by customer_id order by payment_date rows between 3 preceding and current row)
from payment 

select customer_id, payment_date, amount,
	avg(amount) over (partition by customer_id order by payment_date rows between 3 preceding and 2 following)
from payment 

--алиасы

select c.customer_id, concat(c.last_name, ' ', c.first_name), f.film_id, f.title, p.amount,
	avg(p.amount) over w1,
	sum(p.amount) over w1,
	count(p.amount) over w1,
	max(p.amount) over w1,
	sum(p.amount) over w2,
	max(p.amount) over w2,
	count(p.amount) over w2,
	avg(p.amount) over w2,
	sum(p.amount) over w3,
	count(p.amount) over w3,
	avg(p.amount) over w3,
	avg(p.amount) over w4,
	sum(p.amount) over w4,
	count(p.amount) over w4,
	max(p.amount) over w4
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on r.rental_id = p.rental_id
window w1 as (partition by c.customer_id),
	w2 as (partition by f.film_id, r.staff_id),
	w3 as (order by p.payment_date),
	w4 as (partition by c.customer_id, p.staff_id, date_trunc('month', p.payment_date))
order by 1

select customer_id, p.payment_date, p.amount,
	sum(p.amount) filter (where p.amount < 5) over (partition by customer_id order by p.payment_date),
	sum(p.amount) filter (where p.amount >= 5) over (partition by customer_id order by p.payment_date)
from payment p 

============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category

select 
from (
	with cte as () select ) t


2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

select version() --PostgreSQL 15.0

select version() --PostgreSQL 10.22

explain analyze --53.75 / 0.41  / 90.39 0.37
with cte1 as (
	select *
	from film f
	where length > 180),
cte2 as (
	select *
	from category c
	where left(c."name", 1) = 'C'),
cte3 as (
	select *
	from cte1
	join film_category fc on fc.film_id = cte1.film_id
	join cte2 on fc.category_id = cte2.category_id)
select title, length, nam
from cte3
	
explain analyze --53.75 0.41
select title, length, name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where f.length > 180 and  left(c."name", 1) = 'C'


============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие остановки
 + Напишите запрос к CTE

with recursive r as (
	--стартовая часть
	select 1 as i, 1 as factorial
	union
	--рекурсивная часть
	select i + 1 as i, factorial * (i + 1) as factorial
	from r
	where i < 12)
select *
from r

SQL Error [22003]: ОШИБКА: целое вне диапазона

with recursive r as (
	--стартовая часть
	select *, 1 as level
	from structure
	where unit_id = 1
	union
	--рекурсивная часть
	select s.*, level + 1 as level
	from r
	join "structure" s on r.unit_id = s.parent_id)
select count(*)
from r
join position p on r.unit_id = p.unit_id
join employee e on e.pos_id = p.pos_id

with recursive r as (
	--стартовая часть
	select *, 1 as level
	from structure
	where unit_id = 59
	union
	--рекурсивная часть
	select s.*, level + 1 as level
	from r
	join "structure" s on s.unit_id = r.parent_id)
select *
from r

3.2 Работа с рядами.

with recursive r as (
	--стартовая часть
	select 1 as x
	union
	--рекурсивная часть
	select x + 1 as x
	from r
	where x < 10)
select *
from r

select x
from generate_series(1, 10, 1) x

with recursive r as (
	--стартовая часть
	select 1 as x
	union
	--рекурсивная часть
	select x + 5 as x
	from r
	where x < 100)
select *
from r

select x
from generate_series(1, 100, 5) x

explain analyze --3.57 / 0.28
with recursive r as (
	--стартовая часть
	select '01.01.2023'::date as x
	union
	--рекурсивная часть
	select x + 1 as x
	from r
	where x < '31.12.2023')
select *
from r

explain analyze --12.51 / 0.1
select x::date
from generate_series('01.01.2023'::date, '31.12.2023'::date, interval '1 day') x

explain analyze  --5177.71 12
with recursive r as (
	--стартовая часть
	select min(date_trunc('month', payment_date)) x from payment
	union
	--рекурсивная часть
	select x + interval '1 month' as x
	from r
	where x < (select max(date_trunc('month', payment_date)) from payment))
select x::date, coalesce(t.sum, 0),
	coalesce(t.sum, 0) - lag(coalesce(t.sum, 0), 1, 0.) over (order by x)
from r
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by date_trunc('month', payment_date)) t on x = date_trunc
order by 1

select coalesce(null, null, null, 6, null , 8)

explain analyze  --15285.05 12
select x::date, coalesce(t.sum, 0),
	coalesce(t.sum, 0) - lag(coalesce(t.sum, 0), 1, 0.) over (order by x)
from generate_series(
	(select min(date_trunc('month', payment_date)) from payment), 
	(select max(date_trunc('month', payment_date)) from payment), 
	interval '1 month') x
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by date_trunc('month', payment_date)) t on x = date_trunc
order by 1
