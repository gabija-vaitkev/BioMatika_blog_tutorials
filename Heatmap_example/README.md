# How to Create Publication-Ready Heatmaps in R from Raw Gene Expression Data

This directory contains the R code corresponding to the blog post tutorial on processing raw transcriptomic data and generating publication-ready annotated heatmaps using `pheatmap`.

## Overview

The code demonstrates how to analyze RNA-seq data from the `airway` dataset and build a clean, informative gene expression heatmap in four distinct steps:

1. **Differential Expression Analysis:** Process raw counts with `DESeq2` and apply variance-stabilizing transformation (`vst`).
2. **Gene ID Mapping:** Map raw Ensembl IDs to readable gene symbols using `AnnotationDbi` and `org.Hs.eg.db`.
3. **Expression Matrix Preparation:** Select top differentially expressed genes, mean-centre matrix rows, and format sample labels.
4. **Heatmap Construction & Annotation:** Generate a hierarchical clustered heatmap with custom column annotations (treatment status and cell line) and row scaling.

---

## Required R Packages

Install and load the necessary CRAN and Bioconductor packages before running the code:

* `airway`: Source for the human airway smooth muscle cell RNA-seq dataset.
* `DESeq2`: Differential expression analysis and variance stabilization.
* `pheatmap`: Core framework for heatmap generation, clustering, and customized layouts.
* `AnnotationDbi` & `org.Hs.eg.db`: Mapping Ensembl identifiers to human gene symbols.

---

## File Deliverables

Executing the provided script generates a high-resolution (300 DPI) heatmap figure:

* top_20_genes_heatmap.png

---

If you have any questions or suggestions, contact us at info@biomatika.lt.
