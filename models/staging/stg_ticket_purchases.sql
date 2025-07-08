with source as (
    select * from {{ ref('ticket_purchases') }}
)

select
    purchase_id,
    user_id,
    game_id,
    cast(purchase_amount_usd as numeric) as purchase_amount_usd,
    purchase_timestamp
from source 