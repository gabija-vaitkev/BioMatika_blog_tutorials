# Professional PCA Plots in R: From Greyscale Points to Colourful Ellipses

This directory contains the R code corresponding to the blog post tutorial on creating publication-ready Principal Component Analysis (PCA) visualisations using `ggplot2`.

## Overview

The code demonstrates how to run a PCA on the classic `wine` dataset and progressively build clean, high-impact visualisations across four distinct stages:

1. **Stage 1:** Greyscale plot with distinct point shapes for print publications.
2. **Stage 2:** Colour-coded groups for digital presentations.
3. **Stage 3:** Outlined 95% confidence ellipses.
4. **Stage 4:** Publication-standard plot with colourful filled, semi-transparent confidence regions.

---

## Required R Packages

Install and load the necessary libraries before running the code:

* `rattle`: Source for the 13-attribute chemical wine dataset.
* `ggplot2`: Core visualization framework.
* `dplyr`: Data manipulation workflows.
* `car`: Exact mathematical calculation of 95% confidence ellipses via ellipse().

---

## File Deliverables

Executing the provided script generates four high-resolution (300 DPI) images corresponding to each visualisation stage:

* wine_pca_stage1.png
* wine_pca_stage2.png
* wine_pca_stage3.png
* wine_pca_stage4.png
