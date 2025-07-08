

with validation as (
    select
        spend_inminor as value_field
    from main."stg_funnel_spend"
),

validation_errors as (
    select
        value_field
    from validation
    where value_field <= 0
)

select *
from validation_errors

