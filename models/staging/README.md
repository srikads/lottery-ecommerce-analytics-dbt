# Staging Layer

Raw data transformations with minimal business logic. Models are materialized as views for lightweight, always-fresh data.

## Models

- `stg_signups.sql` - User registration data
- `stg_deposits.sql` - User deposit transactions  
- `stg_ticket_purchases.sql` - Lottery ticket purchases
- `stg_games.sql` - Lottery game definitions
- `stg_funnel_spend.sql` - Marketing campaign spend
- `stg_web_events.sql` - Web tracking events

## Purpose

- Clean and standardize raw source data
- Apply consistent naming conventions
- Handle data type conversions
- Remove obvious data quality issues 