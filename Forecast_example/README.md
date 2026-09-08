# How to Model and Forecast Time Series Data in R: From Raw Data to Publication-Ready Charts

This directory contains the R code corresponding to the blog post tutorial on time series analysis, additive ETS (Error, Trend, Seasonality) modelling, and constructing multi-layered forecast visualisations using `ggplot2`.

## Overview

The code demonstrates how to analyze monthly time series data and generate a 5-year forecast across four core steps:

1. **Time Series Preparation:** Generate monthly data and construct an R `ts` time series object with a monthly frequency (`frequency = 12`).
2. **ETS Model Fitting & Forecasting:** Fit an additive model (`ETS(A,A,A)`) with `forecast::ets()` and project future values 60 months (5 years) ahead with 80% and 95% confidence intervals.
3. **Data & Date Alignment:** Construct a unified data frame linking historical dates, observed counts, model fits, and projected dates. Includes seamless handling of month-end roll-overs and gaps.
4. **Visualisation & Uncertainty Shading:** Build a layered `ggplot2` chart featuring custom-shaded prediction intervals, historical trendlines, point forecasts, and custom color scales.

---

## Required R Packages

Install and load the necessary R libraries before running the code:

* `forecast`: Time series modelling, fitting ETS algorithms, and generating forecast objects.
* `lubridate`: Date sequence generation, handling month-end alignments, and annual roll-overs.
* `dplyr`: Data frame manipulation and transformation workflows.
* `ggplot2`: Multi-layered graphics, custom scale formatting, and theme adjustments.

---

## File Deliverables

Executing the provided script generates high-resolution chart and table deliverables:

* `ETS_forecast_emergency_cases.png` – High-resolution (300 DPI) visualization of historical data, model fit, point forecasts, and 80%/95% confidence intervals.
* `ets_forecasted_table.csv` – Exported data frame containing historical observations, fitted values, point forecasts, and lower/upper prediction bounds.

---

If you have any questions or suggestions, contact us at info@biomatika.lt.
