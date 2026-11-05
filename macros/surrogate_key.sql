{#- Deterministic surrogate key from one or more columns (no package dependency). -#}
{% macro surrogate_key(columns) -%}
    md5(concat_ws('|', {% for c in columns %}coalesce(cast({{ c }} as varchar), '_null_'){% if not loop.last %}, {% endif %}{% endfor %}))
{%- endmacro %}
