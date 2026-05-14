# Retail Analytics Resources & Skills

## Available Claude Code Skills

These skills are built into Claude Code and ready to use with `/` command:

### Data Analysis & Exploration
- **`/data:analyze`** — Exploratory data analysis, data profiling, statistical summaries
- **`/data:write-query`** — Write SQL queries for your database (Snowflake, BigQuery, PostgreSQL, etc.)
- **`/data:statistical-analysis`** — Hypothesis testing, correlation analysis, outlier detection
- **`/data:validate-data`** — Data quality checks and validation

### Visualization
- **`/data:data-visualization`** — Create charts with matplotlib, seaborn, plotly
  - Sales trends, KPI dashboards, distribution plots
  - Seasonal analysis, forecasting visualizations
- **`/data:build-dashboard`** — Interactive HTML dashboards with filters and tables
  - Perfect for retail KPI monitoring
  - Customer segmentation dashboards
  - Product performance dashboards

### Data Processing
- **`/data:explore-data`** — Guided exploration of datasets
- **`/data:create-viz`** — Quick chart generation

---

## Retail Analytics Workflow

### 1. Data Import & Profiling
```
/data:analyze
→ Upload your CSV/Parquet with sales data
→ Get profile: nulls, dtypes, distributions
→ Identify issues to fix
```

### 2. Write Queries
```
/data:write-query
→ "Give me top 20 products by revenue last 90 days"
→ "Customer RFM analysis"
→ "Monthly sales trends with YoY comparison"
→ Get optimized SQL (adjust for your DB)
```

### 3. Statistical Analysis
```
/data:statistical-analysis
→ Test if seasonal trends are significant
→ Correlation between price and quantity
→ Identify outlier sales days
```

### 4. Visualize Findings
```
/data:data-visualization
→ Sales trend plot
→ Product performance heatmap
→ Customer lifetime value distribution
→ Forecast visualization
```

### 5. Create Dashboard
```
/data:build-dashboard
→ KPI cards (total sales, avg order value, etc.)
→ Charts with filters
→ Exportable HTML file
```

---

## Predefined Python Utilities

In `src/retail_utils.py`:

### RetailAnalytics class
```python
from src.retail_utils import RetailAnalytics

analytics = RetailAnalytics()

# Calculate KPIs
kpis = analytics.calculate_kpis(df, 'sales_amount', 'quantity')

# Top/bottom products
top_20 = analytics.product_performance(df, 'product_id', 'sales_amount', top_n=20)

# Customer lifetime value
clv = analytics.customer_lifetime_value(df, 'customer_id', 'sales_amount')

# Seasonal analysis
seasonal = analytics.seasonal_analysis(df, 'date', 'sales_amount')

# Simple forecasting
forecast = analytics.forecast_simple(df, 'sales_amount', periods=30, method='trend')
```

### RetailDataValidator class
```python
from src.retail_utils import RetailDataValidator

validator = RetailDataValidator()
validation = validator.validate_sales_data(df, required_cols=['date', 'sales_amount'])
```

---

## SQL Query Templates

In `src/retail_queries.sql`:

- **Daily Sales Summary** — Orders, revenue, customers per day
- **Monthly Trends** — YoY comparison
- **Top Products** — By revenue, growth, units
- **RFM Analysis** — Customer segmentation
- **Churn Risk** — Customers not buying
- **Inventory Health** — Stock-outs, turnover
- **KPI Dashboard** — Daily/weekly/monthly metrics

**Use with**: DuckDB, PostgreSQL, BigQuery, Snowflake, etc.

---

## Notebook Templates

### `notebooks/01_retail_sales_analysis.ipynb`
Complete workflow covering:
1. Data profiling
2. Data validation
3. KPI calculation
4. Product performance
5. Customer RFM segmentation
6. Seasonal analysis
7. 30-day sales forecast
8. Export results

**To use:**
```bash
cd projects/customer-analysis-01
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
jupyter lab
# Open notebooks/01_retail_sales_analysis.ipynb
```

---

## Common Retail Analysis Tasks

### Task: "What are my top-selling products?"
```
→ Use /data:write-query
→ Query: SELECT product_id, SUM(sales_amount) as revenue FROM sales GROUP BY product_id ORDER BY revenue DESC
→ Visualize with /data:data-visualization (bar chart)
```

### Task: "Forecast next month's sales"
```
→ Use /data:analyze to get historical data
→ Use /data:statistical-analysis for trends
→ Use Python: analytics.forecast_simple(df, method='trend', periods=30)
→ Visualize with /data:data-visualization
```

### Task: "Identify customers at risk of churning"
```
→ Use /data:write-query with RFM or "no purchase in 60 days"
→ Use /data:statistical-analysis to find characteristics
→ Use /data:build-dashboard to create monitoring view
```

### Task: "Create executive dashboard"
```
→ Gather data with /data:write-query
→ Create dashboard with /data:build-dashboard
→ Add: Total Sales KPI, Monthly Trend, Top Products, Customer Segments
→ Share HTML file
```

### Task: "Analyze seasonal patterns"
```
→ Use retail_utils.seasonal_analysis()
→ Test significance with /data:statistical-analysis
→ Visualize with /data:data-visualization (monthly/quarterly comparison)
```

---

## Data Format Expected

### Minimal Sales Table Schema
```
order_id (int/string)
order_date (date)
customer_id (string)
product_id (string)
sales_amount (float)
quantity (int)
```

### Enhanced Schema (Optional)
```
+ product_name (string)
+ category (string)
+ customer_name (string)
+ unit_price (float)
+ discount_pct (float)
+ region (string)
+ store_id (string)
```

---

## Next Steps

1. **Prepare your data** → CSV or database connection
2. **Run `/data:analyze`** → Get profile
3. **Use templates** → `notebooks/01_retail_sales_analysis.ipynb`
4. **Create queries** → Use `src/retail_queries.sql` as starting point
5. **Visualize & Report** → `/data:data-visualization` or `/data:build-dashboard`

---

## Tips

- Always use `LIMIT` or `SAMPLE` for exploration queries on large tables
- Test forecasts on holdout data
- Document your assumptions in CLAUDE.md
- Version your analysis in git: `git commit -m "Analysis: seasonal trends + churn risk"`
- Export results to `results/` folder for sharing

See `CLAUDE.md` for full guidelines and principles.
