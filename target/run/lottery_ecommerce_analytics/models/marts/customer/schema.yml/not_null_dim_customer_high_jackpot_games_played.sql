
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select high_jackpot_games_played
from main."dim_customer"
where high_jackpot_games_played is null



  
  
      
    ) dbt_internal_test