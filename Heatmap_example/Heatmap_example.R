# Install BiocManager and required packages if not already installed:
# if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# if (!require("airway")) BiocManager::install("airway")
# if (!require("DESeq2")) BiocManager::install("DESeq2")
# if (!require("pheatmap")) install.packages("pheatmap")
# if (!require("AnnotationDbi")) BiocManager::install("AnnotationDbi")
# if (!require("org.Hs.eg.db")) BiocManager::install("org.Hs.eg.db")

library(airway)
library(DESeq2)
library(pheatmap)
library(AnnotationDbi)
library(org.Hs.eg.db)

# --- Load Data & Prep Metadata ---
data("airway")
colnames(airway) <- gsub(" ", "_", colnames(airway))
airway$dex  <- as.factor(airway$dex)
airway$cell <- as.factor(airway$cell)

# --- Construct DESeq2 Object & Filter Low Counts ---
dds <- DESeqDataSet(airway, design = ~ cell + dex)
keep <- rowSums(counts(dds)) >= 10
dds  <- dds[keep, ]

# --- Run DESeq Analysis & Order Results ---
dds <- DESeq(dds)
res <- results(dds)
res <- na.omit(res)
res <- res[order(res$padj), ]

# --- Clean Ensembl IDs ---
ens_ids <- sub("\\.\\d+$", "", rownames(res))

# --- Offline Symbol Mapping ---
map_symbols <- AnnotationDbi::select(
  org.Hs.eg.db,
  keys     = ens_ids,
  keytype  = "ENSEMBL",
  columns  = c("SYMBOL", "GENENAME")
)

# --- Remove duplicates and align with results ---
map_symbols <- map_symbols[!duplicated(map_symbols$ENSEMBL), ]
symbol_vec  <- map_symbols$SYMBOL[match(ens_ids, map_symbols$ENSEMBL)]

# --- Fallback to Ensembl ID if symbol is missing ---
label_vec <- ifelse(is.na(symbol_vec) | symbol_vec == "", ens_ids, symbol_vec)

# --- Attach cleaned IDs and symbols to results ---
res$ENSEMBL_clean <- ens_ids
res$label         <- label_vec

# --- Select Top 20 Genes ---
top_n <- 20
top_genes_ens <- head(res$ENSEMBL_clean, top_n)
top_labels    <- head(res$label, top_n)

# --- Variance Stabilising Transformation ---
vsd <- vst(dds, blind = FALSE)

# --- Format column names for clarity ---
sample_info <- colData(vsd)
colnames(vsd) <- paste(sample_info$cell, sample_info$dex, sep = "_")

# --- Match row identifiers ---
assay_ids <- sub("\\.\\d+$", "", rownames(vsd))
rownames(vsd) <- assay_ids

# --- Subset & Mean-Centre Matrix ---
mat <- assay(vsd)[top_genes_ens, , drop = FALSE]
mat <- mat - rowMeans(mat)
rownames(mat) <- top_labels

# --- Build Column Metadata ---
annotation_col <- as.data.frame(colData(vsd)[, c("dex", "cell")])
colnames(annotation_col) <- c("Dexamethasone", "Cell line")

annotation_col$Dexamethasone <- factor(
  annotation_col$Dexamethasone,
  levels = c("untrt", "trt"),
  labels = c("untreated", "treated")
)
rownames(annotation_col) <- colnames(mat)

# --- Custom Colour Palettes ---
ann_colors <- list(
  `Dexamethasone` = c(
    "untreated" = "white",
    "treated"   = "gray"
  ),
  `Cell line` = c(
    "N052611" = "#468189",
    "N061011" = "#77aca2",
    "N080611" = "#9dbebb",
    "N61311"  = "#f4e9cd"
  )
)

# --- Plot Heatmap (Displays in RStudio) ---
ph <- pheatmap(
  mat,
  annotation_col           = annotation_col,
  annotation_colors        = ann_colors,
  scale                    = "row",
  clustering_distance_rows = "correlation",
  clustering_distance_cols = "correlation",
  main                     = sprintf("Top %d Differentially Expressed Genes", top_n),
  fontsize                 = 14
)

# --- Export Heatmap to PNG ---
png("top_20_genes_heatmap.png", width = 10, height = 8, units = "in", res = 300)
grid::grid.draw(ph$gtable)
dev.off()
