rm(list=ls())
library(RPostgres)
library(tidyverse)
library(lubridate)
library(zoo)

# =============================================
# Macro Factors Data Processing
# =============================================
m_factors <- read.csv("data/macro_factors.csv", header = T) %>%
  rename(date = X) %>%
  mutate(date = as.Date(date)) %>%
  arrange(date) %>%
  filter(date >= "1986-01-31", date <= "2025-02-28") %>%
  mutate(gdp_growth = zoo::na.spline(gdp_growth))

# =============================================
# Bank and Sector Data Processing
# =============================================
# Load and process bank data
b_data <- read.csv("data/bank_data.csv", header = T, stringsAsFactors = T) %>%
  arrange(desc(market_cap))

# Load and process sector data
s_data <- read.csv("data/sectors.csv") %>%
  distinct(TICKER, .keep_all = TRUE) %>%
  transmute(tic = TICKER, sector = SICCD)

# =============================================
# Data Merging and Financial Firm Filtering
# =============================================
# Merge bank and sector data
merged <- left_join(b_data, s_data, by = "tic") %>%
  arrange(desc(market_cap))

# Identify and filter financial firms
financials <- merged %>%
  select(tic, sector) %>%
  distinct() %>%
  filter(sector >= 6000 & sector < 6300) %>%
  mutate(joined = T)

# Final data processing
data_small <- merged %>%
  left_join(financials, by = c("tic", "sector"), suffix = c("", "_fin")) %>%
  filter(!is.na(joined)) %>%
  select(-joined) %>%
  arrange(by = market_cap) %>%
  mutate(date = as.Date(date))

# =============================================
# Final Data Merge and Export
# =============================================
# Merge with macro factors and export
data <- left_join(m_factors, data_small, by = "date")
data_n <- data

# Print matching statistics
print(paste0(round((length(data$gvkey) - sum(is.na(data$gvkey))) / length(data$gvkey) * 100, 1), 
             "% of observations matched"))
print(paste0(length(unique(data$date))/12, " years of data"))

write.csv(data_n, "data/data.csv", row.names = F) 