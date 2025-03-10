##########################################################
# 0) LOAD PACKAGES
##########################################################
library(changepoint)

##########################################################
# 1) Data Generation: Two Close Mean Shifts
##########################################################
simulate_data_two_close_cps <- function(
    n         = 200,           # total length of the series
    first_cp  = 100,           # location of first CP
    gap       = 5,             # distance to second CP (second CP at first_cp+gap)
    means     = c(0, 3, -2),   # means for three segments
    sds       = c(0.5, 0.5, 0.5)  # standard deviations for three segments
) {
  # Segments: 
  # 1: indices 1:first_cp
  # 2: indices (first_cp+1):(first_cp+gap)
  # 3: indices (first_cp+gap+1):n
  seg_lens <- c(first_cp, gap, n - first_cp - gap)
  data_vec <- unlist(mapply(rnorm, seg_lens, means, sds, SIMPLIFY = FALSE))
  return(data_vec)
}

##########################################################
# 2) Detection Functions for PELT and BinSeg
##########################################################
detect_pelt <- function(data, penalty = "MBIC") {
  cpt.mean(data, method = "PELT", penalty = penalty)
}

detect_binseg <- function(data, penalty = "MBIC") {
  cpt.mean(data, method = "BinSeg", penalty = penalty)
}

##########################################################
# 3) Helper Function: Check if Two Close CPs Were Detected
##########################################################
check_two_close_cps <- function(
    detected_cps,
    cp1 = 100,    # expected CP1
    cp2 = 105,    # expected CP2 (first_cp + gap; default gap = 5)
    tol = 2       # tolerance: ±2 indices
) {
  near_cp1 <- any(detected_cps >= (cp1 - tol) & detected_cps <= (cp1 + tol))
  near_cp2 <- any(detected_cps >= (cp2 - tol) & detected_cps <= (cp2 + tol))
  return(near_cp1 && near_cp2)
}

##########################################################
# 4) Repeated Simulation Functions
##########################################################
# For PELT:
simulate_two_close_cps_pelt <- function(
    times     = 100,
    n         = 200,
    first_cp  = 100,
    gap       = 5,
    means     = c(0, 3, -2),
    sds       = c(1.5, 1.5, 1.5),  # high noise example
    penalty   = "MBIC",
    match_tol = 2
) {
  results <- data.frame(
    found_cps      = integer(times),
    separated_2cps = logical(times)
  )
  
  for (i in seq_len(times)) {
    data_i <- simulate_data_two_close_cps(n, first_cp, gap, means, sds)
    fit_i <- detect_pelt(data_i, penalty = penalty)
    detected_cps <- cpts(fit_i)
    results$found_cps[i] <- length(detected_cps)
    results$separated_2cps[i] <- check_two_close_cps(detected_cps, cp1 = first_cp, cp2 = first_cp + gap, tol = match_tol)
  }
  return(results)
}

# For BinSeg:
simulate_two_close_cps_binseg <- function(
    times     = 100,
    n         = 200,
    first_cp  = 100,
    gap       = 5,
    means     = c(0, 3, -2),
    sds       = c(1.5, 1.5, 1.5),  # high noise example
    penalty   = "MBIC",
    match_tol = 2
) {
  results <- data.frame(
    found_cps      = integer(times),
    separated_2cps = logical(times)
  )
  
  for (i in seq_len(times)) {
    data_i <- simulate_data_two_close_cps(n, first_cp, gap, means, sds)
    fit_i <- detect_binseg(data_i, penalty = penalty)
    detected_cps <- cpts(fit_i)
    results$found_cps[i] <- length(detected_cps)
    results$separated_2cps[i] <- check_two_close_cps(detected_cps, cp1 = first_cp, cp2 = first_cp + gap, tol = match_tol)
  }
  return(results)
}

##########################################################
# 5) Loop Through Gap Values (1 to 10) for Each Penalty and Method
##########################################################
gap_values <- 1:10
n_runs     <- 200   # simulations per gap
means_used <- c(0, 3, -2)
sds_used   <- c(1.5, 1.5, 1.5)

