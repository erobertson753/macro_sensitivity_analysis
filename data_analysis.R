rm(list=ls())
library(dplyr)
library(tidyr)
library(purrr)
library(plm)
library(broom)

# =============================================
# Data Loading and Initial Processing
# =============================================
# Load and process data
data <- read.csv("data/data_final.csv") %>%
  mutate(
    leverage = total_liabilities / assets,
    roe = net_income / equity,
    mtb = market_cap / assets,
    market_excess = quarterly_return - sp_returns
  )

# Print data summary
cat("Number of unique tickers:", length(unique(data$tic)), "\n")
summary(data)

# =============================================
# Time Series Data Preparation
# =============================================
# Prepare time series data
ts_data <- data %>%
  filter(!is.na(leverage) & !is.na(roe) & !is.na(mtb) & !is.na(market_excess)) %>%
  select(tic, date, leverage, roe, mtb, market_excess)

# Standardize variables
ts_data[, 3:6] <- scale(ts_data[, 3:6])

# =============================================
# Firm-Level Beta Estimation
# =============================================
# Estimate betas for each firm
beta_estimates <- ts_data %>%
  group_by(tic) %>%
  nest() %>%
  mutate(
    model = map(data, ~ {
      if (nrow(.x) < 24) return(NULL)
      lm(market_excess ~ leverage + roe + mtb, data = .x)
    }),
    results = map(model, ~ if (!is.null(.x)) tidy(.x) else NULL)
  ) %>%
  select(tic, results) %>%
  unnest(results) %>%
  filter(!is.na(estimate))

# =============================================
# Results Processing and Export
# =============================================
# Reshape results into wide format
estimates_wide <- beta_estimates %>%
  select(tic, term, estimate) %>%
  pivot_wider(names_from = term, values_from = estimate)

pvalues_wide <- beta_estimates %>%
  select(tic, term, p.value) %>%
  pivot_wider(names_from = term, values_from = p.value)

# Combine results
results <- left_join(estimates_wide, pvalues_wide, by = "tic", suffix = c("_estimate", "_pvalue"))

# Export results
write.csv(results, "data/results.csv", row.names = F)

# =============================================
# Research Sample Selection
# =============================================
# Filter results based on research criteria
research <- results %>%
  filter(
    leverage_estimate < 0,
    `(Intercept)_pvalue` < 0.1
  )

# Export research sample
write.csv(research, "data/research.csv", row.names = F) 