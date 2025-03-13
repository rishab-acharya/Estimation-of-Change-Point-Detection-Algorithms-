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

## Change in Variance Analysis using `cpt.var`

This repository now includes scripts to test change in variance using the `cpt.var` function from the [changepoint](https://cran.r-project.org/web/packages/changepoint/index.html) package. In these scripts, synthetic time series data is generated with constant mean but varying variance. The variance shift is then detected using both the PELT and BinSeg methods.

### Code Overview

1. **Data Generation:**  
   The scripts generate data with specified segment lengths, constant means, and differing standard deviations. In the variance analysis, the means are kept constant while the standard deviation changes to simulate a variance shift.

2. **Detection Functions:**  
   - **PELT Detection:**  
     The function `detect_pelt` (or `detect_pelt_crops` in PBS-SCP-VAR) applies the `cpt.var` function with the PELT method using a specified penalty (e.g., AIC, BIC, or MBIC).  
     ```r
     fit <- cpt.var(data, method = "PELT", penalty = "BIC")
     cpts(fit)  # Extracts the change point indices
     ```
   - **BinSeg Detection:**  
     Similarly, `detect_binseg` (or `detect_binseg_crops` in PBS-SCP-VAR) applies the `cpt.var` function with the BinSeg method.  
     ```r
     fit <- cpt.var(data, method = "BinSeg", penalty = "BIC")
     cpts(fit)
     ```

3. **Simulation and Sensitivity Analysis:**  
   The scripts include repeated simulations to evaluate the average number of detected change points as the standard deviation in one segment is varied. This sensitivity analysis helps compare the performance of different penalty methods (AIC, BIC, MBIC) under various noise conditions.

4. **Plotting:**  
   The scripts generate plots that:
   - Show the detected change points (CP) overlaid on the time series.
   - Illustrate the sensitivity of the methods to changes in variance.
   These plots are automatically saved as PNG images.

### Automatically Embedding Generated Plots

The images generated from the variance analyses are saved in the `IMAGES` folder. Below are HTML tables that embed the plots in a side-by-side layout:

#### PBS-SCP-VAR (Single Change Point Variance)
<table>
  <tr>
    <td align="center"><img src="IMAGES/PBS-SCP-CP.png" alt="PBS-SCP-CP" width="400"/></td>
    <td align="center"><img src="IMAGES/PBS-SCP-VAR.png" alt="PBS-SCP-VAR" width="400"/></td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>PBS-SCP-VAR Results</strong></td>
  </tr>
</table>

#### PBS-MCP-VAR (Multiple Change Point Variance)
<table>
  <tr>
    <td align="center"><img src="IMAGES/PBS-MCP-CP.png" alt="PBS-MCP-CP" width="300"/></td>
    <td align="center"><img src="IMAGES/PELT-MCP-VAR.png" alt="PELT-MCP-VAR" width="300"/></td>
    <td align="center"><img src="IMAGES/BINSEG-MCP-VAR.png" alt="BINSEG-MCP-VAR" width="300"/></td>
  </tr>
  <tr>
    <td align="center" colspan="3"><strong>PBS-MCP-VAR Results</strong></td>
  </tr>
</table>

source("PBS-SCP-VAR.R")

# Change Point Detection in Mean and Variance

This repository extends the analysis to detect **change points** in both **mean** and **variance** of a time series. Two main scripts demonstrate this:

1. **PBS-SCP-MEANVAR.R**  
   - **Purpose:** Analyzes scenarios where there is **one** change point (single boundary) in both the mean and variance.  
   - **Key Functions:**  
     - `simulate_single_meanvar()`: Generates data with a single mean/variance shift.  
     - `detect_pelt_1change()` / `detect_binseg_1change()`: Use the `cpt.meanvar` function (from the [changepoint](https://cran.r-project.org/web/packages/changepoint/index.html) package) with **PELT** or **BinSeg** methods, allowing for a single CP (Q=1).  
   - **Sensitivity Analyses:**  
     - Varies the **mean** shift (while keeping variance fixed) to see how frequently each method detects exactly one change point.  
     - Varies the **variance** shift (while keeping the mean fixed) to see detection performance under different noise conditions.

2. **PBS-MCP-MEANVAR-EST.R**  
   - **Purpose:** Analyzes **multiple** change points (MCP) in both mean and variance.  
   - **Key Functions:**  
     - `cpt.meanvar(x, method="PELT" | "BinSeg")`: Detects an unknown number of changes (or up to a specified `Q`) in a simulated multi-segment series.  
     - Summaries of how often each method finds the correct number of change points, distribution of estimated CP locations, and distribution of estimated segment means/variances.

---

## Plots and Figures

Below are the generated plots for both **single** and **multiple** change-point analyses in mean and variance. The images are sorted according to the scripts and scenarios they belong to. All images are stored in (or referenced from) the `IMAGES/` folder (adjust the path as needed).

### A) Single Change Point (PBS-SCP-MEANVAR.R)

<table>
  <!-- Row 1: Overall Single CP in Mean+Variance -->
  <tr>
    <td align="center">
      <img src="IMAGES/PBS-SCP-MEANVAR.png" alt="PBS-SCP-MEANVAR" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/SCP-MEANVAR.png" alt="SCP-MEANVAR" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Overall Single-Change Analysis</strong></td>
  </tr>

  <!-- Row 2: Mean Shift Scenarios S1,S2 or S12 -->
  <tr>
    <td align="center">
      <img src="IMAGES/BINSEG-MEAN-S12.png" alt="BINSEG-MEAN-S12" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/PELT-MEAN-S12.png" alt="PELT-MEAN-S12" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Mean Shift, Scenarios 1 &amp; 2</strong></td>
  </tr>

  <!-- Row 3: Mean Shift Scenarios S3,S4 or S34 -->
  <tr>
    <td align="center">
      <img src="IMAGES/BINSEG-MEAN-S34.png" alt="BINSEG-MEAN-S34" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/PELT-MEAN-S34.png" alt="PELT-MEAN-S34" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Mean Shift, Scenarios 3 &amp; 4</strong></td>
  </tr>

  <!-- Row 4: Variance Shift Scenarios S1,S2 or S12 -->
  <tr>
    <td align="center">
      <img src="IMAGES/BINSEG-VAR-S12.png" alt="BINSEG-VAR-S12" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/PELT-VAR-S12.png" alt="PELT-VAR-S12" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Variance Shift, Scenarios 1 &amp; 2</strong></td>
  </tr>

  <!-- Row 5: Variance Shift Scenarios S3,S4 or S34 -->
  <tr>
    <td align="center">
      <img src="IMAGES/BINSEG-VAR-S34.png" alt="BINSEG-VAR-S34" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/PELT-VAR-S34.png" alt="PELT-VAR-S34" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Variance Shift, Scenarios 3 &amp; 4</strong></td>
  </tr>
</table>

---

### B) Multiple Change Points (PBS-MCP-MEANVAR-EST.R)

<table>
  <!-- Row 1: Overall Multiple CP in Mean+Variance -->
  <tr>
    <td align="center">
      <img src="IMAGES/BINSEG-MCP-MEANVAR.png" alt="BINSEG-MCP-MEANVAR" width="400"/>
    </td>
    <td align="center">
      <img src="IMAGES/PELT-MCP-MEANVAR.png" alt="PELT-MCP-MEANVAR" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Multiple-Change Analysis: BinSeg vs. PELT</strong></td>
  </tr>

  <!-- Row 2: Distribution of CPs -->
  <tr>
    <td align="center" colspan="2">
      <img src="IMAGES/PBS-MCP-3CPDIST.png" alt="PBS-MCP-3CPDIST" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Distribution of 3 CPs in Multiple-Change Analysis</strong></td>
  </tr>
</table>



## Prerequisites

Ensure that you have R (version 3.5 or later) installed along with the following package:

- **changepoint**  
  Install using:
  ```r
  install.packages("changepoint")
