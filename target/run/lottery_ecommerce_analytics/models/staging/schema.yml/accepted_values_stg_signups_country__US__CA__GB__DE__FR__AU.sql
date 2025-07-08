
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

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



  
  
      
    ) dbt_internal_test