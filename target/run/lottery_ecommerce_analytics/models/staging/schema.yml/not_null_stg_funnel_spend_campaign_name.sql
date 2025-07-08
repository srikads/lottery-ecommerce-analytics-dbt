
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select campaign_name
from main."stg_funnel_spend"
where campaign_name is null



  
  
      
    ) dbt_internal_test