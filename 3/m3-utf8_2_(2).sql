--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--решения по заданиям 2.3, 3 и 4.
--В 1 и 2 дополнительных заданиях ложные джойны по неуникальным значениям.


--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
SELECT concat(last_name, ' ', first_name) "Customer name", address, city, country
FROM customer c
JOIN address a ON c.address_id = a.address_id
join city ci on a.city_id = ci.city_id
join country co on ci.country_id = co.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select store_id "ID магазина", count(store_id) "Количество покупателей"
from customer c
group by 1


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select store_id "ID магазина", count(*) "Количество покупателей"
from customer c
group by 1
having count(*) > 300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select s.store_id "ID магазина", count(c.customer_id) "Количество покупателей", city "Город", concat(st.last_name, ' ', st.first_name) "Имя сотрудника"
from store s
join customer c on c.store_id = s.store_id
join address a on s.address_id = a.address_id
join city c2 on a.city_id = c2.city_id
join staff st on s.manager_staff_id = st.staff_id
group by 1, c2.city_id, st.staff_id 
having count(*) > 300


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat(c.last_name, ' ', c.first_name) "Фамилия и имя покупателя", count(rental_id) "Количество фильмов" 
from rental r
join customer c on r.customer_id = c.customer_id
group by c.customer_id
order by 2 desc
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select concat(last_name, ' ', first_name) "Фамилия и имя покупателя", count(r.rental_id) "Количество фильмов", round(sum(p.amount)) "Общая стоимость платежей", min(p.amount) "Минимальная стоимость платежа", max(p.amount) "Максимальная стоимость платежа"
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
group by c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
select c.city "Город 1", c2.city "Город 2"
from city c
cross join city c2
where c.city != c2.city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
select customer_id "ID покупателя", round(avg(return_date::date - rental_date::date), 2)  "Среднее количество дней на возврат"
from rental r
group by customer_id
order by 1




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
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


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.
select f.title "Название фильма", f.rating "Рейтинг", fc.string_agg "Жанр", f.release_year "Год выпуска", l."name" "Язык", count(r.rental_id) "Количество аренд", sum(p.amount) "Общая стоимость аренды"
from film f
left join inventory i on i.film_id = f.film_id
left join rental r using(inventory_id)
left join (
	select fc.film_id, string_agg(c.name, ', ') 
	from film_category fc
	join category c on c.category_id = fc.category_id
	group by fc.film_id
	) fc on fc.film_id = f.film_id
left join "language" l on f.language_id = l.language_id
left join payment p on r.rental_id = p.rental_id
where i.inventory_id  is null
group by f.film_id, l.language_id, fc.string_agg


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select staff_id, count(payment_id),
(case when count(payment_id) > 7300 then 'Да' else 'Нет' end) as "Премия"
from payment p
group by staff_id


