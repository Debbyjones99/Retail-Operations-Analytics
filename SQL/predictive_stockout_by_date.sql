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

