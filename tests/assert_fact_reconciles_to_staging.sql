-- The fact table must contain every order line and the same total amount as staging.
with staging as (
    select count(*) as line_count, sum(line_amount) as amount from {{ ref('stg_order_items') }}
),
fact as (
    select count(*) as line_count, sum(line_amount) as amount from {{ ref('fct_order_items') }}
)
select *
from staging, fact
where staging.line_count != fact.line_count
   or abs(staging.amount - fact.amount) > 0.01
