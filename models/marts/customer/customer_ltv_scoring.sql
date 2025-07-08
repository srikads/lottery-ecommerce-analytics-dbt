-- Customer LTV Scoring Model for VIP Team
-- This model identifies players with high potential lifetime value for special promotions

with customer_behavior as (
    select 
        dc.user_id,
        dc.country,
        dc.signup_date,
        dc.total_deposits,
        dc.total_deposit_amount_minor,
        dc.total_purchases,
        dc.total_purchase_amount_usd,
        dc.unique_games_played,
        dc.high_jackpot_games_played,
        dc.high_jackpot_spend_usd,
        dc.days_to_first_purchase,
        dc.customer_segment,
        dc.player_type,
        
        -- Recency: Days since last activity
        case 
            when dc.last_purchase_timestamp is not null 
            then julianday('now') - julianday(dc.last_purchase_timestamp)
            else julianday('now') - julianday(dc.signup_timestamp)
        end as days_since_last_activity,
        
        -- Frequency: Average purchases per month since signup
        case 
            when julianday('now') - julianday(dc.signup_timestamp) > 0
            then dc.total_purchases / ((julianday('now') - julianday(dc.signup_timestamp)) / 30.0)
            else 0
        end as purchases_per_month,
        
        -- Monetary: Average spend per purchase
        case 
            when dc.total_purchases > 0 
            then dc.total_purchase_amount_usd / dc.total_purchases
            else 0
        end as avg_spend_per_purchase,
        
        -- Tenure: Days since signup
        julianday('now') - julianday(dc.signup_timestamp) as customer_tenure_days
        
    from {{ ref('dim_customer') }} dc
),

-- RFM Scoring (Recency, Frequency, Monetary)
rfm_scores as (
    select 
        cb.*,
        
        -- Recency Score (1-5, 5 being most recent)
        case 
            when days_since_last_activity <= 7 then 5
            when days_since_last_activity <= 30 then 4
            when days_since_last_activity <= 90 then 3
            when days_since_last_activity <= 180 then 2
            else 1
        end as recency_score,
        
        -- Frequency Score (1-5, 5 being most frequent)
        case 
            when purchases_per_month >= 5 then 5
            when purchases_per_month >= 3 then 4
            when purchases_per_month >= 1 then 3
            when purchases_per_month >= 0.5 then 2
            else 1
        end as frequency_score,
        
        -- Monetary Score (1-5, 5 being highest spend)
        case 
            when avg_spend_per_purchase >= 50 then 5
            when avg_spend_per_purchase >= 25 then 4
            when avg_spend_per_purchase >= 10 then 3
            when avg_spend_per_purchase >= 5 then 2
            else 1
        end as monetary_score
        
    from customer_behavior cb
),

-- Behavioral Scoring
behavioral_scores as (
    select 
        rfm.*,
        
        -- High Jackpot Engagement Score (1-5)
        case 
            when high_jackpot_games_played >= 5 then 5
            when high_jackpot_games_played >= 3 then 4
            when high_jackpot_games_played >= 1 then 3
            else 1
        end as high_jackpot_score,
        
        -- Game Variety Score (1-5)
        case 
            when unique_games_played >= 5 then 5
            when unique_games_played >= 3 then 4
            when unique_games_played >= 2 then 3
            when unique_games_played >= 1 then 2
            else 1
        end as game_variety_score,
        
        -- Deposit Behavior Score (1-5)
        case 
            when total_deposits >= 10 then 5
            when total_deposits >= 5 then 4
            when total_deposits >= 3 then 3
            when total_deposits >= 1 then 2
            else 1
        end as deposit_behavior_score,
        
        -- Quick Conversion Score (1-5)
        case 
            when days_to_first_purchase <= 1 then 5
            when days_to_first_purchase <= 3 then 4
            when days_to_first_purchase <= 7 then 3
            when days_to_first_purchase <= 14 then 2
            when days_to_first_purchase is not null then 1
            else 0
        end as quick_conversion_score
        
    from rfm_scores rfm
),

-- LTV Prediction Model
ltv_prediction as (
    select 
        bs.*,
        
        -- RFM Score (sum of recency, frequency, monetary)
        (recency_score + frequency_score + monetary_score) as rfm_score,
        
        -- Behavioral Score (sum of behavioral metrics)
        (high_jackpot_score + game_variety_score + deposit_behavior_score + quick_conversion_score) as behavioral_score,
        
        -- Predicted LTV (based on historical patterns)
        case 
            when customer_tenure_days > 0 then
                (total_purchase_amount_usd / (customer_tenure_days / 365.0)) * 2  -- Project 2 years ahead
            else 0
        end as predicted_annual_ltv,
        
        -- Risk Score (inverse of reliability)
        case 
            when customer_tenure_days < 30 then 3  -- New customers are higher risk
            when days_since_last_activity > 90 then 2  -- Inactive customers
            else 1  -- Low risk
        end as risk_score
        
    from behavioral_scores bs
),

