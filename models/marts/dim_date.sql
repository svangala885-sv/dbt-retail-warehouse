-- Calendar dimension (DuckDB generate_series; on Snowflake use a generator/row_number pattern).
with days as (
    select cast(d as date) as date_day
    from generate_series(timestamp '2025-01-01', timestamp '2026-12-31', interval 1 day) as t(d)
)
select
    date_day,
    year(date_day)                          as year,
    quarter(date_day)                       as quarter,
    month(date_day)                         as month,
    strftime(date_day, '%Y-%m')             as year_month,
    dayofweek(date_day)                     as day_of_week,
    dayofweek(date_day) in (0, 6)           as is_weekend
from days
