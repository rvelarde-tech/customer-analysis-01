"""
Retail Analytics Utilities
For sales analysis, forecasting, and KPI calculations
"""

import pandas as pd
import numpy as np
from typing import Tuple, Dict, List
from datetime import datetime, timedelta


class RetailAnalytics:
    """Sales, inventory, and customer analytics for retail."""

    @staticmethod
    def sales_by_period(df: pd.DataFrame, date_col: str, sales_col: str,
                       freq: str = 'D') -> pd.DataFrame:
        """Aggregate sales by time period (daily, weekly, monthly)."""
        df[date_col] = pd.to_datetime(df[date_col])
        return df.set_index(date_col)[sales_col].resample(freq).sum().reset_index()

    @staticmethod
    def calculate_kpis(df: pd.DataFrame, sales_col: str, quantity_col: str = None) -> Dict:
        """Calculate key retail KPIs."""
        kpis = {
            'total_sales': df[sales_col].sum(),
            'avg_sale': df[sales_col].mean(),
            'median_sale': df[sales_col].median(),
            'std_sale': df[sales_col].std(),
            'min_sale': df[sales_col].min(),
            'max_sale': df[sales_col].max(),
            'transaction_count': len(df)
        }

        if quantity_col and quantity_col in df.columns:
            kpis['total_units'] = df[quantity_col].sum()
            kpis['avg_units_per_transaction'] = df[quantity_col].mean()
            kpis['aov'] = df[sales_col].sum() / len(df)  # Average Order Value

        return kpis

    @staticmethod
    def product_performance(df: pd.DataFrame, product_col: str, sales_col: str,
                           quantity_col: str = None, top_n: int = 10) -> pd.DataFrame:
        """Top/bottom performing products."""
        grouped = df.groupby(product_col).agg({
            sales_col: ['sum', 'mean', 'count']
        }).round(2)

        if quantity_col and quantity_col in df.columns:
            grouped[(quantity_col, 'sum')] = df.groupby(product_col)[quantity_col].sum()

        return grouped.sort_values((sales_col, 'sum'), ascending=False).head(top_n)

    @staticmethod
    def customer_lifetime_value(df: pd.DataFrame, customer_col: str,
                               sales_col: str, date_col: str = None) -> pd.DataFrame:
        """Calculate customer lifetime value and purchase frequency."""
        clv = df.groupby(customer_col).agg({
            sales_col: ['sum', 'mean', 'count']
        }).round(2)

        clv.columns = ['total_spent', 'avg_order_value', 'purchase_count']

        if date_col:
            df[date_col] = pd.to_datetime(df[date_col])
            clv['days_active'] = (df.groupby(customer_col)[date_col].max() -
                                  df.groupby(customer_col)[date_col].min()).dt.days

        return clv.sort_values('total_spent', ascending=False)

    @staticmethod
    def seasonal_analysis(df: pd.DataFrame, date_col: str, sales_col: str) -> pd.DataFrame:
        """Identify seasonal trends by month/quarter."""
        df[date_col] = pd.to_datetime(df[date_col])
        df['month'] = df[date_col].dt.month
        df['quarter'] = df[date_col].dt.quarter
        df['month_name'] = df[date_col].dt.strftime('%B')

        seasonal = df.groupby(['month', 'month_name'])[sales_col].agg(['sum', 'mean', 'count'])
        return seasonal.sort_values('month')

    @staticmethod
    def growth_rate(current: float, previous: float) -> float:
        """Calculate period-over-period growth rate (%)."""
        if previous == 0:
            return np.nan
        return ((current - previous) / previous) * 100

    @staticmethod
    def forecast_simple(df: pd.DataFrame, sales_col: str, periods: int = 30,
                       method: str = 'average') -> np.ndarray:
        """Simple forecasting methods (average, last value, trend)."""
        sales = df[sales_col].values

        if method == 'average':
            forecast = np.full(periods, sales.mean())
        elif method == 'last':
            forecast = np.full(periods, sales[-1])
        elif method == 'trend':
            # Simple linear trend
            x = np.arange(len(sales))
            z = np.polyfit(x, sales, 1)
            p = np.poly1d(z)
            forecast = p(np.arange(len(sales), len(sales) + periods))
        else:
            forecast = np.full(periods, sales.mean())

        return forecast

    @staticmethod
    def inventory_turnover(df: pd.DataFrame, sales_col: str, inventory_col: str,
                          period: str = 'M') -> pd.DataFrame:
        """Calculate inventory turnover ratio."""
        if period == 'M':  # Monthly
            grouped = df.groupby(pd.Grouper(key=df.index, freq='M')).agg({
                sales_col: 'sum',
                inventory_col: 'mean'
            })
        else:
            grouped = df.groupby(df.index.date).agg({
                sales_col: 'sum',
                inventory_col: 'mean'
            })

        grouped['turnover_ratio'] = grouped[sales_col] / grouped[inventory_col].replace(0, 1)
        return grouped


class RetailDataValidator:
    """Data quality checks for retail datasets."""

    @staticmethod
    def validate_sales_data(df: pd.DataFrame, required_cols: List[str]) -> Dict:
        """Check data quality and completeness."""
        issues = []

        # Check required columns
        missing_cols = [col for col in required_cols if col not in df.columns]
        if missing_cols:
            issues.append(f"Missing columns: {missing_cols}")

        # Check nulls
        null_cols = df[required_cols].columns[df[required_cols].isnull().any()].tolist()
        if null_cols:
            issues.append(f"Columns with nulls: {null_cols}")

        # Check duplicates
        duplicates = df.duplicated().sum()
        if duplicates > 0:
            issues.append(f"Found {duplicates} duplicate rows")

        # Check data types (basic)
        for col in required_cols:
            if col in df.columns:
                if 'amount' in col.lower() or 'sales' in col.lower():
                    if not pd.api.types.is_numeric_dtype(df[col]):
                        issues.append(f"{col} should be numeric")

        return {
            'is_valid': len(issues) == 0,
            'issues': issues,
            'row_count': len(df),
            'col_count': len(df.columns)
        }
