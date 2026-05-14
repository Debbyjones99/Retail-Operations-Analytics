-- customer lifetime value vs sku profitability 

 with customer_ltv as (
 select 
 	sum(net_revenue) as total_revenue,
 	s.customer_segment 
 from sales s 
group by s.customer_segment
), 
 sku_contribution as (
 select 
 	sku_id ,
 	customer_segment,
 	sum(net_revenue) as sku_revenue
from sales
group by sku_id, customer_segment
),
contribution_ratio as (
select
	sc.customer_segment ,
	sc.sku_id,
	sc.sku_revenue ,
	cl.total_revenue,
	round(sc.sku_revenue / cl.total_revenue, 2) as contribution_ratio  
from sku_contribution sc
join customer_ltv as cl
on sc.customer_segment = cl.customer_segment
)
select
	customer_segment,
	sku_id,
	sku_revenue,
	total_revenue,
	contribution_ratio,
	rank() over (order by contribution_ratio desc)
from contribution_ratio;
