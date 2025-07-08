
    
    create view main."stg_signups" as
    with source as (
    select * from main."signups"
)

select
    user_id,
    signup_id,
    signup_timestamp,
    country
from source;