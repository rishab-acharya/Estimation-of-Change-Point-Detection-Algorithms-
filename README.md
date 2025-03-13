# Estimation-of-Change-Point-Detection-Algorithms

## Simulation Study for Change Point Detection in Time Series

This repository contains a collection of R scripts developed as part of my dissertation. The simulation study focuses on evaluating change point detection methods for time series data. Three families of methods are considered:

1. **Change in Mean Detection** using `cpt.mean`
2. **Change in Variance Detection** using `cpt.var`
3. **Change in Mean and Variance Detection** using `cpt.meanvar`

Different detection methods (PELT and BinSeg) and various penalty criteria (AIC, BIC, MBIC) are applied. The study involves simulating piecewise-stationary data with known change points and evaluating the performance of each method.

---

## Repository Structure

- **PBS-SCP-MEAN.R**  
  - **Purpose:** Single change point (SCP) detection in mean.  
  - **Highlights:**  
    - Simulates data with two segments (one mean shift).
    - Implements single change point detection using `cpt.mean` with both PELT and BinSeg (with Q set to 1).
    - Includes repeated simulation functions and sensitivity analyses (with and without MAD normalization).
  - **Example Code:**  
    ```r
    fit <- cpt.mean(data_vector, method = "PELT", penalty = "BIC")
    cpts(fit)  # Extracts the change point index
    ```
  - **Plots:**  
    <table>
      <tr>
        <td><img src="IMAGES/SCP-MEAN- CP.png" alt="SCP Mean CP Overlay" width="400"/></td>
        <td><img src="IMAGES/PBS-SCP-MEAN.png" alt="SCP Mean" width="400"/></td>
        <td><img src="IMAGES/PBS-SCP-MEAN-MAD.png" alt="SCP Mean with MAD Normalization" width="400"/></td>
      </tr>
    </table>
    *Figure: Single change point detection in mean using both standard and MAD normalized data.*

- **PBS-MCP-MEAN.R**  
  - **Purpose:** Multiple change point (MCP) detection in mean.  
  - **Highlights:**  
    - Simulates data with four segments (multiple mean shifts).
    - Contains functions for repeated simulations and sensitivity analysis (varying the magnitude of the mean shift under different noise conditions).
    - Generates comparative 2×2 plots for penalty methods (AIC, BIC, MBIC).
  - **Example Code:**  
    ```r
    fit <- cpt.mean(data_vector, method = "BinSeg", penalty = "MBIC", Q = 15)
    cpts(fit)
    ```
  - **Plots:**  
    <table>
      <tr>
        <td><img src="IMAGES/MCP-MEAN-CP.png" alt="MCP Mean CP Overlay" width="400"/></td>
        <td><img src="IMAGES/PBS-MCP-MEAN.png" alt="MCP Mean" width="400"/></td>
        <td><img src="IMAGES/PBS-MCP-MAD.png" alt="MCP Mean with MAD Normalization" width="400"/></td>
      </tr>
    </table>
    *Figure: Multiple change point detection in mean with sensitivity analysis.*

- **PBS-MCP2.R**  
  - **Purpose:** Detection of two closely spaced change points in mean.  
  - **Highlights:**  
    - Simulates data with two closely spaced mean shifts.
    - Uses repeated simulations to evaluate how often both change points are detected and plots the average number of detected CPs against the gap value.
  - **Example Code:**  
    ```r
    sim_res <- simulate_two_close_cps_pelt(times = 100, n = 200, first_cp = 100, gap = 5, penalty = "MBIC")
    mean(sim_res$separated_2cps)
    ```
  - **Plots:**  
    <table>
      <tr>
        <td><img src="IMAGES/PBS-MCP2.png" alt="MCP2 - Close CP Detection" width="400"/></td>
        <td><img src="IMAGES/P-MCP2.png" alt="PELT MCP2" width="400"/></td>
        <td><img src="IMAGES/B-MCP2.png" alt="BinSeg MCP2" width="400"/></td>
      </tr>
    </table>
    *Figure: Detection of two closely spaced change points in mean.*

