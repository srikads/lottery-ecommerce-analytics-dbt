# Lottery E-commerce Analytics dbt Project

A dbt project for analyzing lottery e-commerce data, including customer behavior, marketing attribution, and high jackpot analysis.

## Quick Start

### Prerequisites
- Python 3.8+
- dbt Core 1.10+
- SQLite (for local development)

### Installation

1. **Install dbt**
   ```bash
   pip install dbt-core dbt-sqlite
   ```

2. **Configure database**
   
   Create `profiles.yml`:
   ```yaml
   lottery_ecommerce:
     target: dev
     outputs:
       dev:
         type: sqlite
         database: target/lottery_ecommerce.db
         schema: main
         schemas_and_paths:
           main: target/lottery_ecommerce.db
         schema_directory: target/
         threads: 1
   ```

3. **Run the project**
   ```bash
   dbt debug
   dbt seed
   dbt run
   dbt test
   ```

## Project Structure

```
models/
├── staging/          # Raw data staging
├── intermediate/     # Complex transformations  
└── marts/           # Business-ready analytics
    ├── customer/     # Customer analytics
    ├── finance/      # Financial analytics
    └── marketing/    # Marketing analytics

seeds/               # Static data files
macros/              # Reusable SQL components
tests/               # Custom data tests
```

## Data Models

### Staging Layer
Raw data transformations with minimal business logic.

### Intermediate Layer  
Complex transformations and business logic.

### Marts Layer
Business-ready analytics tables for customer, financial, and marketing analysis.

# Project Assumptions

## Business Assumptions

### Customer Identity
- Users can be uniquely identified across systems
- Identity stitching logic correctly matches users across platforms
- Customer IDs remain consistent over time
- Anonymous users can be tracked via session IDs

### Financial Transactions
- All monetary amounts are in the same currency (assumed USD)
- Transaction amounts are positive for deposits, negative for withdrawals
- Failed transactions are excluded from analysis
- Refunds are handled as separate transaction types

### Gaming Behavior
- Ticket purchases represent actual lottery participation
- Game outcomes are independent events

### Lottery Operations
- Lottery games follow standard probability rules
- Ticket pricing is consistent across games
- User journey follows typical e-commerce patterns

## Technical Assumptions

### Data Quality
- All required source tables are available and accessible
- Data is consistently loaded and updated
- No critical data gaps exist in the source systems
- Timestamps are in a consistent timezone (assumed UTC)
- Primary keys are unique and not null
- Foreign key relationships are maintained
- No duplicate records exist in source tables
- Data types are consistent across loads








"# lottery-ecommerce-analytics-dbt" 
