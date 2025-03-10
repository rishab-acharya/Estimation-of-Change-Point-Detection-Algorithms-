###############################################################################
# 0) LOAD PACKAGES
###############################################################################
library(changepoint)

###############################################################################
# 1) DATA GENERATION
###############################################################################
generate_data <- function(seg_lens = c(100, 100, 100, 100),
                          means    = c(0, 0, 0, 0),
                          sd       = c(1, 2.5, 0.5, 1)) {
  data <- unlist(mapply(rnorm, seg_lens, means, sd, SIMPLIFY = FALSE))
  return(data)
}

###############################################################################
# 2) DETECTION FUNCTIONS (PELT, BinSeg) with cpt.var
###############################################################################
# A) PELT detection (penalty_method in {"AIC","BIC","MBIC"})
detect_pelt <- function(data, penalty_method = "BIC") {
  cpt.var(data, method = "PELT", penalty = penalty_method)
}

# B) BinSeg detection (penalty_method in {"AIC","BIC","MBIC"})
detect_binseg <- function(data, penalty_method = "BIC") {
  cpt.var(data, method = "BinSeg", penalty = penalty_method)
}

###############################################################################
# 3) SIMULATION FUNCTIONS FOR REPEATED RUNS
###############################################################################
# A) PELT repeated simulation
simulate_pelt <- function(times = 100,
                          means = c(0, 0, 0, 0),
                          sd = c(1, 2.5, 0.5, 1),
                          penalty_method = "BIC") {
  out <- numeric(times)
  for (i in seq_len(times)) {
    data <- generate_data(seg_lens = c(100, 100, 100, 100),
                          means = means, sd = sd)
    fit <- detect_pelt(data, penalty_method)
    out[i] <- length(cpts(fit))
  }
  out
}

# B) BinSeg repeated simulation
simulate_binseg <- function(times = 100,
                            means = c(0, 0, 0, 0),
                            sd = c(1, 2.5, 0.5, 1),
                            penalty_method = "BIC") {
  out <- numeric(times)
  for (i in seq_len(times)) {
    data <- generate_data(seg_lens = c(100, 100, 100, 100),
                          means = means, sd = sd)
    fit <- detect_binseg(data, penalty_method)
    out[i] <- length(cpts(fit))
  }
  out
}

###############################################################################
# 4) SENSITIVITY ANALYSIS FOR AVERAGE # OF CPs
###############################################################################
# We'll vary the standard deviation of the 2nd segment from 0..3 in increments of 0.1

# For PELT
sensitivity_analysis_avg_cpts <- function(sim_func, mean_values = c(0, 0, 0, 0),
                                          penalty_methods = c("AIC", "BIC", "MBIC")) {
  sd_steps <- seq(0, 3, by = 0.1)
  avg_cpts_list <- list()
  
  for (penalty_method in penalty_methods) {
    avg_cpts <- numeric(length(sd_steps))
    for (i in seq_along(sd_steps)) {
      res <- sim_func(times = 100,
                      means = mean_values,
                      sd = c(1, sd_steps[i], 0.5, 1),
                      penalty_method = penalty_method)
      avg_cpts[i] <- mean(res)
    }
    avg_cpts_list[[penalty_method]] <- data.frame(sd_step = sd_steps, avg_cpts = avg_cpts)
  }
  return(avg_cpts_list)
}

# For BinSeg
sensitivity_analysis_avg_cpts_binseg <- function(sim_func, mean_values = c(0, 0, 0, 0),
                                                 penalty_methods = c("AIC", "BIC", "MBIC")) {
  sd_steps <- seq(0, 3, by = 0.1)
  avg_cpts_list <- list()
  
  for (penalty_method in penalty_methods) {
    avg_cpts <- numeric(length(sd_steps))
    for (i in seq_along(sd_steps)) {
      res <- sim_func(times = 100,
                      means = mean_values,
                      sd = c(1, sd_steps[i], 0.5, 1),
                      penalty_method = penalty_method)
      avg_cpts[i] <- mean(res)
    }
    avg_cpts_list[[penalty_method]] <- data.frame(sd_step = sd_steps, avg_cpts = avg_cpts)
  }
  return(avg_cpts_list)
}

