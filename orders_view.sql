--updated view for "orders" with "orderstatuslog"
create or replace view orders as 
with cte as (
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