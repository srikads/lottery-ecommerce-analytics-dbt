
    
    

with all_values as (

    select
        player_type as value_field,
        count(*) as n_records

    from main."dim_customer"
    group by player_type

)

select *
from all_values
where value_field not in (
    'High Jackpot Player','Regular Player'
)


