# We'll pick, for instance, the first run that found exactly 3 CPs for PELT:
###############################################################################
# STEP 1) LOAD REQUIRED LIBRARY
###############################################################################
# We need the 'changepoint' package for cpt.meanvar(), cpts(), param.est(), etc.
library(changepoint)

###############################################################################
# STEP 2) SIMULATION PARAMETERS
###############################################################################
# We will run N=1000 simulations, each time generating a piecewise-stationary
# time series with 4 segments. The 3 true change-points are at indices 30, 60, 100.

N <- 1000

# Segment lengths
len1 <- 30
len2 <- 30
len3 <- 40
len4 <- 50

# True means and standard deviations in each segment
mean1 <- 0.0;  sd1 <- 1.0
mean2 <- 0.5;  sd2 <- 2.0
mean3 <- -1.0; sd3 <- 1.2
mean4 <- 1.0;  sd4 <- 2.5

# total_len = total data length = 30 + 30 + 40 + 50 = 150
total_len <- len1 + len2 + len3 + len4

###############################################################################
# STEP 3) CREATE STORAGE FOR PELT & BINSEG RESULTS
###############################################################################
# We'll store each simulation's results in lists. 
# For PELT:
cpts_ests_pelt       <- vector("list", N)  # store the detected change-point indices
param_ests_mean_pelt <- vector("list", N)  # store segment means
param_ests_var_pelt  <- vector("list", N)  # store segment variances

# For BinSeg:
cpts_ests_binseg       <- vector("list", N)
param_ests_mean_binseg <- vector("list", N)
param_ests_var_binseg  <- vector("list", N)

# We also store the raw data for each simulation in data_list (useful for plotting)
data_list <- vector("list", N)

###############################################################################
# STEP 4) MAIN SIMULATION LOOP
###############################################################################
# We set a seed for reproducibility, then run N times:
set.seed(123)

for(i in seq_len(N)) {
  
  # 4A) Generate the piecewise-normal data:
  seg1 <- rnorm(len1, mean=mean1, sd=sd1)
  seg2 <- rnorm(len2, mean=mean2, sd=sd2)
  seg3 <- rnorm(len3, mean=mean3, sd=sd3)
  seg4 <- rnorm(len4, mean=mean4, sd=sd4)
  
  x <- c(seg1, seg2, seg3, seg4)  # combine them into a single series
  data_list[[i]] <- x            # store for later reference
  
  # 4B) Detect changes using PELT (allowing mean + variance changes)
  fit_pelt <- cpt.meanvar(x, method="PELT")
  
  # Extract results for PELT:
  cpts_ests_pelt[[i]]       <- cpts(fit_pelt)              # indices of detected CPs
  param_ests_mean_pelt[[i]] <- param.est(fit_pelt)$mean    # estimated means
  param_ests_var_pelt[[i]]  <- param.est(fit_pelt)$variance# estimated variances
  
  # 4C) Detect changes using BinSeg (mean + variance), up to 3 CPs
  fit_binseg <- cpt.meanvar(x, method="BinSeg", Q=3)
  
  # Extract results for BinSeg:
  cpts_ests_binseg[[i]]       <- cpts(fit_binseg)
  param_ests_mean_binseg[[i]] <- param.est(fit_binseg)$mean
  param_ests_var_binseg[[i]]  <- param.est(fit_binseg)$variance
}

###############################################################################
# STEP 5) SUMMARIZE: NUMBER OF DETECTED CPs FOR EACH METHOD
###############################################################################
# Count how many CPs each method found in each simulation:
NUM_CPTS_pelt   <- sapply(cpts_ests_pelt,   length)
NUM_CPTS_binseg <- sapply(cpts_ests_binseg, length)

cat("\n-- PELT: counts of detected CPs --\n")
print(table(NUM_CPTS_pelt))
cat("\nProportions:\n")
print(table(NUM_CPTS_pelt)/N)

