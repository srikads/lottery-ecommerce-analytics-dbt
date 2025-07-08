

with validation as (
    select
        jackpot_estimate_inminor as value_field
    from main."stg_games"
),

validation_errors as (
    select
        value_field
    from validation
    where value_field <= 0
)

select *
from validation_errors

