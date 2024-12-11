============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1 as 
	explain analyze --2148.35 / 10
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
explain analyze --2148.35 / 10

create or replace view task_1 as 
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1

drop view task_1 
	
select * 
from task_1

create view task_2 as 
	select c.customer_id, f.film_id, concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
select t.*, r.count
from task_2 t
join (
	select customer_id, count(*)
	from rental 
	group by 1) r on t.customer_id = r.customer_id

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_3 as 
	select f.title, concat(a.last_name, ' ', a.first_name),
		count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on f.film_id = fa.film_id
	join actor a on a.actor_id = fa.actor_id
	
select f.title, concat(a.last_name, ' ', a.first_name),
	count(f.film_id) over (partition by a.actor_id order by f.film_id)
from film f
join film_actor fa on f.film_id = fa.film_id
join actor a on a.actor_id = fa.actor_id
	
============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные 

create materialized view task_4 as 
	select c.customer_id, f.film_id, concat(c.last_name, ' ', c.first_name), c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
with no data

select * from task_4

refresh materialized view task_4 

explain analyze --2148.35 / 10
select * 
from task_1

explain analyze --13.99 / 0.05
select * 
from task_4

pg_inv


5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные

create materialized view task_5 as 
	select c."name"
	from category c
	join film_category fc on c.category_id = fc.category_id
	join film f on f.film_id = fc.film_id
	group by c.category_id
	having avg(f.rental_duration) > 5
--with data
	
select * 
from task_5

create materialized view task_5 as 
	select c."name"
	from category c
	join film_category fc on c.category_id = fc.category_id
	join film f on f.film_id = fc.film_id
	group by c.category_id
	having avg(f.rental_duration) > 5
 
--запрос на проверку времени обновления мат представлений

WITH pgdata AS (
    SELECT setting AS path
    FROM pg_settings
    WHERE name = 'data_directory'
),
path AS (
    SELECT
    	CASE
            WHEN pgdata.separator = '/' THEN '/'    -- UNIX
            ELSE '\'                                -- WINDOWS
        END AS separator
    FROM 
        (SELECT SUBSTR(path, 1, 1) AS separator FROM pgdata) AS pgdata
)
SELECT
        ns.nspname||'.'||c.relname AS mview,
        (pg_stat_file(pgdata.path||path.separator||pg_relation_filepath(ns.nspname||'.'||c.relname))).modification AS refresh
FROM pgdata, path, pg_class c
JOIN pg_namespace ns ON c.relnamespace=ns.oid
WHERE c.relkind='m';

id | schema_name | view_name | refresh_start_time | refresh_end_time | refresh_status | user | error_message

explain analyze --1987.72 / 14
select * 
from task_2
where lower(left(concat, 1)) in ('a', 'b', 'c')

explain analyze --19.23 / 0.3
select * 
from task_4
where lower(left(concat, 1)) in ('a', 'b', 'c')

create index first_letter_idx on task_4 (lower(left(concat, 1)))

explain analyze --17.10 / 0.04
select * 
from task_4
where lower(left(concat, 1)) in ('a', 'b', 'c')

select *

select col1

============ Индексы ===========

btree = > < in between null
hash = 
gist 
gin 

select *
from film 

alter table film drop constraint film_pkey cascade

alter table film add constraint film_pkey primary key (film_id)

0 индексов - 472кб 

explain analyze --Seq Scan on film  (cost=0.00..67.50 rows=1 width=386) (actual time=0.047..0.134 rows=1 loops=1)
select *
from film
where film_id = 289

explain analyze --Index Scan using film_pkey on film  (cost=0.28..8.29 rows=1 width=386) (actual time=0.013..0.014 rows=1 loops=1)
select *
from film
where film_id = 289

explain analyze --Index Scan using strange_1_idx on film  (cost=0.00..8.02 rows=1 width=386) (actual time=0.013..0.013 rows=1 loops=1)
select *
from film
where film_id = 289

explain analyze --Index Scan using film_pkey on film  (cost=0.28..32.55 rows=288 width=386) (actual time=0.010..0.065 rows=288 loops=1)
select *
from film
where film_id < 289

explain analyze --Seq Scan on film  (cost=0.00..67.50 rows=649 width=386) (actual time=0.010..0.143 rows=649 loops=1)
select *
from film
where film_id < 650

create index strange_1_idx on film using hash (film_id)

create index strange_2_idx on film (title, rental_duration, rental_rate, length)

explain analyze --Seq Scan on film  (cost=0.00..70.00 rows=69 width=386) (actual time=0.010..0.186 rows=78 loops=1)
select * 
from film
where rental_duration = 3 and rental_rate = 0.99

explain analyze --Index Scan using strange_2_idx on film  (cost=0.28..52.31 rows=3 width=386) (actual time=0.134..0.134 rows=0 loops=1)
select * 
from film
where rental_duration = 3 and rental_rate = 0.99 and length > 180

create index strange_3_idx on film (title, rental_duration, rental_rate, length, description)

6 индексов - 848кб

explain analyze --Index Scan using title_idx on film  (cost=0.28..101.46 rows=1000 width=386) (actual time=0.019..0.248 rows=1000 loops=1)
select *
from film 
order by title

insert 
update 
delete

1-1000
1-500 501-1000
1-250 251-500 501-750 751-1000
1-125 126-250 251-375....

explain analyze --Seq Scan on film  (cost=0.00..67.50 rows=1 width=386) (actual time=0.058..0.151 rows=1 loops=1)
select *
from film
where title = 'FIDELITY DEVIL'

create index title_idx on film (title)

