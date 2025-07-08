{% macro display_all_results() %}
    {% set queries = [
        {
            "name": "CUSTOMER LTV SCORING RESULTS",
            "query": "SELECT user_id, country, customer_segment, ltv_score, vip_tier, predicted_annual_ltv FROM " ~ ref('customer_ltv_scoring') ~ " ORDER BY ltv_score DESC"
        },
        {
            "name": "MARKETING ATTRIBUTION RESULTS", 
            "query": "SELECT utm_campaign, channel, spend_usd, roas_first_deposit, performance_category FROM " ~ ref('marketing_attribution') ~ " ORDER BY roas_first_deposit DESC"
        },
        {
            "name": "HIGH JACKPOT ANALYSIS RESULTS",
            "query": "SELECT game_name, jackpot_estimate_inminor, ticket_count, total_revenue_usd, avg_ticket_value_usd FROM " ~ ref('high_jackpot_analysis') ~ " ORDER BY total_revenue_usd DESC"
        },
        {
            "name": "IDENTITY STITCHING RESULTS",
            "query": "SELECT unified_user_id, user_id, anonymous_user_id, conversion_status, total_events FROM " ~ ref('int_identity_stitching') ~ " ORDER BY total_events DESC"
        },
        {
            "name": "DIM CUSTOMER RESULTS",
            "query": "SELECT user_id, country, customer_segment, total_deposits, total_purchase_amount_usd, player_type FROM " ~ ref('dim_customer') ~ " ORDER BY total_purchase_amount_usd DESC"
        }
    ] %}
    
    {% for query_info in queries %}
        {% do log("=" * 60, info=true) %}
        {% do log(query_info.name, info=true) %}
        {% do log("=" * 60, info=true) %}
        
        {% set results = run_query(query_info.query) %}
        {% if results %}
            {% for row in results %}
                {% do log(row, info=true) %}
            {% endfor %}
        {% else %}
            {% do log("No results found", info=true) %}
        {% endif %}
        
        {% do log("", info=true) %}
    {% endfor %}
{% endmacro %} 