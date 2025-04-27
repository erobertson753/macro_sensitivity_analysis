# Macro-Factor Sensitivity Analysis for Financial Firms

This repository contains the code and documentation for analyzing the macroeconomic factor sensitivities of U.S. financial and banking firms. The analysis uses the first stage of the Fama-MacBeth two-step asset pricing model to estimate firm-level sensitivities to key macroeconomic factors.

## Project Overview

The study analyzes 316 publicly traded U.S. financial and banking firms from 2001 to 2025, focusing on their sensitivity to:
- Inflation
- Credit spreads
- GDP growth

The analysis produces a macro-resilience score designed to identify firms better positioned to withstand adverse macroeconomic conditions.

## Repository Structure

```
project_files/
├── clean_data.R
├── clean_data_2.R
├── data_analysis.R
├── scoring.R
├── wrds.R
└── README.md
```

## Data Requirements

To reproduce this analysis, you will need access to:

1. WRDS (Wharton Research Data Services)
   - CRSP database for stock returns
   - Compustat database for firm financials
   - Required SIC codes: 6000-6300 (Financial Services)

2. FRED API
   - Macroeconomic time series
   - API key required

3. S&P 500 Historical Data
   - Daily price data
   - Available from various financial data providers

## Installation and Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/erobertson753/macro_sensitivity_analysis.git
   ```

2. Install required R packages:
   ```R
   install.packages(c("dplyr", "tidyr", "purrr", "plm", "broom", "RPostgres", "tidyverse", "lubridate", "zoo"))
   ```

3. Install required Python packages:
   ```bash
   pip install pandas numpy requests
   ```

4. Set up environment variables:
   - WRDS username and password
   - FRED API key
   - Database connection parameters

## Data Processing Pipeline

1. Extract data from WRDS using `wrds.R`
2. Clean and process data using `clean_data.R` and `clean_data_2.R`
3. Perform analysis using `data_analysis.R`
4. Generate scores using `scoring.R`

## Reproducing Results

To reproduce the analysis:

1. Ensure you have access to all required data sources
2. Run the scripts in the following order:
   ```bash
   Rscript wrds.R
   Rscript clean_data.R
   Rscript clean_data_2.R
   Rscript data_analysis.R
   Rscript scoring.R
   ```

## Output Files

The analysis generates several key output files:
- Regression results
- Firm-level sensitivity estimates
- Macro-resilience scores
- Summary statistics

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- WRDS for providing access to CRSP and Compustat data
- FRED for macroeconomic data
- Fama and MacBeth for their foundational work in asset pricing

## Contact

For questions or comments, please contact the author at [your-email@example.com](mailto:your-email@example.com) 
