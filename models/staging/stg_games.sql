with source as (
    select * from {{ ref('games') }}
)

select
    game_id,
    game_name,
    cast(jackpot_estimate_inminor as integer) as jackpot_estimate_inminor
from source 