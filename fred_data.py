"""
Macroeconomic Data Extraction from FRED API
This script extracts and processes key macroeconomic indicators from the FRED API.
"""

from fredapi import Fred 
import pandas as pd  
import os

# =============================================
# API Setup and Configuration
# =============================================
# Initialize FRED API client using environment variable
fred = Fred(api_key=os.getenv('FRED_API_KEY'))

# =============================================
# Data Extraction
# =============================================
# Extract raw series from FRED
market_excess_returns = fred.get_series('SP500')
t_bill = fred.get_series('DTB3')  # Risk-Free Rate
interest_rate_risk = fred.get_series('GS10')  # 10-Year Treasury Spread
yield_spread = fred.get_series('T10Y2Y')  # Yield Spread
inflation_risk = fred.get_series('CPIAUCSL')  # CPI Inflation Rate
economic_activity = fred.get_series('A191RL1Q225SBEA')  # GDP Growth Rate
credit_spread = fred.get_series('BAA10Y') - fred.get_series('AAA10Y')  # Credit Spread

# =============================================
# Data Processing
# =============================================
# Convert all series to monthly frequency
series_to_resample = [
    t_bill,
    interest_rate_risk,
    yield_spread,
    inflation_risk,
    economic_activity,
    credit_spread
]

# Resample each series
resampled_series = [s.resample('ME').mean() for s in series_to_resample]

# =============================================
# Data Merging and Export
# =============================================
# Combine all series into a single DataFrame
macro_factors = pd.concat(resampled_series, axis=1)

# Set column names
macro_factors.columns = [
    'risk_free_rate',
    '10_yr_spread',
    'yield_spread',
    'cpi',
    'gdp_growth',
    'credit_spread'
]

# Export to CSV
macro_factors.to_csv('data/macro_factors.csv', index=True)
print("Macroeconomic factors successfully saved to macro_factors.csv") 