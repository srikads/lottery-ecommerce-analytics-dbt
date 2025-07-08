# Marketing Analytics Data Mart

This `marts/marketing` directory serves as the dedicated domain for all marketing-centric analytical data models within the dbt project. These models are strategically designed to provide comprehensive marketing attribution, campaign performance analysis, and conversion funnel insights that drive data-informed marketing decisions and optimize customer acquisition strategies.

## 🎯 Purpose and Business Impact

The overarching purpose of this domain is to:

1. **Enable Marketing Attribution**: Provide accurate and comprehensive attribution models that measure the effectiveness of marketing campaigns across different touchpoints and channels.
2. **Optimize Campaign Performance**: Deliver detailed insights into campaign ROI, conversion rates, and customer acquisition costs to inform marketing budget allocation and strategy.
3. **Facilitate Conversion Optimization**: Offer granular analysis of the customer journey from first marketing touch to conversion, enabling optimization of conversion funnels.
4. **Support Data-Driven Marketing**: Provide actionable insights that enable marketing teams to make informed decisions about campaign targeting, messaging, and budget allocation.

These models directly contribute to answering critical business questions:

- **Return on Ad Spend (ROAS)**: What is our Return on Ad Spend, measured by players' first-time deposits?
- **Marketing Channel Effectiveness**: Which marketing channels and campaigns are most effective at driving conversions?
- **Customer Acquisition Costs**: What are the costs associated with acquiring customers through different channels?
- **Conversion Funnel Analysis**: How do customers move through the marketing funnel from first touch to conversion?

## 📁 Models Overview

This directory contains one primary analytical model: `marketing_attribution`.

### `marketing_attribution.sql` - Comprehensive Marketing Attribution Analysis

The `marketing_attribution` model is specifically engineered to provide comprehensive marketing attribution analysis, combining first-touch and multi-touch attribution methodologies to deliver accurate insights into marketing campaign performance and ROI.

#### Purpose

- To calculate accurate Return on Ad Spend (ROAS) for marketing campaigns based on first-time deposits.
- To provide both first-touch and multi-touch attribution models for comprehensive marketing analysis.
- To measure conversion rates and customer acquisition costs across different marketing channels.
- To enable data-driven decisions for marketing budget allocation and campaign optimization.

#### Business Value

- **Marketing ROI Optimization**: Enables marketing teams to identify high-performing campaigns and allocate budget more effectively.
- **Attribution Accuracy**: Provides multiple attribution models to understand the true impact of marketing efforts across the customer journey.
- **Conversion Funnel Insights**: Offers detailed analysis of the time from marketing touch to conversion, enabling funnel optimization.
- **Channel Performance Comparison**: Facilitates comparison of performance across different marketing channels and campaigns.

#### Data Sources

This model integrates data from multiple staging models:

- `{{ ref('stg_funnel_spend') }}`: Marketing spend data for campaign cost analysis and ROI calculations.
- `{{ ref('stg_web_events') }}`: Marketing touchpoints and attribution data for understanding customer journey.
- `{{ ref('stg_signups') }}`: Customer signup information for conversion funnel analysis.
- `{{ ref('stg_deposits') }}`: Deposit transactions for revenue attribution and conversion measurement.

#### Transformation Logic

The `marketing_attribution` model processes data through several analytical stages:

1. **campaign_spend**: Standardizes marketing spend data by converting minor units to USD and preparing campaign cost data for attribution analysis.

2. **first_touch_attribution**: Implements first-touch attribution methodology by:
   - Identifying the first marketing touch for each user
   - Calculating time from first touch to signup and first deposit
   - Linking marketing touchpoints to conversion events
   - Measuring conversion timing and effectiveness

3. **campaign_attribution**: Aggregates first-touch attribution metrics at the campaign level:
   - Attributed users and depositing users
   - Total and average first deposit amounts
   - Conversion rates from signup to deposit
   - ROAS calculations based on first deposits
   - Cost per acquisition metrics

