
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select deposit_amount_inminor
from main."stg_deposits"
where deposit_amount_inminor is null



  
  
      
    ) dbt_internal_test