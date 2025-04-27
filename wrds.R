rm(list=ls())
library(RPostgres)
library(dplyr)
library(lubridate)

# =============================================
# Database Connection Setup
# =============================================
db <- dbConnect(Postgres(),
                host = "wrds-pgdata.wharton.upenn.edu",
                port = 9737,
                user = "YOUR_USERNAME_HERE",
                password = "YOUR_PASSWORD_HERE",
                dbname = "wrds",
                sslmode = "require")

# =============================================
# Data Extraction Parameters
# =============================================
start_date <- '20010101'
end_date <- '20250304'

# =============================================
# Compustat Data Extraction
# =============================================
# Get column names for reference
res <- dbSendQuery(db, "
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema='comp'
    AND table_name='fundq'
    ORDER BY column_name
")
data <- dbFetch(res, n=-1)
dbClearResult(res)
write.csv(data, "data/fundqvars.csv", row.names = F)

# Extract quarterly financial data
compustat_query <- "
    SELECT 
        datadate, GVKEY, TIC, GSECTOR, 
        ATQ, SEQQ, LCTQ, NIQ, TIIQ, XINTQ, MKVALTQ, CEQQ
    FROM comp.fundq
    WHERE datadate BETWEEN '20010101' AND '20250304'
"

colnames <- c("date", "gvkey", "tic", "sector", "assets", "equity", 
              "total_liabilities", "net_income", "interest_income", 
              "interest expense", "market_cap", "book_value")

bank_data <- dbGetQuery(db, compustat_query)
colnames(bank_data) <- colnames
write.csv(bank_data, "data/bank_data.csv", row.names = F)

# =============================================
# Bank-Specific Financial Data
# =============================================
compustat_query <- "
    SELECT 
        datadate, gvkey, tic, at, seq, ni, txditc, lt, dltt, lnat, 
        nicon, lq, npl, mkvalt, cshoq, ceqq
    FROM comp.fundq
    WHERE CAST(sic AS INT) BETWEEN 6000 AND 6999 
    AND datadate BETWEEN '19860101' AND '20250304'
"

bank_data <- dbGetQuery(db, compustat_query)

# Calculate key financial ratios
bank_data <- bank_data %>%
  mutate(
    Leverage_Ratio = at / ceqq,
    Loan_to_Deposit_Ratio = lq / dltt,
    ROE = ni / ceqq,
    Net_Interest_Margin = (nicon - txditc) / at,
    NPL_Ratio = npl / lq,
    Market_to_Book = mkvalt / ceqq
  ) %>%
  select(datadate, gvkey, tic, Leverage_Ratio, Loan_to_Deposit_Ratio, 
         ROE, Net_Interest_Margin, NPL_Ratio, Market_to_Book)

# =============================================
# CRSP Data Linkage
# =============================================
linking_query <- "
    SELECT gvkey, lpermno AS permno, linkdt, linkenddt
    FROM crsp.ccmxpf_lnkhist
    WHERE linktype IN ('LU', 'LC')
    AND linkdt <= '20250304' 
    AND (linkenddt IS NULL OR linkenddt >= '19860101')
"

link_table <- dbGetQuery(db, linking_query)
bank_data <- bank_data %>%
  left_join(link_table, by = "gvkey") %>%
  filter(!is.na(permno))

# =============================================
# Stock Returns Data
# =============================================
crsp_query <- "
    SELECT date, permno, ret, vwretd, me
    FROM crsp.msf
    WHERE date BETWEEN '19860101' AND '20250304'
"
crsp_data <- dbGetQuery(db, crsp_query)

# =============================================
# Macroeconomic Data
# =============================================
macro_query <- "
    SELECT 
        date, risk_free_rate, X10_yr_spread, yield_spread, 
        cpi, gdp_growth, credit_spread, ind_prod_growth, 
        unemployment_rate, fed_funds_rate, vix
    FROM macroecon.macro_data
    WHERE date BETWEEN '19860131' AND '20250228'
"
macro_data <- dbGetQuery(db, macro_query)

# =============================================
# Final Data Merge and Export
# =============================================
merged_data <- bank_data %>%
  inner_join(crsp_data, by = c("permno" = "permno")) %>%
  inner_join(macro_data, by = c("date" = "date"))

dbDisconnect(db)
write.csv(merged_data, "bank_financials_macro_returns.csv", row.names = FALSE) 