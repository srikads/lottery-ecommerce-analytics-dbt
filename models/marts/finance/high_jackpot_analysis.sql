-- High Jackpot Analysis Model
-- This model answers: "Which marketing channels are most effective at acquiring players who participate in high-jackpot games?"

with high_jackpot_games as (
    select 
        game_id,
        game_name,
        jackpot_estimate_inminor,
        jackpot_estimate_inminor / 100.0 as jackpot_estimate_usd
    from {{ ref('stg_games') }}
    where jackpot_estimate_inminor >= {{ var('high_jackpot_threshold_minor') }}
),

high_jackpot_purchases as (
    select 
        tp.user_id,
        tp.game_id,
        tp.purchase_amount_usd,
        tp.purchase_timestamp,
        hjg.game_name,
        hjg.jackpot_estimate_usd
    from {{ ref('stg_ticket_purchases') }} tp
    inner join high_jackpot_games hjg on tp.game_id = hjg.game_id
),

user_first_high_jackpot as (
    select 
        user_id,
        min(purchase_timestamp) as first_high_jackpot_purchase,
        sum(purchase_amount_usd) as total_high_jackpot_spend,
        count(*) as high_jackpot_purchases,
        count(distinct game_id) as unique_high_jackpot_games
    from high_jackpot_purchases
    group by user_id
),

user_marketing_attribution as (
    select 
        we.user_id,
        we.utm_campaign,
        we.event_timestamp as first_marketing_touch,
        s.signup_timestamp,
        ufhj.first_high_jackpot_purchase,
        ufhj.total_high_jackpot_spend,
        ufhj.high_jackpot_purchases,
        ufhj.unique_high_jackpot_games,
        
        -- Time from first marketing touch to high jackpot purchase
        case 
            when ufhj.first_high_jackpot_purchase is not null 
            then julianday(ufhj.first_high_jackpot_purchase) - julianday(we.event_timestamp)
            else null 
        end as days_to_high_jackpot,
        
        -- Time from signup to high jackpot purchase
        case 
            when ufhj.first_high_jackpot_purchase is not null 
            then julianday(ufhj.first_high_jackpot_purchase) - julianday(s.signup_timestamp)
            else null 
        end as days_from_signup_to_high_jackpot
        
    from {{ ref('stg_web_events') }} we
    inner join {{ ref('stg_signups') }} s on we.user_id = s.user_id
    left join user_first_high_jackpot ufhj on we.user_id = ufhj.user_id
    where we.utm_campaign is not null
    and we.event_timestamp = (
        select min(event_timestamp) 
        from {{ ref('stg_web_events') }} we2 
        where we2.user_id = we.user_id 
        and we2.utm_campaign is not null
    )
),

campaign_high_jackpot_performance as (
    select 
        uma.utm_campaign,
        fs.channel,
        fs.spend_inminor / 100.0 as spend_usd,
        
        -- User counts
        count(distinct uma.user_id) as total_attributed_users,
        count(distinct case when uma.first_high_jackpot_purchase is not null then uma.user_id end) as high_jackpot_players,
        
        -- Conversion metrics
        cast(count(distinct case when uma.first_high_jackpot_purchase is not null then uma.user_id end) as float) / 
        nullif(count(distinct uma.user_id), 0) as high_jackpot_conversion_rate,
        
        -- Revenue metrics
        sum(case when uma.first_high_jackpot_purchase is not null then uma.total_high_jackpot_spend else 0 end) as total_high_jackpot_revenue,
        avg(case when uma.first_high_jackpot_purchase is not null then uma.total_high_jackpot_spend else null end) as avg_high_jackpot_spend_per_player,
        
        -- Engagement metrics
        sum(case when uma.first_high_jackpot_purchase is not null then uma.high_jackpot_purchases else 0 end) as total_high_jackpot_purchases,
        avg(case when uma.first_high_jackpot_purchase is not null then uma.unique_high_jackpot_games else null end) as avg_unique_high_jackpot_games,
        
        -- Timing metrics
        avg(uma.days_to_high_jackpot) as avg_days_to_high_jackpot,
        avg(uma.days_from_signup_to_high_jackpot) as avg_days_from_signup_to_high_jackpot,
        
        -- ROAS for high jackpot players
        case 
            when fs.spend_inminor > 0 
            then sum(case when uma.first_high_jackpot_purchase is not null then uma.total_high_jackpot_spend else 0 end) / (fs.spend_inminor / 100.0)
            else 0 
        end as high_jackpot_roas,
        
        -- Cost per high jackpot acquisition
        case 
            when count(distinct case when uma.first_high_jackpot_purchase is not null then uma.user_id end) > 0
            then (fs.spend_inminor / 100.0) / count(distinct case when uma.first_high_jackpot_purchase is not null then uma.user_id end)
            else null 
        end as cpa_high_jackpot_player
        
    from user_marketing_attribution uma
    left join {{ ref('stg_funnel_spend') }} fs on uma.utm_campaign = fs.campaign_name
    group by uma.utm_campaign, fs.channel, fs.spend_inminor
),

