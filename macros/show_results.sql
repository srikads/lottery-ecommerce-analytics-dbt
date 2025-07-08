{% macro show_customer_ltv_results() %}
    {% set query %}
        SELECT 
            user_id,
            country,
            customer_segment,
            player_type,
            ltv_score,
            vip_tier,
            predicted_annual_ltv
        FROM {{ ref('customer_ltv_scoring') }}
        ORDER BY ltv_score DESC
    {% endset %}
    
    {% do log("=== CUSTOMER LTV SCORING RESULTS ===", info=true) %}
    {% do run_query(query) %}
{% endmacro %}

{% macro show_marketing_attribution_results() %}
    {% set query %}
        SELECT 
            utm_campaign,
            channel,
            spend_usd,
            roas_first_deposit,
            signup_to_deposit_conversion_rate,
            performance_category
        FROM {{ ref('marketing_attribution') }}
        ORDER BY roas_first_deposit DESC
    {% endset %}
    
    {% do log("=== MARKETING ATTRIBUTION RESULTS ===", info=true) %}
    {% do run_query(query) %}
{% endmacro %}

{% macro show_high_jackpot_results() %}
    {% set query %}
        SELECT 
            game_name,
            jackpot_estimate_inminor,
            ticket_count,
            total_revenue_usd,
            avg_ticket_value_usd
        FROM {{ ref('high_jackpot_analysis') }}
        ORDER BY total_revenue_usd DESC
    {% endset %}
    
    {% do log("=== HIGH JACKPOT ANALYSIS RESULTS ===", info=true) %}
    {% do run_query(query) %}
{% endmacro %}

{% macro show_identity_stitching_results() %}
    {% set query %}
        SELECT 
            unified_user_id,
            user_id,
            anonymous_user_id,
            conversion_status,
            total_events
        FROM {{ ref('int_identity_stitching') }}
        ORDER BY total_events DESC
    {% endset %}
    
    {% do log("=== IDENTITY STITCHING RESULTS ===", info=true) %}
    {% do run_query(query) %}
{% endmacro %}

{% macro show_dim_customer_results() %}
    {% set query %}
        SELECT 
            user_id,
            country,
            customer_segment,
            total_deposits,
            total_purchase_amount_usd,
            player_type
        FROM {{ ref('dim_customer') }}
        ORDER BY total_purchase_amount_usd DESC
    {% endset %}
    
    {% do log("=== DIM CUSTOMER RESULTS ===", info=true) %}
    {% do run_query(query) %}
{% endmacro %} 