###############################################################################
# 0) LOAD REQUIRED PACKAGE
###############################################################################
library(changepoint)

###############################################################################
# 1) DATA SIMULATION: SINGLE CHANGE (MEAN + VAR)
###############################################################################
simulate_single_meanvar <- function(
    n = 200,
    mean1 = 0, mean2 = 3,
    sd1   = 1, sd2   = 2
){
  # Each segment is length n/2 -> single boundary at index n/2
  half <- n / 2
  seg1 <- rnorm(half, mean=mean1, sd=sd1)
  seg2 <- rnorm(half, mean=mean2, sd=sd2)
  c(seg1, seg2)
}

###############################################################################
# 2) DETECTION: PELT OR BINSEG (SINGLE CHANGE)
###############################################################################
detect_pelt_1change <- function(x, penalty="MBIC"){
  # cpt.meanvar with PELT, typically 0..∞ CP, but for 1 boundary data
  cpt.meanvar(x, method="PELT", penalty=penalty)
}

detect_binseg_1change <- function(x, penalty="MBIC"){
  # cpt.meanvar with BinSeg, Q=1 => up to 1 CP
  cpt.meanvar(x, method="BinSeg", penalty=penalty, Q=1)
}

###############################################################################
# 3) REPEATED SIMULATION
###############################################################################
# We'll define repeat functions for PELT/BinSeg, specifying (mean1,mean2,sd1,sd2).

repeat_pelt_meanvar <- function(times=100, n=200,
                                mean1=0, mean2=5,
                                sd1=1, sd2=2,
                                penalty="MBIC")
{
  results <- integer(times)
  for(i in seq_len(times)){
    x <- simulate_single_meanvar(n, mean1, mean2, sd1, sd2)
    fit <- detect_pelt_1change(x, penalty)
    results[i] <- length(cpts(fit))
  }
  results
}

repeat_binseg_meanvar <- function(times=100, n=200,
                                  mean1=0, mean2=5,
                                  sd1=1, sd2=2,
                                  penalty="MBIC")
{
  results <- integer(times)
  for(i in seq_len(times)){
    x <- simulate_single_meanvar(n, mean1, mean2, sd1, sd2)
    fit <- detect_binseg_1change(x, penalty)
    results[i] <- length(cpts(fit))
  }
  results
}

###############################################################################
# 4) SENSITIVITY: VARY MEAN SHIFT (NO VAR SHIFT) FOR LOW vs. HIGH NOISE
###############################################################################
# We'll define functions that vary mean2 from 0..5 while mean1=0,
# but keep sd1=sd2 either =1 (low noise) or =2 (high noise).
# We'll do PELT or BinSeg by param 'method'.

sensitivity_mean_shift <- function(method=c("PELT","BinSeg"),
                                   n=200,
                                   mean_seq=seq(0,5,by=0.5),
                                   sd_val=1,   # 1 => low noise, 2 => high noise
                                   times=100,
                                   penalty="MBIC")
{
  method <- match.arg(method)
  prop_1cp <- numeric(length(mean_seq))
  
  for(k in seq_along(mean_seq)){
    if(method=="PELT"){
      res <- repeat_pelt_meanvar(times, n,
                                 mean1=0, mean2=mean_seq[k],
                                 sd1=sd_val, sd2=sd_val,
                                 penalty=penalty)
    } else {
      res <- repeat_binseg_meanvar(times, n,
                                   mean1=0, mean2=mean_seq[k],
                                   sd1=sd_val, sd2=sd_val,
                                   penalty=penalty)
    }
    prop_1cp[k] <- mean(res==1)
  }
  data.frame(mean2=mean_seq, prop_1cp=prop_1cp)
}

###############################################################################
# 5) SENSITIVITY: VARY VAR SHIFT (NO MEAN SHIFT) FOR LOW vs. HIGH NOISE
###############################################################################
# We'll define functions that vary sd2 from 1..3 while sd1=1 or 2,
# but keep mean1=mean2=0.

sensitivity_var_shift <- function(method=c("PELT","BinSeg"),
                                  n=200,
                                  sd_seq=seq(1,3,by=0.2),
                                  mean_val=0,   # no mean shift => mean1=mean2=0
                                  sd_base=1,    # 1 => low noise base, or 2 => high noise base
                                  times=100,
                                  penalty="MBIC")
{
  method <- match.arg(method)
  prop_1cp <- numeric(length(sd_seq))
  
  for(k in seq_along(sd_seq)){
    if(method=="PELT"){
      res <- repeat_pelt_meanvar(times, n,
                                 mean1=mean_val, mean2=mean_val,
                                 sd1=sd_base, sd2=sd_seq[k],
                                 penalty=penalty)
    } else {
      res <- repeat_binseg_meanvar(times, n,
                                   mean1=mean_val, mean2=mean_val,
                                   sd1=sd_base, sd2=sd_seq[k],
                                   penalty=penalty)
    }
    prop_1cp[k] <- mean(res==1)
  }
  data.frame(sd2=sd_seq, prop_1cp=prop_1cp)
}

