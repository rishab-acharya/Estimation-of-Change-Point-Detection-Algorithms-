library(changepoint)

################################################
# 1. Data Generation Function for Multiple CPs
################################################
generate_data_close_cps <- function(seg_lens = c(100, 10, 45, 10, 40, 10, 200),
                                    means = c(0, 3, -2, 5, 2, 4, 4),
                                    sd = rep(0.5, 7)) {
  data <- unlist(mapply(rnorm, seg_lens, means, sd, SIMPLIFY = FALSE))
  return(data)
}

################################################
# 2. Changepoint Detection Functions
################################################
detect_changepoints_binseg <- function(data, penalty_method = "MBIC") {
  fit <- cpt.mean(data, method = "BinSeg", penalty = penalty_method)
  return(fit)
}

detect_changepoints_pelt <- function(data, penalty_method = "MBIC") {
  fit <- cpt.mean(data, method = "PELT", penalty = penalty_method)
  return(fit)
}

################################################
# 3. Generate Data for Low and High Noise
################################################
set.seed(123)
data_low <- generate_data_close_cps(sd = rep(0.5, 7))  # Low SD (0.5)
data_high <- generate_data_close_cps(sd = rep(1.5, 7))  # High SD (1.5)

################################################
# 4. Detect Change-Points Using BinSeg and PELT (MBIC penalty)
################################################
# BinSeg detection for Low and High SD
fit_binseg_low <- detect_changepoints_binseg(data_low, penalty_method = "MBIC")
cp_binseg_low <- cpts(fit_binseg_low)

fit_binseg_high <- detect_changepoints_binseg(data_high, penalty_method = "MBIC")
cp_binseg_high <- cpts(fit_binseg_high)

# PELT detection for Low and High SD
fit_pelt_low <- detect_changepoints_pelt(data_low, penalty_method = "MBIC")
cp_pelt_low <- cpts(fit_pelt_low)

fit_pelt_high <- detect_changepoints_pelt(data_high, penalty_method = "MBIC")
cp_pelt_high <- cpts(fit_pelt_high)

################################################
# 5. Plot the Time Series and Overlay Detected CPs
################################################
# Set up plotting layout for 2 rows, 1 column
par(mfrow = c(2,1), mar = c(5,5,4,6))  # Increase right margin to allow room for legend

# --- Plot 1: BinSeg with Low Noise (sd = 0.5) ---
plot(data_low, type = "l", main = "BinSeg Detection: Low Noise (sd = 0.5)",
     xlab = "Time Index", ylab = "Value", cex.lab = 1.2, cex.main = 1.2)
abline(v = cp_binseg_low, col = "blue", lwd = 2, lty = 2)  # BinSeg CPs
abline(v = cp_pelt_low,   col = "red",  lwd = 2, lty = 3)  # PELT CPs

# --- Plot 2: BinSeg with High Noise (sd = 1.5) ---
plot(data_high, type = "l", main = "BinSeg Detection: High Noise (sd = 1.5)",
     xlab = "Time Index", ylab = "Value", cex.lab = 1.2, cex.main = 1.2)
abline(v = cp_binseg_high, col = "blue", lwd = 2, lty = 2)  # BinSeg CPs
abline(v = cp_pelt_high,   col = "red",  lwd = 2, lty = 3)  # PELT CPs

# --- SINGLE LEGEND FOR BOTH PLOTS ---
par(xpd = NA)  # Allow drawing outside the plot region
legend(x=-25, y=25, xpd = NA, legend = c("BinSeg", "PELT"),
       col = c("blue", "red"), lty = c(2,3), lwd = 2, cex = 0.9)
par(xpd = FALSE)  # Reset clipping