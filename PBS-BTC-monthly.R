###############################################################################
# 1) Setup: Packages, CSV Data Import, and Subset to 2014-2021
###############################################################################
if (!require("quantmod")) install.packages("quantmod")
if (!require("changepoint")) install.packages("changepoint")
if (!require("xts")) install.packages("xts")

library(quantmod)
library(changepoint)
library(xts)

# -- (A) Read CSV (Adjust file path if needed) --
data <- read.csv("C:/Users/risha/Downloads/archive (2)/coin_Bitcoin.csv", 
                 header = TRUE, stringsAsFactors = FALSE)

# Convert Date column to Date objects
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")

# Subset data to [2014-01-01, 2021-12-31]
start_date <- as.Date("2014-01-01")
end_date   <- as.Date("2021-12-31")
data_sub   <- subset(data, Date >= start_date & Date <= end_date)

###############################################################################
# 2) Create Monthly Time Series and Compute Log Returns
###############################################################################
# Convert daily subset to an xts object using 'Close'
btc_xts <- xts(data_sub$Close, order.by = data_sub$Date)

# Convert to monthly series (based on first trading day each month)
btc_monthly <- to.monthly(btc_xts, 
                          indexAt  = "firstof", 
                          drop.time= TRUE, 
                          OHLC     = FALSE)

# Compute monthly log returns
monthly_log_returns <- diff(log(btc_monthly))
monthly_log_returns <- na.omit(monthly_log_returns)

# For change-point detection, we'll need a numeric vector
x_data <- as.numeric(coredata(monthly_log_returns))

###############################################################################
# 3) Change-Point Detection - Method A: BinSeg (Variance, Manual, Q=6)
###############################################################################
result_binseg <- cpt.var(
  data      = x_data,
  method    = "BinSeg",
  penalty   = "Manual", 
  Q         = 6,        # up to 6 change points
  minseglen = 5
)

# Extract numeric indices of detected CPs
cp_indices_binseg <- cpts(result_binseg)
# Convert to actual Date (Month-Year)
cp_dates_binseg   <- index(monthly_log_returns)[cp_indices_binseg]

###############################################################################
# 4) Change-Point Detection - Method B: PELT (Variance, CROPS)
###############################################################################
result_pelt <- cpt.var(
  data      = monthly_log_returns,
  method    = "PELT",
  penalty   = "CROPS",
  pen.value = c(1, 100),
  minseglen = 6
)

# Pick the 5-change-point solution (ncpts=6 in changepoint notation)
cp_indices_pelt <- cpts(result_pelt, ncpts = 6)
cp_dates_pelt   <- index(monthly_log_returns)[cp_indices_pelt]

###############################################################################
# 5) Plot Monthly Log Returns + Overlay Both Methods' Change Points
###############################################################################
plot(monthly_log_returns, 
     main = "Monthly Log Returns (2014–2021) with Detected Change Points",
     xlab = "Date", 
     ylab = "Log Return", 
     type = "l", col = "blue")

abline(h = 0, col = "gray70", lty = 2)

# (A) BinSeg CPs (Red, dashed)
abline(v = cp_dates_binseg, col = "red", lty = 2, lwd = 1.5)

# (B) PELT CPs (Green, dotted)
abline(v = cp_dates_pelt, col = "green4", lty = 3, lwd = 1.5)

legend("topright",
       legend = c("Monthly Log Returns","BinSeg CPs (Manual)","PELT CPs (CROPS)"),
       col    = c("blue","red","green4"),
       lty    = c(1,2,3),
       lwd    = c(1,1.5,1.5))

###############################################################################
# 6) Print the Detected Change Point Dates in the Console
###############################################################################
cat("\n----------------------------------------------\n")
cat("BinSeg (Variance, Manual, Q=6) Results:\n")
cat("Indices of CPs:", cp_indices_binseg, "\n")
cat("Dates of CPs (Month-Year):\n")
print(format(cp_dates_binseg, "%Y-%m"))

cat("\n----------------------------------------------\n")
cat("PELT (Variance, CROPS) Results:\n")
cat("Indices of CPs:", cp_indices_pelt, "\n")
cat("Dates of CPs (Month-Year):\n")
print(format(cp_dates_pelt, "%Y-%m"))
cat("\n----------------------------------------------\n")

###############################################################################
# 7) Additional Plots & Diagnostic
###############################################################################
# Diagnostic plot for the PELT (CROPS) result
plot(result_pelt, diagnostic = TRUE)

# Side-by-side standard cpt plots, with date-labeled x-axes
par(mfrow = c(1,2))

###############################################################################
# Side-by-side plots for result_pelt and result_binseg with custom labeling
###############################################################################
par(mfrow = c(1, 2))  # 1 row, 2 columns

# (A) PELT plot
plot(result_pelt, ncpts = 6, 
     main = "PELT (CROPS), 6 CPs",
     xlab = "",           # remove default x-axis label
     ylab = "Log Return", # consistent y-axis label
     xaxt = "n")          # suppress default x-axis ticks/labels

# Build a custom x-axis using the monthly_log_returns index
n <- length(monthly_log_returns)
x_seq <- seq(1, n, length.out = 8)   # choose 8 tick positions
date_labels <- format(index(monthly_log_returns)[round(x_seq)], "%Y-%m")
axis(1, at = x_seq, labels = date_labels, las = 2)  # las=2 makes them vertical

# (B) BinSeg plot
plot(result_binseg, Q = 6,
     main = "BinSeg (Manual), Q=6",
     xlab = "",           # remove default x-axis label
     ylab = "Log Return", # same y-axis label
     xaxt = "n")          # suppress default x-axis ticks/labels

# Use the same custom axis approach
axis(1, at = x_seq, labels = date_labels, las = 2)


###############################################################################
# 8) (Optional) Inspect the Solutions & Penalty Values
###############################################################################
cat("\nNumber of CPs for each penalty (PELT, CROPS):\n")
print(apply(!is.na(result_pelt@cpts.full),1,sum))
cat("\nPenalty values:\n")
print(result_pelt@pen.value.full)
