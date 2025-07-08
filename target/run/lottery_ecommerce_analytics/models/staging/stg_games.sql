
    
    create view main."stg_games" as
    with source as (
    select * from main."games"
)

select
    game_id,
    game_name,
    cast(jackpot_estimate_inminor as integer) as jackpot_estimate_inminor
from source;