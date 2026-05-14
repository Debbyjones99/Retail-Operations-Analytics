
--sku- level profitabbility after landed costs

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

-- supplier risk index
with avg_delivery_dalay as (
select 
	po.supplier_id ,
	round(avg(po.delivery_date - po.promised_delivery_date ), 2)as delivery_delay
from purchase_orders po 
group by po.supplier_id 
),
late_po as (
select
	po.supplier_id ,
	count(*) as late_po
from purchase_orders po 
where po.promised_delivery_date < po.delivery_date 
group by po.supplier_id 
),
lead_time as (
select 
	po.supplier_id ,
	round(avg(po.delivery_date - po.po_date), 2) as lead_time
from purchase_orders po 
group  by po.supplier_id 
),
supplier_risk as (select 
	ad.supplier_id,
	ad.delivery_delay ,
	l.late_po,
	l d.lead_time,
	ad.delivery_delay * 0.4 + l.late_po *0.3+ ld.lead_time *0.3 as supplier_risk
from avg_delivery_dalay as ad
join late_po l 
on ad.supplier_id = l.supplier_id
join lead_time as ld
on ad.supplier_id = ld.supplier_id
)
select  
	supplier_id ,
	delivery_delay ,
	late_po ,
	lead_time,
	rank() over(order by supplier_risk desc) high_risk
from supplier_risk ;


-- channel allocation efficiency 

with pivoted_table as (
select 
	di.sku_id ,
	'Amazon' as channel,
	di.amazon_allocated as allocated_stock
from daily_inventory di 
union all 

select 
	di.sku_id ,
	'TikTokShop',
	di.tiktokshop_allocated 
from daily_inventory di 

union all

select 
	di.sku_id ,
	'Zalora',
	di.zalora_allocated 
from daily_inventory di 

union all 

select 
	di.sku_id ,
	'retail',
	di.retail_stock 
from daily_inventory di 
),
allocated_stock as (
select  
	sku_id ,
	channel ,
	sum(allocated_stock ) as allocated_stock
from pivoted_table 
group by sku_id , channel 
),
sales_per_channel as (
select 
	sku_id,
	case when channel in ('Retail_Flagship', 'Retail_Kiosk') then 'retail' else channel end as channel,
	sum(quantity) as total_sales
from sales
group by sku_id, case when channel in ('Retail_Flagship', 'Retail_Kiosk') then 'retail' else channel end 
)
select
	a.sku_id,
	a.channel,
	a.allocated_stock,
	s.total_sales
from allocated_stock a
left join sales_per_channel s
on a.sku_id = s.sku_id
and a.channel = s.channel;

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

-- inventory aging & self life risk

with product_age as (
select 
	t.sku_id, 
	round(t.stock_age_days *30.0, 0) as stock_age_monthly,
	p.shelf_life_months,
	t.current_stock * p.default_price as revenue_loss
from inventory_snapshots t 
left join products p 
on t.sku_id  =  p.sku_id
where p.shelf_life_months is not null
),
risk_of_obsolescence as (
select 
	p.sku_id ,
	p.stock_age_monthly ,
	p.shelf_life_months,
	revenue_loss
from product_age p
where p.stock_age_monthly > p.shelf_life_months 
)
select 
	sku_id ,
	stock_age_monthly ,
	shelf_life_months ,
	case 
		when stock_age_monthly > shelf_life_months then 'obsolete risk'
		when stock_age_monthly > shelf_life_months *0.8 then 'at risk' else 'healthy'
	end as risk_identification,
	revenue_loss ,
	rank() over (order by revenue_loss  desc) as revenue_loss_rank
from risk_of_obsolescence
;


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
from contribution_ratio


-- predictive stockout by date 

 with sales_rate as (
 select 
 	  sku_id ,
 	  round(avg(daily_sales), 2) as avg_daily_sales
 from daily_inventory
group by sku_id
),
latest_stock as (
select distinct on( sku_id)
	sku_id,
	snapshot_date,
	current_stock,
	safety_stock
from daily_inventory
order by sku_id, snapshot_date
),
stockout_date as (
select 
	l.sku_id,
	l.snapshot_date ,
	l.current_stock,
	l.safety_stock,
	s.avg_daily_sales,
	round((l.current_stock - l. safety_stock)/s.avg_daily_sales , 2)as days_to_skockout
from latest_stock l
join sales_rate s
on l.sku_id = s.sku_id
)
select 
	sku_id,
	current_stock,
	safety_stock,
	avg_daily_sales,
	snapshot_date,
	snapshot_date + (days_to_skockout * interval '1 day')
	days_to_skockout,
	case 
		when days_to_skockout <= 3 then 'urgent'
		when days_to_skockout <=  7 then 'warning'
		else 'safe'
	end as stockout_reviews
