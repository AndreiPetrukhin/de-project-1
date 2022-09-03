--updated view for "orders" with "orderstatuslog"
create or replace view orders as 
with cte as (--explain analyze --(cost=3696.54..3967.04) (actual time=1793.253..2044.182)
select
	order_id,
	status_id
from (
select 
	*,
	row_number() over(partition by o.order_id order by o.dttm desc) as date_rank
from production.orderstatuslog o) fin
where date_rank = 1)
select 
	po.order_id,
	po.order_ts,
	po.user_id,
	po.bonus_payment,
	po.payment,
	po."cost",
	po.bonus_grant,
	cte.status_id as status
from production.orders po
left join cte on cte.order_id = po.order_id;

--explain analyze --(cost=4317.27..4617.09) (actual time=2523.054..2606.071)
SELECT 
    DISTINCT o.order_id,
    o.order_ts,
    o.user_id,
    o.bonus_payment,
    o.payment,
    o."cost",
    o.bonus_grant,
    LAST_VALUE(p.status_id) OVER (PARTITION BY p.order_id ORDER BY dttm ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS status --ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    --FIRST_VALUE(p.status_id) OVER (PARTITION BY p.order_id ORDER BY dttm desc ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS status --ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
FROM 
    production.orders AS o
JOIN
    production.orderstatuslog AS p
        USING(order_id);