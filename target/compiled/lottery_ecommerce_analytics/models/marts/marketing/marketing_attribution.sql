-- Marketing Attribution Model for ROAS Calculation
-- This model answers: "What is our Return on Ad Spend (ROAS), measured by players' first-time deposits?"

with campaign_spend as (
    select 
        date,
        campaign_name,
        channel,
        spend_inminor,
        spend_inminor / 100.0 as spend_usd  -- Convert minor units to USD
    from main."stg_funnel_spend"
),

first_touch_attribution as (
    select 
        we.user_id,
        we.utm_campaign,
        we.event_timestamp as first_touch_timestamp,
        s.signup_timestamp,
        d.first_deposit_timestamp,
        d.first_deposit_amount_minor,
        d.first_deposit_amount_minor / 100.0 as first_deposit_amount_usd,
        -- Calculate time from first touch to signup
        julianday(s.signup_timestamp) - julianday(we.event_timestamp) as days_to_signup,
        -- Calculate time from first touch to first deposit
        case 
            when d.first_deposit_timestamp is not null 
            then julianday(d.first_deposit_timestamp) - julianday(we.event_timestamp)
            else null 
        end as days_to_first_deposit
    from main."stg_web_events" we
    inner join main."stg_signups" s on we.user_id = s.user_id
    left join (
        select 
            user_id,
            min(deposit_timestamp) as first_deposit_timestamp,
            min(deposit_amount_inminor) as first_deposit_amount_minor
        from main."stg_deposits"
        group by user_id
    ) d on we.user_id = d.user_id
    where we.utm_campaign is not null
    and we.event_timestamp = (
        select min(event_timestamp) 
        from main."stg_web_events" we2 
        where we2.user_id = we.user_id 
        and we2.utm_campaign is not null
    )
),

campaign_attribution as (
    select 
        fta.utm_campaign,
        cs.channel,
        cs.spend_usd,
        count(distinct fta.user_id) as attributed_users,
        count(distinct case when fta.first_deposit_timestamp is not null then fta.user_id end) as depositing_users,
        sum(case when fta.first_deposit_timestamp is not null then fta.first_deposit_amount_usd else 0 end) as total_first_deposits_usd,
        avg(case when fta.first_deposit_timestamp is not null then fta.first_deposit_amount_usd else null end) as avg_first_deposit_usd,
        avg(fta.days_to_signup) as avg_days_to_signup,
        avg(fta.days_to_first_deposit) as avg_days_to_first_deposit,
        -- Conversion rates
        cast(count(distinct case when fta.first_deposit_timestamp is not null then fta.user_id end) as float) / 
        nullif(count(distinct fta.user_id), 0) as signup_to_deposit_conversion_rate,
        -- ROAS calculation
        case 
            when cs.spend_usd > 0 
            then sum(case when fta.first_deposit_timestamp is not null then fta.first_deposit_amount_usd else 0 end) / cs.spend_usd
            else 0 
        end as roas_first_deposit,
        -- Cost per acquisition
        case 
            when count(distinct case when fta.first_deposit_timestamp is not null then fta.user_id end) > 0
            then cs.spend_usd / count(distinct case when fta.first_deposit_timestamp is not null then fta.user_id end)
            else null 
        end as cpa_first_deposit
    from first_touch_attribution fta
    left join campaign_spend cs on fta.utm_campaign = cs.campaign_name
    group by fta.utm_campaign, cs.channel, cs.spend_usd
),

-- Multi-touch attribution (weighted by touch position)
multi_touch_attribution as (
    select 
        we.user_id,
        we.utm_campaign,
        we.event_timestamp,
        row_number() over (partition by we.user_id order by we.event_timestamp) as touch_number,
        count(*) over (partition by we.user_id) as total_touches,
        -- Weight touches (first touch gets 40%, last touch gets 40%, middle touches share 20%)
        case 
            when row_number() over (partition by we.user_id order by we.event_timestamp) = 1 then 0.4
            when row_number() over (partition by we.user_id order by we.event_timestamp desc) = 1 then 0.4
            else 0.2 / nullif(count(*) over (partition by we.user_id) - 2, 0)
        end as touch_weight
    from main."stg_web_events" we
    where we.utm_campaign is not null
),

weighted_attribution as (
    select 
        mta.utm_campaign,
        cs.channel,
        cs.spend_usd,
        sum(mta.touch_weight) as weighted_touches,
        count(distinct mta.user_id) as unique_users,
        sum(case when d.first_deposit_timestamp is not null then mta.touch_weight else 0 end) as weighted_depositing_users,
        sum(case when d.first_deposit_timestamp is not null then d.first_deposit_amount_usd * mta.touch_weight else 0 end) as weighted_deposit_value,
        -- Weighted ROAS
        case 
            when cs.spend_usd > 0 
            then sum(case when d.first_deposit_timestamp is not null then d.first_deposit_amount_usd * mta.touch_weight else 0 end) / cs.spend_usd
            else 0 
        end as weighted_roas
    from multi_touch_attribution mta
    left join campaign_spend cs on mta.utm_campaign = cs.campaign_name
    left join (
        select 
            user_id,
            min(deposit_timestamp) as first_deposit_timestamp,
            min(deposit_amount_inminor) / 100.0 as first_deposit_amount_usd
        from main."stg_deposits"
        group by user_id
    ) d on mta.user_id = d.user_id
    group by mta.utm_campaign, cs.channel, cs.spend_usd
)

select 
    -- Campaign identification
    ca.utm_campaign,
    ca.channel,
    
    -- Spend metrics
    ca.spend_usd,
    
    -- First-touch attribution metrics
    ca.attributed_users,
    ca.depositing_users,
    ca.total_first_deposits_usd,
    ca.avg_first_deposit_usd,
    ca.signup_to_deposit_conversion_rate,
    ca.roas_first_deposit,
    ca.cpa_first_deposit,
    
    -- Timing metrics
    ca.avg_days_to_signup,
    ca.avg_days_to_first_deposit,
    
    -- Multi-touch attribution metrics
    wa.weighted_touches,
    wa.weighted_depositing_users,
    wa.weighted_deposit_value,
    wa.weighted_roas,
    
    -- Attribution comparison
    ca.roas_first_deposit - wa.weighted_roas as attribution_difference,
    
    -- Performance indicators
    case 
        when ca.roas_first_deposit >= 3.0 then 'High Performing'
        when ca.roas_first_deposit >= 1.5 then 'Medium Performing'
        else 'Low Performing'
    end as performance_category,
    
    -- Channel effectiveness
    case 
        when ca.signup_to_deposit_conversion_rate >= 0.3 then 'High Conversion'
        when ca.signup_to_deposit_conversion_rate >= 0.15 then 'Medium Conversion'
        else 'Low Conversion'
    end as conversion_category,
    
    current_timestamp as dbt_updated_at

from campaign_attribution ca
left join weighted_attribution wa on ca.utm_campaign = wa.utm_campaign
order by ca.roas_first_deposit desc