- **PBS-SCP-VAR.R**  
  - **Purpose:** Single change point detection in variance.  
  - **Highlights:**  
    - Simulates data with two segments having a variance shift (constant mean).
    - Applies `cpt.var` with both PELT and BinSeg to detect the variance change.
  - **Example Code:**  
    ```r
    fit <- cpt.var(data_vector, method = "PELT", penalty = "BIC")
    cpts(fit)
    ```
  - **Plots:**  
    <table>
      <tr>
        <td align="center"><img src="IMAGES/PBS-SCP-CP.png" alt="SCP Variance CP Overlay" width="400"/></td>
        <td align="center"><img src="IMAGES/PBS-SCP-VAR.png" alt="SCP Variance" width="400"/></td>
      </tr>
      <tr>
        <td align="center" colspan="2"><strong>PBS-SCP-VAR Results</strong></td>
      </tr>
    </table>

- **PBS-MCP-VAR.R**  
  - **Purpose:** Multiple change point detection in variance.  
  - **Highlights:**  
    - Simulates a time series with four segments having different variances.
    - Conducts repeated simulations and sensitivity analysis on variance shifts.
  - **Example Code:**  
    ```r
    fit <- cpt.var(data_vector, method = "BinSeg", penalty = "BIC", Q = 5)
    cpts(fit)
    ```
  - **Plots:**  
    <table>
      <tr>
        <td align="center"><img src="IMAGES/PBS-MCP-CP.png" alt="MCP Variance CP Overlay" width="300"/></td>
        <td align="center"><img src="IMAGES/PELT-MCP-VAR.png" alt="PELT MCP Variance" width="300"/></td>
        <td align="center"><img src="IMAGES/BINSEG-MCP-VAR.png" alt="BinSeg MCP Variance" width="300"/></td>
      </tr>
      <tr>
        <td align="center" colspan="3"><strong>PBS-MCP-VAR Results</strong></td>
      </tr>
    </table>

- **PBS-SCP-MEANVAR.R**  
  - **Purpose:** Single change point detection in both mean and variance.  
  - **Highlights:**  
    - Simulates data with two segments where both the mean and variance change.
    - Uses `cpt.meanvar` with both PELT and BinSeg to detect the boundary.
    - Sensitivity analyses are performed by varying the magnitude of the mean or variance shift.
  - **Example Code:**  
    ```r
    fit <- cpt.meanvar(data_vector, method = "PELT", penalty = "MBIC")
    cpts(fit)
    param.est(fit)$mean      # Estimated means
    param.est(fit)$variance  # Estimated variances
    ```
  - **Plots:**  
    <table>
      <tr>
        <td align="center">
          <img src="IMAGES/PBS-SCP-MEANVAR.png" alt="SCP Mean and Variance" width="400"/>
        </td>
      </tr>
      <tr>
        <td align="center"><strong>PBS-SCP-MEANVAR Results</strong></td>
      </tr>
    </table>

- **PBS-MCP-MEANVAR-EST.R**  
  - **Purpose:** Multiple change point detection in both mean and variance.  
  - **Highlights:**  
    - Simulates a time series with four segments (three change points) where both the mean and variance differ.
    - Runs a simulation study (e.g., N = 1000) to assess the frequency of correctly detected CPs.
    - Summarizes the distributions of estimated segment means, variances, and CP locations.
  - **Example Code:**  
    ```r
    fit_pelt <- cpt.meanvar(x, method = "PELT")
    cpts(fit_pelt)
    param.est(fit_pelt)$mean
    param.est(fit_pelt)$variance
    ```
  - **Plots:**  
    <table>
      <tr>
        <td align="center">
          <img src="IMAGES/BINSEG-MCP-MEANVAR.png" alt="BinSeg MCP MeanVar" width="400"/>
        </td>
        <td align="center">
          <img src="IMAGES/PELT-MCP-MEANVAR.png" alt="PELT MCP MeanVar" width="400"/>
        </td>
      </tr>
      <tr>
        <td align="center" colspan="2"><strong>Multiple Change Points in Mean and Variance: BinSeg vs. PELT</strong></td>
      </tr>
      <tr>
        <td align="center" colspan="2">
          <img src="IMAGES/PBS-MCP-3CPDIST..png" alt="Distribution of CP Locations" width="400"/>
        </td>
      </tr>
      <tr>
        <td align="center" colspan="2"><strong>Distribution of Estimated CP Locations</strong></td>
      </tr>
    </table>

