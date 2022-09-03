insert into analysis.tmp_rfm_recency (user_id, recency)
SELECT --explain analyze--(cost=388.81..406.31) (actual time=552.717..564.999)
    u.id AS user_id,
    ntile(5) OVER (ORDER BY max(o.order_ts) NULLS FIRST) AS recency
FROM 
    analysis.users AS u
LEFT JOIN
    analysis.orders AS o 
        ON u.id = o.user_id
        AND o.status = (SELECT id FROM analysis.orderstatuses WHERE key = 'Closed')
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY u.id;

--Solution V2.0
--explain analyze--(cost=537.71..620.21) (actual time=1018.345..1197.697)
with cte as (
select 
	u2.id,
	row_number() over(order by last_date desc nulls last) as numb
from users u2
left join (
	select 
		u.id,
		max(o.order_ts) as last_date
	from users u
	left join orders o on o.user_id = u.id
	left join orderstatuses o2 on o2.id = o.status
	where o2."key" = 'Closed' and extract ('year' from o.order_ts) = 2022
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
	end as recency
from cte;