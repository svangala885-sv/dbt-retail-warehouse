-- Grain: one row per order line.
-- Incremental: only orders newer than the latest loaded order are processed on re-runs.
{{
    config(
        materialized='incremental',
        unique_key='order_item_sk',
        incremental_strategy='delete+insert'
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
    {% if is_incremental() %}
    where ordered_at > (select coalesce(max(ordered_at), timestamp '1900-01-01') from {{ this }})
    {% endif %}
),

items as (
    select * from {{ ref('stg_order_items') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

products as (
    select * from {{ ref('dim_products') }}
)

select
    {{ surrogate_key(['i.order_id', 'i.line_number']) }} as order_item_sk,
    i.order_id,
    i.line_number,
    coalesce(c.customer_sk, '-1')           as customer_sk,   -- unknown member keeps totals whole
    p.product_sk,
    cast(o.ordered_at as date)              as order_date,
    o.ordered_at,
    o.status,
    i.quantity,
    i.unit_price,
    i.line_amount,
    o.status in ('completed', 'shipped')    as is_revenue
from orders as o
inner join items as i
    on i.order_id = o.order_id
left join customers as c                     -- point-in-time: version valid when the order was placed
    on c.customer_id = o.customer_id
   and o.ordered_at >= c.valid_from
   and (c.valid_to is null or o.ordered_at < c.valid_to)
left join products as p
    on p.product_id = i.product_id
