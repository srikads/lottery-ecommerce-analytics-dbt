
    
    

select
    signup_id as unique_field,
    count(*) as n_records

from main."stg_signups"
where signup_id is not null
group by signup_id
having count(*) > 1