cat("\n-- BinSeg: counts of detected CPs --\n")
print(table(NUM_CPTS_binseg))
cat("\nProportions:\n")
print(table(NUM_CPTS_binseg)/N)

###############################################################################
# STEP 6) FOCUS ON SIMULATIONS WITH EXACTLY 3 CPs
###############################################################################
# We'll gather only those runs that found 3 changes, i.e. 4 segments:
idx_3_pelt   <- which(NUM_CPTS_pelt   == 3)
idx_3_binseg <- which(NUM_CPTS_binseg == 3)

cat("\nNumber of simulations with exactly 3 CPs (PELT):",   length(idx_3_pelt))
cat("\nNumber of simulations with exactly 3 CPs (BinSeg):", length(idx_3_binseg), "\n")

# Then we can extract their parameter estimates:
mean_list_3_pelt <- param_ests_mean_pelt[idx_3_pelt]
var_list_3_pelt  <- param_ests_var_pelt[idx_3_pelt]

mean_list_3_binseg <- param_ests_mean_binseg[idx_3_binseg]
var_list_3_binseg  <- param_ests_var_binseg[idx_3_binseg]

###############################################################################
# STEP 7) EXTRACT SEGMENT-BY-SEGMENT ESTIMATES (PELT vs BINSEG)
###############################################################################
# For each method, we want the estimated mean/variance in segments 1..4
# specifically in the runs that found exactly 3 CPs.

# -- PELT means --
mean1_pelt <- sapply(mean_list_3_pelt, function(a) a[1])
mean2_pelt <- sapply(mean_list_3_pelt, function(a) a[2])
mean3_pelt <- sapply(mean_list_3_pelt, function(a) a[3])
mean4_pelt <- sapply(mean_list_3_pelt, function(a) a[4])

# -- PELT variances --
var1_pelt <- sapply(var_list_3_pelt, function(a) a[1])
var2_pelt <- sapply(var_list_3_pelt, function(a) a[2])
var3_pelt <- sapply(var_list_3_pelt, function(a) a[3])
var4_pelt <- sapply(var_list_3_pelt, function(a) a[4])

# -- BinSeg means --
mean1_binseg <- sapply(mean_list_3_binseg, function(a) a[1])
mean2_binseg <- sapply(mean_list_3_binseg, function(a) a[2])
mean3_binseg <- sapply(mean_list_3_binseg, function(a) a[3])
mean4_binseg <- sapply(mean_list_3_binseg, function(a) a[4])

# -- BinSeg variances --
var1_binseg <- sapply(var_list_3_binseg, function(a) a[1])
var2_binseg <- sapply(var_list_3_binseg, function(a) a[2])
var3_binseg <- sapply(var_list_3_binseg, function(a) a[3])
var4_binseg <- sapply(var_list_3_binseg, function(a) a[4])

###############################################################################
# STEP 8) PLOT DISTRIBUTIONS: PELT MEANS (Segments 1..4)
###############################################################################
par(mfrow=c(2,2))

# S1
plot(density(mean1_pelt), main="PELT: Mean S1", col="blue", xlab="Value", ylab="Density")
hist(mean1_pelt, main="PELT: Mean S1", col="lightblue", xlab="Value", ylab="Frequency")

# S2
plot(density(mean2_pelt), main="PELT: Mean S2", col="red", xlab="Value", ylab="Density")
hist(mean2_pelt, main="PELT: Mean S2", col="pink", xlab="Value", ylab="Frequency")

par(mfrow=c(2,2))

# S3
plot(density(mean3_pelt), main="PELT: Mean S3", col="darkgreen", xlab="Value", ylab="Density")
hist(mean3_pelt, main="PELT: Mean S3", col="lightgreen", xlab="Value", ylab="Frequency")

# S4
plot(density(mean4_pelt), main="PELT: Mean S4", col="purple", xlab="Value", ylab="Density")
hist(mean4_pelt, main="PELT: Mean S4", col="violet", xlab="Value", ylab="Frequency")

