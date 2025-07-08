
    
    

select
    deposit_id as unique_field,
    count(*) as n_records

from main."stg_deposits"
where deposit_id is not null
group by deposit_id
having count(*) > 1


