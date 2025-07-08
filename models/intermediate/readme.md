# Identity Stitching - Technical Approach

This `models/intermediate/` directory contains the `int_identity_stitching` model, which implements a sophisticated identity resolution system to unify anonymous and authenticated user journeys. This approach enables complete customer journey tracking from first marketing touch through conversion and beyond.

## 🎯 Purpose and Business Impact

The identity stitching model addresses a critical challenge in digital analytics: **connecting anonymous user behavior to authenticated user profiles**. This enables:

1. **Complete Customer Journey Analysis**: Track users from first marketing touch through signup and beyond
2. **Accurate Attribution Modeling**: Attribute conversions to the correct marketing touchpoints, even when users start as anonymous
3. **Enhanced Customer Insights**: Understand the full path-to-conversion for better marketing optimization
4. **Improved ROAS Calculations**: More accurate return on ad spend by capturing pre-signup engagement

## 🔧 Technical Approach

### Overview
The identity stitching process uses a **probabilistic matching algorithm** that combines multiple signals to link anonymous users to authenticated profiles with high confidence.

### Core Methodology

#### 1. **Data Segmentation**
```sql
-- Separate anonymous and authenticated events
anonymous_events: user_id IS NULL, anonymous_user_id IS NOT NULL
authenticated_events: user_id IS NOT NULL
```

#### 2. **Matching Criteria**
The algorithm uses a **scoring system** based on multiple signals:

- **UTM Campaign Matching** (3 points): Same marketing campaign
- **Temporal Proximity** (2 points): Events within 1 day
- **Temporal Proximity** (1 point): Events within 1 week
- **Maximum Time Window**: 30 days for potential matches

#### 3. **Confidence Scoring**
```sql
match_score = 
  CASE WHEN same_campaign THEN 3 ELSE 0 END +
  CASE WHEN time_diff <= 1 THEN 2 
       WHEN time_diff <= 7 THEN 1 
       ELSE 0 END
```

#### 4. **Match Selection**
- **Minimum Threshold**: Match score ≥ 3 (ensures high confidence)
- **Best Match Selection**: For each anonymous user, select the highest-scoring authenticated user
- **One-to-One Mapping**: Each anonymous user maps to at most one authenticated user

### Technical Implementation

#### Phase 1: Potential Match Identification
```sql
potential_matches as (
    select 
        ae.anonymous_user_id,
        aue.user_id,
        ae.utm_campaign,
        -- Calculate time difference and match score
        julianday(aue.event_timestamp) - julianday(ae.event_timestamp) as time_difference_days,
        -- Scoring logic here
    from anonymous_events ae
    cross join authenticated_events aue
    where ae.utm_campaign = aue.utm_campaign
    and abs(time_difference) <= 30
)
```

#### Phase 2: Best Match Selection
```sql
best_matches as (
    select 
        anonymous_user_id,
        user_id,
        match_score,
        row_number() over (partition by anonymous_user_id 
                          order by match_score desc, time_difference_days asc) as match_rank
    from potential_matches
    where match_score >= 3
)
```

#### Phase 3: Journey Unification
```sql
unified_user_journey as (
    -- Combine anonymous and authenticated events
    -- Apply identity mappings
    -- Categorize journey stages
)
```

## 📊 Journey Stage Classification

The model categorizes user interactions into distinct journey stages:

- **`pre_signup`**: Anonymous events that are later linked to authenticated users
- **`post_signup`**: Events that occur after user authentication
- **`authenticated_only`**: Users who only have authenticated events
- **`anonymous_only`**: Users who only have anonymous events

## 🎯 Business Applications

### 1. **Marketing Attribution Enhancement**
- **Pre-signup Attribution**: Attribute conversions to marketing touchpoints that occurred before signup
- **Multi-touch Journey Analysis**: Understand the complete path from first touch to conversion
- **Campaign Effectiveness**: Measure which campaigns drive both awareness and conversion

### 2. **Customer Journey Optimization**
- **Conversion Funnel Analysis**: Identify drop-off points in the pre-signup journey
- **Touchpoint Optimization**: Understand which marketing touchpoints are most effective at each stage
- **Timing Analysis**: Optimize the timing of marketing messages and conversion prompts

### 3. **ROAS Calculation Improvement**
- **Complete Attribution**: Include pre-signup engagement in ROAS calculations
- **Accurate Cost Allocation**: Distribute marketing costs across the full customer journey
- **Channel Performance**: Compare channel effectiveness across different journey stages

## 🔍 Data Quality & Validation

### Confidence Metrics
- **`match_score`**: Numerical confidence in the identity resolution (3-5 points)
- **`mapping_status`**: Status of the identity mapping ('confirmed' or null)
- **`has_identity_resolution`**: Boolean indicating successful identity resolution

### Validation Rules
- **Minimum Confidence Threshold**: Only matches with score ≥ 3 are considered valid
- **Temporal Constraints**: Maximum 30-day window for potential matches
- **One-to-One Mapping**: Prevents multiple anonymous users mapping to the same authenticated user

## 📈 Output Metrics

The model provides comprehensive journey analytics:

### User Identification
- `unified_user_id`: Primary identifier for the unified user journey
- `has_identity_resolution`: Whether anonymous and authenticated events were successfully linked
- `max_match_score`: Highest confidence score for the identity resolution

### Journey Metrics
- `first_touch_timestamp`: Earliest recorded interaction
- `last_touch_timestamp`: Most recent interaction
- `total_events`: Total number of interactions across the journey
- `unique_campaigns`: Number of distinct marketing campaigns engaged with

### Stage-Specific Metrics
- `pre_signup_events`: Number of events before user authentication
- `post_signup_events`: Number of events after user authentication
- `anonymous_only_events`: Events that couldn't be linked to authenticated users

### Journey Analysis
- `journey_completeness`: Classification of journey type (Complete, Pre-signup Only, Post-signup Only, Anonymous Only)
- `campaign_journey`: Chronological sequence of campaigns engaged with
- `earliest_event_days_from_signup`: Days from signup to first recorded event
- `latest_event_days_from_signup`: Days from signup to last recorded event

## 🚀 Performance Considerations

### Optimization Strategies
- **Efficient Joins**: Uses indexed fields for optimal join performance
- **Filtered Cross Joins**: Applies constraints early to reduce computational complexity
- **Window Functions**: Uses row_number() for efficient best match selection
- **Materialization**: Materialized as table for consistent query performance

### Scalability
- **Batch Processing**: Designed for batch processing of identity resolution
- **Incremental Updates**: Can be adapted for incremental processing in production
- **Memory Efficiency**: Optimized to handle large volumes of user events

## 🔗 Integration with Other Models

The identity stitching model serves as a foundation for:

1. **`dim_customer`**: Enhanced customer profiles with complete journey data
2. **`marketing_attribution`**: More accurate attribution by including pre-signup engagement
3. **`customer_ltv_scoring`**: Better LTV predictions with complete behavioral data
4. **`high_jackpot_analysis`**: Improved understanding of high-value customer acquisition


This identity stitching approach provides a robust foundation for complete customer journey analysis, enabling more accurate marketing attribution and deeper customer insights across the entire user lifecycle.
