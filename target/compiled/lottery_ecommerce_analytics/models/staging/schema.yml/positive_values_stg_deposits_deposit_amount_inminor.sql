

with validation as (
    select
        deposit_amount_inminor as value_field
    from main."stg_deposits"
),

validation_errors as (
    select
        value_field
    from validation
    where value_field <= 0
)

select *
from validation_errors

