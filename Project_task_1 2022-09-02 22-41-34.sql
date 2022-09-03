SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname = 'analysis';

select * from orderstatuses o;


with cte as (
select 
	u2.id,
	row_number() over(order by last_date desc nulls last) as numb,
	row_number() over(order by qnty desc nulls last) as qnty_rank,
	row_number() over(order by value desc nulls last) as value_rank
from users u2
left join (
	select 
		u.id,
		max(o.order_ts) as last_date,
  		count(o.order_id) as qnty,
  		sum(o.payment) as value
	from users u
	left join orders o on o.user_id = u.id
	left join orderstatuses o2 on o2.id = o.status
	where o2."key" = 'Closed'
	group by u.id
	) r on u2.id = r.id)
select 
	id,
	case 
		when numb <= (select count(1) from users)/5 then 5
		when numb > (select count(1) from users)/5 
			and numb <= 2*(select count(1) from users)/5 then 4
		when numb > 2*(select count(1) from users)/5 
			and numb <= 3*(select count(1) from users)/5 then 3
		when numb > 3*(select count(1) from users)/5 
			and numb <= 4*(select count(1) from users)/5 then 2
		when numb >= 4*(select count(1) from users)/5 then 1
	end as recency,
	case 
		when qnty_rank <= (select count(1) from users)/5 then 5
		when qnty_rank > (select count(1) from users)/5 
			and qnty_rank <= 2*(select count(1) from users)/5 then 4
		when qnty_rank > 2*(select count(1) from users)/5 
			and qnty_rank <= 3*(select count(1) from users)/5 then 3
		when qnty_rank > 3*(select count(1) from users)/5 
			and qnty_rank <= 4*(select count(1) from users)/5 then 2
		when qnty_rank >= 4*(select count(1) from users)/5 then 1
	end as frequency,
	case 
		when value_rank <= (select count(1) from users)/5 then 5
		when value_rank > (select count(1) from users)/5 
			and value_rank <= 2*(select count(1) from users)/5 then 4
		when value_rank > 2*(select count(1) from users)/5 
			and value_rank <= 3*(select count(1) from users)/5 then 3
		when value_rank > 3*(select count(1) from users)/5 
			and value_rank <= 4*(select count(1) from users)/5 then 2
		when value_rank >= 4*(select count(1) from users)/5 then 1
	end as monetary_value
from cte;


--Дубли в данных. Фокусируемся на таблицах users, orders, orderstatuses, так как
--имеено они нужны для разработки витрины данных.
--В таблице users дублирующиеся записи отсутствуют
select 
	count(u.*) as unique_rows, --1000
	count(u2.*) as total_rows  --1000
from (select distinct * from users u) u
join (select * from users u2) u2 on u.id = u2.id;
--важно проверить отсуствуие дубликатов в колонке login, так как она не имеет ограничения уникальности
select 
	count(distinct login) as unique_rows, --1000
	count(login) as total_rows  --1000
from users u; -- дублирующиеся записи отсутствуют
--В таблице orders дублирующиеся записи отсутствуют
select 
	count(o.*) as unique_rows, --10000
	count(o2.*) as total_rows  --10000
from (select distinct * from orders o) o
join (select * from orders o2) o2 on o.order_id = o2.order_id;
--В таблице orderstatuslog дублирующиеся записи отсутствуют
select 
	count(o.*) as unique_rows, --29982
	count(o2.*) as total_rows  --29982
from (select distinct * from orderstatuslog o) o
join (select * from orderstatuslog o2) o2 on o.id = o2.id;
--В таблице orderstatuses дублирующиеся записи отсутствуют
select 
	count(o.*) as unique_rows, --5
	count(o2.*) as total_rows  --5
from (select distinct * from orderstatuses o) o
join (select * from orderstatuses o2) o2 on o.id = o2.id;
--важно проверить отсуствуие дубликатов в колонке 	key, так как она не имеет ограничения уникальности
select 
	count(distinct key) as unique_rows, --5
	count(key) as total_rows  --5
from orderstatuses o; -- дублирующиеся записи отсутствуют

--пропущенные значения в важных полях. Аналогично, фокусируемся на таблицах users, orders, 
--orderstatuses, orderstatuslog
--1. Таблица users. Важной является колонка id, которая является первичным ключом и не может принимать 
--значение null. В проверке нет необходимости.
--2. Таблица orders. Важными являются колонки order_id, user_id, status, payment, order_ts.
--order_id является первичным ключом и не может принимать значение null. В проверке нет необходимости.
--user_id не имеет внешнего ключа к таблице users(id), соответственно может содержать id несуществующих
--пользователей. не может принимать значение null
select * from orders o
left join users u on u.id = o.user_id
where u.id is null; --значение null отсутствуют --> user_id соответствуют значениям users(id)
--status не имеет внешнего ключа к таблице orderstatuses(id), соответственно может содержать id 
--несуществующих статусов. не может принимать значение null
select * from orders o
left join orderstatuses o2 on o2.id = o.status
where o2.id is null;--значение null отсутствуют --> status соответствуют значениям orderstatuses(id)
--payment не может принимать значение null и не должен ссылкаться на другие таблицы. В проверке нет необходимости.
--order_ts не может принимать значение null и не должен ссылкаться на другие таблицы. В проверке нет необходимости.
--3. Таблица orderstatuses. Важными являются колонки id, key. Не могут принимать значение null. В 
--проверке нет необходимости.

SELECT
    "ns"."nspname" AS "table_schema",
    "t"."relname" AS "table_name",
	"a"."attname" AS "column_name",
    "cnst"."conname" AS "constraint_name", pg_get_constraintdef ( "cnst"."oid" ) AS "expression",
CASE
        "cnst"."contype" 
        WHEN 'p' THEN
        'PRIMARY' 
        WHEN 'u' THEN
        'UNIQUE' 
        WHEN 'c' THEN
        'CHECK' 
        WHEN 'x' THEN
        'EXCLUDE' 
    END AS "constraint_type"
FROM
    "pg_constraint" "cnst" 
    INNER JOIN "pg_class" "t" ON "t"."oid" = "cnst"."conrelid"
    INNER JOIN "pg_namespace" "ns" ON "ns"."oid" = "cnst"."connamespace"
    LEFT JOIN "pg_attribute" "a" ON "a"."attrelid" = "cnst"."conrelid" 
    AND "a"."attnum" = ANY ( "cnst"."conkey" );

--некорректные типы данных;
--неверные форматы записей.