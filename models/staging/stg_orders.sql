select
    cast(order_id as integer)           as order_id,
    cast(customer_id as integer)        as customer_id,
    cast(ordered_at as timestamp)       as ordered_at,
    lower(status)                       as status
from {{ ref('raw_orders') }}
