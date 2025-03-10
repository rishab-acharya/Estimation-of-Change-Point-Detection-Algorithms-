###############################################################################
# 0) LOAD PACKAGES
###############################################################################
library(changepoint)

###############################################################################
# 1) DATA GENERATION: 4 segments by default
###############################################################################
generate_data <- function(seg_lens = c(100, 100, 100, 100),
                          means    = c(0, 3, -2, 5),
                          sd       = c(0.5,0.5,0.5,0.5)) {
  data <- unlist(mapply(rnorm, seg_lens, means, sd, SIMPLIFY=FALSE))
  return(data)
}

generate_data_low  <- function() {
  generate_data(means=c(0,3,-2,5), sd=c(0.5,0.5,0.5,0.5))
}
generate_data_high <- function() {
  generate_data(means=c(0,3,-2,5), sd=c(1.5,1.5,1.5,1.5))
}

###############################################################################
# 2) DETECTION FUNCTIONS (MULTIPLE CPs)
###############################################################################
# BinSeg: allow up to 5 CPs
detect_binseg <- function(data, penalty_method="MBIC", Q=5) {
  cpt.mean(data, method="BinSeg", penalty=penalty_method, Q=Q)
}
# PELT: automatically chooses # of CPs
detect_pelt <- function(data, penalty_method="MBIC") {
  cpt.mean(data, method="PELT", penalty=penalty_method)
}

###############################################################################
# 3) REPEATED SIMULATION (Not Normalized)
###############################################################################
simulate_binseg <- function(times=100,
                            means=c(0,3,-2,5),
                            sd=c(0.5,0.5,0.5,0.5),
                            penalty_method="MBIC") {
  out <- numeric(times)
  for(i in seq_len(times)){
    data <- generate_data(seg_lens=c(100,100,100,100),
                          means=means, sd=sd)
    fit  <- detect_binseg(data, penalty_method, Q=5)
    out[i] <- length(cpts(fit))  # number of CPs
  }
  out
}

simulate_pelt <- function(times=100,
                          means=c(0,3,-2,5),
                          sd=c(0.5,0.5,0.5,0.5),
                          penalty_method="MBIC") {
  out <- numeric(times)
  for(i in seq_len(times)){
    data <- generate_data(seg_lens=c(100,100,100,100),
                          means=means, sd=sd)
    fit  <- detect_pelt(data, penalty_method)
    out[i] <- length(cpts(fit))
  }
  out
}

###############################################################################
# 4) MAD NORMALIZATION + REPEATED SIMULATION
###############################################################################
normalize_data <- function(x) {
  scale_est <- mad(diff(x)) / sqrt(2)
  x_norm <- x / scale_est
  return(x_norm)
}

simulate_binseg_norm <- function(times=100,
                                 means=c(0,3,-2,5),
                                 sd=c(0.5,0.5,0.5,0.5),
                                 penalty_method="MBIC") {
  out <- numeric(times)
  for(i in seq_len(times)){
    data <- generate_data(seg_lens=c(100,100,100,100),
                          means=means, sd=sd)
    data_norm <- normalize_data(data)
    fit  <- detect_binseg(data_norm, penalty_method, Q=5)
    out[i] <- length(cpts(fit))
  }
  out
}

simulate_pelt_norm <- function(times=100,
                               means=c(0,3,-2,5),
                               sd=c(0.5,0.5,0.5,0.5),
                               penalty_method="MBIC") {
  out <- numeric(times)
  for(i in seq_len(times)){
    data <- generate_data(seg_lens=c(100,100,100,100),
                          means=means, sd=sd)
    data_norm <- normalize_data(data)
    fit  <- detect_pelt(data_norm, penalty_method)
    out[i] <- length(cpts(fit))
  }
  out
}

###############################################################################
# 5) SENSITIVITY: AVERAGE # OF CPs vs. MEAN SHIFT
###############################################################################
# We'll vary the 2nd segment's mean from 0..5 in increments of 0.2,
# then compute the average # CPs (which can be 0..some max).
sensitivity_analysis_avg_cpts <- function(sim_func, sd_values=c(0.5,0.5,0.5,0.5)) {
  mean_steps <- seq(0, 5, by=0.2)
  avg_cpts   <- numeric(length(mean_steps))
  
  for(i in seq_along(mean_steps)){
    # means = c(0, mean_steps[i], -2, 5), for example
    res <- sim_func(times=100,
                    means=c(0, mean_steps[i], -2, 5),
                    sd=sd_values)
    avg_cpts[i] <- mean(res)
  }
  data.frame(mean_step=mean_steps, avg_cpts=avg_cpts)
}

###############################################################################
# 6) MAKE 2×2 SENSITIVITY PLOTS (Not Normalized) + SINGLE LEGEND
###############################################################################
penalties <- c("AIC", "BIC", "MBIC")
colors    <- c("red", "blue", "green")
lty_vec   <- c(1, 2, 3)
pch_vec   <- c(16,17,18)

# 2x2 for BinSeg (low/high noise) & PELT (low/high noise), average # CP.
par(mfrow=c(2,2), mar=c(5,5,3,2))

