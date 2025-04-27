rm(list=ls())
library(RPostgres)
library(tidyverse)
library(lubridate)
library(zoo)

# =============================================
# Initial Data Processing
# =============================================
df <- read.csv("data/data.csv") %>%
  mutate(
    total_liabilities = assets - equity,
    date = as.Date(date)
  ) %>%
  filter(!is.na(gvkey)) %>%
  select(-interest_income, -interest.expense)

# =============================================
# Market Cap Data Cleaning
# =============================================
# Identify firms with excessive missing market cap data
gvkeys_to_drop <- df %>%
  filter(is.na(market_cap)) %>%
  group_by(gvkey, tic) %>%
  summarise(missing_count = n(), .groups = "drop") %>%
  filter(missing_count >= 90) %>%
  pull(gvkey)

# Clean and interpolate market cap data
data_c <- df %>%
  filter(!(gvkey %in% gvkeys_to_drop)) %>%
  group_by(gvkey) %>%
  arrange(gvkey, date) %>%
  mutate(market_cap = zoo::na.approx(market_cap, x = date, na.rm = FALSE)) %>%
  fill(market_cap, .direction = "downup") %>%
  ungroup()

# =============================================
# Returns Data Processing
# =============================================
# Load and process returns data
returns <- read.csv("data/returns.csv") %>%
  mutate(RET = as.numeric(RET)) %>%
  transmute(
    date = as.Date(date),
    tic = TICKER,
    return = RET
  )

# Calculate quarterly returns
quarterly_returns <- returns %>%
  mutate(quarter = floor_date(date, unit = "quarter") - days(1)) %>%
  group_by(tic, quarter) %>%
  summarise(
    quarterly_return = prod(1 + return) - 1,
    .groups = "drop"
  ) %>%
  mutate(date = quarter) %>%
  select(tic, quarterly_return, date)

# Merge returns and clean data
data_clean <- data_c %>%
  drop_na() %>%
  left_join(quarterly_returns, by = c("date", "tic"))

# Filter firms with excessive missing returns
gvkeys_to_drop <- data_clean %>%
  filter(is.na(quarterly_return)) %>%
  group_by(gvkey, tic) %>%
  summarise(missing_count = n(), .groups = "drop") %>%
  filter(missing_count >= 70) %>%
  pull(gvkey)

data_clean <- data_clean %>%
  filter(!(gvkey %in% gvkeys_to_drop)) %>%
  group_by(gvkey) %>%
  arrange(gvkey, date) %>%
  fill(quarterly_return, .direction = "downup") %>%
  ungroup()

# =============================================
# S&P 500 Data Processing
# =============================================
# Process S&P 500 data
sp500 <- read.csv("data/sp500.csv") %>%
  transmute(
    date = mdy(as.character(Date)),
    sp_price = Open
  )

# Create date sequence and merge
date_df <- data.frame(
  date = seq(from = as.Date("2001-01-01"), to = as.Date("2025-01-31"), by = "day")
)

sp500 <- left_join(date_df, sp500, by = "date") %>%
  mutate(sp_price = zoo::na.spline(sp_price))

# Calculate S&P 500 returns
sp500 <- left_join(
  data.frame(date = unique(data_clean$date)),
  sp500,
  by = "date"
) %>%
  mutate(sp_returns = c(NA, diff(sp_price) / head(sp_price, -1)))

# =============================================
# Final Data Merge and Export
# =============================================
# Merge all data and export
data_clean <- data_clean %>%
  left_join(sp500, by = "date") %>%
  drop_na()

write.csv(data_clean, "data/data_final.csv", row.names = F)

# Example analysis for CADE
cade_returns <- subset(data_clean, tic == "CADE", select = quarterly_return)
summary(cade_returns) 