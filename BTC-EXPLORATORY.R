# Load necessary libraries
library(xts)
library(zoo)
library(moments)
library(tseries)

# -------------------------
# 1. Data Preparation
# -------------------------
# Read CSV data and convert Date column to Date type
data <- read.csv("C:/Users/risha/Downloads/archive (2)/coin_Bitcoin.csv", 
                 header = TRUE, stringsAsFactors = FALSE)
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")

# Subset data from January 1, 2014 to December 31, 2021
start_date <- as.Date("2014-01-01")
end_date   <- as.Date("2021-12-31")
data_sub   <- subset(data, Date >= start_date & Date <= end_date)

# -------------------------
# 2. Return Calculations
# -------------------------
# Calculate log prices and daily log returns (using 'Close' price)
data_sub$LogPrice <- log(data_sub$Close)
data_sub$DailyReturn <- c(NA, diff(data_sub$LogPrice))

# Convert to an xts object for time-series operations
data_xts <- xts(data_sub[, c("Close", "DailyReturn")], order.by = data_sub$Date)

# Weekly returns: Use the last price of each week
weekly_prices <- to.weekly(data_xts[, "Close"])
weekly_returns <- diff(log(weekly_prices[,4]))

# Monthly returns: Use the last price of each month
monthly_prices <- to.monthly(data_xts[, "Close"])
monthly_returns <- diff(log(monthly_prices[,4]))

# -------------------------
# 3. Descriptive Statistics
# -------------------------
# Remove NA values from daily returns
daily_returns <- na.omit(data_sub$DailyReturn)

# Daily statistics
mean_daily <- mean(daily_returns)
var_daily  <- var(daily_returns)
skew_daily <- skewness(daily_returns)
kurt_daily <- kurtosis(daily_returns)

# Weekly statistics
mean_weekly <- mean(weekly_returns, na.rm = TRUE)
var_weekly  <- var(weekly_returns, na.rm = TRUE)
skew_weekly <- skewness(weekly_returns, na.rm = TRUE)
kurt_weekly <- kurtosis(weekly_returns, na.rm = TRUE)

# Monthly statistics
mean_monthly <- mean(monthly_returns, na.rm = TRUE)
var_monthly  <- var(monthly_returns, na.rm = TRUE)
skew_monthly <- skewness(monthly_returns, na.rm = TRUE)
kurt_monthly <- kurtosis(monthly_returns, na.rm = TRUE)

# Print statistics to the console
cat("Daily Returns:\n")
cat("Mean:", mean_daily, "\nVariance:", var_daily, "\nSkewness:", skew_daily, "\nKurtosis:", kurt_daily, "\n\n")

cat("Weekly Returns:\n")
cat("Mean:", mean_weekly, "\nVariance:", var_weekly, "\nSkewness:", skew_weekly, "\nKurtosis:", kurt_weekly, "\n\n")

cat("Monthly Returns:\n")
cat("Mean:", mean_monthly, "\nVariance:", var_monthly, "\nSkewness:", skew_monthly, "\nKurtosis:", kurt_monthly, "\n\n")

# -------------------------
# 4. Rolling Metrics & Plots
# -------------------------
# Calculate a 30-day rolling average and standard deviation for the closing prices
rolling_avg <- rollapply(data_sub$Close, width = 30, FUN = mean, fill = NA, align = "right")
rolling_sd  <- rollapply(data_sub$Close, width = 30, FUN = sd, fill = NA, align = "right")

# Plot Bitcoin Price with 30-Day Rolling Average
plot(data_sub$Date, data_sub$Close, type = "l", col = "gray", 
     main = "Bitcoin Price with 30-Day Rolling Average", xlab = "Date", ylab = "Price")
lines(data_sub$Date, rolling_avg, col = "blue", lwd = 2)

# Plot 30-Day Rolling Standard Deviation (Volatility)
plot(data_sub$Date, rolling_sd, type = "l", col = "red", 
     main = "30-Day Rolling Standard Deviation (Volatility)", xlab = "Date", ylab = "Standard Deviation")

# -------------------------
# 5. Return Distribution & ACF Plots
# -------------------------
# Set up a 1x2 plotting area for histogram and QQ plot of daily returns
par(mfrow = c(1, 2))
hist(daily_returns, breaks = 50, main = "Histogram of Daily Returns", 
     xlab = "Daily Returns", col = "lightblue")
qqnorm(daily_returns, main = "QQ Plot of Daily Returns")
qqline(daily_returns, col = "red")
par(mfrow = c(1, 1))  # reset plotting layout

# Plot ACF for daily returns and squared daily returns to assess volatility clustering
par(mfrow = c(2, 1))
acf(daily_returns, main = "ACF of Daily Returns")
acf(daily_returns^2, main = "ACF of Squared Daily Returns")
par(mfrow = c(1, 1))  # reset plotting layout

# -------------------------
# 6. Stationarity Testing
# -------------------------
# Conduct Augmented Dickey-Fuller (ADF) test on the price series
adf_result <- adf.test(data_sub$Close)
print(adf_result)
