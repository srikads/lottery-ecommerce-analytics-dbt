
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select event_id
from main."stg_web_events"
where event_id is null



  
  
      
    ) dbt_internal_test