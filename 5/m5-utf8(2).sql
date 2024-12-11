--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
SELECT *, row_number() over(order by payment_date)
from payment

select *, dense_rank() over(partition by customer_id order by payment_date)
FROM payment

select payment_id, customer_id, staff_id, rental_id, amount, payment_date, 
	sum(amount) over(partition by customer_id order by payment_date)
from payment
order by customer_id, payment_date, amount

select *, dense_rank() over(partition by customer_id order by amount desc)
from payment

SELECT customer_id, payment_id, payment_date,
	row_number() over(order by payment_date),
	dense_rank() over(partition by customer_id order by payment_date),
	sum(amount) over(partition by customer_id order by payment_date, amount),
	dense_rank() over(partition by customer_id order by amount desc)
FROM payment p 
order by 1, 7, 3


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.
select customer_id, payment_id, payment_date, amount,
	lag(amount, 1, 0) over(partition by customer_id order by payment_date) last_amount
from payment




--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select customer_id, payment_id, payment_date, amount,
	(amount - (lead(amount, 1, 0) over(partition by customer_id order by payment_date))) difference
from payment




--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select customer_id, payment_id, payment_date, amount
from (select *, first_value(payment_date) over(partition by customer_id order by payment_date desc)
	from payment p)
where payment_date = first_value


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
select staff_id, to_char(payment_date, 'dd.mm.yyyy') payment_date, 
	sum(amount) over(partition by staff_id, payment_date::date order by payment_date::date) sum_amount,
	sum(amount) over(partition by staff_id order by payment_date::date)
from  payment p
where payment_date::date between '2005-08-01' and '2005-08-31'
order by staff_id


--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
select customer_id, payment_date, row_number 
from (select *, row_number() over(order by payment_date) from payment p 
	where payment_date::date = '2005-08-20') r
where row_number % 100 = 0
order by payment_date


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
select distinct c3.country, 
	first_value(concat(c.first_name, ' ', c.last_name)) over(partition by c3.country_id order by count desc),
	first_value(concat(c.first_name, ' ', c.last_name)) over(partition by c3.country_id order by sum desc),
	first_value(concat(c.first_name, ' ', c.last_name)) over(partition by c3.country_id order by first_value desc)
from customer c
join address a using(address_id)
join city c2 using(city_id)
join country c3 using(country_id)
join (select r.customer_id, 
		  count(r.rental_id) over(partition by r.customer_id), 
		  first_value(r.rental_date) over(partition by r.customer_id order by r.rental_date desc) 
	  from rental r) r on r.customer_id = c.customer_id
join (select p.customer_id, sum(p.amount) from payment p group by p.customer_id) p on p.customer_id  = c.customer_id
order by c3.country

