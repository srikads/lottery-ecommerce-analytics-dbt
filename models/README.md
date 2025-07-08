# Data Models

This directory contains data transformation models organized in a layered architecture.

## Architecture

```
Raw Sources → Staging → Intermediate → Marts
     ↓           ↓           ↓          ↓
   Clean      Standardize  Transform  Business
   Data       Data         Data       Ready
```

## Directory Structure

### `staging/` - Data Cleaning Layer
Clean and standardize raw source data (views).

**Models**:
- `stg_signups.sql` - User registration data
- `stg_deposits.sql` - User deposit transactions  
- `stg_ticket_purchases.sql` - Lottery ticket purchases
- `stg_games.sql` - Lottery game definitions
- `stg_funnel_spend.sql` - Marketing campaign spend
- `stg_web_events.sql` - Web tracking events

### `intermediate/` - Complex Transformations
Handle complex business logic and multi-table transformations (tables).

**Models**:
- `int_identity_stitching.sql` - Unifies anonymous and authenticated user journeys

### `marts/` - Business-Ready Models
Domain-specific models optimized for business users (tables).

**Domains**:
- `customer/` - Customer analytics and segmentation
- `marketing/` - Marketing attribution and campaign performance
- `finance/` - Financial analysis and revenue optimization

## Design Principles

- **Separation of Concerns**: Each layer has a specific purpose
- **Domain-Driven Design**: Models organized by business domain
- **Data Quality First**: Comprehensive testing at each layer
- **Performance Optimization**: Appropriate materialization strategies 