# Initialize result vectors for PELT
prop_correct_AIC_pelt  <- numeric(length(gap_values))
avg_found_AIC_pelt     <- numeric(length(gap_values))
prop_correct_BIC_pelt  <- numeric(length(gap_values))
avg_found_BIC_pelt     <- numeric(length(gap_values))
prop_correct_MBIC_pelt <- numeric(length(gap_values))
avg_found_MBIC_pelt    <- numeric(length(gap_values))

# Initialize result vectors for BinSeg
prop_correct_AIC_binseg  <- numeric(length(gap_values))
avg_found_AIC_binseg     <- numeric(length(gap_values))
prop_correct_BIC_binseg  <- numeric(length(gap_values))
avg_found_BIC_binseg     <- numeric(length(gap_values))
prop_correct_MBIC_binseg <- numeric(length(gap_values))
avg_found_MBIC_binseg    <- numeric(length(gap_values))

for (i in seq_along(gap_values)) {
  gap_val <- gap_values[i]
  
  # For PELT:
  # AIC
  sim_res_aic_pelt <- simulate_two_close_cps_pelt(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "AIC",
    match_tol = 2
  )
  prop_correct_AIC_pelt[i] <- mean(sim_res_aic_pelt$separated_2cps)
  avg_found_AIC_pelt[i]    <- mean(sim_res_aic_pelt$found_cps)
  
  # BIC
  sim_res_bic_pelt <- simulate_two_close_cps_pelt(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "BIC",
    match_tol = 2
  )
  prop_correct_BIC_pelt[i] <- mean(sim_res_bic_pelt$separated_2cps)
  avg_found_BIC_pelt[i]    <- mean(sim_res_bic_pelt$found_cps)
  
  # MBIC
  sim_res_mbic_pelt <- simulate_two_close_cps_pelt(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "MBIC",
    match_tol = 2
  )
  prop_correct_MBIC_pelt[i] <- mean(sim_res_mbic_pelt$separated_2cps)
  avg_found_MBIC_pelt[i]    <- mean(sim_res_mbic_pelt$found_cps)
  
  # For BinSeg:
  # AIC
  sim_res_aic_binseg <- simulate_two_close_cps_binseg(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "AIC",
    match_tol = 2
  )
  prop_correct_AIC_binseg[i] <- mean(sim_res_aic_binseg$separated_2cps)
  avg_found_AIC_binseg[i]    <- mean(sim_res_aic_binseg$found_cps)
  
  # BIC
  sim_res_bic_binseg <- simulate_two_close_cps_binseg(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "BIC",
    match_tol = 2
  )
  prop_correct_BIC_binseg[i] <- mean(sim_res_bic_binseg$separated_2cps)
  avg_found_BIC_binseg[i]    <- mean(sim_res_bic_binseg$found_cps)
  
  # MBIC
  sim_res_mbic_binseg <- simulate_two_close_cps_binseg(
    times     = n_runs,
    n         = 200,
    first_cp  = 100,
    gap       = gap_val,
    means     = means_used,
    sds       = sds_used,
    penalty   = "MBIC",
    match_tol = 2
  )
  prop_correct_MBIC_binseg[i] <- mean(sim_res_mbic_binseg$separated_2cps)
  avg_found_MBIC_binseg[i]    <- mean(sim_res_mbic_binseg$found_cps)
}

##########################################################
# 7) Plot the Results for PELT
##########################################################
par(mfrow = c(1,2))

# PELT: Fraction of runs with both CPs detected vs. Gap Value
plot(gap_values, prop_correct_AIC_pelt, type="b", pch=16, col="red",
     ylim=c(0,1), xlab="Gap Value", 
     ylab="Fraction of Runs with 2 CPs Detected",
     main="PELT Detection Success")
