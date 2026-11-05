select
    {{ surrogate_key(['product_id']) }} as product_sk,
    product_id,
    product_name,
    category,
    list_price
from {{ ref('stg_products') }}
