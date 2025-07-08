with source as (
    select * from {{ ref('signups') }}
)

select
    user_id,
    signup_id,
    signup_timestamp,
    country
from source 