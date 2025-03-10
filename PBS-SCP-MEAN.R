###############################################################################
# 0) LOAD PACKAGES AND HELPER CODE
###############################################################################
library(changepoint)

# (A) Data Simulation
sim_data <- function(seg_lens = c(200, 200), means = c(0, 5), sd = c(0.5, 0.5)) {
  out <- numeric(0)
  for(i in seq_along(seg_lens)) {
    out <- c(out, rnorm(seg_lens[i], mean=means[i], sd=sd[i]))
  }
  return(out)
}
sim_data_low <- function() sim_data(means=c(0,5), sd=c(0.5,0.5))
sim_data_high <- function() sim_data(means=c(0,5), sd=c(1.5,1.5))

# (B) Detection Functions (BinSeg, PELT) - single CP
detect_binseg <- function(data, penalty_method="MBIC") {
  cpt.mean(data, method="BinSeg", penalty=penalty_method, Q=1)
}
detect_pelt <- function(data, penalty_method="MBIC") {
  cpt.mean(data, method="PELT", penalty=penalty_method, Q=1)
}

# (C) Repeated Simulation
repeat_simulation_low_binseg <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(0.5,0.5))
    fit <- detect_binseg(d, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_high_binseg <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(1.5,1.5))
    fit <- detect_binseg(d, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_low_pelt <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(0.5,0.5))
    fit <- detect_pelt(d, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_high_pelt <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(1.5,1.5))
    fit <- detect_pelt(d, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}

# (D) MAD Normalization + Repeat Functions
normalize_data <- function(x) {
  scale_est <- mad(diff(x)) / sqrt(2)
  x_norm <- x / scale_est
  return(x_norm)
}

repeat_simulation_low_binseg_norm <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(0.5,0.5))
    d_norm <- normalize_data(d)
    fit <- detect_binseg(d_norm, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_high_binseg_norm <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(1.5,1.5))
    d_norm <- normalize_data(d)
    fit <- detect_binseg(d_norm, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_low_pelt_norm <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(0.5,0.5))
    d_norm <- normalize_data(d)
    fit <- detect_pelt(d_norm, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}
repeat_simulation_high_pelt_norm <- function(times=100, means=c(0,5), penalty_method="MBIC") {
  results <- vector("list", times)
  for(j in seq_len(times)) {
    d <- sim_data(means=means, sd=c(1.5,1.5))
    d_norm <- normalize_data(d)
    fit <- detect_pelt(d_norm, penalty_method)
    results[[j]] <- cpts(fit)
  }
  results
}

# (E) Sensitivity Analysis
sensitivity_to_mean_step_size <- function(repeat_sim_func) {
  mean_shifts <- seq(0, 5, by=0.2)
  pct_1cpts <- numeric(length(mean_shifts))
  for(k in seq_along(mean_shifts)) {
    sim_results <- repeat_sim_func(times=100, means=c(0, mean_shifts[k]))
    # fraction with exactly 1 CP
    pct_1cpts[k] <- mean(sapply(sim_results, length) == 1)
  }
  data.frame(mean_shift=mean_shifts, pct_1cpts=pct_1cpts)
}

###############################################################################
# 1) PENALTIES + COLORS
###############################################################################
penalties <- c("AIC", "BIC", "MBIC")
colors <- c("red", "blue", "green")

###############################################################################
# 2) PLOTS FOR UNNORMALIZED DATA (2x2) + SINGLE LEGEND
###############################################################################
par(mfrow=c(2,2), mar=c(4,4,4,2))