---

## How to Run the Simulation Study

These R scripts were designed and executed as part of the simulation study conducted for my dissertation. They simulate piecewise-stationary time series data with known change points and apply different change point detection methods to estimate the locations and parameters of the changes.

---

### Change Point Detection within Bitcoin Prices

This section of the repository applies change point detection techniques to real-world Bitcoin price data. The analysis investigates changes in the behavior of Bitcoin prices over the period 2014–2021 using multiple approaches. In particular, the study examines:
  
- **Raw Log Returns Analysis:** Direct change point detection on weekly or monthly log returns.
- **EGARCH Modeling:** Fitting an EGARCH(1,1) model to account for volatility clustering and then applying CPD on standardized residuals.
- **Frequency-Based Analysis:** Conducting separate analyses on weekly and monthly data.
- **Exploratory Analysis:** Assessing descriptive statistics, rolling metrics, and autocorrelation properties.

### Overview of the Analysis

1. **Data Preparation:**  
   Bitcoin closing prices are imported from a CSV file, converted to a time series (using `xts`), and subset to cover January 1, 2014–December 31, 2021. Log returns are then computed at various frequencies (daily, weekly, and monthly).

2. **Raw Model CPD and Diagnostics (BS-BTC-EGARCH.R):**  
   - **Raw Log Returns:** Weekly log returns are calculated from the closing prices.
   - **Change Point Detection:**  
     Change points in the raw log returns are detected using the `cpt.meanvar` function (with the BinSeg method, AIC penalty, and Q = 5).
   - **Diagnostics:**  
     A series of tests (ADF, KPSS, Ljung-Box, ARCH, and Jarque-Bera) are applied to assess stationarity, autocorrelation, and heteroskedasticity.
   - **EGARCH Modeling:**  
     An EGARCH(1,1) model is fitted (using the `rugarch` package) to capture volatility effects. Standardized residuals are extracted and then analyzed with CPD to detect structural changes not explained by the volatility model.
     
   **Resulting Plots:**
   <table>
     <tr>
       <td align="center">
         <img src="BTC_IMAGES/RAW-EGARCH-BTC.png" alt="Raw Log Returns CPD" width="400"/>
       </td>
     </tr>
     <tr>
       <td align="center" colspan="2"><strong>EGARCH Analysis: Change Point Detection on Raw Log Returns and on EGARCH Standardized Residuals</strong></td>
     </tr>
   </table>

3. **Weekly Analysis (BS-BTC-WEEKLY.R):**  
   - **Weekly Series Construction:**  
     The daily closing prices are aggregated into a weekly series (using the first trading day of each week), and weekly log returns are computed.
   - **Change Point Detection:**  
     The `cpt.meanvar` function (using BinSeg with AIC penalty and a specified number of change points) is applied on the weekly returns.
   - **Custom Timeline Plot:**  
     A custom x-axis (showing years from 2014 to 2021) is built for clear visualization.
     
   **Resulting Plot:**
   <table>
     <tr>
       <td align="center">
         <img src="BTC_IMAGES/BS-BTC-WEEKLY.png" alt="Weekly Log Returns CPD" width="400"/>
       </td>
     </tr>
     <tr>
       <td align="center"><strong>Weekly Analysis: Change Point Detection on Bitcoin Weekly Log Returns</strong></td>
     </tr>
   </table>

