
    
    create view main."stg_funnel_spend" as
    with source as (
    select * from main."funnel_spend"
)

select
    cast(date as date) as date,
    campaign_name,
    channel,
    cast(spend_inminor as integer) as spend_inminor
from source;