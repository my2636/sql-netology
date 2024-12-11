https://www.sqlstyle.guide/ru/

Комментарии

/*
 * dfghsfgh
 * fsghdfgh
 */
select /*действие */ действие_2
where 1 = 1
	and ...
	--and ...
	
#

Отличие ' ' от " "  --` `

' ' - значения
where first_name = 'Николай'
where date = '01.01.2024'

" " - названия сущностей
set search_path to "dvd-rental"

Зарезервированные слова

select name
from language

select "select"
from "from"

синтаксический порядок инструкции select;

select столбцы, функции, вычисления
from основная таблицу из которой получаете данные
join остальные таблицы
on условие по которому присоедитняете остальные таблицы
where фильтрация данных
group by группировку данных
having фильтрация результата агрегации
order by сортировка результата
offset 
limit

from table1
join table2 on ...
join table3 on ...

логический порядок инструкции select;

from
on
join
where
group by
having
select --алиасы
order by
offset 
limit

pg_typeof(), приведение типов

integer

count() -- bigint

select pg_typeof(100) --integer

select pg_typeof(100.) --numeric

select pg_typeof('100.') --unknown


numeric | text
100.	 '100.'

select pg_typeof(sqrt('100')) --float

select pg_typeof('100' || '100') --text

select ~ '100'

  Подсказка: Не удалось выбрать лучшую кандидатуру оператора. Возможно, вам следует добавить явные приведения типов.
  
select ~ '100'::int

select pg_typeof('100'::int)

select pg_typeof('100'::varchar)

select pg_typeof(cast('100' as int))

select pg_typeof(cast('100' as varchar))


1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select *
from film 

select film_id, title, description, release_year
from film 

select film_id FilmFilm_id, title FilmTitle, description FilmDescription, release_year FilmRelease_year
from film 

select film_id as FilmFilm_id, title as FilmTitle, description as FilmDescription, release_year as FilmRelease_year
from film 

select film_id "FilmFilm_id", title "FilmTitle", description "FilmDescription", release_year "Год выпуска фильма"
from film 

select *
from (
	select c.first_name as cust_name, s.first_name as staff_name
	from customer c, staff s) 
where staff_name = 'Mike'

select 2+2 x, 2*2 y, 2/2 z

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

int2 0-65535
integer int4 0-65535^2
bigint int8 0-65535^4
numeric (6, 2) 9999.99
float real / double precision 

select title, rental_rate, rental_duration, rental_rate / rental_duration as cost_per_day,
	rental_rate * rental_duration,
	rental_rate + rental_duration,
	rental_rate - rental_duration,
	power(rental_rate, rental_duration),
	mod(rental_rate, rental_duration) "остаток от деления",
	sqrt(rental_rate),
	sin(rental_rate),
	sind(rental_rate)
from film 

select 1 "не нужно придумывать очень длинынее названия, все равно не получится"

64байта

select title, rental_rate, rental_duration, rental_rate / rental_duration as cost_per_day
from film 

round(numeric, int)
round(float)

select title, rental_rate, rental_duration, round(rental_rate / rental_duration, 2) as cost_per_day
from film 

select round(8. / 17, 2)

select round(8::numeric / 17, 2)

select round(123656, -3)

select round(10800., -3)

select ceil(0.1)

select floor(0.9)

select x,
	round(x::numeric),
	round(x::float)
from generate_series(0.5, 7.5, 1) x

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, 2

3.1* Отсортируйте таблицу платежей по возрастанию размера платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select *
from payment 
order by amount

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
-- используйте limit

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc
limit 10

1 - 1000
2, 3, 4 - 990
5-20 - 980

топ-3?
на задачу нет ответа

3 квартиры
конфеты

460	INNOCENT USUAL	1.66
938	VELVET TERMINATOR	1.66
65	BEHAVIOR RUNAWAY	1.66
897	TORQUE BOUND	1.66
904	TRAIN BUNCH	1.66
908	TRAP GUYS	1.66
919	TYCOON GATHERING	1.66
71	BILKO ANONYMOUS	1.66
580	MINE TITANS	1.66
583	MISSION ZOOLANDER	1.66

120	CARIBBEAN LIBERTY	1.66
124	CASPER DRAGONFLY	1.66
46	AUTUMN CROW	1.66
60	BEAST HUNCHBACK	1.66
65	BEHAVIOR RUNAWAY	1.66
71	BILKO ANONYMOUS	1.66
2	ACE GOLDFINGER	1.66
21	AMERICAN CIRCUS	1.66
48	BACKLASH UNDEFEATED	1.66
126	CASUALTIES ENCINO	1.66

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc
fetch first 10 rows only 

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc
fetch first 10 rows with ties 

