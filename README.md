# Estimation-of-Change-Point-Detection-Algorithms

# Change Point Detection in Mean Using R

This repository contains a collection of R scripts that perform change point detection on simulated time series data. The primary focus is on detecting changes in the mean using the `cpt.mean` function from the [changepoint](https://cran.r-project.org/web/packages/changepoint/index.html) package. The scripts include examples for multiple change point (MCP) detection and single change point (SCP) detection using different detection methods and penalty criteria.

## Repository Structure

- **PBS-SCP-MEAN.R**  
  - **Purpose:**  
    Focuses on single change point (SCP) detection scenarios.  
  - **Highlights:**  
    - Simulates data with two segments (one change point).
    - Implements single change point detection functions using both BinSeg and PELT (with Q set to 1).
    - Provides repeated simulation functions and sensitivity analyses (with and without MAD normalization).
    - Generates sensitivity plots and visualizations for single change point detection under different noise conditions.
    <table>
  <tr>
    <td><img src="IMAGES/SCP-MEAN-CP.png" alt="Plot 1" width="400"/></td>
    <td><img src="IMAGES/PBS-SCP-MEAN.png" alt="Plot 2" width="400"/></td>
    <td><img src="IMAGES/PBS-SCP-MEAN-MAD.png" alt="Plot 2" width="400"/></td>
  </tr>
</table>


- **PBS-MCP-MEAN.R**  
  - **Purpose:**  
    Provides a more extensive simulation framework for multiple change point detection with sensitivity analysis.  
  - **Highlights:**  
    - Simulates data with four segments (multiple change points).
    - Contains functions for repeated simulation:
      - Both for unnormalized data and for data normalized using MAD normalization.
    - Implements sensitivity analysis by varying the magnitude of the mean shift.
    - Generates multiple 2×2 plots comparing the performance of penalty methods (AIC, BIC, MBIC) under different noise conditions (low vs. high noise).
    - Provides example plots of time series with overlaid change points for visual inspection.
     <table>
  <tr>
    <td><img src="IMAGES/MCP-MEAN-CP.png" alt="Plot 1" width="400"/></td>
    <td><img src="IMAGES/PBS-MCP-MEAN.png" alt="Plot 2" width="400"/></td>
    <td><img src="IMAGES/PBS-MCP-MAD.png" alt="Plot 2" width="400"/></td>
  </tr>
</table>


- **PBS-MCP2.R**  
  - **Purpose:**  
    Focuses on the detection of two closely spaced change points.  
  - **Highlights:**  
    - Simulates a series with two close mean shifts.
    - Uses repeated simulations to evaluate the performance of BinSeg and PELT methods.
    - Performs sensitivity analysis over a range of gap values between change points.
    - Plots:
      - The fraction of runs where both change points are detected.
      - The average number of detected change points versus the gap value.
    - Includes an example visualization of detected change points on a single simulated time series.
   <table>
  <tr>
    <td><img src="IMAGES/PBS-MCP2.png" alt="Plot 1" width="400"/></td>
    <td><img src="IMAGES/P-MCP2.png" alt="Plot 2" width="400"/></td>
    <td><img src="IMAGES/B-MCP2.png" alt="Plot 2" width="400"/></td>
  </tr>
</table>



## Prerequisites

Ensure that you have R (version 3.5 or later) installed along with the following package:

- **changepoint**  
  Install using:
  ```r
  install.packages("changepoint")
