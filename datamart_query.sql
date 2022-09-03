insert into analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
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

--the first 10 rows request
select * from dm_rfm_segments drs
order by user_id
limit 10;

--the first 10 rows
0	1	3	4
1	4	3	3
2	2	3	5
3	2	3	3
4	4	3	3
5	5	5	5
6	1	3	5
7	4	2	2
8	1	2	3
9	1	2	2