insert into analysis.tmp_rfm_frequency (user_id, frequency)
SELECT --explain analyze--(cost=388.81..406.31) (actual time=552.717..564.999)
    u.id AS user_id,
    ntile(5) OVER (ORDER BY count(o.order_id) NULLS FIRST) AS recency
FROM 
    analysis.users AS u
LEFT JOIN
    analysis.orders AS o 
        ON u.id = o.user_id
        AND o.status = (SELECT id FROM analysis.orderstatuses WHERE key = 'Closed')
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
GROUP BY u.id
order by user_id;

--solution v2.0
with cte as (
select 
	u2.id,
	row_number() over(order by qnty desc nulls last) as qnty_rank
from users u2
left join (
	select 
		u.id,
  		count(o.order_id) as qnty
	from users u
	left join orders o on o.user_id = u.id
	left join orderstatuses o2 on o2.id = o.status
	where o2."key" = 'Closed' and extract ('year' from o.order_ts) = 2022
	group by u.id
	) r on u2.id = r.id)
select 
	id,
	case 
		when qnty_rank <= (select count(1) from users)/5 then 5
		when qnty_rank > (select count(1) from users)/5 
			and qnty_rank <= 2*(select count(1) from users)/5 then 4
		when qnty_rank > 2*(select count(1) from users)/5 
			and qnty_rank <= 3*(select count(1) from users)/5 then 3
		when qnty_rank > 3*(select count(1) from users)/5 
			and qnty_rank <= 4*(select count(1) from users)/5 then 2
		when qnty_rank >= 4*(select count(1) from users)/5 then 1
	end as frequency
from cte
order by id;