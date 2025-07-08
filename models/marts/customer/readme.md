# Customer Analytics Data Mart

This `marts/customer` directory serves as the dedicated domain for all customer-centric analytical data models within the dbt project. These models are meticulously designed to provide a comprehensive, unified, and business-ready view of our players, empowering the marketing and VIP teams with actionable insights for customer analysis, segmentation, and strategic decision-making.

## 🎯 Purpose and Business Impact

The overarching purpose of this domain is to:

1. **Establish a Single Source of Truth**: Consolidate disparate customer-related data points into coherent, easily consumable tables.
2. **Facilitate Self-Service Analytics**: Deliver clean, well-defined models optimized for direct consumption by Business Intelligence (BI) tools (e.g., Looker) and ad-hoc SQL queries, reducing reliance on data engineering for routine reporting.
3. **Drive Strategic Initiatives**: Directly support key business objectives related to player acquisition, engagement, and retention, particularly through customer segmentation and lifetime value analysis.

These models directly contribute to answering the core business questions from the case study:

- **Return on Ad Spend (ROAS)**: By providing granular customer attributes and linking them to their first deposit, these models enable the calculation of ROAS for various marketing campaigns.
- **Time from First Marketing Interaction to First Purchase**: The `dim_customer` model consolidates crucial timestamps, allowing for precise measurement of conversion funnel efficiency.
- **Effectiveness of Channels for High-Jackpot Players**: Both models provide attributes and scores related to high-jackpot game participation, enabling targeted analysis of acquisition channels.
- **Customer Lifetime Value (LTV)**: The `customer_ltv_scoring` model directly addresses the VIP team's request to identify and segment high-potential players.

## 📁 Models Overview

This directory contains two primary analytical models: `dim_customer` and `customer_ltv_scoring`.

### `dim_customer.sql` - The Customer Profile Hub

The `dim_customer` model functions as the central customer dimension table, providing a unique and persistent profile for each player. It aggregates core customer attributes and key lifecycle timestamps from various raw data sources, serving as the foundational lookup table for all customer-related analysis.

#### Purpose

- To create a single, comprehensive, and consistent record for every unique customer.
- To consolidate essential customer lifecycle events and attributes in one accessible location.
- To serve as the primary dimension table for joining with fact tables (e.g., purchases, deposits) in downstream analyses.

#### Business Value

- **Unified Customer View**: Provides a holistic understanding of each player, essential for accurate segmentation and personalized marketing.
- **Foundation for Analytics**: Enables consistent customer-centric reporting across the organization.
- **Supports Conversion Analysis**: Crucial for measuring the time taken for customers to move through the funnel (e.g., `days_to_first_purchase`).

#### Data Sources

This model primarily joins and aggregates data from the following staging models:

- `{{ ref('stg_signups') }}`: Core signup details (`user_id`, `signup_timestamp`, `country`).
- `{{ ref('stg_deposits') }}`: Deposit transaction summaries.
- `{{ ref('stg_ticket_purchases') }}`: Ticket purchase transaction summaries.
- `{{ ref('stg_web_events') }}`: Web engagement metrics for identified users.
- `{{ ref('stg_games') }}`: Game metadata, used indirectly via `high_jackpot_games` to identify high-jackpot game participation.

#### Transformation Logic

The `dim_customer` model is constructed through a series of CTEs, each focusing on aggregating specific customer behaviors, followed by a final join to consolidate these insights:

1. **customer_signups**: Extracts foundational signup information (`user_id`, `signup_timestamp`, `country`, `signup_date`) from `stg_signups`. This CTE establishes the base customer record.

2. **customer_deposits**: Aggregates `stg_deposits` by `user_id` to calculate `total_deposits`, `total_deposit_amount_minor`, `first_deposit_timestamp`, `last_deposit_timestamp`, and `avg_deposit_amount_minor`.

3. **customer_purchases**: Aggregates `stg_ticket_purchases` by `user_id` to derive `total_purchases`, `total_purchase_amount_usd`, `first_purchase_timestamp`, `last_purchase_timestamp`, `avg_purchase_amount_usd`, and `unique_games_played`.

4. **customer_web_events**: Summarizes `stg_web_events` (for identified users) by `user_id` to capture `total_web_events`, `first_web_event_timestamp`, `last_web_event_timestamp`, and `unique_campaigns_engaged`.

