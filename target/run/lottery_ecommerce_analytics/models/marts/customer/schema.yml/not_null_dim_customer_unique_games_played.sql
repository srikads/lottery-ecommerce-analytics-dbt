
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select unique_games_played
from main."dim_customer"
where unique_games_played is null



  
  
      
    ) dbt_internal_test