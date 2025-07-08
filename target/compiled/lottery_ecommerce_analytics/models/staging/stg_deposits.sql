with source as (
    select * from main."deposits"
)

select
    deposit_id,
    user_id,
    cast(deposit_amount_inminor as integer) as deposit_amount_inminor,
    cast(deposit_timestamp as timestamp) as deposit_timestamp
from source