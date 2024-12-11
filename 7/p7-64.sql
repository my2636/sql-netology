Задание 1.Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, 
а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: letsdocode.ru...in/2-7.png

select title, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or 
	(rating = 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: letsdocode.ru...in/2-8.png

select title, description, char_length(description)
from film 
order by char_length(description) desc 
fetch first 3 rows with ties

select title, description, char_length(description)
from film 
order by char_length(description) desc 
limit 3

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.
Ожидаемый результат запроса: letsdocode.ru...in/2-9.png

select email,
	split_part(email, '@', 1),
	split_part(email, '@', 2)
from customer 

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква строки должна быть заглавной, 
остальные строчными.
Ожидаемый результат запроса: letsdocode.ru...n/2-10.png

--ЛОЖНЫЙ ЗАПРОС
select email,
	concat(left(split_part(email, '@', 1), 1), lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)), right(split_part(email, '@', 2), -1))
from customer 
order by customer_id

select email,
	concat(upper(left(split_part(email, '@', 1), 1)), lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), -1)))
from customer 
order by customer_id

select email,
	overlay(lower(split_part(email, '@', 1)) placing upper(left(split_part(email, '@', 1), 1)) from 1 for 1),
	overlay(lower(split_part(email, '@', 2)) placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1)
from customer 
order by customer_id

Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». 
Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».

--ЛОЖНЫЙ ЗАПРОС
select s.staff_id, 
	case 
		when count(*) > 7300 then 'da'
		else 'net'
	end
from staff s
join payment p on s.staff_id = p.staff_id
group by 1

select *
from staff s

insert into staff
values (3,	'Mike',	'Hillyer',	3,	'Mike.Hillyer@sakilastaff.com',	1,	true,	'Mike',	'8cb2237d0679ca88db6464eac60da96345513964',	'2006-02-15 04:57:16', null	)

select s.staff_id, 
	case 
		when count(*) > 7300 then 'da'
		else 'net'
	end
from staff s
left join payment p on s.staff_id = p.staff_id
group by 1

Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0)
)

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

select unnest(array)

from unnest(array1, arrayN)

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select *
from unnest(
	array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])
	
select * from film_new

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

delete from film_new
where film_id = 3

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('sdfg', 2022, 2.89, 50)

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку «длительность фильма в часах», 
округлённую до десятых.

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new

Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику 
и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select *
from (
	select *, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') 
where row_number % 100 = 0

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.png

explain analyze --5613 / 18
select distinct c.country,
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by count(i.film_id) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by sum(p.amount) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by max(r.rental_date) desc)
from country c
left join city c2 on c.country_id = c2.country_id
left join address a on a.city_id = c2.city_id
left join customer c3 on c3.address_id = a.address_id
left join rental r on r.customer_id = c.country_id
left join payment p on p.rental_id = r.rental_id
left join inventory i on i.inventory_id = r.inventory_id
group by c.country_id, c3.customer_id

explain analyze --1258.89 / 14
with cte1 as (
	select p.customer_id, p.sum, r.count, r.max
	from (
		select customer_id, sum(amount)
		from payment 
		group by 1) p
	join (
		select customer_id, count(i.film_id), max(r.rental_date)
		from rental r
		join inventory i on i.inventory_id = r.inventory_id
		group by 1) r on r.customer_id = p.customer_id),
cte2 as (
	select c2.country_id, 
		case when cte1.sum = max(cte1.sum) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cc,
		case when cte1.count = max(cte1.count) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cs,
		case when cte1.max = max(cte1.max) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name) end cm
	from cte1
	join customer c on c.customer_id = cte1.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id)
select c.country, string_agg(cc, ', '), string_agg(cs, ', '), string_agg(cm, ', ')
from country c
left join cte2 on c.country_id = cte2.country_id
group by c.country_id 

Задание 1. Откройте по ссылке SQL-запрос.

explain analyze --1090.40
select cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) 
from customer cu
join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
group by cu.customer_id
order by count desc

Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть по ссылке.

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

select *
from (
	select *, row_number() over (partition by staff_id order by payment_date)
	from payment) 
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png

задание не имеет решения.

аренда			платеж
сотрудник		сотрудник
пользователь	пользователь
диск			диск
сотрудник		диск
сотрудник		пользователь
пользователь	диск
пользователь	сотрудник
диск			пользователь
диск			сотрудник

select *
from (
	select i.store_id, r.rental_date::date, count(*),
		row_number() over (partition by i.store_id order by count(*) desc)
	from rental r
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, r.rental_date::date) r
join (
	select i.store_id, p.payment_date::date, sum(amount),
		row_number() over (partition by i.store_id order by sum(amount))
	from payment p
	join rental r on r.rental_id = p.rental_id
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, p.payment_date::date) p on r.store_id = p.store_id
where r.row_number = 1 and p.row_number = 1

--нужно получить сумму текущих окладов сотрудников

select sum(salary)
from employee_salary es
where (emp_id, effective_from) in (
	select emp_id, max(effective_from)
	from employee_salary
	group by 1)

--вывести в виде строки значения грейдов в которые попадают текущие оклады сотрудников

select es.emp_id, es.salary, string_agg(gs.grade::text, ', ')
from employee_salary es
left join grade_salary gs on es.salary between gs.min_salary and gs.max_salary
where (emp_id, effective_from) in (
	select emp_id, max(effective_from)
	from employee_salary
	group by 1)
group by 1, 2

--вывести количество сотрудников у которых было изменение оклада на 25%

select count(distinct emp_id)
from (
	select emp_id, salary,
		abs((salary * 100 / lag(salary) over (partition by emp_id order by effective_from)) - 100)
	from employee_salary es)
where abs = 25

select 150 - 120