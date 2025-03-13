###############################################################################
# 1) SETUP: PACKAGES, DATA IMPORT, AND SUBSET (2014–2021)
###############################################################################
if (!require("quantmod")) install.packages("quantmod")
if (!require("changepoint")) install.packages("changepoint")
if (!require("xts")) install.packages("xts")

library(quantmod)
library(changepoint)
library(xts)

# Read CSV file (adjust file path if needed)
data <- read.csv("C:\\Users\\risha\\OneDrive - University of Edinburgh\\CPD CODE\\Estimation-of-Change-Point-Detection-Algorithms-\\coin_Bitcoin.csv", 
                 header = TRUE, stringsAsFactors = FALSE)

# Convert the Date column to Date objects
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")

# Subset data to include only dates from January 1, 2014 to December 31, 2021
start_date <- as.Date("2014-01-01")
end_date   <- as.Date("2021-12-31")
data_sub   <- subset(data, Date >= start_date & Date <= end_date)

###############################################################################
# 2) CREATE WEEKLY TIME SERIES & COMPUTE LOG RETURNS
###############################################################################
btc_xts <- xts(data_sub$Close, order.by = data_sub$Date)

# Convert daily data to weekly data (using the closing price on the first trading day)
btc_weekly <- to.weekly(btc_xts, 
                        indexAt  = "firstof", 
                        drop.time= TRUE, 
                        OHLC     = FALSE)

# Compute weekly log returns and remove NA
weekly_log_returns <- diff(log(btc_weekly))
weekly_log_returns <- na.omit(weekly_log_returns)

# Numeric vector for change-point detection
x_data <- as.numeric(coredata(weekly_log_returns))

###############################################################################
# 3) CHANGE-POINT DETECTION WITH BINSEG (cpt.meanvar) USING AIC PENALTY
###############################################################################
# Using cpt.meanvar with BinSeg to detect 10 change points (set Q = 10) with AIC penalty
cpt_binseg <- cpt.meanvar(x_data, method = "BinSeg", penalty = "AIC", Q = 10)
print(cpt_binseg)

###############################################################################
# 4) PLOTTING WITH A TIMELINE ON THE X-AXIS AND Y-AXIS LABEL "Log Returns"
###############################################################################
# Plot the change-point analysis result with custom x-axis labels (timeline) and y-axis label
plot(cpt_binseg, xlab = "", ylab = "Log Returns", xaxt = "n", 
     main = "BinSeg Change-Point Analysis (AIC) on Weekly Log Returns")

# Define tick positions: here we choose every 12th week for clarity
tick_positions <- seq(1, length(weekly_log_returns), by = 12)
tick_labels <- format(index(weekly_log_returns)[tick_positions], "%b-%Y")
axis(1, at = tick_positions, labels = tick_labels, las = 2)

###############################################################################
# 5) PRINT CHANGE-POINT DATES IN "MONTH-YEAR" FORMAT
###############################################################################
# Extract change point indices
cp_indices <- cpts(cpt_binseg)

# Convert indices to dates using the xts index from weekly_log_returns
cp_dates <- index(weekly_log_returns)[cp_indices]

# Print the change point dates in "Month-Year" format
print(format(cp_dates, "%b-%Y"))
