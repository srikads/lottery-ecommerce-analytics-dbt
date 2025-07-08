
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  

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


  
  
      
    ) dbt_internal_test