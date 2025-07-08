# Seeds - Sample Data

This directory contains static CSV files that represent the raw source data for the lottery e-commerce analytics project. These files serve as sample data for local development and testing.

## 🎯 Purpose

- **Sample Data**: Representative data for development and testing
- **Business Context**: Realistic scenarios for lottery e-commerce operations
- **Data Validation**: Test business logic with known data patterns
- **Documentation**: Illustrate data structure and relationships

## 📁 Files

### `signups.csv`
**Purpose**: User registration data  
**Rows**: 3 sample users  
**Business Context**: New customer acquisitions across different countries

**Columns**:
- `user_id` (Primary Key): Unique user identifier
- `signup_id`: Unique signup event identifier
- `signup_timestamp`: User registration timestamp
- `country`: User's country (US, CA, GB)

**Sample Data**:
```csv
user_id,signup_id,signup_timestamp,country
1,1001,2024-01-01 10:00:00,US
2,1002,2024-01-02 11:00:00,CA
3,1003,2024-01-03 12:00:00,GB
```

### `deposits.csv`
**Purpose**: User deposit transactions  
**Rows**: 3 sample deposits  
**Business Context**: Customer funding behavior and patterns

**Columns**:
- `deposit_id` (Primary Key): Unique deposit identifier
- `user_id` (Foreign Key): References signups.user_id
- `deposit_amount_inminor`: Deposit amount in minor units (cents)
- `deposit_timestamp`: Transaction timestamp

**Sample Data**:
```csv
deposit_id,user_id,deposit_amount_inminor,deposit_timestamp
2001,1,5000,2024-01-01 10:30:00
2002,2,10000,2024-01-02 12:00:00
2003,1,3000,2024-01-03 14:00:00
```

### `ticket_purchases.csv`
**Purpose**: Lottery ticket purchase transactions  
**Rows**: 3 sample purchases  
**Business Context**: Core revenue generation from ticket sales

**Columns**:
- `purchase_id` (Primary Key): Unique purchase identifier
- `user_id` (Foreign Key): References signups.user_id
- `game_id` (Foreign Key): References games.game_id
- `purchase_amount_usd`: Purchase amount in USD
- `purchase_timestamp`: Transaction timestamp

**Sample Data**:
```csv
purchase_id,user_id,game_id,purchase_amount_usd,purchase_timestamp
3001,1,4001,5.00,2024-01-01 10:10:00
3002,2,4002,10.00,2024-01-02 11:20:00
3003,3,4001,2.00,2024-01-03 12:30:00
```

### `games.csv`
**Purpose**: Lottery game definitions  
**Rows**: 2 sample games  
**Business Context**: Different lottery games with varying jackpot sizes

**Columns**:
- `game_id` (Primary Key): Unique game identifier
- `game_name`: Game name/identifier
- `jackpot_estimate_inminor`: Estimated jackpot in minor units

**Sample Data**:
```csv
game_id,game_name,jackpot_estimate_inminor
4001,Eurojackpot,100000000
4002,Powerball,50000000
```

### `funnel_spend.csv`
**Purpose**: Marketing campaign spend data  
**Rows**: 2 sample campaigns  
**Business Context**: Marketing investment across different channels

**Columns**:
- `date`: Campaign date
- `campaign_name`: Campaign identifier
- `channel`: Marketing channel (Email, Social, Search, Display, Affiliate)
- `spend_inminor`: Campaign spend in minor units

**Sample Data**:
```csv
date,campaign_name,channel,spend_inminor
2024-01-01,Winter_Lottery,Email,50000
2024-01-02,New_Year_Bonanza,Social,75000
```

### `web_events.csv`
**Purpose**: Web tracking events  
**Rows**: 3 sample events  
**Business Context**: User behavior tracking and attribution

**Columns**:
- `event_id` (Primary Key): Unique event identifier
- `user_id` (Optional): References signups.user_id (for authenticated users)
- `anonymous_user_id` (Optional): Anonymous user identifier
- `utm_campaign`: UTM campaign parameter
- `event_timestamp`: Event timestamp

