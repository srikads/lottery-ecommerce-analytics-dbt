with source as (
    select * from {{ ref('funnel_spend') }}
)

select
    cast(date as date) as date,
    campaign_name,
    channel,
    cast(spend_inminor as integer) as spend_inminor
from source 