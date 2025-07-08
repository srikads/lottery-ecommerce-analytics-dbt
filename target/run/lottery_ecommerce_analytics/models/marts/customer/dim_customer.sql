
  
    
    
    create  table main."dim_customer"
    as
        -- Dimension table for customer data
-- This model serves as the foundation for customer analytics and marketing attribution

with customer_signups as (
    select 
        user_id,
        signup_timestamp,
        country,
        date(signup_timestamp) as signup_date
    from main."stg_signups"
),

customer_deposits as (
    select 
        user_id,
        count(*) as total_deposits,
        sum(deposit_amount_inminor) as total_deposit_amount_minor,
        min(deposit_timestamp) as first_deposit_timestamp,
        max(deposit_timestamp) as last_deposit_timestamp,
        avg(deposit_amount_inminor) as avg_deposit_amount_minor
    from main."stg_deposits"
    group by user_id
),

customer_purchases as (
    select 
        user_id,
        count(*) as total_purchases,
        sum(purchase_amount_usd) as total_purchase_amount_usd,
        min(purchase_timestamp) as first_purchase_timestamp,
        max(purchase_timestamp) as last_purchase_timestamp,
        avg(purchase_amount_usd) as avg_purchase_amount_usd,
        count(distinct game_id) as unique_games_played
    from main."stg_ticket_purchases"
    group by user_id
),

customer_web_events as (
    select 
        user_id,
        count(*) as total_web_events,
        min(event_timestamp) as first_web_event_timestamp,
        max(event_timestamp) as last_web_event_timestamp,
        count(distinct utm_campaign) as unique_campaigns_engaged
    from main."stg_web_events"
    where user_id is not null
    group by user_id
),

high_jackpot_games as (
    select distinct game_id
    from main."stg_games"
    where jackpot_estimate_inminor >= 1000000
),

high_jackpot_participation as (
    select 
        tp.user_id,
        count(distinct tp.game_id) as high_jackpot_games_played,
        sum(tp.purchase_amount_usd) as high_jackpot_spend_usd
    from main."stg_ticket_purchases" tp
    inner join high_jackpot_games hjg on tp.game_id = hjg.game_id
    group by tp.user_id
)

select 
    -- Customer identification
    cs.user_id,
    cs.country,
    
    -- Signup information
    cs.signup_timestamp,
    cs.signup_date,
    
    -- Deposit behavior
    coalesce(cd.total_deposits, 0) as total_deposits,
    coalesce(cd.total_deposit_amount_minor, 0) as total_deposit_amount_minor,
    cd.first_deposit_timestamp,
    cd.last_deposit_timestamp,
    coalesce(cd.avg_deposit_amount_minor, 0) as avg_deposit_amount_minor,
    
    -- Purchase behavior
    coalesce(cp.total_purchases, 0) as total_purchases,
    coalesce(cp.total_purchase_amount_usd, 0) as total_purchase_amount_usd,
    cp.first_purchase_timestamp,
    cp.last_purchase_timestamp,
    coalesce(cp.avg_purchase_amount_usd, 0) as avg_purchase_amount_usd,
    coalesce(cp.unique_games_played, 0) as unique_games_played,
    
    -- Web engagement
    coalesce(cwe.total_web_events, 0) as total_web_events,
    cwe.first_web_event_timestamp,
    cwe.last_web_event_timestamp,
    coalesce(cwe.unique_campaigns_engaged, 0) as unique_campaigns_engaged,
    
    -- High jackpot participation
    coalesce(hjp.high_jackpot_games_played, 0) as high_jackpot_games_played,
    coalesce(hjp.high_jackpot_spend_usd, 0) as high_jackpot_spend_usd,
    
    -- Calculated fields
    case 
        when cp.first_purchase_timestamp is not null 
        then julianday(cp.first_purchase_timestamp) - julianday(cs.signup_timestamp)
        else null 
    end as days_to_first_purchase,
    
    case 
        when cd.first_deposit_timestamp is not null 
        then julianday(cd.first_deposit_timestamp) - julianday(cs.signup_timestamp)
        else null 
    end as days_to_first_deposit,
    
    case 
        when cwe.first_web_event_timestamp is not null 
        then julianday(cwe.first_web_event_timestamp) - julianday(cs.signup_timestamp)
        else null 
    end as days_to_first_web_event,
    
    -- Customer segments
    case 
        when coalesce(cp.total_purchases, 0) >= 10 then 'High Value'
        when coalesce(cp.total_purchases, 0) >= 3 then 'Medium Value'
        when coalesce(cp.total_purchases, 0) >= 1 then 'Low Value'
        else 'No Purchase'
    end as customer_segment,
    
    case 
        when coalesce(hjp.high_jackpot_games_played, 0) > 0 then 'High Jackpot Player'
        else 'Regular Player'
    end as player_type,
    
    -- Timestamps for tracking
    current_timestamp as dbt_updated_at

from customer_signups cs
left join customer_deposits cd on cs.user_id = cd.user_id
left join customer_purchases cp on cs.user_id = cp.user_id
left join customer_web_events cwe on cs.user_id = cwe.user_id
left join high_jackpot_participation hjp on cs.user_id = hjp.user_id

  