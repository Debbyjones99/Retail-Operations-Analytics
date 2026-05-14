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
	ld.lead_time,
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
	supplier_risk,
	rank() over(order by supplier_risk desc) high_risk
from supplier_risk ;