-- Fail if more than 1% of order lines could not be matched to a customer version.
select count(*) as unknown_lines
from {{ ref('fct_order_items') }}
having count(*) filter (where customer_sk = '-1') > 0.01 * count(*)
