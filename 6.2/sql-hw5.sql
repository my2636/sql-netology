explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

-- 		лишние алиасы для полей в подзапросах, неиспользуемые
-- 		во всех подзапросах выводятся лишние поля через * + дубли выведены с алиасом
-- 		3 full outer join-а вместо inner join, добавляет лишние строки, не имеющие совпадений в присоединяемой таблице.
-- 		в первом select вместо оконной функции можно использовать group by, если есть возможность не использовать оконную функцию, лучше не использовать
-- 		джойн вложенных подзапросов вместо обычных таблиц, во вложенных подзапросах нет необходимости, данные в них никак не обрабатываются
-- 		сортировка по count в основном запросе не нужна, нет сортировки по customer_id как в ожидаемом результате
-- 		вместо unnest(f.special_features) во втором подзапросе + where ren.sfs like '%Behind the Scenes%' в основном запросе нужно использовать операторы или функции some/any 
-- (пример where array['Behind the Scenes'] && special_features). Like даст неверный результат если в массиве pecial_features будут похожие элементы, например Behind the Scenes789

explain analyze
select r.customer_id, count(f.film_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id
join (SELECT film_id, title, special_features
	FROM film
	where array['Behind the Scenes'] && special_features) f on f.film_id = i.film_id
group by r.customer_id

HashAggregate  (cost=640.35..646.34 rows=599 width=10) (actual time=7.008..7.056 rows=599 loops=1) -- в этой строке выполнена операция HashAggregate - сканирование всех строк результата, помещение в хэш-таблицу по ключу для группировки, возвращение строк по ключу. 
-- Предварительная оценка без факт. выполнения запроса: cost=640.35 - стоимость выполненных операций до получения данных по запросу (приблизительная) ..646.34 - общая стоимость выполнения всего запроса
-- Оценка после факт. выполнения запроса: actual time=7.008 время выполнения операций до получения данных, ..7.056 - общее время выполнения всех предшествующих операций + HashAggregate, rows=599 - получено 599 записей, loops=1 кол-во раз выполнения операции  HashAggregate
  Group Key: r.customer_id -- выбран ключ для группировки - r.customer_id
  Batches: 1  Memory Usage: 105kB -- Batches не больше 1, значит для выполнения HashAggregate хватило оперативной памяти, диск использовать не пришлось. Использовано 105kB памяти. 
  ->  Hash Join  (cost=202.30..597.19 rows=8632 width=6) (actual time=1.020..6.071 rows=8608 loops=1) -- узел соединения хэшированием (film и inventory)
      Hash Cond: (i.film_id = film.film_id) -- соединение результата сканирования film с inventory (хэш-таблица по film)
        ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=0.640..4.165 rows=16044 loops=1) -- узел соединение хэшированием (inventory и rental)
            Hash Cond: (r.inventory_id = i.inventory_id) -- соединение результатов сканирования inventory и rental (хэш-таблица по inventory)
              ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.004..0.722 rows=16044 loops=1) -- сканирование rental, получение набора строк
              ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.615..0.616 rows=4581 loops=1) -- результат сканирования inventory добавлен в хэш-таблицу
                  Buckets: 8192  Batches: 1  Memory Usage: 234kB
                  ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.005..0.298 rows=4581 loops=1) -- сканирование inventory, получение набора строк
        ->  Hash  (cost=67.50..67.50 rows=538 width=4) (actual time=0.373..0.373 rows=538 loops=1) -- результат сканирования film добавлен в хэш-таблицу
            Buckets: 1024  Batches: 1  Memory Usage: 27kB -- при добавлении в хэш использовано 1024 корзины в хэше, использована только оперативная память (27kB)
             ->  Seq Scan on film  (cost=0.00..67.50 rows=538 width=4) (actual time=0.012..0.330 rows=538 loops=1) -- сканирует все записи таблицы film с применением фильтра
                    Filter: ('{"Behind the Scenes"}'::text[] && special_features) -- условие для фильтрации
                    Rows Removed by Filter: 462 -- после применения фильтра отброшено 462 записи
Planning Time: 0.349 ms
Execution Time: 7.127 ms 