channel_performance as (
    select 
        channel,
        count(distinct utm_campaign) as total_campaigns,
        sum(spend_usd) as total_channel_spend,
        sum(high_jackpot_players) as total_high_jackpot_players,
        sum(total_high_jackpot_revenue) as total_channel_high_jackpot_revenue,
        avg(high_jackpot_conversion_rate) as avg_high_jackpot_conversion_rate,
        avg(high_jackpot_roas) as avg_high_jackpot_roas,
        avg(cpa_high_jackpot_player) as avg_cpa_high_jackpot_player,
        avg(avg_high_jackpot_spend_per_player) as avg_spend_per_high_jackpot_player,
        avg(avg_days_to_high_jackpot) as avg_days_to_high_jackpot
    from campaign_high_jackpot_performance
    group by channel
),

-- High jackpot player segments
high_jackpot_segments as (
    select 
        uma.user_id,
        uma.utm_campaign,
        fs.channel,
        uma.total_high_jackpot_spend,
        uma.high_jackpot_purchases,
        uma.unique_high_jackpot_games,
        uma.days_to_high_jackpot,
        
        -- Player segments based on high jackpot behavior
        case 
            when uma.total_high_jackpot_spend >= 1000 then 'Whale'
            when uma.total_high_jackpot_spend >= 500 then 'High Roller'
            when uma.total_high_jackpot_spend >= 100 then 'Regular High Jackpot Player'
            else 'Occasional High Jackpot Player'
        end as high_jackpot_player_segment,
        
        -- Engagement level
        case 
            when uma.high_jackpot_purchases >= 10 then 'Very Engaged'
            when uma.high_jackpot_purchases >= 5 then 'Engaged'
            when uma.high_jackpot_purchases >= 2 then 'Moderately Engaged'
            else 'Lightly Engaged'
        end as engagement_level,
        
        -- Speed of conversion
        case 
            when uma.days_to_high_jackpot <= 1 then 'Immediate Converter'
            when uma.days_to_high_jackpot <= 7 then 'Quick Converter'
            when uma.days_to_high_jackpot <= 30 then 'Standard Converter'
            else 'Slow Converter'
        end as conversion_speed
        
    from user_marketing_attribution uma
    left join {{ ref('stg_funnel_spend') }} fs on uma.utm_campaign = fs.campaign_name
    where uma.first_high_jackpot_purchase is not null
)

select 
    -- Campaign performance
    chp.utm_campaign,
    chp.channel,
    chp.spend_usd,
    chp.total_attributed_users,
    chp.high_jackpot_players,
    chp.high_jackpot_conversion_rate,
    chp.total_high_jackpot_revenue,
    chp.avg_high_jackpot_spend_per_player,
    chp.high_jackpot_roas,
    chp.cpa_high_jackpot_player,
    chp.avg_days_to_high_jackpot,
    
    -- Channel performance comparison
    cp.avg_high_jackpot_conversion_rate as channel_avg_conversion_rate,
    cp.avg_high_jackpot_roas as channel_avg_roas,
    
    -- Performance indicators
    case 
        when chp.high_jackpot_roas >= 5.0 then 'Exceptional'
        when chp.high_jackpot_roas >= 3.0 then 'High Performing'
        when chp.high_jackpot_roas >= 1.5 then 'Medium Performing'
        else 'Low Performing'
    end as performance_category,
    
    case 
        when chp.high_jackpot_conversion_rate >= 0.1 then 'High Conversion'
        when chp.high_jackpot_conversion_rate >= 0.05 then 'Medium Conversion'
        else 'Low Conversion'
    end as conversion_category,
    
    -- Channel effectiveness ranking
    rank() over (order by chp.high_jackpot_roas desc) as channel_roas_rank,
    rank() over (order by chp.high_jackpot_conversion_rate desc) as channel_conversion_rank,
    
    current_timestamp as dbt_updated_at

from campaign_high_jackpot_performance chp
left join channel_performance cp on chp.channel = cp.channel
order by chp.high_jackpot_roas desc 