
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

select
    signup_id as unique_field,
    count(*) as n_records

from main."stg_signups"
where signup_id is not null
group by signup_id
having count(*) > 1



  
  
      
    ) dbt_internal_test