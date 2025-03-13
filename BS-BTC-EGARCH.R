###############################################################################
# Combined Analysis: Raw Model and EGARCH Model with Diagnostics & CPD Plots
###############################################################################

# 1) SETUP: PACKAGES, DATA IMPORT, AND SUBSET (2014–2021)
if (!require("quantmod")) install.packages("quantmod")
if (!require("changepoint")) install.packages("changepoint")
if (!require("xts")) install.packages("xts")
if (!require("tseries")) install.packages("tseries")
if (!require("FinTS")) install.packages("FinTS")
if (!require("rugarch")) install.packages("rugarch")

library(quantmod)
library(changepoint)
library(xts)
library(tseries)
library(FinTS)
library(rugarch)

# Read CSV (adjust file path if needed)
data <- read.csv("C:/Users/risha/Downloads/archive (2)/coin_Bitcoin.csv", 
                 header = TRUE, stringsAsFactors = FALSE)
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")

# Subset data to include only dates from January 1, 2014 to December 31, 2021
start_date <- as.Date("2014-01-01")
end_date   <- as.Date("2021-12-31")
data_sub   <- subset(data, Date >= start_date & Date <= end_date)

# 2) CREATE WEEKLY TIME SERIES & COMPUTE LOG RETURNS
btc_xts <- xts(data_sub$Close, order.by = data_sub$Date)
btc_weekly <- to.weekly(btc_xts, indexAt = "firstof", drop.time = TRUE, OHLC = FALSE)
weekly_log_returns <- diff(log(btc_weekly))
weekly_log_returns <- na.omit(weekly_log_returns)
x_data <- as.numeric(coredata(weekly_log_returns))  # for CPD on raw returns

###############################################################################
# 3) RAW MODEL: CHANGE-POINT DETECTION ON RAW LOG RETURNS
###############################################################################
cpt_binseg <- cpt.meanvar(x_data, method = "BinSeg", penalty = "AIC", Q = 5)
cat("=== Change-Point Analysis on Raw Log Returns ===\n")
print(cpt_binseg)

###############################################################################
# 4) DIAGNOSTICS ON RAW LOG RETURNS
###############################################################################
cat("\n--- Diagnostics on Raw Log Returns ---\n")

# Stationarity Tests
adf_result <- adf.test(weekly_log_returns)
cat("\nAugmented Dickey-Fuller Test:\n")
print(adf_result)

kpss_result <- kpss.test(weekly_log_returns)
cat("\nKPSS Test:\n")
print(kpss_result)

# Autocorrelation (Ljung-Box)
lb_test <- Box.test(weekly_log_returns, lag = 20, type = "Ljung-Box")
cat("\nLjung-Box Test for Autocorrelation:\n")
print(lb_test)

# Heteroskedasticity (ARCH)
arch_test <- ArchTest(weekly_log_returns, lags = 12)
cat("\nARCH Test for Heteroskedasticity:\n")
print(arch_test)

# Normality (Jarque-Bera)
jb_result <- jarque.bera.test(weekly_log_returns)
cat("\nJarque-Bera Normality Test:\n")
print(jb_result)

###############################################################################
# 5) FIT EGARCH MODEL TO WEEKLY LOG RETURNS AND EXTRACT STANDARDIZED RESIDUALS
###############################################################################
spec_egarch <- ugarchspec(
  variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
  mean.model     = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)
fit_egarch <- ugarchfit(spec = spec_egarch, data = x_data)
cat("\n=== EGARCH(1,1) Fit Summary ===\n")
print(fit_egarch)

z_egarch <- residuals(fit_egarch, standardize = TRUE)
z_egarch_clean <- as.numeric(na.omit(z_egarch))  # for CPD on EGARCH residuals

###############################################################################
# 6) DIAGNOSTICS ON EGARCH STANDARDIZED RESIDUALS
###############################################################################
cat("\n--- Diagnostics on EGARCH Standardized Residuals ---\n")

lb_test_egarch <- Box.test(z_egarch_clean, lag = 20, type = "Ljung-Box")
cat("\nLjung-Box Test (EGARCH Residuals):\n")
print(lb_test_egarch)

arch_test_egarch <- ArchTest(z_egarch_clean, lags = 12)
cat("\nARCH Test (EGARCH Residuals):\n")
print(arch_test_egarch)

###############################################################################
# 7) CHANGE-POINT DETECTION ON EGARCH STANDARDIZED RESIDUALS USING BINSEG
###############################################################################
cpt_binseg_egarch <- cpt.meanvar(z_egarch_clean, method = "BinSeg", 
                                 penalty = "AIC", Q = 5, minseglen = 2)
cat("\n=== Change-Point Analysis on EGARCH Standardized Residuals (BinSeg) ===\n")
print(cpt_binseg_egarch)

###############################################################################
# 8) SIDE-BY-SIDE PLOTTING OF CHANGE-POINT DETECTION RESULTS (WITH TIMELINES)
###############################################################################
par(mfrow = c(1, 2))

# (A) Raw Log Returns CPD (Left Plot)
plot(cpt_binseg, xlab = "", ylab = "Log Returns", xaxt = "n",
     main = "Raw Log Returns CPD")

# Create custom axis ticks for years 2014-2021 based on the weekly_log_returns index
all_years <- 2014:2021
# Find the position of the first weekly return in each year
tick_positions <- sapply(all_years, function(y) {
  idx <- which(format(index(weekly_log_returns), "%Y") == as.character(y))[1]
  if (!is.na(idx)) idx else NA
})

# Remove any NA (in case a particular year doesn't exist in your data subset)
valid_positions <- tick_positions[!is.na(tick_positions)]
valid_years <- all_years[!is.na(tick_positions)]

# Add the axis with only the years
axis(1, at = valid_positions, labels = valid_years, las = 1)  # las=1 makes labels horizontal

# (B) EGARCH Residuals CPD (Right Plot)
plot(cpt_binseg_egarch, xlab = "", ylab = "Standardized Residuals", xaxt = "n",
     main = "EGARCH Residuals CPD")

# If z_egarch_clean has the same length and aligns with weekly_log_returns
# you can reuse the same approach. Otherwise, compute a matching date index
# for z_egarch_clean. For simplicity, assume same length & alignment here:

axis(1, at = valid_positions, labels = valid_years, las = 1)

par(mfrow = c(1, 1))  # reset plotting layout


###############################################################################
# 9) PRINT CHANGE-POINT DATES FOR BOTH MODELS
###############################################################################
# Raw model CP dates
cp_indices_raw <- cpts(cpt_binseg)
cp_dates_raw <- index(weekly_log_returns)[cp_indices_raw]
cat("\nChange-Point Dates (Raw Log Returns):\n")
print(format(cp_dates_raw, "%b-%Y"))

# EGARCH model CP dates
cp_indices_egarch <- cpts(cpt_binseg_egarch)
cp_dates_egarch <- index(weekly_log_returns)[cp_indices_egarch]
cat("\nChange-Point Dates (EGARCH Standardized Residuals):\n")
print(format(cp_dates_egarch, "%b-%Y"))
