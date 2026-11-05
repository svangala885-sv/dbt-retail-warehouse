select
    cast(customer_id as integer)        as customer_id,
    trim(first_name)                    as first_name,
    trim(last_name)                     as last_name,
    lower(trim(email))                  as email,
    upper(trim(state))                  as state,
    cast(updated_at as timestamp)       as updated_at
from {{ ref('raw_customer_changes') }}
