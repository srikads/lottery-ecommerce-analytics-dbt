
    
    

with all_values as (

    select
        channel as value_field,
        count(*) as n_records

    from main."stg_funnel_spend"
    group by channel

)

select *
from all_values
where value_field not in (
    'Email','Social','Search','Display','Affiliate'
)