**Sample Data**:
```csv
event_id,user_id,anonymous_user_id,utm_campaign,event_timestamp
5001,1,,Winter_Lottery,2024-01-01 09:45:00
5002,,anon_001,New_Year_Bonanza,2024-01-02 10:30:00
5003,2,,Winter_Lottery,2024-01-02 11:15:00
```

## 🔗 Data Relationships

### Entity Relationship Diagram
```
signups (1) ←→ (many) deposits
    ↓
    ↓ (1) ←→ (many) ticket_purchases
    ↓
    ↓ (many) ←→ (1) games
    ↓
    ↓ (many) ←→ (many) web_events
    ↓
    ↓ (many) ←→ (many) funnel_spend
```

### Key Relationships
1. **User Journey**: signups → deposits → ticket_purchases
2. **Game Selection**: ticket_purchases → games
3. **Marketing Attribution**: web_events → funnel_spend (via utm_campaign)
4. **Identity Stitching**: web_events (user_id + anonymous_user_id)

## 📊 Business Scenarios

### Scenario 1: High-Value Customer
- **User 1**: US customer with multiple deposits and purchases
- **Behavior**: Engages with high jackpot games
- **Marketing**: Attributed to Winter_Lottery campaign

### Scenario 2: New Customer
- **User 2**: CA customer with single deposit and purchase
- **Behavior**: Standard lottery participation
- **Marketing**: Attributed to New_Year_Bonanza campaign

### Scenario 3: Anonymous to Authenticated
- **User 3**: GB customer with web events before signup
- **Behavior**: Anonymous browsing before registration
- **Marketing**: Identity stitching opportunity

## 🧪 Testing Scenarios

### Data Quality Tests
- **Completeness**: All required fields populated
- **Accuracy**: Valid foreign key relationships
- **Consistency**: Proper data types and formats

### Business Logic Tests
- **Purchase After Signup**: All purchases occur after user registration
- **Positive Values**: All monetary amounts are positive
- **Valid Countries**: Country codes match accepted values

### Edge Cases
- **Anonymous Users**: Web events without user_id
- **Multiple Deposits**: Users with multiple funding events
- **High Jackpot Games**: Games with large jackpot estimates

## 🔧 Usage

### Loading Data
```bash
# Load all seed data
dbt seed

# Load specific seed
dbt seed --select signups

# Load with custom schema
dbt seed --schema-name custom_schema
```

### Querying Data
```sql
-- Check data relationships
SELECT 
    s.user_id,
    s.country,
    COUNT(d.deposit_id) as deposit_count,
    COUNT(t.purchase_id) as purchase_count
FROM signups s
LEFT JOIN deposits d ON s.user_id = d.user_id
LEFT JOIN ticket_purchases t ON s.user_id = t.user_id
GROUP BY s.user_id, s.country;
```

### Validation Queries
```sql
-- Validate foreign key relationships
SELECT COUNT(*) as orphaned_deposits
FROM deposits d
LEFT JOIN signups s ON d.user_id = s.user_id
WHERE s.user_id IS NULL;

-- Check for data quality issues
SELECT COUNT(*) as invalid_purchases
FROM ticket_purchases t
JOIN signups s ON t.user_id = s.user_id
WHERE t.purchase_timestamp < s.signup_timestamp;
```

## 📈 Business Insights

### Customer Behavior Patterns
1. **Geographic Distribution**: Users across US, CA, GB
2. **Funding Patterns**: Multiple deposits per user
3. **Game Preferences**: Mix of high and standard jackpot games
4. **Marketing Attribution**: Campaign tracking via UTM parameters

### Revenue Patterns
1. **Deposit Amounts**: Range from $30 to $100
2. **Purchase Amounts**: Range from $2 to $10
3. **Game Revenue**: High jackpot games drive larger purchases
4. **Marketing ROI**: Campaign spend vs. attributed revenue

### User Journey Insights
1. **Signup to Deposit**: Time gap between registration and funding
2. **Deposit to Purchase**: Conversion from funding to ticket purchase
3. **Anonymous to Authenticated**: Web tracking before registration
4. **Campaign Attribution**: Marketing touchpoints in user journey
