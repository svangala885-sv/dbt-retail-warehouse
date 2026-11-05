select
    d.year_month,
    c.state,
    p.category,
    count(distinct f.order_id)              as orders,
    sum(f.quantity)                         as units,
    cast(sum(f.line_amount) as decimal(14, 2)) as revenue
from {{ ref('fct_order_items') }} as f
inner join {{ ref('dim_date') }} as d on d.date_day = f.order_date
left join {{ ref('dim_customers') }} as c on c.customer_sk = f.customer_sk
left join {{ ref('dim_products') }} as p on p.product_sk = f.product_sk
where f.is_revenue
group by 1, 2, 3
