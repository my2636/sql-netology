--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze --..67.50 0.322 ms
SELECT film_id, title, special_features
FROM film
where array['Behind the Scenes'] && special_features


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze -- ..67.50 0.321 ms
SELECT film_id, title, special_features
FROM film
where array['Behind the Scenes'] <@ special_features

explain analyze --..77.50 0.289 ms
SELECT film_id, title, special_features
FROM film
where 'Behind the Scenes' = some(special_features)


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
explain analyze -- ..646.34
with cte as (SELECT film_id, title, special_features
FROM film
where array['Behind the Scenes'] && special_features)
select r.customer_id, count(cte.film_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id
join cte on cte.film_id = i.film_id
group by r.customer_id


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
explain analyze -- ..646.34
select r.customer_id, count(f.film_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id
join (SELECT film_id, title, special_features
	FROM film
	where array['Behind the Scenes'] && special_features) f on f.film_id = i.film_id
group by r.customer_id


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view rental_count_check as (
select r.customer_id, count(f.film_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id
join (SELECT film_id, title, special_features
	FROM film
	where array['Behind the Scenes'] && special_features) f on f.film_id = i.film_id
group by r.customer_id
)

refresh materialized view rental_count_check


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
с операторами && и <@
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.
оба варианта затрачивают одинаковое кол-во ресурсов




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
select p.staff_id, f.film_id, f.title, p.amount, p.first_value, c.last_name as customer_last_name, c.first_name as customer_first_name
from (select staff_id, rental_id, customer_id, amount, payment_date, first_value(payment_date) over (partition by staff_id order by payment_date)
	from payment) p
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id  = r.inventory_id
join film f on f.film_id = i.film_id
join customer c on c.customer_id = p.customer_id
where p.payment_date = p.first_value


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день







