-- Custom test: Ensure ticket purchases happen after user signup
-- This enforces the business rule that a player's first ticket purchase cannot occur before their signup

with signup_times as (
    select 
        user_id,
        signup_timestamp
    from {{ ref('stg_signups') }}
),

purchase_times as (
    select 
        user_id,
        min(purchase_timestamp) as first_purchase_timestamp
    from {{ ref('stg_ticket_purchases') }}
    group by user_id
),

validation as (
    select 
        s.user_id,
        s.signup_timestamp,
        p.first_purchase_timestamp,
        case 
            when p.first_purchase_timestamp < s.signup_timestamp then 1 
            else 0 
        end as invalid_purchase
    from signup_times s
    inner join purchase_times p on s.user_id = p.user_id
)

select *
from validation 
where invalid_purchase = 1 