###############################################################################
# STEP 9) PLOT DISTRIBUTIONS: PELT VARIANCES (Segments 1..4)
###############################################################################
par(mfrow=c(2,2))

plot(density(var1_pelt), main="PELT: Var S1", col="blue", xlab="Value", ylab="Density")
hist(var1_pelt, main="PELT: Var S1", col="lightblue", xlab="Value", ylab="Frequency")

plot(density(var2_pelt), main="PELT: Var S2", col="red", xlab="Value", ylab="Density")
hist(var2_pelt, main="PELT: Var S2", col="pink", xlab="Value", ylab="Frequency")

par(mfrow=c(2,2))

plot(density(var3_pelt), main="PELT: Var S3", col="darkgreen", xlab="Value", ylab="Density")
hist(var3_pelt, main="PELT: Var S3", col="lightgreen", xlab="Value", ylab="Frequency")

plot(density(var4_pelt), main="PELT: Var S4", col="purple", xlab="Value", ylab="Density")
hist(var4_pelt, main="PELT: Var S4", col="violet", xlab="Value", ylab="Frequency")

###############################################################################
# STEP 10) PLOT DISTRIBUTIONS: BINSEG MEANS (Segments 1..4)
###############################################################################
par(mfrow=c(2,2))

plot(density(mean1_binseg), main="BinSeg: Mean S1", col="blue", xlab="Value", ylab="Density")
hist(mean1_binseg, main="BinSeg: Mean S1", col="lightblue", xlab="Value", ylab="Frequency")

plot(density(mean2_binseg), main="BinSeg: Mean S2", col="red", xlab="Value", ylab="Density")
hist(mean2_binseg, main="BinSeg: Mean S2", col="pink", xlab="Value", ylab="Frequency")

par(mfrow=c(2,2))

plot(density(mean3_binseg), main="BinSeg: Mean S3", col="darkgreen", xlab="Value", ylab="Density")
hist(mean3_binseg, main="BinSeg: Mean S3", col="lightgreen", xlab="Value", ylab="Frequency")

plot(density(mean4_binseg), main="BinSeg: Mean S4", col="purple", xlab="Value", ylab="Density")
hist(mean4_binseg, main="BinSeg: Mean S4", col="violet", xlab="Value", ylab="Frequency")

###############################################################################
# STEP 11) PLOT DISTRIBUTIONS: BINSEG VARIANCES (Segments 1..4)
###############################################################################
par(mfrow=c(2,2))

plot(density(var1_binseg), main="BinSeg: Var S1", col="blue", xlab="Value", ylab="Density")
hist(var1_binseg, main="BinSeg: Var S1", col="lightblue", xlab="Value", ylab="Frequency")

plot(density(var2_binseg), main="BinSeg: Var S2", col="red", xlab="Value", ylab="Density")
hist(var2_binseg, main="BinSeg: Var S2", col="pink", xlab="Value", ylab="Frequency")

par(mfrow=c(2,2))

plot(density(var3_binseg), main="BinSeg: Var S3", col="darkgreen", xlab="Value", ylab="Density")
hist(var3_binseg, main="BinSeg: Var S3", col="lightgreen", xlab="Value", ylab="Frequency")

plot(density(var4_binseg), main="BinSeg: Var S4", col="purple", xlab="Value", ylab="Density")
hist(var4_binseg, main="BinSeg: Var S4", col="violet", xlab="Value", ylab="Frequency")

###############################################################################
# STEP 12) HELPERS FOR COMPARING THE FIRST CP DISTRIBUTION
###############################################################################
# Here we define a small function to compute how frequently a certain "CP number"
# is placed at each possible index, among a list of CP vectors.