4. **multi_touch_attribution**: Implements weighted multi-touch attribution by:
   - Identifying all marketing touches in the customer journey
   - Assigning weights to different touch positions (first touch: 40%, last touch: 40%, middle touches: 20%)
   - Calculating weighted attribution for more accurate campaign impact measurement

5. **weighted_attribution**: Aggregates multi-touch attribution metrics:
   - Weighted touches and unique users
   - Weighted depositing users and deposit value
   - Weighted ROAS calculations

6. **Final SELECT**: Combines first-touch and multi-touch attribution results with:
   - Performance indicators and categories
   - Attribution comparison metrics
   - Channel effectiveness classifications

#### Key Output Columns

The `marketing_attribution` model outputs comprehensive marketing performance metrics including:

- **Campaign Identification**: `utm_campaign`, `channel`
- **Financial Metrics**: `spend_usd`, `total_first_deposits_usd`, `avg_first_deposit_usd`
- **First-Touch Attribution**: `attributed_users`, `depositing_users`, `roas_first_deposit`, `cpa_first_deposit`
- **Conversion Metrics**: `signup_to_deposit_conversion_rate`, `avg_days_to_signup`, `avg_days_to_first_deposit`
- **Multi-Touch Attribution**: `weighted_touches`, `weighted_depositing_users`, `weighted_roas`
- **Performance Indicators**: `performance_category` (High Performing, Medium Performing, Low Performing)
- **Conversion Categories**: `conversion_category` (High Conversion, Medium Conversion, Low Conversion)
- **Attribution Comparison**: `attribution_difference` (difference between first-touch and weighted ROAS)
- **Metadata**: `dbt_updated_at`

#### Attribution Methodologies

The model implements two complementary attribution approaches:

1. **First-Touch Attribution**: Attributes 100% of the conversion value to the first marketing touch, useful for understanding initial customer acquisition effectiveness.

2. **Multi-Touch Attribution**: Uses a weighted approach where:
   - First touch receives 40% of attribution (customer discovery)
   - Last touch receives 40% of attribution (final conversion driver)
   - Middle touches share the remaining 20% (nurturing and engagement)

This dual approach provides a more nuanced understanding of marketing effectiveness across the customer journey.

#### Data Quality & Governance

The `marketing_attribution` model implements several data quality measures:

- **Null Handling**: Proper handling of null values in conversion calculations to ensure accurate metrics.
- **Division by Zero Protection**: Implements `nullif` functions to prevent division by zero in rate calculations.
- **Data Validation**: Ensures marketing spend data is properly linked to campaign attribution data.
- **Performance Classification**: Automatic categorization of campaigns based on performance thresholds.

#### Performance Considerations

- **Materialization**: Materialized as a table to ensure optimal query performance for downstream BI tools and consistent data availability.
- **Aggregation Strategy**: Pre-computes complex attribution calculations to reduce query time for end users.
- **Indexing**: The model structure supports efficient filtering and sorting by campaign, channel, and performance metrics.

#### Business Applications

This model directly supports several key marketing initiatives:

1. **Campaign Performance Analysis**: Identify top-performing campaigns and channels for budget optimization.

2. **ROI Reporting**: Provide executive-level reporting on marketing ROI and customer acquisition costs.

3. **Attribution Strategy**: Understand the relative importance of different touchpoints in the customer journey.

4. **Conversion Optimization**: Identify bottlenecks in the conversion funnel and opportunities for improvement.

5. **Budget Allocation**: Make data-driven decisions about marketing spend allocation across channels and campaigns.

6. **A/B Testing Support**: Provide baseline metrics for campaign testing and optimization.

## 🔗 Inter-Model Dependencies

The `marts/marketing` domain exhibits clear dependencies:

- **Upstream Dependencies**: Relies on staging models for clean, standardized data inputs.
- **Cross-Domain Integration**: Can be joined with `marts/customer` and `marts/finance` models for enriched analysis.
- **Downstream Consumption**: Designed for direct consumption by BI tools, marketing dashboards, and executive reporting.

This marketing analytics domain ensures that marketing insights are accurate, actionable, and aligned with business objectives, providing the foundation for data-driven marketing decision-making and campaign optimization.
