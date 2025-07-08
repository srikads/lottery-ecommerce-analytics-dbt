
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select purchase_amount_usd
from main."stg_ticket_purchases"
where purchase_amount_usd is null



  
  
      
    ) dbt_internal_test