# -- BinSeg, Low Noise --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="BinSeg Sensitivity\nLow Noise (SD=0.5,Not Normalized)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_low_binseg(times, means, penalty_method=penalties[i]))
  lines(df$mean_shift, df$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- BinSeg, High Noise --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="BinSeg Sensitivity\nHigh Noise (SD=1.5,Not Normalized)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_high_binseg(times, means, penalty_method=penalties[i]))
  lines(df$mean_shift, df$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- PELT, Low Noise --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="PELT Sensitivity\nLow Noise (SD=0.5,Not Normalized)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_low_pelt(times, means, penalty_method=penalties[i]))
  lines(df$mean_shift, df$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- PELT, High Noise --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="PELT Sensitivity\nHigh Noise (SD=1.5,Not Normalized)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_high_pelt(times, means, penalty_method=penalties[i]))
  lines(df$mean_shift, df$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# --- NOW ADD A LEGEND IN THE ABSOLUTE CENTER ---
par(xpd=NA, fig=c(0,1,0,1), new=TRUE)
plot(0,0,type="n", bty="n", xlab="", ylab="",
     xlim=c(0,1), ylim=c(0,1), xaxt="n", yaxt="n")

legend(
  x=0.5, y=0.5,            # put the legend at device-center
  legend=c("AIC", "BIC", "MBIC"), 
  col   =c("red","blue","green"),
  lty   =1, lwd=3,
  xjust=0.5, yjust=0.5,    # anchor by center
  cex=1.2, bg="white"      # white background if desired
)

###############################################################################
# 3) PLOTS FOR MAD-NORMALIZED DATA (2x2) + SINGLE LEGEND
###############################################################################
par(mfrow=c(2,2), mar=c(4,4,4,2))

# -- BinSeg, Low Noise, Normalized --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="BinSeg (Normalized)\nLow Noise (SD=0.5)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df_norm <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_low_binseg_norm(times, means, penalty_method=penalties[i]))
  lines(df_norm$mean_shift, df_norm$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- BinSeg, High Noise, Normalized --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="BinSeg (Normalized)\nHigh Noise (SD=1.5)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df_norm <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_high_binseg_norm(times, means, penalty_method=penalties[i]))
  lines(df_norm$mean_shift, df_norm$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- PELT, Low Noise, Normalized --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="PELT (Normalized)\nLow Noise (SD=0.5)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df_norm <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_low_pelt_norm(times, means, penalty_method=penalties[i]))
  lines(df_norm$mean_shift, df_norm$pct_1cpts, type="b", col=colors[i], lwd=2)
}

# -- PELT, High Noise, Normalized --
plot(NULL, xlim=c(0,5), ylim=c(0,1),
     main="PELT (Normalized)\nHigh Noise (SD=1.5)",
     xlab="Mean Shift", ylab="Proportion of Detecting 1 CP", cex.lab=1.2)
for(i in seq_along(penalties)) {
  df_norm <- sensitivity_to_mean_step_size(function(times, means)
    repeat_simulation_high_pelt_norm(times, means, penalty_method=penalties[i]))
  lines(df_norm$mean_shift, df_norm$pct_1cpts, type="b", col=colors[i], lwd=2)
}


# --- NOW ADD A LEGEND IN THE ABSOLUTE CENTER ---
par(xpd=NA, fig=c(0,1,0,1), new=TRUE)
plot(0,0,type="n", bty="n", xlab="", ylab="",
     xlim=c(0,1), ylim=c(0,1), xaxt="n", yaxt="n")

legend(
  x=0.5, y=0.5,            # put the legend at device-center
  legend=c("AIC", "BIC", "MBIC"), 
  col   =c("red","blue","green"),
  lty   =1, lwd=3,
  xjust=0.5, yjust=0.5,    # anchor by center
  cex=1.2, bg="white"      # white background if desired
)

###############################################################################
# 4) VISUALIZE SINGLE REALIZATIONS (2 plots) + SINGLE LEGEND
###############################################################################
# We'll produce 2 plots (top=low noise, bottom=high noise),
# with a single legend for both methods.
# Generate the two datasets
set.seed(2023)
data_low <- sim_data_low()
data_high <- sim_data_high()

# Then proceed with plotting
par(mfrow=c(2,1), mar=c(4,4,4,2))

# (A) Low Noise
plot(data_low, type="l", main="Low Noise (SD=0.5)",
     xlab="Index", ylab="Value", cex.lab=1.2)
fit_binseg_low <- detect_binseg(data_low, penalty_method="MBIC")
abline(v = cpts(fit_binseg_low), col="blue", lwd=2, lty=2, xpd=FALSE)
fit_pelt_low <- detect_pelt(data_low, penalty_method="MBIC")
abline(v = cpts(fit_pelt_low), col="red", lwd=2, lty=3, xpd=FALSE)

# (B) High Noise
plot(data_high, type="l", main="High Noise (SD=1.5)",
     xlab="Index", ylab="Value", cex.lab=1.2)
fit_binseg_high <- detect_binseg(data_high, penalty_method="MBIC")
abline(v = cpts(fit_binseg_high), col="blue", lwd=2, lty=2, xpd=FALSE)
fit_pelt_high <- detect_pelt(data_high, penalty_method="MBIC")
abline(v = cpts(fit_pelt_high), col="red", lwd=2, lty=3, xpd=FALSE)

# Single legend for both
par(xpd=NA)
legend(x = -30, y = 22.5,
       legend=c("BinSeg CP","PELT CP"),
       col=c("blue","red"), lty=c(2,3), lwd=2,
       horiz=TRUE, cex=1.0, box.lty=0)
par(xpd=FALSE)