# (A) BinSeg, Low Noise
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="BinSeg \nLow Noise (SD=0.5, Not Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func = function(...) simulate_binseg(..., penalty_method=penalties[i]),
    sd_values=c(0.5,0.5,0.5,0.5))
  xvals <- df$mean_step + 0.01*(i-2)  # small offset
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (B) BinSeg, High Noise
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="BinSeg \nHigh Noise (SD=1.5, Not Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func = function(...) simulate_binseg(..., penalty_method=penalties[i]),
    sd_values=c(1.5,1.5,1.5,1.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (C) PELT, Low Noise
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="PELT \nLow Noise (SD=0.5, Not Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func = function(...) simulate_pelt(..., penalty_method=penalties[i]),
    sd_values=c(0.5,0.5,0.5,0.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (D) PELT, High Noise
plot(NULL, xlim=c(0,5), ylim=c(0,80),
     main="PELT \nHigh Noise (SD=1.5, Not Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func = function(...) simulate_pelt(..., penalty_method=penalties[i]),
    sd_values=c(1.5,1.5,1.5,1.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# Place a shared legend in the absolute center
par(xpd=NA, fig=c(0,1,0,1), new=TRUE)
plot(0,0,type="n", bty="n", xlab="", ylab="",
     xlim=c(0,1), ylim=c(0,1), xaxt="n", yaxt="n")
legend(x=0.5, y=0.45,
       legend=penalties,
       col=colors, lty=lty_vec, pch=pch_vec, lwd=2,
       xjust=0.5, yjust=0.5,
       cex=1.1, bg="white")
par(xpd=FALSE)

###############################################################################
# 7) 2×2 SENSITIVITY PLOTS (MAD‐Normalized) + SINGLE LEGEND
###############################################################################
par(mfrow=c(2,2), mar=c(5,5,3,2))

# (A) BinSeg, Low Noise (Normalized)
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="BinSeg \nLow Noise (SD=0.5, Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func=function(...){
      simulate_binseg_norm(..., penalty_method=penalties[i])
    }, sd_values=c(0.5,0.5,0.5,0.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (B) BinSeg, High Noise (Normalized)
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="BinSeg \nHigh Noise (SD=1.5, Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func=function(...){
      simulate_binseg_norm(..., penalty_method=penalties[i])
    }, sd_values=c(1.5,1.5,1.5,1.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (C) PELT, Low Noise (Normalized)
plot(NULL, xlim=c(0,5), ylim=c(0,5),
     main="PELT \nLow Noise (SD=0.5, Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func=function(...){
      simulate_pelt_norm(..., penalty_method=penalties[i])
    }, sd_values=c(0.5,0.5,0.5,0.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# (D) PELT, High Noise (Normalized)
plot(NULL, xlim=c(0,5), ylim=c(0,80),
     main="PELT \nHigh Noise (SD=1.5, Normalized)",
     xlab="Mean Shift in 2nd Segment", ylab="No. of CPs Detected")
for(i in seq_along(penalties)){
  df <- sensitivity_analysis_avg_cpts(
    sim_func=function(...){
      simulate_pelt_norm(..., penalty_method=penalties[i])
    }, sd_values=c(1.5,1.5,1.5,1.5))
  xvals <- df$mean_step + 0.01*(i-2)
  lines(xvals, df$avg_cpts,
        type="b", col=colors[i], lty=lty_vec[i], pch=pch_vec[i], lwd=2)
}

# Single legend in the center again
par(xpd=NA, fig=c(0,1,0,1), new=TRUE)
plot(0,0,type="n", bty="n", xlab="", ylab="",
     xlim=c(0,1), ylim=c(0,1), xaxt="n", yaxt="n")
legend(x=0.5, y=0.45,
       legend=penalties,
       col=colors, lty=lty_vec, pch=pch_vec, lwd=2,
       xjust=0.5, yjust=0.5,
       cex=1.1, bg="white")
par(xpd=FALSE)

###############################################################################
# 8) EXAMPLE TIME SERIES (2×1) + SINGLE LEGEND
###############################################################################
par(mfrow=c(2,1), mar=c(5,5,3,2))

set.seed(123)
data_low  <- generate_data_low()   # 4 segments, low noise
data_high <- generate_data_high()  # 4 segments, high noise

# Low noise: detect CPs with BinSeg + PELT
fit_binseg_low <- detect_binseg(data_low,  penalty_method="MBIC", Q=5)
cp_binseg_low  <- cpts(fit_binseg_low)
fit_pelt_low   <- detect_pelt(data_low, penalty_method="MBIC")
cp_pelt_low    <- cpts(fit_pelt_low)

plot(data_low, type="l", main="Multiple CPs - Low Noise (SD=0.5)",
     xlab="Time Index", ylab="Value")
abline(v=cp_binseg_low, col="blue", lty=2, lwd=2, xpd=FALSE)
abline(v=cp_pelt_low,   col="red",  lty=3, lwd=2, xpd=FALSE)

# High noise
fit_binseg_high <- detect_binseg(data_high, penalty_method="MBIC", Q=5)
cp_binseg_high  <- cpts(fit_binseg_high)
fit_pelt_high   <- detect_pelt(data_high, penalty_method="MBIC")
cp_pelt_high    <- cpts(fit_pelt_high)

plot(data_high, type="l", main="Multiple CPs - High Noise (SD=1.5)",
     xlab="Time Index", ylab="Value")
abline(v=cp_binseg_high, col="blue", lty=2, lwd=2, xpd=FALSE)
abline(v=cp_pelt_high,   col="red",  lty=3, lwd=2, xpd=FALSE)

# Single legend for both subplots
par(xpd=NA)
legend(x=-75, y=22.5,
       legend=c("BinSeg", "PELT"),
       col=c("blue","red"), lty=c(2,3), lwd=2,
       horiz=TRUE, cex=1.0, box.lty=0)
par(xpd=FALSE)
