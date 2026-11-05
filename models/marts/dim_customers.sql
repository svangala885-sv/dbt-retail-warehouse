-- SCD Type 2 customer dimension built from the source change log.
-- Each change opens a version; the next change for the same customer closes it.
with changes as (
    select * from {{ ref('stg_customer_changes') }}
),

deduped as (
    -- identical consecutive rows (no attribute change) do not create a new version
    select *
    from (
        select
            *,
            lag(email) over w as prev_email,
            lag(state) over w as prev_state,
            lag(last_name) over w as prev_last_name
        from changes
        window w as (partition by customer_id order by updated_at)
    ) t
    where prev_email is null
       or email is distinct from prev_email
       or state is distinct from prev_state
       or last_name is distinct from prev_last_name
),

versions as (
    select
        *,
        lead(updated_at) over (partition by customer_id order by updated_at) as next_change_at
    from deduped
)

select
    {{ surrogate_key(['customer_id', 'updated_at']) }} as customer_sk,
    customer_id,
    first_name,
    last_name,
    email,
    state,
    updated_at          as valid_from,
    next_change_at      as valid_to,
    next_change_at is null as is_current
from versions