-- Final LTV Scoring
ltv_scoring as (
    select 
        lp.*,
        
        -- Overall LTV Score (0-100)
        (
            (rfm_score / 15.0) * 40 +  -- RFM contributes 40%
            (behavioral_score / 20.0) * 30 +  -- Behavioral contributes 30%
            (case 
                when predicted_annual_ltv >= 1000 then 1.0
                when predicted_annual_ltv >= 500 then 0.8
                when predicted_annual_ltv >= 200 then 0.6
                when predicted_annual_ltv >= 100 then 0.4
                when predicted_annual_ltv >= 50 then 0.2
                else 0.0
            end) * 30  -- LTV prediction contributes 30%
        ) as ltv_score,
        
        -- VIP Tier Classification
        case 
            when (
                (rfm_score / 15.0) * 40 + 
                (behavioral_score / 20.0) * 30 + 
                (case 
                    when predicted_annual_ltv >= 1000 then 1.0
                    when predicted_annual_ltv >= 500 then 0.8
                    when predicted_annual_ltv >= 200 then 0.6
                    when predicted_annual_ltv >= 100 then 0.4
                    when predicted_annual_ltv >= 50 then 0.2
                    else 0.0
                end) * 30
            ) >= 80 then 'Diamond VIP'
            when (
                (rfm_score / 15.0) * 40 + 
                (behavioral_score / 20.0) * 30 + 
                (case 
                    when predicted_annual_ltv >= 1000 then 1.0
                    when predicted_annual_ltv >= 500 then 0.8
                    when predicted_annual_ltv >= 200 then 0.6
                    when predicted_annual_ltv >= 100 then 0.4
                    when predicted_annual_ltv >= 50 then 0.2
                    else 0.0
                end) * 30
            ) >= 60 then 'Gold VIP'
            when (
                (rfm_score / 15.0) * 40 + 
                (behavioral_score / 20.0) * 30 + 
                (case 
                    when predicted_annual_ltv >= 1000 then 1.0
                    when predicted_annual_ltv >= 500 then 0.8
                    when predicted_annual_ltv >= 200 then 0.6
                    when predicted_annual_ltv >= 100 then 0.4
                    when predicted_annual_ltv >= 50 then 0.2
                    else 0.0
                end) * 30
            ) >= 40 then 'Silver VIP'
            else 'Standard'
        end as vip_tier,
        
        -- Promotion Eligibility
        case 
            when (
                (rfm_score / 15.0) * 40 + 
                (behavioral_score / 20.0) * 30 + 
                (case 
                    when predicted_annual_ltv >= 1000 then 1.0
                    when predicted_annual_ltv >= 500 then 0.8
                    when predicted_annual_ltv >= 200 then 0.6
                    when predicted_annual_ltv >= 100 then 0.4
                    when predicted_annual_ltv >= 50 then 0.2
                    else 0.0
                end) * 30
            ) >= 60 and days_since_last_activity <= 30 then 'Eligible for VIP Promotions'
            when days_since_last_activity > 90 then 'Eligible for Re-engagement'
            else 'Standard Marketing'
        end as promotion_category
        
    from ltv_prediction lp
)

select 
    -- Customer identification
    user_id,
    country,
    signup_date,
    
    -- Current behavior metrics
    total_deposits,
    total_deposit_amount_minor,
    total_purchases,
    total_purchase_amount_usd,
    unique_games_played,
    high_jackpot_games_played,
    high_jackpot_spend_usd,
    
    -- RFM metrics
    recency_score,
    frequency_score,
    monetary_score,
    rfm_score,
    
    -- Behavioral metrics
    high_jackpot_score,
    game_variety_score,
    deposit_behavior_score,
    quick_conversion_score,
    behavioral_score,
    
    -- LTV prediction
    predicted_annual_ltv,
    ltv_score,
    
    -- Risk assessment
    risk_score,
    
    -- VIP classification
    vip_tier,
    promotion_category,
    
    -- Additional context
    customer_segment,
    player_type,
    days_since_last_activity,
    customer_tenure_days,
    
    current_timestamp as dbt_updated_at

from ltv_scoring
order by ltv_score desc 