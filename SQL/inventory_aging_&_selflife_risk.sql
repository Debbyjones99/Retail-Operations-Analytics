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