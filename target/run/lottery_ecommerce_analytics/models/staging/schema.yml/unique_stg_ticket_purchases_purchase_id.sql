
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

select
    purchase_id as unique_field,
    count(*) as n_records

from main."stg_ticket_purchases"
where purchase_id is not null
group by purchase_id
having count(*) > 1



  
  
      
    ) dbt_internal_test