3.2.1 Вывести топ-1 самых дорогих фильмов по стоимости за день аренды, то есть вывести все 62 фильма
--начиная с 13 версии

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc
fetch first 63 rows with ties 

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и offset

select *
from payment 
order by amount
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct release_year
from film 

select release_year
from film 
group by release_year

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select first_name --599
from customer 

select distinct first_name --591
from customer 

select distinct first_name, last_name --599
from customer 

--так плохо
explain analyze --25.47
select distinct customer_id, first_name, last_name 
from customer

explain analyze --14.99
select customer_id, first_name, last_name 
from customer

cost=25.47 
actual time=0.264

4.1 нужно получить последний платеж каждого пользователя

select distinct on (customer_id) *
from payment 
order by customer_id, payment_date desc

select distinct on (customer_id) payment_date
from payment 
order by customer_id, payment_date desc

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

text - 1гб
varchar(N) varchar(100)
char(N) char(10) 'xxxxx' -> 'xxxxx     '

select title, rating, release_year
from film 
where rating = 'PG-13'

select title || ' - ' || release_year, rating
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

select concat_ws(' ', last_name, first_name, middle_name)
from person p

номер_паспорта | серия_паспорта
9999			null

select '9999' || null

имя 		| отчество
Николай			null

select concat('Николай', null)

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

like
ilike
% - от 0 до N символов
_ - строго один символ

select concat(title, ' - ', release_year), rating
from film 
where rating like 'PG%'

SQL Error [42883]: ОШИБКА: оператор не существует: mpaa_rating ~~ unknown

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where left(rating::text, 2) = 'PG'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%3'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'N%7'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where not rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text not like '%-%'

select concat_ws(' ', last_name, first_name, middle_name)
from person p
where last_name like 'А__к%в'

select concat_ws(' ', last_name, first_name, middle_name)
from person p
where last_name like 'А__________а'

select concat_ws(' ', last_name, first_name, middle_name)
from person p
where last_name like 'А%а' and char_length(last_name) = 12

select *
from film 
where title like '%\%%'
order by 1

select *
from film 
where title like '%Y%%' escape 'Y'
order by 1

