create database название_базы_данных

create schema lecture_4

set search_path to lecture_4

======================== Создание таблиц ========================

 https://dbdiagram.io/, https://sqldbm.com, https://pgmodeler.io

1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar (30),
	born_date date not null check(date_part('year', born_date) >= 1800 and date_part('year', age(born_date)) >= 18),
	city_id int2 not null references city(city_id),
	--language_id int2 not null references language(language_id),
	created_at timestamp not null default now(),
	created_user varchar(64) not null default current_user,
	deleted boolean not null default false)

uuid

create extension "uuid-ossp"

create table a (
	id uuid default uuid_generate_v4() primary key,
	val text)
	
'db2fef52-daf6-4e32-b434-e1e7ff46c980'
	
insert into a (val)
values ('a'), ('b')

select * from a
	
	
customer_id | city 
1			 1
2			 1
3			 2
4			 1

city 
Москва
Питер
Самара

select distinct city
Москва
Питер
Самара

select distinct city
Москва
Самара

select distinct city
Москва
Питер

serial = integer + sequence + default nextval(sequence) --автоинкремент

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table language (
	language_id serial2 primary key,
	language_name varchar(35) not null unique)
	
create table city (
	city_id serial2 primary key,
	city_name varchar(35) not null,
	country_id int2 not null references country(country_id))
	
create table country (
	country_id serial2 primary key,
	country_name varchar(35) not null unique)

== Отношения / связи ==
А		Б
один к одному  		Б является атрибутом А
один ко многим		А и Б два отдельных справочника
многие ко многим	в реляционной модели не существует, реализуется через два отношения один 
					ко многим А-В и В-Б
			
--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int unique,
	language_id int unique)
	
a l
1 1
2 3
3 2

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int unique,
	language_id int)
	
a l
1 1
2 1
3 2

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int,
	language_id int unique)
	
a l
1 1
1 2
2 3
	
--ТАК ДЕЛАТЬ НУЖНО
create table author_language (
	author_id int references author(author_id),
	language_id int2 references language(language_id),
	primary key (author_id, language_id))
	
a l
1 1
1 2
2 3 
2 1

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into "language" (language_name) 
values ('Русский'), ('Французский'), ('Японский')

select * from "language" 

insert into "language" 
values (4, 'Финский')

insert into "language" (language_name) 
values ('Китайский')

SQL Error [23505]: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "language_pkey"
  Подробности: Ключ "(language_id)=(4)" уже существует.
  
-- демонстрация работы счетчика и сброс счетчика

alter sequence language_language_id_seq restart with 100

insert into "language" (language_name) 
values ('Монгольский')

alter sequence language_language_id_seq restart with 6

insert into "language" (language_name) 
values ('Сербский')

drop table language

create table language (
	language_id int2 primary key generated always as identity,
	language_name varchar(35) not null unique)
	
insert into "language" (language_name) 
values ('Русский'), ('Французский'), ('Японский')

select * from "language" 	

insert into "language" 
overriding system value
values (4, 'Финский')

SQL Error [428C9]: ОШИБКА: в столбец "language_id" можно вставить только значение по умолчанию
  Подробности: Столбец "language_id" является столбцом идентификации со свойством GENERATED ALWAYS.
  Подсказка: Для переопределения укажите OVERRIDING SYSTEM VALUE.
  
insert into "language" (language_name) 
values ('Сербский')

--Работает начиная с 13 версии PostgreSQL - stored

create table b (
	order_id int primary key generated always as identity,
	amount_per_one numeric not null check (amount_per_one > 0),
	qty numeric not null check (qty > 0),
	res_total numeric generated always as (round(amount_per_one * qty / 1.2, 2)) stored)
	
insert into b (amount_per_one, qty)
values (1000, 3), (500, 2)

select * from b

update b 
set amount_per_one = 10000
where order_id = 1

2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

select * from country c

insert into country
select country_id, country 
from public.country c

alter table country alter column country_name type varchar(45)

alter sequence country_country_id_seq restart with 110

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

select * from city

insert into city (city_name, country_id)
select city, country_id
from public.city

alter sequence city_city_id_seq restart with 601

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

