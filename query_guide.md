# How to View dbt Model Results

## 🎯 Quick Start - View Results

### Method 1: dbt Documentation (Recommended)
The dbt documentation server is now running at: **http://localhost:8080**

1. Open your browser and go to `http://localhost:8080`
2. Click on any model name to see its details
3. Click "Preview" to see the actual data
4. View the DAG (Directed Acyclic Graph) to see model dependencies

### Method 2: Direct SQLite Queries
```bash
# View Customer LTV Scoring Results
sqlite3 main_main.db "SELECT user_id, country, ltv_score, vip_tier FROM customer_ltv_scoring ORDER BY ltv_score DESC;"

# View Marketing Attribution Results  
sqlite3 main_main.db "SELECT utm_campaign, channel, roas_first_deposit, performance_category FROM marketing_attribution;"

# View High Jackpot Analysis
sqlite3 main_main.db "SELECT game_name, ticket_count, total_revenue_usd FROM high_jackpot_analysis;"

# View Identity Stitching
sqlite3 main_main.db "SELECT unified_user_id, conversion_status, total_events FROM int_identity_stitching;"

# View Dim Customer
sqlite3 main_main.db "SELECT user_id, country, customer_segment, total_purchase_amount_usd FROM dim_customer;"
```

### Method 3: Using dbt Macros
```bash
# Run individual result macros
dbt run-operation show_customer_ltv_results
dbt run-operation show_marketing_attribution_results
dbt run-operation show_high_jackpot_results
```

## 📊 Expected Results Summary

### Customer LTV Scoring
- **Diamond VIP**: User 2 (Canada) - LTV Score: 85.2
- **Gold VIP**: User 1 (US) - LTV Score: 72.8  
- **Silver VIP**: User 3 (GB) - LTV Score: 45.3

### Marketing Attribution
- **NewYearPromo**: ROAS 0.05, Email channel
- **WinterBlast**: ROAS 0.05, Social channel
- Both classified as "Low Performing"

### High Jackpot Analysis
- **Eurojackpot**: 2 tickets, $7.00 revenue, $3.50 avg ticket
- **MegaMillions**: 1 ticket, $10.00 revenue, $10.00 avg ticket

### Identity Stitching
- 2 converted authenticated users
- 1 anonymous user (opportunity for re-engagement)

## 🔧 Troubleshooting

If you encounter database schema errors:

1. **Recreate the database:**
   ```bash
   rm -f main_main.db
   dbt seed
   dbt run
   ```

2. **Check model status:**
   ```bash
   dbt ls
   ```

3. **Run tests to verify data:**
   ```bash
   dbt test
   ```

## 📈 Business Insights

The models provide insights for:
- **VIP Customer Targeting**: Focus on Canadian customers
- **Marketing Optimization**: Improve ROAS and conversion rates
- **Game Strategy**: Different approaches for Eurojackpot vs MegaMillions
- **Re-engagement**: Target anonymous users from campaigns
- **Customer Segmentation**: Tailored strategies for different value tiers 
