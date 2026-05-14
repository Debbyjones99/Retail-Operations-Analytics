
--sku level profitability after landed costs

with Revenue as (
select 
	sku_id,
	sum(net_revenue) as revenue
from sales
where returned_flag = 0
group  by sku_id
),
unit_cost as (
	select
	sku_id,
	avg(((po.unit_cost * po.order_qty ) +( po.freight_cost + po.duty_cost ))/ po.order_qty ) as unit_price
	from purchase_orders po 
	group by sku_id
),
order_quantity as (
	select
		sku_id,
		sum(quantity) as quantity
	from sales
	where returned_flag =0
	group by sales.sku_id 
),
total_cost as (
	select 
		o.sku_id,
		u.unit_price * o.quantity as total_cost
	from unit_cost as u
	join order_quantity o
	on o.sku_id = u.sku_id 
),
profit as (
select 
	r.sku_id ,
	r.revenue ,
	t.total_cost,
	ROUND(r.revenue - t.total_cost , 2) as profit
from Revenue r
join total_cost as t
on r.sku_id = t.sku_id 
)
select
	sku_id ,
	revenue ,
	total_cost ,
	profit,
	row_number() over (order by profit desc) as profit_rank
from profit 
limit 20;