5. **high_jackpot_games**: Identifies `game_ids` corresponding to high-jackpot games, leveraging a dbt variable (`{{ var('high_jackpot_threshold_minor') }}`) for configurable thresholds.

6. **high_jackpot_participation**: Joins `stg_ticket_purchases` with `high_jackpot_games` to calculate `high_jackpot_games_played` and `high_jackpot_spend_usd` per user.

7. **Final SELECT**: LEFT JOINs all aggregated CTEs onto `customer_signups` using `user_id`. `COALESCE` functions are used to handle NULL values from LEFT JOINs, ensuring numerical fields default to 0. This stage also calculates derived metrics such as `days_to_first_purchase`, `days_to_first_deposit`, and `days_to_first_web_event`. Additionally, rule-based customer segments (`customer_segment`, `player_type`) are assigned for immediate analytical utility.

#### Key Output Columns

The `dim_customer` model outputs a single row per `user_id` with a comprehensive set of attributes, including:

- **Identification**: `user_id`, `country`
- **Signup**: `signup_timestamp`, `signup_date`
- **Deposit Behavior**: `total_deposits`, `total_deposit_amount_minor`, `first_deposit_timestamp`, `last_deposit_timestamp`, `avg_deposit_amount_minor`
- **Purchase Behavior**: `total_purchases`, `total_purchase_amount_usd`, `first_purchase_timestamp`, `last_purchase_timestamp`, `avg_purchase_amount_usd`, `unique_games_played`
- **Web Engagement**: `total_web_events`, `first_web_event_timestamp`, `last_web_event_timestamp`, `unique_campaigns_engaged`
- **High Jackpot Participation**: `high_jackpot_games_played`, `high_jackpot_spend_usd`
- **Calculated Timings**: `days_to_first_purchase`, `days_to_first_deposit`, `days_to_first_web_event`
- **Segments**: `customer_segment`, `player_type`
- **Metadata**: `dbt_updated_at`

#### Data Quality & Governance

The `dim_customer` model is subject to rigorous data quality checks defined in its `schema.yml` file. This includes:

- **Primary Key Validation**: `not_null` and `unique` tests on `user_id` to ensure data integrity.
- **Referential Integrity**: `relationships` tests to ensure `user_id` maps correctly to upstream `stg_signups`.
- **Business Rule Enforcement**: Custom tests (e.g., `assert_purchase_after_signup.sql`) ensure logical consistency of timestamps.
- **Column Descriptions**: All columns are thoroughly documented in `schema.yml`, serving as a clear data contract for data consumers and facilitating self-service analytics.

#### Performance Considerations

- **Materialization**: Materialized as a table to ensure optimal query performance for downstream BI tools and consistent data availability. This pre-computes complex joins and aggregations.
- **Coalesce Usage**: `COALESCE` ensures that LEFT JOIN results in 0 instead of NULL for numerical fields, preventing issues in downstream calculations and simplifying query logic.

### `customer_ltv_scoring.sql` - Customer Lifetime Value Assessment

The `customer_ltv_scoring` model is specifically engineered to calculate and assign a Customer Lifetime Value (LTV) score to each player. This model integrates various behavioral and transactional metrics to provide a nuanced understanding of a customer's potential long-term value, directly supporting the VIP team's objectives for targeted promotions.

#### Purpose

- To calculate a comprehensive Customer Lifetime Value (LTV) score for each player.
- To classify customers into VIP tiers based on their LTV and behavioral patterns.
- To identify promotion eligibility categories, enabling targeted marketing and re-engagement strategies.

#### Business Value

- **VIP Identification**: Directly addresses the VIP team's need to identify high-potential players for exclusive promotions, optimizing marketing spend and customer retention efforts.
- **Enhanced Segmentation**: Provides a more sophisticated segmentation framework beyond basic demographics or total spend, incorporating recency, frequency, monetary value, and specific lottery-related behaviors.
- **Strategic Marketing**: Informs strategic decisions on customer acquisition, retention, and win-back campaigns by quantifying customer value and risk.

#### Data Sources

This model primarily leverages the enriched customer profiles from:

- `{{ ref('dim_customer') }}`: Provides all core customer attributes and aggregated behavior metrics.

#### Transformation Logic