###############################################################################
# 5) RUN SENSITIVITY ANALYSIS FOR MULTIPLE PENALTIES (PELT + BINSEG)
###############################################################################
penalty_methods <- c("AIC", "BIC", "MBIC")

# PELT
result_list_pelt <- sensitivity_analysis_avg_cpts(
  sim_func = simulate_pelt,
  penalty_methods = penalty_methods
)

# BinSeg
result_list_binseg <- sensitivity_analysis_avg_cpts_binseg(
  sim_func = simulate_binseg,
  penalty_methods = penalty_methods
)

###############################################################################
# 6) PLOT THE RESULTS (PELT and BinSeg, Different Penalties)
###############################################################################
opar <- par(no.readonly = TRUE)  # save original graphics settings

# ---------------- Plot for PELT ----------------
plot(NULL, xlim = c(0, 3),
     ylim = c(0, max(unlist(lapply(result_list_pelt, function(x) max(x$avg_cpts))))), 
     main = "Sensitivity to SD Change (PELT)",
     xlab = "Standard Deviation of 2nd Segment", ylab = "No. of Detected CP")

colors <- c("red", "green", "blue")
for (i in seq_along(result_list_pelt)) {
  result <- result_list_pelt[[i]]
  lines(result$sd_step, result$avg_cpts, type = "b", col = colors[i], pch = 16, lwd = 2)
}
legend("right", legend = penalty_methods, col = colors, lty = 1, pch = 16, lwd = 2)

# ---------------- Plot for BinSeg ----------------
plot(NULL, xlim = c(0, 3),
     ylim = c(0, max(unlist(lapply(result_list_binseg, function(x) max(x$avg_cpts))))), 
     main = "Sensitivity to SD Change (BinSeg)",
     xlab = "Standard Deviation of 2nd Segment", ylab = "No. of Detected CP")

for (i in seq_along(result_list_binseg)) {
  result <- result_list_binseg[[i]]
  lines(result$sd_step, result$avg_cpts, type = "b", col = colors[i], pch = 16, lwd = 2)
}
legend("bottomright", legend = penalty_methods, col = colors, lty = 1, pch = 16, lwd = 2)

par(opar)  # restore original graphics settings

###############################################################################
# 7) OVERLAY DETECTED CPs ON A SINGLE EXAMPLE TIME SERIES
###############################################################################
# Generate a single example dataset
set.seed(2023)
example_data <- generate_data(
  seg_lens = c(100, 100, 100, 100),
  means    = c(0, 0, 0, 0),
  sd       = c(1, 2.5, 0.5, 1)
)

# Choose a penalty, e.g., "BIC"
chosen_penalty <- "BIC"

# Detect CPs using PELT
fit_pelt_single <- detect_pelt(example_data, penalty_method = chosen_penalty)
cpts_pelt       <- cpts(fit_pelt_single)

# Detect CPs using BinSeg
fit_binseg_single <- detect_binseg(example_data, penalty_method = chosen_penalty)
cpts_binseg       <- cpts(fit_binseg_single)

# Plot the time series
plot(example_data, type="l",
     main=paste("PELT vs. BinSeg"),
     xlab="Time Index", ylab="Value")

# Overlay PELT CPs
abline(v = cpts_pelt, col="red", lwd=2, lty=2)
# Overlay BinSeg CPs
abline(v = cpts_binseg, col="blue", lwd=2, lty=3)

legend("topleft",
       legend=c(paste("PELT (",chosen_penalty,")"), 
                paste("BinSeg (",chosen_penalty,")")),
       col=c("red","blue"), lty=c(2,3), lwd=2)