explain analyze --Index Scan using title_idx on film  (cost=0.28..8.29 rows=1 width=386) (actual time=0.022..0.023 rows=1 loops=1)
select *
from film
where title = 'FIDELITY DEVIL'

explain analyze --Index Scan using title_idx on film  (cost=0.28..8.29 rows=1 width=386) (actual time=0.022..0.023 rows=1 loops=1)
select *
from film
where title like '%LITY DE%'

select film_id, title, *
from film

2 индекса - 568кб

tsvector

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=26) (actual time=0.036..2.302 rows=671 loops=1)
select * 
from payment 
where payment_date::date = '01.08.2005'

create index pay_date_idx on payment (payment_date)

create index pay_date_2_idx on payment (cast(payment_date as date))

explain analyze --Seq Scan on payment  (cost=0.00..359.74 rows=80 width=26) (actual time=0.036..2.302 rows=671 loops=1)
select * 
from payment 
where payment_date::date = '01.08.2005'


============ explain ===========

Ссылка на сервис по анализу плана запроса 
https://explain.depesz.com/ -- открывать через ВПН
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

explain analyze --2148.35 / 10
select concat(c.last_name, ' ', c.first_name), c.email, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r 
join customer c on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

cost 
time 

a		b 

a1		b1
a2		b2
a3		b3

1		1
2		2
3		3
4		4

explain (format json, analyze)
select concat(c.last_name, ' ', c.first_name), c.email, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r 
join customer c on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

======================== json ========================

СЛОЖНЫЕ ТИПЫ ДАННЫХ НЕЛЬЗЯ ПРИВОДИТЬ К СТРОКЕ, НЕДОПУСТИМО, ПЛОХО И УЖАСНО.

json::text like --НЕЛЬЗЯ !!!!!!!!!!!!!!!!!!!!!!

контакты::text like '%phone: +7%' --НЕЛЬЗЯ !!!!!!!!!!!!!!!!!!!!!!

json - строковый тип данных
jsonb - бинарный тип данных

Создайте таблицу orders

CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "Beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24.5}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );

delete from orders
 
INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "01.01.2023","qty": "fgdfgh"}, "customer": "John Doe"}'
 )

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )

select  * from orders

|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|

6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select info, pg_typeof(info)
from orders

select info->'items', pg_typeof(info->'items')
from orders

select info->'items', pg_typeof(info->'items')
from orders

select info->'items'->'qty', pg_typeof(info->'items'->'qty')
from orders

select (info->'items'->'qty')::text::numeric, pg_typeof(info->'items'->'qty') --не корректно
from orders

select info->'items'->>'qty', pg_typeof(info->'items'->>'qty')
from orders

select sum((info->'items'->>'qty')::numeric)
from orders
where (info->'items'->>'qty') ~ '[0-9]'


6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where (info->'items'->>'qty') ~ '[0-9]' and info->'items'->>'product' like 'Toy%'

select json_object_keys(info->'items')
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

time[] ['10:00', '16:00']
int[] [456745,1234,6896,23626]
text[] ['01.01.2003', '100.', 'dfhadsgfjhdf']

create table a (
	id serial,
	val int[])
	
insert into a (val) 
values (array[1,2,3])

insert into a (val) 
values ('{1, 4, 7}'::int[])

select val[1], val[2], val[1:2]
from a 

update a 
set val[-10] = 999
where id = 1

select *
from a 

[-10:3]={999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,2,3}

select val[-10:-5]
from a

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 1) --12

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2) --3

select cardinality('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[]) --36

select array_lower(val, 1), array_upper(val, 1), 
from a

select val || array[456,678,345]
from a

select val, array_append(val, 2234)
from a

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/14/functions-subquery
https://postgrespro.ru/docs/postgrespro/14/functions-array

-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
select title, special_features --535
from film 
where special_features::text like '%Trailers%'

Trailers
Trailers1
Trailers2

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features --535
from film 
where special_features[1] = 'Trailers' or special_features[2] = 'Trailers'
	or special_features[3] = 'Trailers' or special_features[4] = 'Trailers'
	
-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --
select f.*
from (
	select film_id, title, unnest(special_features) --535
	from film) t 
join film f on f.film_id = t.film_id
where unnest = 'Trailers'

select title, special_features
from film
where 'Trailers' in (select unnest(special_features))

select film_id, title, special_features --535
from film

-- ХОРОШАЯ ПРАКТИКА --
select title, special_features --535
from film 
where special_features && array['Trailers', 'jkdsfbglkjdfb']

select title, special_features --535
from film 
where special_features @> array['Trailers']

select title, special_features --535
from film 
where array['Trailers'] <@ special_features

select title, special_features --535
from film 
where special_features <@ array['Trailers']

select title, special_features --535
from film 
where 'Trailers' = any(special_features) --some 

select title, special_features --535
from film 
where 'Trailers' = all(special_features) 

select title, array_position(special_features, 'Deleted Scenes')
from film 

select title, special_features
from film
where array_position(special_features, 'Trailers') is not null

select title, array_positions(array_append(special_features, 'Deleted Scenes'), 'Deleted Scenes')
from film 

create materialized view some_task as 
	select concat(c.last_name, ' ', c.first_name), c.email, f.title, now()
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
select * from some_task

refresh materialized view some_task

create table mat_view_audit (
	id serial primary key,
	schema_name varchar(64) not null default current_schema,
	view_name varchar(64) not null,
	refresh_time timestamp not null default now(),
	refresh_user varchar(64) not null default current_user)
	
insert into mat_view_audit (view_name) values ('some_task');

select * from mat_view_audit