The `customer_ltv_scoring` model processes data through several analytical stages:

1. **customer_behavior**: Selects key customer attributes from `dim_customer` and calculates foundational RFM (Recency, Frequency, Monetary) components: `days_since_last_activity`, `purchases_per_month`, `avg_spend_per_purchase`, and `customer_tenure_days`.

2. **rfm_scores**: Assigns a standardized score (1-5) for `recency_score`, `frequency_score`, and `monetary_score` based on predefined thresholds. This normalizes these diverse metrics for aggregation.

3. **behavioral_scores**: Extends the RFM framework by incorporating lottery-specific behavioral scores: `high_jackpot_score` (engagement with high-jackpot games), `game_variety_score` (diversity of games played), `deposit_behavior_score` (frequency of deposits), and `quick_conversion_score` (speed of first purchase).

4. **ltv_prediction**: Aggregates the individual RFM and behavioral scores into composite `rfm_score` (sum of RFM components) and `behavioral_score` (sum of behavioral components). It also calculates a `predicted_annual_ltv` (a simple annualized projection of past spend) and a `risk_score` based on tenure and activity.

5. **ltv_scoring**: This is the final calculation stage. It computes the `ltv_score` (0-100) as a weighted average of the `rfm_score` (40%), `behavioral_score` (30%), and a scaled `predicted_annual_ltv` (30%). This composite score provides a single, holistic measure of customer value. Additionally, it classifies customers into `vip_tier` categories ('Diamond VIP', 'Gold VIP', 'Silver VIP', 'Standard') and `promotion_category` ('Eligible for VIP Promotions', 'Eligible for Re-engagement', 'Standard Marketing') based on `ltv_score` and recency.

6. **Final SELECT**: Selects all relevant calculated metrics, scores, and classifications for the final output, ordered by `ltv_score` for immediate insight into top-tier customers.

#### Key Output Columns

The `customer_ltv_scoring` model outputs a single row per `user_id` with detailed LTV and segmentation attributes:

- **Identification**: `user_id`, `country`, `signup_date`
- **Current Behavior**: `total_deposits`, `total_deposit_amount_minor`, `total_purchases`, `total_purchase_amount_usd`, `unique_games_played`, `high_jackpot_games_played`, `high_jackpot_spend_usd`
- **RFM Metrics**: `recency_score`, `frequency_score`, `monetary_score`, `rfm_score`
- **Behavioral Metrics**: `high_jackpot_score`, `game_variety_score`, `deposit_behavior_score`, `quick_conversion_score`, `behavioral_score`
- **LTV Prediction**: `predicted_annual_ltv`, `ltv_score`
- **Risk Assessment**: `risk_score`
- **VIP Classification**: `vip_tier`, `promotion_category`
- **Additional Context**: `customer_segment`, `player_type`, `days_since_last_activity`, `customer_tenure_days`
- **Metadata**: `dbt_updated_at`

#### Data Quality & Governance

- **Upstream Reliance**: Relies on the data quality and integrity established in `dim_customer` and other upstream staging models.
- **Score Validity**: Tests should be implemented in `schema.yml` to ensure `ltv_score` falls within expected ranges (e.g., 0-100) and that other scores (1-5) are valid.
- **Documentation**: All new columns are clearly described in `schema.yml`, providing transparency on their calculation and meaning.

#### Performance Considerations

- **Materialization**: Typically materialized as a table to pre-compute the complex scoring logic, ensuring fast access for BI tools and marketing campaign systems.
- **Pre-computation**: The multi-stage CTE structure allows for logical breakdown and optimization of calculations.
- **julianday('now')**: Note that `julianday('now')` is specific to SQLite/DuckDB. In a production BigQuery environment, this would be replaced with `UNIX_DATE(CURRENT_DATE())` or similar functions for date difference calculations relative to the current date.

## 🔗 Inter-Model Dependencies within marts/customer

The `marts/customer` domain exhibits a clear dependency flow:

- `dim_customer` is the foundational model, consolidating all core customer attributes.
- `customer_ltv_scoring` depends on and consumes data from `dim_customer`. It enriches the customer profile with advanced LTV calculations and segmentation, which can then be joined back to `dim_customer` or used independently for specific LTV-driven initiatives.

This layered approach ensures modularity, reusability, and maintainability of your customer analytics data assets.
