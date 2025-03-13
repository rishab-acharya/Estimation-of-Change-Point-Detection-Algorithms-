# -------------------------------------------------------------
# Minimal example of reproducing a binary segmentation plot in R
# -------------------------------------------------------------

# 1. Install and load required package (uncomment if needed):
# install.packages("changepoint")

library(changepoint)

# 2. Generate synthetic data
set.seed(123)  # for reproducibility
# Create a signal with two true changes:
#  - First 50 points ~ N(0,1)
#  - Next 50 points ~ N(3,1)
#  - Last 50 points ~ N(-2,1)
x <- c(rnorm(50, mean = 0),
       rnorm(50, mean = 3),
       rnorm(50, mean = -2))
time <- seq_along(x)

# 3. Perform binary segmentation to find change points
cpt_model <- cpt.mean(x, method = "BinSeg", Q = 2)
final_breaks <- cpts(cpt_model)  # e.g. could be c(50, 100)
bp_step1 <- final_breaks[1]      # first breakpoint
bp_step2 <- final_breaks         # both breakpoints

# 4. Helper function to plot each segmentation step
plot_segmentation_step <- function(x, breakpoints, step_title) {
  bps <- sort(unique(breakpoints))
  plot(x, type = "l", xlab = "Time", ylab = "Amplitude",
       main = step_title, col = "gray50")
  start_idx <- 1
  for (bp in c(bps, length(x))) {
    seg_mean <- mean(x[start_idx:bp])
    segments(x0 = start_idx, x1 = bp, y0 = seg_mean, y1 = seg_mean,
             col = "red", lwd = 2)
    start_idx <- bp + 1
  }
  abline(v = bps, col = "blue", lty = 2)
}

# 5. Plot each step in a 3-row layout
par(mfrow = c(3,1), mar = c(3,4,3,2))

# Step 0: no breakpoints
plot_segmentation_step(x, breakpoints = integer(0),
                       step_title = "Step 0: No breakpoints")

# Step 1: first breakpoint
plot_segmentation_step(x, breakpoints = bp_step1,
                       step_title = "Step 1: First breakpoint")

# Step 2: both breakpoints
plot_segmentation_step(x, breakpoints = bp_step2,
                       step_title = "Step 2: Second breakpoint")
