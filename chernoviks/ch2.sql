@netonkh
---- !!!!!!!!! ----
explain analyze --1511.31/10
SELECT DISTINCT ON (customer_id) *
FROM rental
ORDER BY customer_id, rental_date

explain analyze --800.31/5
select *
from rental r 
where (customer_id, rental_date) in (
	select customer_id, min(rental_date)
	from rental r2 
	group by 1
)

explain analyze --2433.84/23
select * from
(select distinct *, first_value(rental_id) over (partition by customer_id order by rental_date)
from rental)
where rental_id = first_value
-------------------

create table test (
date_event timestamp,
field varchar(50),
old_value varchar(50),
new_value varchar(50)
)

insert into test (date_event, field, old_value, new_value)
values
('2017-08-05', 'val', 'ABC', '800'),
('2017-07-26', 'pin', '', '10-AA'),
('2017-07-21', 'pin', '300-L', ''),
('2017-07-26', 'con', 'CC800', 'null'),
('2017-08-11', 'pin', 'EKH', 'ABC-500'),
('2017-08-16', 'val', '990055', '100')

select * from test order by date(date_event)
select *
from film f
join inventory i on i.film_id = f.film_id
join rental r using(inventory_id)
join (
	select fc.film_id, string_agg(c.name, ', ') 
	from film_category fc
	join category c on c.category_id = fc.category_id
	group by fc.film_id
	) fc on fc.film_id = f.film_id

select c.category_id, title "Название фильма", rating "Рейтинг", c."name" "Жанр", f.release_year "Год выпуска", l."name" "Язык", count(r.rental_id) "Количество аренд", sum(amount) "Общая стоимость аренды"
from film f
join inventory i on i.film_id = f.film_id
join rental r using(inventory_id)
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
join "language" l on f.language_id = l.language_id
join payment p on r.rental_id = p.rental_id
group by f.film_id, c.category_id,l.language_id
order by title

insert into film_category (film_id, category_id)
values (1, 1), (1, 2), (1, 3)


select f.title "Название фильма", f.rating "Рейтинг", fc.string_agg "Жанр", f.release_year "Год выпуска", l."name" "Язык", count(r.rental_id) "Количество аренд", sum(p.amount) "Общая стоимость аренды"
from film f
join inventory i on i.film_id = f.film_id
join rental r using(inventory_id)
join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc
	join category c on c.category_id = fc.category_id
	group by fc.film_id
	) fc on fc.film_id = f.film_id
join "language" l on f.language_id = l.language_id
join payment p on r.rental_id = p.rental_id
group by f.film_id, l.language_id, fc.string_agg

create table orders (
id serial not null primary key,
info json not null
)

insert into orders (info)
values (
'{"customer": "John Doe", "items":{"product":"Beer","qty":6}}'
),
(
'{"customer": "Lily Bush", "items":{"product":"Diaper","qty":24}}'
),
(
'{"customer": "Josh William", "items":{"product":"Toy Car","qty":1}}'
),
(
'{"customer": "Mary Clark", "items":{"product":"Toy Train","qty":2}}'
)

select sum((info -> 'items' ->> 'qty')::int ) from orders

explain analyze
select *
from(select p.customer_id, p.payment_date, p.amount, row_number() over (partition by p.payment_date) as rn from payment p) Q1, payment p2
where q1.rn < 4

explain analyze
select * from (select first_name || ' ' || last_name as full_name from actor_info ai where ai.film_info like '%Animation:%') t1
where full_name ilike 'liza%'

explain analyze
with cte1 as (select first_name || ' ' || last_name as full_name from actor_info ai where ai.film_info like '%Animation:%')
select full_name from cte1
