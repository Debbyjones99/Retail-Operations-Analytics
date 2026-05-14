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
	coalesce(s.total_sales, 0) as total_sales
from allocated_stock a
left join sales_per_channel s
on a.sku_id = s.sku_id
and a.channel = s.channel;