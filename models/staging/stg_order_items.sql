select
    cast(order_id as integer)           as order_id,
    cast(line_number as integer)        as line_number,
    cast(product_id as integer)         as product_id,
    cast(quantity as integer)           as quantity,
    cast(unit_price as decimal(10, 2))  as unit_price,
    cast(quantity * unit_price as decimal(12, 2)) as line_amount
from {{ ref('raw_order_items') }}
