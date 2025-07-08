
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select avg_deposit_amount_minor
from main."dim_customer"
where avg_deposit_amount_minor is null



  
  
      
    ) dbt_internal_test