select ''''

select concat_ws(' ', last_name, first_name, middle_name)
from person p
where last_name ilike 'а%А' and char_length(last_name) = 12

select concat_ws(' ', last_name, first_name, middle_name), lower(last_name)
from person p
where lower(last_name) like 'а%а' and char_length(last_name) = 12

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания),
в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select *
from customer 
where first_name ilike '%jam%'

select strpos('Привет мир', 'мир')

select substring('Привет мир', 4, 3)

select substring('Привет мир', 4)

select substring('Привет мир' from 4 for 3)

select left('Привет мир', 3)

select left('Привет мир', -3)

select right('Привет мир', 3)

select right('Привет мир', -3)

select split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 1),	
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 2),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 3)
from person p

select * from person p

Литвинова 1
Амелия 2
Егоровна 3

select character_length('Привет мир')

select char_length('Привет мир')

select length('Привет мир') --10

select octet_length('Привет мир')

select concat_ws(' ', last_name, first_name, middle_name),
	replace(concat_ws(' ', last_name, first_name, middle_name), 'Николай', 'Nikolay')
from person p
where first_name = 'Николай'

select concat_ws(' ', last_name, first_name, middle_name),
	overlay(
		concat_ws(' ', last_name, first_name, middle_name)
		placing 'Nikolay'
		from strpos(concat_ws(' ', last_name, first_name, middle_name), 'Николай') - 1
		for char_length('Николай') + 1)
from person p
where first_name = 'Николай'

select lower(concat_ws(' ', last_name, first_name, middle_name))
from person p

select lower(last_name), lower(first_name), lower(middle_name)
from person p

select upper(concat_ws(' ', last_name, first_name, middle_name))
from person p

select initcap(upper(concat_ws(' ', last_name, first_name, middle_name)))
from person p

select initcap('aaaBBB.ccc dDD8EEE')
				Aaabbb.Ccc Ddd8eee

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 включительно по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval

select now()

timestamptz
2024-05-02 21:21:26.244402+03
timetz
21:21:26.244402+03
timestamp
2024-05-02 21:21:26.244402
time
21:21:26.244402
date
2024-05-02
interval 

select '13/01/2024'::date

to_date
to_char
to_...

show lc_time --Russian_Russia.1251

yyyy.mm.dd
dd.mm.yyyy

select '2024-05-02 05:21:26.244402+10'::timestamptz
		2024-05-01 22:21:26.244402+03
		2024-05-02 05:21:26.244402+10
		
set time zone 'utc-10'

set time zone 'utc-3'

--ложный запрос
select *
from payment 
where payment_date >= '27-05-2005' and payment_date <= '28-05-2005'
order by payment_date desc

--ложный запрос 
select *
from payment 
where payment_date between '27-05-2005 00:00:00' and '28-05-2005 00:00:00'
order by payment_date desc

--можно, но не нужно
select *
from payment 
where payment_date between '27-05-2005 00:00:00' and '28-05-2005 24:00:00'
order by payment_date desc

select *
from payment 
where payment_date between '27-05-2005 00:00:00' and '29-05-2005'
order by payment_date desc

select *
from payment 
where payment_date between '27-05-2005 00:00:00' and '28-05-2005'::date + interval '1 day'
order by payment_date desc

--как нужно
select *
from payment 
where payment_date::date between '27-05-2005' and '28-05-2005'
order by payment_date desc

select payment_date::date as x
from payment 

select date(payment_date)
from payment 


6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select *
from payment 
where payment_date::date > '2005-07-08'
order by payment_date

extract --numeric
date_part --float
date_trunc

select 
	extract(year from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(month from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(day from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(hour from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(minutes from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(seconds from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(week from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(quarter from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(isodow from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(epoch from '2024-05-02 05:21:26.244402+10'::timestamptz),
	extract(millennium from '2024-05-02 05:21:26.244402+10'::timestamptz)

select 
	date_part('year', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('month', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('day', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('hours', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('minutes', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('seconds', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('week', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('quarter', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('isodow', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('epoch', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_part('millennium', '2024-05-02 05:21:26.244402+10'::timestamptz)
	
select 
	date_trunc('year', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('month', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('day', '2024-05-02 05:21:26.244402+3'::timestamptz),
	date_trunc('hours', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('minutes', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('seconds', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('week', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('quarter', '2024-05-02 05:21:26.244402+10'::timestamptz),
	date_trunc('millennium', '2024-05-02 05:21:26.244402+10'::timestamptz)
	
date_trunc('month'
	
7. Получить количество дней с '17-04-2007' по сегодняшний день.
Получить количество месяцев с '17-04-2007' по сегодняшний день.
Получить количество лет с '17-04-2007' по сегодняшний день.

select now()

select current_timestamp

select current_time

select current_date

select current_user

select current_schema

timestamp - timestamp = interval
date - date = integer

--дни:
select current_date - '17-02-2007'::date --6284

--Месяцы:
select date_part('year', age(current_date, '17-02-2007'::date)) * 12 + date_part('month', age(current_date, '17-02-2007'::date)) --206

--Года:
select date_part('year', age(current_date, '17-02-2007'::date)) --17


8. Булев тип

true 't' 1 'on' 'yes'::boolean
false 'f' 0 'off' 'no'

select *
from customer 
where activebool is false

select *
from customer 
where activebool is true

select *
from customer 
where activebool is null

9 Логические операторы and и or

нужно вывести платежи по пользователям с id 1 и 2 и их платежами размерами 0.99 и 2.99

--ложный запрос
select customer_id, amount
from payment 
where customer_id = 1 or 2 and amount = 0.99 and 2.99

--ложный запрос
select customer_id, amount
from payment 
where customer_id = 1 and customer_id = 2 and amount = 0.99 and amount = 2.99

--ложный запрос
select customer_id, amount
from payment 
where customer_id = 1 or customer_id = 2 and amount = 0.99 or amount = 2.99
		
a + b * c + d

оператор and имеет приоритет работы перед оператором or 

and = *
or = +

(a + b) * (c + d)

select customer_id, amount
from payment 
where (customer_id = 1 or customer_id = 2) and (amount = 0.99 or amount = 2.99)

select customer_id, amount
from payment 
where customer_id in (1, 2) and amount in (0.99, 2.99)

select customer_id, amount
from payment 
where customer_id in (1, 2) and not amount in (0.99, 2.99)

select customer_id, amount
from payment 
where customer_id in (1, 2) and amount not in (0.99, 2.99)