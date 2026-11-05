-- SCD2 validity windows for a customer must not overlap.
select a.customer_id, a.customer_sk, b.customer_sk as overlapping_sk
from {{ ref('dim_customers') }} as a
inner join {{ ref('dim_customers') }} as b
    on a.customer_id = b.customer_id
   and a.customer_sk != b.customer_sk
   and a.valid_from < coalesce(b.valid_to, timestamp '9999-12-31')
   and b.valid_from < coalesce(a.valid_to, timestamp '9999-12-31')