insert into author (author_name, nick_name, born_date, city_id)
values ('Жюль Верн', null, '08.02.1828', 54),
('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 399),
('Харуки Мураками', null, '12.01.1949', 66)

SQL Error [23514]: ОШИБКА: новая строка в отношении "author" нарушает ограничение-проверку "author_born_date_check"
  Подробности: Ошибочная строка содержит (3, Харуки Мураками, null, 1749-01-12, 66, 2023-06-05 20:31:15.812245, postgres, f).
  
select * from author

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;
 
-- добавление нового столбца
select * from author

alter table author add column language_id int2

-- удаление столбца
alter table author drop column language_id 

-- добавление ограничения not null
alter table author alter column language_id set not null

-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint author_name_unique unique (author_name)

-- удаление ограничения unique
alter table author drop constraint author_name_unique

-- изменение типа данных столбца
alter table author alter column language_id type varchar(100)

alter table author alter column language_id type int2 using(language_id::int2)

 3* В таблице с авторами измените колонку language_id - внешний ключ - ссылка на языки
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition

alter table author add constraint author_language_fkey foreign key (language_id) references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;
  
select * from author a

4	Жюль Верн
5	Михаил Лермонтов
6	Харуки Мураками

select * from "language" l

1	Русский
2	Французский
3	Японский

update author
set language_id = 2
where author_id = 4

update author
set language_id = 1

00:00:00
17:59:59

update author
set language_id = 3, nick_name = 'отсутствует', city_id = 555
where author_id = 6

update author
set language_id = (select language_id from "language" where language_name = 'Японский')
where author_id = 6

update author
set author_id = 700
where author_id = 6

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author 
where author_id = 5

5.1 Удалите все страны

delete from country

truncate country cascade 

select * from country c

delete from "language"

drop table "language"

drop schema lecture_4 cascade 

cascade

create schema lecture_4

create table country (
	country_id serial2 primary key,
	country_name varchar(45) not null unique)

create table city (
	city_id serial2 primary key,
	city_name varchar(45) not null,
	country_id int2 not null references country(country_id) on delete cascade on update cascade)
	
create table city (
	city_id serial2 primary key,
	city_name varchar(45) not null,
	country_id int2 default 1 references country(country_id) on delete set null on update set default)
	
cascade 
restrict 
no action 
set null 
set default

	
insert into country
select country_id, country 
from public.country c

insert into city (city_name, country_id)
select city, country_id
from public.city

select * from city

select * from country

drop table city

drop table country cascade

truncate country cascade

delete from country
where country_id = 1 

update country
set country_id = 1000
where country_id = 2

drop cascade - будут удалены FK, данные сохранятся
truncate cascade - будут удалены данные, FK сохранится
on delete cascade - будут удалены данные, FK сохранится

----------------------------------------------------------------------------

create temporary table temp_agg as (
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
	from payment 
	group by cube(1, 2, 3)
	order by 1, 2, 3)
	
select * from temp_agg

alter table temp_agg add column test int

SELECT
	n.nspname as SchemaName
	,c.relname as RelationName
	,CASE c.relkind
	WHEN 'r' THEN 'table'
	WHEN 'v' THEN 'view'
	WHEN 'i' THEN 'index'
	WHEN 'S' THEN 'sequence'
	WHEN 's' THEN 'special'
	END as RelationType
	,pg_catalog.pg_get_userbyid(c.relowner) as RelationOwner               
	,pg_size_pretty(pg_relation_size(n.nspname ||'.'|| c.relname)) as RelationSize
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n               
                ON n.oid = c.relnamespace
WHERE  c.relkind IN ('r','s') 
AND  (n.nspname !~ '^pg_toast' and nspname like 'pg_temp%')
ORDER BY pg_relation_size(n.nspname ||'.'|| c.relname) desc

create table temp_payment (like payment)

drop table temp_payment 

create table temp_payment (like payment including all)

explain analyze --320.94 / 2
select distinct customer_id
from payment 
where amount >= 10

< 5
5 - 10 
> 10

create table payment_new (like payment) partition by range (amount)

create table payment_low partition of payment_new for values from (minvalue) to (5)

create table payment_mid partition of payment_new for values from (5) to (10)

create table payment_hi partition of payment_new for values from (10) to (maxvalue)

insert into payment_new
select * from payment

select * from only payment_new

explain analyze --320.94 / 2   3.85 / 0.06
select distinct customer_id
from payment_new 
where amount >= 10

explain analyze --365.44 / 4
select distinct customer_id
from payment 
where amount < 10

explain analyze --438.70 / 5
select distinct customer_id
from payment_new 
where amount < 10

explain analyze --355.83 / 3.5
select distinct customer_id
from payment 
where amount < 5

explain analyze --272.38 / 3.2
select distinct customer_id
from payment_new 
where amount < 5

create table customer_new (like customer) partition by list (lower(left(last_name, 1)))

create table customer_a_g partition of customer_new for values in ('a', 'b','c','d','e','f','g') 

create table customer_h_p partition of customer_new for values in ('h','i','j','k','l','m','n','o','p')

create table customer_q_z partition of customer_new for values in ('q','r','s','t','u','v','w','x','y','z') 

drop table customer_q_z

insert into customer_new
select * from customer

explain analyze --20.23 / 0.3
select *
from customer
where lower(left(last_name, 1)) in ('a', 'b', 'c')

explain analyze --8.22 / 0.12
select *
from customer_new
where lower(left(last_name, 1)) in ('a', 'b', 'c')

explain analyze --14.99 / 0.05
select *
from customer

explain analyze --18.98 / 0.09
select *
from customer_new

select...into... from = create table ... as (...)



select * into ttt 
from  (
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
	from payment 
	group by cube(1, 2, 3)
	order by 1, 2, 3) t
	
select * from ttt 

do $$
begin
	if ... 
		then ... 
 	elseif ...
 		then ...
	else ...
	end if;
end;
language plpgsql
