--pareto analysis of revenue

with revenue as (
select
	s.sku_id ,
	sum(s.net_revenue ) as total_revenue
from sales s 
group by s.sku_id 
),
revenue_rank  as ( 
select 
	sku_id,
	total_revenue,
	rank() over (order by total_revenue desc) as revenue_rank
from revenue 
),
cummulative_revenue as ( 
select
	sku_id, 
	total_revenue,
	revenue_rank,
	sum(total_revenue ) over( order by revenue_rank desc ) cummulative_total,
	sum(total_revenue ) over () as grand_total
from revenue_rank 
),
paretor_percentage as (select
	sku_id ,
	total_revenue ,
	revenue_rank ,
	cummulative_total ,
	round( cummulative_total/ grand_total , 2) as paretor_percentage
from cummulative_revenue 
),
total_return as (select 
	sku_id,
	sum(returned_flag) *1.0 / count(*) as total_return
from sales s 
group by s.sku_id
),
supplier_reliability as (
select
	po.sku_id ,
	round(avg(case
			when delivery_date <= promised_delivery_date then 1 else 0
	end
	), 2) as supplier_reliability_score
from purchase_orders po
group by po.sku_id 
),
stock as (
select  
	sku_id,
	max(di.current_stock ) as current_stock,
	max(di.reorder_point ) as reorder_point
from daily_inventory di 
group by di.sku_id 
)
select  
	p.sku_id, 
	p.total_revenue,
	p.revenue_rank,
	cummulative_total,
	p.paretor_percentage,
	t.total_return,
	sr.supplier_reliability_score,
	case
		when s.current_stock > reorder_point then 'good' else 'urgent restock'
	end as stock_health
from paretor_percentage  p 
left join total_return t
on p.sku_id = t.sku_id
left join supplier_reliability sr
on p.sku_id = sr.sku_id 
left join stock s
on p.sku_id = s.sku_id 
where p.paretor_percentage  <= 0.8;