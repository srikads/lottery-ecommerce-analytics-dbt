# Marts Layer

Business-ready models organized by domain, optimized for end-user analytics and reporting.

## Domain Structure

### `customer/` - Customer Analytics
**Models**:
- `dim_customer.sql` - Comprehensive customer dimension
- `customer_ltv_scoring.sql` - VIP segmentation and LTV prediction

**Key Metrics**: Customer acquisition, lifetime value, behavioral patterns

### `marketing/` - Marketing Analytics
**Models**:
- `marketing_attribution.sql` - Campaign performance and ROAS analysis

**Key Metrics**: Campaign performance, attribution, channel effectiveness

### `finance/` - Financial Analytics
**Models**:
- `high_jackpot_analysis.sql` - High-value player acquisition analysis

**Key Metrics**: Revenue optimization, high-value player analysis

## Design Principles

- **Domain-Driven Design**: Models organized by business domain
- **Star Schema Design**: Fact and dimension tables optimized for analytics
- **Business User Focus**: Intuitive naming and pre-calculated metrics
- **Performance Optimization**: Materialized as tables with appropriate indexing 