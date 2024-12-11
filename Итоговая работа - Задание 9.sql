--	9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
-- Для поиска расстояния между двумя точками на поверхности Земли используется модуль earthdistance.
-- Для работы модуля earthdistance необходимо предварительно установить модуль cube.
-- Установка модулей происходит через команду: create extension название_модуля. 

select min(round(tf.amount / (earth_distance(ll_to_earth(a.latitude, a.longitude), ll_to_earth(a2.latitude, a2.longitude))  / 1000)::numeric, 2))
from flights f
join ticket_flights tf ON tf.flight_id = f.flight_id
join (select longitude, latitude, airport_code from airports) a on a.airport_code = f.departure_airport
join (select longitude, latitude, airport_code from airports) a2 on a2.airport_code = f.arrival_airport