###############################################################################
# 6) EXAMPLES: PLOT RESULTS
###############################################################################
# We'll produce 4 small plots:
#  A) Mean shift, low noise
#  B) Mean shift, high noise
#  C) Var shift, low noise
#  D) Var shift, high noise
# We'll do PELT vs BinSeg side-by-side for each scenario.

par(mfrow=c(2,2), mar=c(5,5,3,2))

### (A) Mean Shift, Low Noise
ms_low_pelt   <- sensitivity_mean_shift(method="PELT", mean_seq=seq(0,5,by=0.5), sd_val=1)
ms_low_binseg <- sensitivity_mean_shift(method="BinSeg", mean_seq=seq(0,5,by=0.5), sd_val=1)

plot(ms_low_pelt$mean2, ms_low_pelt$prop_1cp,
     type="b", col="blue",
     main="Mean Shift (Low Noise)\nPELT vs BinSeg",
     xlab="Mean", ylab="Proportion of detecting 1 CP", ylim=c(0,1))
lines(ms_low_binseg$mean2, ms_low_binseg$prop_1cp, type="b", col="red")
legend("bottomright", legend=c("PELT","BinSeg"), col=c("blue","red"), lty=1)

### (B) Mean Shift, High Noise
ms_high_pelt   <- sensitivity_mean_shift(method="PELT", mean_seq=seq(0,5,by=0.5), sd_val=2)
ms_high_binseg <- sensitivity_mean_shift(method="BinSeg", mean_seq=seq(0,5,by=0.5), sd_val=2)

plot(ms_high_pelt$mean2, ms_high_pelt$prop_1cp,
     type="b", col="blue",
     main="Mean Shift (High Noise)\nPELT vs BinSeg",
     xlab="Mean", ylab="Proportion of detecting 1 CP", ylim=c(0,1))
lines(ms_high_binseg$mean2, ms_high_binseg$prop_1cp, type="b", col="red")
legend("bottomright", legend=c("PELT","BinSeg"), col=c("blue","red"), lty=1)

### (C) Var Shift, Low Noise
vs_low_pelt   <- sensitivity_var_shift(method="PELT", sd_seq=seq(1,3,by=0.2), sd_base=1)
vs_low_binseg <- sensitivity_var_shift(method="BinSeg", sd_seq=seq(1,3,by=0.2), sd_base=1)

plot(vs_low_pelt$sd2, vs_low_pelt$prop_1cp,
     type="b", col="blue",
     main="Var Shift (Low Noise)\nPELT vs BinSeg",
     xlab="Std. Deviation", ylab="Proportion of detecting 1 CP", ylim=c(0,1))
lines(vs_low_binseg$sd2, vs_low_binseg$prop_1cp, type="b", col="red")
legend("bottomright", legend=c("PELT","BinSeg"), col=c("blue","red"), lty=1)

### (D) Var Shift, High Noise
# now base sd=2, so segment1 sd=2, segment2 in [2..4, etc.]
vs_high_pelt   <- sensitivity_var_shift(method="PELT", sd_seq=seq(2,4,by=0.2), sd_base=2)
vs_high_binseg <- sensitivity_var_shift(method="BinSeg", sd_seq=seq(2,4,by=0.2), sd_base=2)

plot(vs_high_pelt$sd2, vs_high_pelt$prop_1cp,
     type="b", col="blue",
     main="Var Shift (High Noise)\nPELT vs BinSeg",
     xlab="Std. Deviation", ylab="Proportion of detecting 1 CP", ylim=c(0,1))
lines(vs_high_binseg$sd2, vs_high_binseg$prop_1cp, type="b", col="red")
legend("topleft", legend=c("PELT","BinSeg"), col=c("blue","red"), lty=1)

###############################################################################
# DONE: Single code block for single-change in mean & variance,
# with both "low" (sd=1) and "high" (sd=2) scenarios for PELT and BinSeg.
###############################################################################
###############################################################################
# EXAMPLE: Overlaying plot(fit_binseg, ...) and plot(fit_pelt, add=TRUE)
###############################################################################
set.seed(123)
# Generate a two-segment time series (change at index 51)
x <- c(rnorm(50, 0, 1), rnorm(50, 5, 1))

library(changepoint)
# Fit using BinSeg & PELT
fit_binseg <- cpt.meanvar(x, method = "BinSeg", penalty = "MBIC", Q = 1)
fit_pelt   <- cpt.meanvar(x, method = "PELT",   penalty = "MBIC")

# Plot the time series
plot(x, type = "l", main = "Time Series with Change Points",
     xlab = "Time Index", ylab = "Value")

# Overlay the detected change points (first change point from each)
abline(v = cpts(fit_binseg)[1], col = "red", lwd = 2, lty = 2, xpd=FALSE)
abline(v = cpts(fit_pelt)[1],   col = "blue", lwd = 2, lty = 2, xpd=FALSE)

par(mfrow=c(1,1))


