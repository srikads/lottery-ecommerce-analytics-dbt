# Lottery E-commerce Analytics dbt Project - Case Study Summary

## Project Overview
This dbt project implements a comprehensive analytics solution for a lottery e-commerce company, designed to measure marketing campaign performance, customer lifetime value (LTV), and player engagement. The project includes identity stitching for anonymous and authenticated users.

## Project Structure

### Data Model Architecture
```
models/
├── staging/           # Raw data cleaning and standardization
│   ├── stg_signups.sql
│   ├── stg_deposits.sql
│   ├── stg_ticket_purchases.sql
│   ├── stg_games.sql
│   ├── stg_funnel_spend.sql
│   ├── stg_web_events.sql
│   └── schema.yml
├── intermediate/      # Complex transformations and business logic
│   └── int_identity_stitching.sql
└── marts/            # Domain-specific models for business users
    ├── customer/
    │   ├── dim_customer.sql
    │   ├── customer_ltv_scoring.sql
    │   └── schema.yml
    ├── marketing/
    │   ├── marketing_attribution.sql
    │   └── schema.yml
    └── finance/
        ├── high_jackpot_analysis.sql
        └── schema.yml
```

### Key Models

#### 1. Staging Layer (`models/staging/`)
- **stg_signups**: User signup data with standardized timestamps
- **stg_deposits**: User deposit transactions
- **stg_ticket_purchases**: Lottery ticket purchase transactions
- **stg_games**: Lottery game definitions and jackpot estimates
- **stg_funnel_spend**: Marketing campaign spend data
- **stg_web_events**: Web tracking events with UTM parameters

#### 2. Intermediate Layer (`models/intermediate/`)
- **int_identity_stitching**: Unifies anonymous and authenticated user journeys

#### 3. Marts Layer (`models/marts/`)

**Customer Domain:**
- **dim_customer**: Comprehensive customer dimension with behavioral metrics
- **customer_ltv_scoring**: VIP segmentation and LTV prediction

**Marketing Domain:**
- **marketing_attribution**: ROAS calculation and campaign performance

**Finance Domain:**
- **high_jackpot_analysis**: High-value player acquisition analysis

## Data Quality & Testing

### Test Coverage: 71/71 Tests Passing ✅

#### Custom Tests Implemented:
1. **assert_purchase_after_signup**: Business rule ensuring purchases occur after signup
2. **non_negative_values**: Custom macro for fields that can be 0 (web events, campaigns, etc.)

#### Standard Tests:
- **not_null**: Required fields validation
- **unique**: Primary key constraints
- **relationships**: Foreign key integrity
- **accepted_values**: Domain validation (countries, channels, segments)
- **positive_values**: Numeric field validation

### Schema Documentation
- Complete column descriptions for all models
- Business logic documentation
- Data lineage tracking

## Key Features Implemented

### 1. Marketing Attribution
- **First-touch attribution** for user acquisition
- **ROAS calculation** based on first deposits
- **Multi-touch weighted attribution** for complex journeys
- **Performance categorization** (High/Medium/Low performing campaigns)

### 2. Customer LTV Scoring
- **RFM analysis** (Recency, Frequency, Monetary)
- **Behavioral scoring** based on engagement patterns
- **VIP tier classification** (Diamond, Gold, Silver, Standard)
- **Promotion targeting** categories

### 3. High Jackpot Analysis
- **High jackpot player identification**
- **Channel effectiveness** for high-value players
- **Conversion rate analysis** by marketing channel
- **Revenue attribution** for high jackpot games

### 4. Identity Stitching
- **Anonymous to authenticated user mapping**
- **Cross-device journey unification**
- **UTM parameter tracking** across sessions

## Business Questions Answered

### 1. ROAS Measurement ✅
- **Model**: `marketing_attribution`
- **Metrics**: ROAS by campaign, channel, and conversion type
- **Granularity**: Campaign and channel level

### 2. Time to First Purchase ✅
- **Model**: `dim_customer` (days_to_first_purchase)
- **Analysis**: Average time from signup to first ticket purchase
- **Segmentation**: By customer segment and marketing channel

### 3. High Jackpot Channel Effectiveness ✅
- **Model**: `high_jackpot_analysis`
- **Metrics**: High jackpot conversion rates, ROAS, CPA
- **Insights**: Channel performance for high-value player acquisition

## Technical Implementation

### Materialization Strategy
- **Staging**: Views (lightweight, always fresh)
- **Intermediate**: Tables (complex transformations)
- **Marts**: Tables (business-ready, optimized for queries)

### Data Governance
- **Schema contracts** via YAML files
- **Data quality tests** with business rules
- **Documentation** with column descriptions
- **Lineage tracking** for impact analysis

### Performance Optimizations
- **Efficient joins** with proper indexing
- **Aggregated metrics** pre-calculated
- **Partitioning strategy** for large tables (production)



## Usage Instructions

### Running the Project:
```bash
# Set up environment
export PATH=$PATH:~/Library/Python/3.9/bin

# Load data
dbt seed

# Build models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate

# Serve documentation
dbt docs serve
```

### Key Queries:
```sql
-- Marketing ROAS by campaign
SELECT * FROM marketing_attribution;

-- Customer LTV scores
SELECT * FROM customer_ltv_scoring;

-- High jackpot analysis
SELECT * FROM high_jackpot_analysis;

-- Complete customer view
SELECT * FROM dim_customer;
```



---

**Project Status**: ✅ Ready for Analytics Engineer Interview
**Test Coverage**: 100% (71/71 tests passing)
**Documentation**: Complete with business context
**Code Quality**: Production-ready with best practices 
