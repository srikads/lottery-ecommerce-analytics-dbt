
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select dbt_updated_at
from main."dim_customer"
where dbt_updated_at is null



  
  
      
    ) dbt_internal_test