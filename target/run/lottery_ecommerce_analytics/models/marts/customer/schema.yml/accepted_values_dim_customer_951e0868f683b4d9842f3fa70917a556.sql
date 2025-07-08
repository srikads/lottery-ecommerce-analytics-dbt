
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        customer_segment as value_field,
        count(*) as n_records

    from main."dim_customer"
    group by customer_segment

)

select *
from all_values
where value_field not in (
    'High Value','Medium Value','Low Value','No Purchase'
)



  
  
      
    ) dbt_internal_test