from stockout_date 















--sku- level profitabbility after landed costs

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

-- supplier risk index
with avg_delivery_dalay as (
select 
	po.supplier_id ,
	round(avg(po.delivery_date - po.promised_delivery_date ), 2)as delivery_delay
from purchase_orders po 
group by po.supplier_id 
),
late_po as (
select
	po.supplier_id ,
	count(*) as late_po
from purchase_orders po 
where po.promised_delivery_date < po.delivery_date 
group by po.supplier_id 
),
lead_time as (
select 
	po.supplier_id ,
	round(avg(po.delivery_date - po.po_date), 2) as lead_time
from purchase_orders po 
group  by po.supplier_id 
),
supplier_risk as (select 
	ad.supplier_id,
	ad.delivery_delay ,
	l.late_po,
	l d.lead_time,
	ad.delivery_delay * 0.4 + l.late_po *0.3+ ld.lead_time *0.3 as supplier_risk
from avg_delivery_dalay as ad
join late_po l 
on ad.supplier_id = l.supplier_id
join lead_time as ld
on ad.supplier_id = ld.supplier_id
)
select  
	supplier_id ,
	delivery_delay ,
	late_po ,
	lead_time,
	rank() over(order by supplier_risk desc) high_risk
from supplier_risk ;


-- channel allocation efficiency 

with pivoted_table as (
select 
	di.sku_id ,
	'Amazon' as channel,
	di.amazon_allocated as allocated_stock
from daily_inventory di 
union all 

select 
	di.sku_id ,
	'TikTokShop',
	di.tiktokshop_allocated 
from daily_inventory di 

union all

select 
	di.sku_id ,
	'Zalora',
	di.zalora_allocated 
from daily_inventory di 

union all 

select 
	di.sku_id ,
	'retail',
	di.retail_stock 
from daily_inventory di 
),
allocated_stock as (
select  
	sku_id ,
	channel ,
	sum(allocated_stock ) as allocated_stock
from pivoted_table 
group by sku_id , channel 
),
sales_per_channel as (
select 
	sku_id,
	case when channel in ('Retail_Flagship', 'Retail_Kiosk') then 'retail' else channel end as channel,
	sum(quantity) as total_sales
from sales
group by sku_id, case when channel in ('Retail_Flagship', 'Retail_Kiosk') then 'retail' else channel end 
)
select
	a.sku_id,
	a.channel,
	a.allocated_stock,
	s.total_sales
from allocated_stock a
left join sales_per_channel s
on a.sku_id = s.sku_id
and a.channel = s.channel;

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

-- inventory aging & self life risk

with product_age as (
select 
	t.sku_id, 
	round(t.stock_age_days *30.0, 0) as stock_age_monthly,
	p.shelf_life_months,
	t.current_stock * p.default_price as revenue_loss
from inventory_snapshots t 
left join products p 
on t.sku_id  =  p.sku_id
where p.shelf_life_months is not null
),
risk_of_obsolescence as (
select 
	p.sku_id ,
	p.stock_age_monthly ,
	p.shelf_life_months,
	revenue_loss
from product_age p
where p.stock_age_monthly > p.shelf_life_months 
)
select 
	sku_id ,
	stock_age_monthly ,
	shelf_life_months ,
	case 
		when stock_age_monthly > shelf_life_months then 'obsolete risk'
		when stock_age_monthly > shelf_life_months *0.8 then 'at risk' else 'healthy'
	end as risk_identification,
	revenue_loss ,
	rank() over (order by revenue_loss  desc) as revenue_loss_rank
from risk_of_obsolescence
;


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
from contribution_ratio


-- predictive stockout by date 

 with sales_rate as (
 select 
 	  sku_id ,
 	  round(avg(daily_sales), 2) as avg_daily_sales
 from daily_inventory
group by sku_id
),
latest_stock as (
select distinct on( sku_id)
	sku_id,
	snapshot_date,
	current_stock,
	safety_stock
from daily_inventory
order by sku_id, snapshot_date
),
stockout_date as (
select 
	l.sku_id,
	l.snapshot_date ,
	l.current_stock,
	l.safety_stock,
	s.avg_daily_sales,
	round((l.current_stock - l. safety_stock)/s.avg_daily_sales , 2)as days_to_skockout
from latest_stock l
join sales_rate s
on l.sku_id = s.sku_id
)
select 
	sku_id,
	current_stock,
	safety_stock,
	avg_daily_sales,
	snapshot_date,
	snapshot_date + (days_to_skockout * interval '1 day')
	days_to_skockout,
	case 
		when days_to_skockout <= 3 then 'urgent'
		when days_to_skockout <=  7 then 'warning'
		else 'safe'
	end as stockout_reviews
from stockout_date 
















































 

































 