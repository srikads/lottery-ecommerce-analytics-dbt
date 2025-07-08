# Finance Analytics Data Mart

This `marts/finance` directory serves as the dedicated domain for all finance-centric analytical data models within the dbt project. These models are strategically designed to provide comprehensive financial insights, revenue analysis, and performance metrics that drive data-informed business decisions for the lottery and gaming platform.

## 🎯 Purpose and Business Impact

The overarching purpose of this domain is to:

1. **Enable Revenue Optimization**: Provide granular insights into revenue streams, customer spending patterns, and high-value player identification to optimize financial performance.
2. **Support Marketing ROI Analysis**: Deliver comprehensive attribution models that measure the effectiveness of marketing campaigns in driving high-value customer acquisition.
3. **Facilitate Strategic Planning**: Offer detailed financial metrics and KPIs that inform strategic decisions around game development, marketing spend allocation, and customer acquisition strategies.

These models directly contribute to answering critical business questions:

- **High-Value Player Acquisition**: Which marketing channels are most effective at acquiring players who participate in high-jackpot games?
- **Revenue Attribution**: How do different marketing campaigns contribute to overall revenue generation?
- **Customer Lifetime Value**: What is the financial impact of different customer segments and acquisition channels?
- **Marketing Efficiency**: Which campaigns and channels provide the best return on investment for high-value players?

## 📁 Models Overview

This directory contains one primary analytical model: `high_jackpot_analysis`.

### `high_jackpot_analysis.sql` - High-Value Player Marketing Effectiveness

The `high_jackpot_analysis` model is specifically engineered to analyze the effectiveness of marketing channels in acquiring and converting players who participate in high-jackpot games. This model provides comprehensive insights into marketing ROI, customer acquisition costs, and revenue attribution for high-value players.

#### Purpose

- To identify which marketing channels and campaigns are most effective at acquiring high-jackpot players.
- To calculate detailed ROI metrics for high-value customer acquisition.
- To provide insights into the conversion funnel from marketing touch to high-jackpot participation.
- To enable data-driven decisions for marketing spend allocation and campaign optimization.

#### Business Value

- **Marketing Optimization**: Enables marketing teams to allocate budget more effectively by identifying high-performing channels for high-value players.
- **Revenue Maximization**: Provides insights into which campaigns drive the highest revenue from high-jackpot games.
- **Customer Acquisition Strategy**: Informs strategic decisions about targeting and messaging for high-value player acquisition.
- **Performance Benchmarking**: Establishes benchmarks for campaign performance and ROI across different channels.

#### Data Sources

This model integrates data from multiple staging models:

- `{{ ref('stg_games') }}`: Game metadata and jackpot information for identifying high-jackpot games.
- `{{ ref('stg_ticket_purchases') }}`: Purchase transactions to identify high-jackpot game participation.
- `{{ ref('stg_web_events') }}`: Marketing touchpoints and attribution data.
- `{{ ref('stg_signups') }}`: Customer signup information for conversion funnel analysis.
- `{{ ref('stg_funnel_spend') }}`: Marketing spend data for ROI calculations.

#### Transformation Logic

The `high_jackpot_analysis` model processes data through several analytical stages:

1. **high_jackpot_games**: Identifies games that meet the high-jackpot threshold criteria using the configurable variable `{{ var('high_jackpot_threshold_minor') }}`. Converts jackpot amounts from minor units to USD for easier analysis.

2. **high_jackpot_purchases**: Joins ticket purchases with high-jackpot games to identify all high-jackpot transactions, including purchase amounts and jackpot estimates.

3. **user_first_high_jackpot**: Aggregates high-jackpot purchase data by user to calculate key metrics:
   - First high-jackpot purchase timestamp
   - Total high-jackpot spend
   - Number of high-jackpot purchases
   - Unique high-jackpot games played

4. **user_marketing_attribution**: Links marketing touchpoints to high-jackpot behavior by:
   - Identifying the first marketing touch for each user
   - Calculating time from first touch to high-jackpot purchase
   - Measuring conversion speed from signup to high-jackpot participation

5. **campaign_high_jackpot_performance**: Aggregates performance metrics at the campaign level:
   - High-jackpot conversion rates
   - Revenue from high-jackpot players
   - ROAS for high-jackpot acquisition
   - Cost per acquisition for high-jackpot players
   - Average spend per high-jackpot player

6. **channel_performance**: Provides channel-level insights by aggregating campaign performance across channels.

7. **high_jackpot_segments**: Creates customer segments based on high-jackpot behavior:
   - Player segments (Whale, High Roller, Regular, Occasional)
   - Engagement levels (Very Engaged, Engaged, Moderately Engaged, Lightly Engaged)
   - Conversion speed categories (Immediate, Quick, Standard, Slow)

#### Key Output Columns

The `high_jackpot_analysis` model outputs comprehensive performance metrics including:

- **Campaign Identification**: `utm_campaign`, `channel`
- **Financial Metrics**: `spend_usd`, `total_high_jackpot_revenue`, `high_jackpot_roas`, `cpa_high_jackpot_player`
- **Conversion Metrics**: `high_jackpot_players`, `high_jackpot_conversion_rate`, `avg_high_jackpot_spend_per_player`
- **Timing Metrics**: `avg_days_to_high_jackpot`, `avg_days_from_signup_to_high_jackpot`
- **Performance Indicators**: `performance_category` (Exceptional, High Performing, Medium Performing, Low Performing)
- **Channel Benchmarks**: `channel_avg_conversion_rate`, `channel_avg_roas`
- **Metadata**: `dbt_updated_at`

#### Data Quality & Governance

The `high_jackpot_analysis` model implements several data quality measures:

- **Threshold Configuration**: Uses dbt variables for configurable high-jackpot thresholds, ensuring flexibility across different business contexts.
- **Null Handling**: Implements proper null handling for users without high-jackpot purchases to ensure accurate conversion rate calculations.
- **Referential Integrity**: Maintains data integrity through proper joins with staging models.
- **Performance Validation**: Includes performance category classifications to identify exceptional and underperforming campaigns.

#### Performance Considerations

- **Materialization**: Materialized as a table to ensure optimal query performance for downstream BI tools and consistent data availability.
- **Aggregation Strategy**: Pre-computes complex aggregations and calculations to reduce query time for end users.
- **Indexing**: The model structure supports efficient filtering and sorting by campaign, channel, and performance metrics.

#### Business Applications

This model directly supports several key business initiatives:

1. **Marketing Budget Allocation**: Identify which channels and campaigns should receive increased budget based on high-jackpot player acquisition performance.

2. **Campaign Optimization**: Optimize messaging and targeting for campaigns that show high potential for acquiring high-value players.

3. **Channel Strategy**: Develop channel-specific strategies based on performance insights and conversion characteristics.

4. **ROI Reporting**: Provide executive-level reporting on marketing ROI specifically for high-value customer acquisition.

5. **Competitive Analysis**: Benchmark performance across different marketing channels and campaigns.

## 🔗 Inter-Model Dependencies

The `marts/finance` domain exhibits clear dependencies:

- **Upstream Dependencies**: Relies on staging models for clean, standardized data inputs.
- **Cross-Domain Integration**: Can be joined with `marts/customer` models for enriched customer analysis.
- **Downstream Consumption**: Designed for direct consumption by BI tools and executive dashboards.

This finance analytics domain ensures that financial insights are accurate, actionable, and aligned with business objectives, providing the foundation for data-driven financial decision-making.
