

with validation as (
    select
        total_purchases as value_field
    from main."dim_customer"
),

validation_errors as (
    select
        value_field
    from validation
    where value_field <= 0
)

select *
from validation_errors

