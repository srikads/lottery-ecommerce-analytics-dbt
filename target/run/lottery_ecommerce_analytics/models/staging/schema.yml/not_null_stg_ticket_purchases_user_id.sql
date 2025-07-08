
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select user_id
from main."stg_ticket_purchases"
where user_id is null



  
  
      
    ) dbt_internal_test