4. **Exploratory Analysis (BTC-EXPLORATORY.R):**  
   - **Descriptive Statistics:**  
     The script computes key statistics (mean, variance, skewness, kurtosis) for daily, weekly, and monthly returns.
   - **Rolling Metrics:**  
     It calculates a 30-day rolling average and standard deviation to illustrate price trends and volatility.
   - **Distribution and ACF Plots:**  
     Histograms, QQ plots, and autocorrelation plots are generated to explore the distribution and dependency structure of the returns.
   - **Stationarity Testing:**  
     An Augmented Dickey-Fuller (ADF) test is performed to check for stationarity.
     
   *Note:* This script provides important background information on Bitcoin's statistical properties.

    **Resulting Plots:**
   <table>
  <tr>
    <td align="center">
      <img src="BTC_IMAGES/BTC-ROLLING AVG.png" alt="Raw Log Returns CPD" width="400"/>
    </td>
    <td align="center">
      <img src="BTC_IMAGES/BTC-ROLLING SD.png" alt="EGARCH Residuals CPD" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="BTC_IMAGES/BTC-ACF.png" alt="EGARCH Residual ACF" width="400"/>
    </td>
    <td align="center">
      <img src="BTC_IMAGES/BTC-HIST-QQ.png" alt="EGARCH Diagnostics" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <strong>EGARCH Analysis: Change Point Detection on Raw Log Returns, EGARCH Standardized Residuals, and Diagnostic Plots</strong>
    </td>
  </tr>
</table>


5. **Monthly Analysis (PBS-BTC-monthly.R) & Weekly Analysis (PBS-BTC-weekly.R):**  
   - **Frequency-Based CPD:**  
     These scripts create monthly and weekly time series, compute log returns, and apply two CPD methods:
       - **Method A (BinSeg):** Using a Manual penalty with a predefined number of change points.
       - **Method B (PELT):** Using the CROPS penalty to allow adaptive detection.
   - **Plotting with Custom Labels:**  
     Both scripts generate plots that overlay the detected change points on the log returns with date-labeled x-axes.
   - **Output:**  
     The change point dates (formatted as Month-Year) are printed to the console.



**Resulting PELT Diagnostic (Elbow) Plot:**
<table>
  <tr>
    <td align="center">
      <img src="BTC_IMAGES/BTC-WEEKLY-ELBOW.png" alt="PELT Elbow Plot" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Diagnostic Elbow Plot for PELT Change Point Detection</strong>
    </td>
  </tr>
</table>

     
   **Resulting Monthly Plot:**
   <table>
     <tr>
       <td align="center">
         <img src="BTC_IMAGES/PBS-BTC-MONTHLY.png" alt="Monthly Log Returns CPD" width="400"/>
       </td>
       <td align="center">
         <img src="BTC_IMAGES/BTC-MONTHLY-LOG.png" alt="Monthly Log Returns Diagnostics" width="400"/>
       </td>
     </tr>
     <tr>
       <td align="center" colspan="2"><strong>Monthly Analysis: Change Point Detection and Diagnostics on Bitcoin Log Returns</strong></td>
     </tr>
   </table>

   **Resulting Weekly Plot:**
<table>
  <tr>
    <td align="center">
      <img src="BTC_IMAGES/PBS-BTC-WEEKLY.png" alt="Weekly Log Returns CPD" width="400"/>
    </td>
    <td align="center">
      <img src="BTC_IMAGES/BTC-WEEKLY-RETURNS.png" alt="Weekly Log Returns Diagnostics" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <strong>Weekly Analysis: Change Point Detection and Diagnostics on Bitcoin Log Returns</strong>
    </td>
  </tr>
</table>
   
   
---





## Prerequisites

Ensure that you have R (version 3.5 or later) installed along with the following package:

- **changepoint**  
  Install using:
  ```r
  install.packages("changepoint")
