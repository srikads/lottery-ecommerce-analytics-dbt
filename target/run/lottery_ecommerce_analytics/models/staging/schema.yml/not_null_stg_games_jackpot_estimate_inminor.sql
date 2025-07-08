
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select jackpot_estimate_inminor
from main."stg_games"
where jackpot_estimate_inminor is null



  
  
      
    ) dbt_internal_test