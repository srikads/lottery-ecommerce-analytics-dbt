
    
    

with all_values as (

    select
        country as value_field,
        count(*) as n_records

    from main."stg_signups"
    group by country

)

select *
from all_values
where value_field not in (
    'US','CA','GB','DE','FR','AU'
)


