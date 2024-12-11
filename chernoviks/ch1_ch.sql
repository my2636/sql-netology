SELECT substring(city, 0, strpos(city, '-'))
FROM public.city;

SELECT substring(city, strpos(city, '-') +1)
FROM public.city;

SELECT substring(city, strpos(city, ' ') +1)
FROM public.city;

SELECT
concat(upper(left(city, 1)), lower(substring(city, 2)))
FROM public.city;

SELECT
split_part(city, '-', 1),
split_part(city, '-', 2),
split_part(city, '-', 3),
split_part(city, ' ', 4),
split_part(city, ' ', 5)
FROM public.city;

select

split_part(city, '-', 1),
split_part(city, '-', 2),
split_part(city, '-', 3),
split_part(city, ' ', 2),
split_part(city, ' ', 3),
split_part(city, ' ', 4),
split_part(city, ' ', 5)
FROM public.city;






select 
concat(upper(left(split_part(city, '-', 1), 1)), substring(split_part(city, '-', 1), 2)),
concat('-',upper(left(split_part(city, '-', 2), 1)), substring(split_part(city, '-', 2), 2)),
concat(upper(left(split_part(city, ' ', 2), 1)), substring(split_part(city, ' ', 2), 2)),
concat(upper(left(split_part(city, ' ', 3), 1)), substring(split_part(city, ' ', 3), 2)),
concat(upper(left(split_part(city, ' ', 4), 1)), substring(split_part(city, ' ', 4), 2)),
concat(upper(left(split_part(city, ' ', 5), 1)), substring(split_part(city, ' ', 5), 2))
from city

substring(city, strpos(city, '-') +1)
FROM public.city;


select concat(upper(left(city, 1)), substring(city, 2))
from (select city from city where city not like '%-%'and city not like '% %')
union
select concat(
concat(upper(left(split_part(city, '-', 1), 1)), substring(split_part(city, '-', 1), 2)), 
concat('-',upper(left(split_part(city, '-', 2), 1)), substring(split_part(city, '-', 2), 2))
)
from (select city from city where city like '%-%'and city not like '% %')
union 
select concat(
concat(
upper(left(split_part(city, ' ', 1), 1)), substring(split_part(city, ' ', 1), 2)
),
concat(' ', upper(left(split_part(city, ' ', 2), 1)), substring(split_part(city, ' ', 2), 2)),
concat(' ', upper(left(split_part(city, ' ', 3), 1)), substring(split_part(city, ' ', 3), 2)),
concat(' ', upper(left(split_part(city, ' ', 4), 1)), substring(split_part(city, ' ', 4), 2)),
concat(' ', upper(left(split_part(city, ' ', 5), 1)), substring(split_part(city, ' ', 5), 2))
)
from (select city from city where city like '% %' and city not like '%-%')



s
select character_length('Привет мир')

select char_length('Привет мир')

select substring('Привет мир' from 4 for 3)