get_cp_distribution <- function(cpts_list, cp_num, total_len){
  # cpts_list: a list of numeric vectors, each containing the CP indices
  # cp_num:    which CP are we focusing on? (1, 2, 3, etc.)
  # total_len: time-series length, used to ensure we create freq bins for 1..total_len
  
  cp_vals <- unlist(lapply(cpts_list, function(v){
    if(length(v) >= cp_num) v[cp_num] else NA
  }))
  cp_vals <- cp_vals[!is.na(cp_vals)]  # ignore runs that don't have that many CPs
  
  freq_vec <- table(c(cp_vals, 1:total_len)) - 1  # ensure 1..total_len are all in table
  freq_prop <- freq_vec / length(cp_vals)        # proportion in each bin
  
  return(freq_prop)
}

###############################################################################
# STEP 13) EXAMPLE: COMPARE FIRST CP DISTRIBUTION (PELT vs BINSEG)
###############################################################################
# We only do this for runs that have exactly 3 CPs in each method. 
# Note: these sets of runs might differ, so it's not the same group of data 
# (unless you specifically restrict to runs that had 3 CPs under BOTH methods).

dist_cp1_pelt   <- get_cp_distribution(cpts_ests_pelt[idx_3_pelt],         1, total_len)
dist_cp1_binseg <- get_cp_distribution(cpts_ests_binseg[idx_3_binseg],     1, total_len)

# Combine into a data frame for easy plotting
df_compare_cp1 <- data.frame(
  Index  = as.integer(names(dist_cp1_pelt)),
  PELT   = as.numeric(dist_cp1_pelt),
  BinSeg = as.numeric(dist_cp1_binseg)
)

# Overlaid plot:
par(mfrow=c(1,1))
plot(df_compare_cp1$Index, df_compare_cp1$PELT,
     type="h", col="blue", lwd=2, 
     xlab="Index", ylab="Proportion", 
     main="First CP Distribution:PELT vs. BinSeg (Runs with Exactly 3 ChangePoints)")
lines(df_compare_cp1$Index, df_compare_cp1$BinSeg,
      type="h", col="red", lwd=2)
legend("topright", legend=c("PELT","BinSeg"), 
       col=c("blue","red"), lty=1, lwd=2, xpd=TRUE, inset=c(0.1, 0))



if(length(idx_3_pelt) > 0){
  
  i_ex_pelt <- idx_3_pelt[1]
  x_ex <- data_list[[i_ex_pelt]]
  cpts_ex <- cpts_ests_pelt[[i_ex_pelt]]
  
  plot(x_ex, type="b", main=paste("Run", i_ex_pelt, "- PELT: ChangePoints"),
       xlab="Index", ylab="Value")
  # Add the true CPs (vertical lines in blue dashed)
  abline(v = c(len1, len1+len2, len1+len2+len3), col="blue", lty=2, lwd=2)
  # Add the estimated CPs in red dotted
  abline(v = cpts_ex, col="red", lty=3, lwd=2)
  # Add legend for PELT plot outside the plot area
  legend(x=115, y=9, legend=c("True CPs","Estimated CPs"),
         col=c("blue","red"), lty=c(2,3), lwd=2, xpd=TRUE, inset=c(0.1, 0))
}

# Similarly, the first run that found exactly 3 CPs for BinSeg:
if(length(idx_3_binseg) > 0){
  
  i_ex_binseg <- idx_3_binseg[1]
  x_ex <- data_list[[i_ex_binseg]]
  cpts_ex <- cpts_ests_binseg[[i_ex_binseg]]
  
  plot(x_ex, type="b", main=paste("Run", i_ex_binseg, "- BinSeg: ChangePoints"),
       xlab="Index", ylab="Value")
  abline(v = c(len1, len1+len2, len1+len2+len3), col="blue", lty=2, lwd=2)
  abline(v = cpts_ex, col="red", lty=3, lwd=2)
  # Add legend for PELT plot outside the plot area
  legend(x=115, y=12, legend=c("True CPs","Estimated CPs"),
         col=c("blue","red"), lty=c(2,3), lwd=2, xpd=TRUE, inset=c(0.1, 0))
}




