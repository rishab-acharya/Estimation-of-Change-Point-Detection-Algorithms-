###############################################################################
# 0) LOAD PACKAGES
###############################################################################
library(changepoint)

###############################################################################
# 1) DATA GENERATION
###############################################################################
generate_data <- function(seg_lens = c(100, 100),
                          means    = c(0, 0),
                          sd       = c(1, 2.5)) {
  # Combine normal segments of specified lengths, means, sds
  data <- unlist(mapply(rnorm, seg_lens, means, sd, SIMPLIFY = FALSE))
  return(data)
}

###############################################################################
# 2) DETECTION FUNCTIONS (PELT and BinSeg) with cpt.var
###############################################################################
# A) PELT version (using pen.value = "AIC"/"BIC"/"MBIC")
detect_pelt_crops <- function(data, penalty_value) {
  # cpt.var with method="PELT" and user-specified penalty
  cpt.var(data, method = "PELT", pen.value = penalty_value)
}

# B) BinSeg version (using pen.value = "AIC"/"BIC"/"MBIC")
detect_binseg_crops <- function(data, penalty_value) {
  # cpt.var with method="BinSeg"
  cpt.var(data, method = "BinSeg", pen.value = penalty_value)
}

###############################################################################
# 3) SIMULATION FUNCTIONS FOR REPEATED RUNS
###############################################################################
# A) PELT repeated simulation
simulate_pelt_crops <- function(times = 100,
                                means = c(0, 0),
                                sd = c(1, 2.5),
                                penalty_value) {
  out <- numeric(times)
  for (i in seq_len(times)) {
    data <- generate_data(seg_lens = c(100, 100), means = means, sd = sd)
    fit  <- detect_pelt_crops(data, penalty_value)
    out[i] <- length(cpts(fit))  # number of detected changepoints
  }
  return(out)
}

# B) BinSeg repeated simulation
simulate_binseg_crops <- function(times = 100,
                                  means = c(0, 0),
                                  sd = c(1, 2.5),
                                  penalty_value) {
  out <- numeric(times)
  for (i in seq_len(times)) {
    data <- generate_data(seg_lens = c(100, 100), means = means, sd = sd)
    fit  <- detect_binseg_crops(data, penalty_value)
    out[i] <- length(cpts(fit))  # number of detected changepoints
  }
  return(out)
}

###############################################################################
# 4) SENSITIVITY ANALYSIS FOR AVERAGE # OF CPs (VARYING 2nd SEGMENT'S SD)
###############################################################################
sensitivity_analysis_avg_cpts <- function(sim_func, penalty_value) {
  sd_steps <- seq(0, 5, by = 0.2)
  avg_cpts_list <- numeric(length(sd_steps))
  
  for (i in seq_along(sd_steps)) {
    res <- sim_func(times = 100,
                    means = c(0, 0),
                    sd = c(1, sd_steps[i]),  # vary only the 2nd segment's sd
                    penalty_value = penalty_value)
    avg_cpts_list[i] <- mean(res)
  }
  return(data.frame(sd_step = sd_steps, avg_cpts = avg_cpts_list))
}

###############################################################################
# 5) RUN SENSITIVITY ANALYSIS FOR PELT AND BINSEG UNDER MULTIPLE PENALTIES
###############################################################################
penalty_methods <- c("AIC", "BIC", "MBIC")

# -- (A) PELT results --
pelt_results <- list()
for (penalty_method in penalty_methods) {
  pelt_results[[penalty_method]] <- sensitivity_analysis_avg_cpts(
    sim_func      = simulate_pelt_crops,
    penalty_value = penalty_method
  )
}

# -- (B) BinSeg results --
binseg_results <- list()
for (penalty_method in penalty_methods) {
  binseg_results[[penalty_method]] <- sensitivity_analysis_avg_cpts(
    sim_func      = simulate_binseg_crops,
    penalty_value = penalty_method
  )
}

###############################################################################
# 6) PLOT THE RESULTS: 2 SEPARATE PLOTS, ONE FOR PELT AND ONE FOR BINSEG
###############################################################################
opar <- par(no.readonly = TRUE)  # save original graphics settings

par(mfrow = c(1,2), mar = c(5,5,4,2), oma=c(0,0,0,0))

# (A) Plot PELT results
plot(pelt_results$AIC$sd_step, pelt_results$AIC$avg_cpts,
     type = "b", col = "red",
     ylim = c(0, max(sapply(pelt_results, function(x) max(x$avg_cpts)))),
     xlim = c(0, 5),
     main = "PELT: Sensitivity to SD of 2nd Segment",
     xlab = "SD (2nd Segment)",
     ylab = "No. of Detected CP",
     pch = 16, lwd = 2)

lines(pelt_results$BIC$sd_step, pelt_results$BIC$avg_cpts, type = "b",
      col = "green", pch = 16, lwd = 2)
lines(pelt_results$MBIC$sd_step, pelt_results$MBIC$avg_cpts, type = "b",
      col = "blue", pch = 16, lwd = 2)

legend("bottomright", legend = penalty_methods,
       col = c("red","green","blue"),
       lty = 1, pch = 16, lwd = 2,
       title = "Penalty")

# (B) Plot BinSeg results
plot(binseg_results$AIC$sd_step, binseg_results$AIC$avg_cpts,
     type = "b", col = "red",
     ylim = c(0, max(sapply(binseg_results, function(x) max(x$avg_cpts)))),
     xlim = c(0, 5),
     main = "BinSeg: Sensitivity to SD of 2nd Segment",
     xlab = "SD (2nd Segment)",
     ylab = "No. of Detected CP",
     pch = 16, lwd = 2)

lines(binseg_results$BIC$sd_step, binseg_results$BIC$avg_cpts, type = "b",
      col = "green", pch = 16, lwd = 2)
lines(binseg_results$MBIC$sd_step, binseg_results$MBIC$avg_cpts, type = "b",
      col = "blue", pch = 16, lwd = 2)

legend("bottomright", legend = penalty_methods,
       col = c("red","green","blue"),
       lty = 1, pch = 16, lwd = 2,
       title = "Penalty")

par(opar)  # restore original graphics settings

###############################################################################
# 7) VISUALIZE CHANGE IN VARIANCE ON A SINGLE TIME SERIES
###############################################################################
# Generate one example dataset for demonstration
set.seed(123)  # for reproducibility
example_data <- generate_data(seg_lens = c(100, 100),
                              means    = c(0, 0),
                              sd       = c(1, 2.5))

# Detect CPs with PELT and BinSeg under a chosen penalty (e.g. "AIC")
fit_pelt_example   <- detect_pelt_crops(example_data,  "AIC")
fit_binseg_example <- detect_binseg_crops(example_data,"AIC")

# Plot the time series
plot(example_data, type = "l",
     main = " CP Detection for Variance Shift",
     xlab = "Index", ylab = "Value")

# Mark PELT's detected CPs (red dashed)
abline(v = cpts(fit_pelt_example), col = "red", lwd = 2, lty = 2)
# Mark BinSeg's detected CPs (blue dotted)
abline(v = cpts(fit_binseg_example), col = "blue", lwd = 2, lty = 3)

legend("topleft", legend = c("PELT (AIC)", "BinSeg (AIC)"),
       col = c("red", "green"), lty = c(2,3), lwd = 2)