lines(gap_values, prop_correct_BIC_pelt, type="b", pch=16, col="green")
lines(gap_values, prop_correct_MBIC_pelt, type="b", pch=16, col="blue")
legend("bottomright", legend=c("AIC","BIC","MBIC"),
       col=c("red","green","blue"), lty=1, pch=16, cex=1, bty="n")

# PELT: Average # of CPs vs. Gap Value
plot(gap_values, avg_found_AIC_pelt, type="b", pch=16, col="red",
     ylim=c(0, max(avg_found_AIC_pelt, avg_found_BIC_pelt, avg_found_MBIC_pelt)), 
     xlab="Gap Value", ylab="Average No. of CPs Detected",
     main="PELT: Avg CPs")
lines(gap_values, avg_found_BIC_pelt, type="b", pch=16, col="green")
lines(gap_values, avg_found_MBIC_pelt, type="b", pch=16, col="blue")
legend("right", legend=c("AIC","BIC","MBIC"),
       col=c("red","green","blue"), lty=1, pch=16, cex=1, bty="n")

##########################################################
# 8) Plot the Results for BinSeg
##########################################################
par(mfrow = c(1,2))

# BinSeg: Fraction of runs with both CPs detected vs. Gap Value
plot(gap_values, prop_correct_AIC_binseg, type="b", pch=16, col="red",
     ylim=c(0,1), xlab="Gap Value", 
     ylab="Fraction of Runs with 2 CPs Detected",
     main="BinSeg Detection Success")
lines(gap_values, prop_correct_BIC_binseg, type="b", pch=16, col="green")
lines(gap_values, prop_correct_MBIC_binseg, type="b", pch=16, col="blue")
legend("bottomright", legend=c("AIC","BIC","MBIC"),
       col=c("red","green","blue"), lty=1, pch=16, cex=1, bty="n")

# BinSeg: Average # of CPs vs. Gap Value
plot(gap_values, avg_found_AIC_binseg, type="b", pch=16, col="red",
     ylim=c(0, max(avg_found_AIC_binseg, avg_found_BIC_binseg, avg_found_MBIC_binseg)), 
     xlab="Gap Value", ylab="Average No. of CPs Detected",
     main="BinSeg: Avg CPs")
lines(gap_values, avg_found_BIC_binseg, type="b", pch=16, col="green")
lines(gap_values, avg_found_MBIC_binseg, type="b", pch=16, col="blue")
legend("bottomright", legend=c("AIC","BIC","MBIC"),
       col=c("red","green","blue"), lty=1, pch=16, cex=1, bty="n")




##########################################################
# Visualize Detected Change Points on a Single Time Series
##########################################################
set.seed(123)
# Generate one example dataset with two close CPs
example_data <- simulate_data_two_close_cps(
  n = 200,
  first_cp = 100,
  gap = 5,              # Adjust gap as needed
  means = c(0, 3, -2),
  sds = c(1.5, 1.5, 1.5)  # Higher noise example
)

# Detect CPs using PELT with MBIC penalty
fit_pelt <- detect_pelt(example_data, penalty = "MBIC")
cp_pelt <- cpts(fit_pelt)

# Detect CPs using BinSeg with MBIC penalty
fit_binseg <- detect_binseg(example_data, penalty = "MBIC")
cp_binseg <- cpts(fit_binseg)

# Plot the time series
plot(example_data, type = "l", 
     main = "Detected Change Points on Given Time Series",
     xlab = "Time Index", ylab = "Value", cex.lab = 1.2, cex.main = 1.2)

# Overlay PELT detected CPs (red dashed lines)
abline(v = cp_pelt, col = "red", lwd = 2, lty = 2)

# Overlay BinSeg detected CPs (blue dotted lines)
abline(v = cp_binseg, col = "blue", lwd = 2, lty = 3)

# Add a legend
legend(x=5,y=-2.5, legend = c("PELT (MBIC)", "BinSeg (MBIC)"),
       col = c("red", "blue"), lty = c(2,3), lwd = 2)

