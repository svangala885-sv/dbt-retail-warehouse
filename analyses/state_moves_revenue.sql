-- Example analysis: revenue attributed to each state before and after customers moved.
select c.customer_id, c.state, c.valid_from, c.valid_to, sum(f.line_amount) as revenue
from {{ ref('fct_order_items') }} f
join {{ ref('dim_customers') }} c on c.customer_sk = f.customer_sk
where c.customer_id in (select customer_id from {{ ref('dim_customers') }} where not is_current)
group by all
order by c.customer_id, c.valid_from
