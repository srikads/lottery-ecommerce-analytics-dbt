

with validation as (
    select
        purchase_amount_usd as value_field
    from main."stg_ticket_purchases"
),

validation_errors as (
    select
        value_field
    from validation
    where value_field <= 0
)

select *
from validation_errors

