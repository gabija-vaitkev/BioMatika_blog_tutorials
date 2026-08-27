# Install packages if you haven't already:
# if (!require("rattle")) install.packages("rattle")
# if (!require("ggplot2")) install.packages("ggplot2")
# if (!require("dplyr")) install.packages("dplyr")
# if (!require("car")) install.packages("car")

# --- Load the packages
library(rattle)   # Sample wine dataset
library(ggplot2)  # Data visualisation
library(dplyr)    # Data wrangling
library(car)      # Exact ellipse calculations

# --- Load & Prep Data ---
data(wine, package = "rattle")
wine_data  <- wine[, -1]           # Drop categorical column for PCA
wine_class <- factor(wine$Type)   # Store class labels (1, 2, 3)

# --- Perform PCA ---
wine_pca <- prcomp(wine_data, scale. = TRUE)

# --- Extract PC Scores ---
pca_df <- as.data.frame(wine_pca$x[, 1:2])
names(pca_df)[1:2] <- c("PC1", "PC2")
pca_df$Class <- wine_class

# --- Calculate % Variance Explained ---
var_exp <- wine_pca$sdev^2 / sum(wine_pca$sdev^2)
x_lab <- sprintf("PC1 (%.1f%%)", 100 * var_exp[1])
y_lab <- sprintf("PC2 (%.1f%%)", 100 * var_exp[2])

# --- Padding function to give plot borders breathing room ---
pad <- function(z, f = 0.05) range(z) + diff(range(z)) * c(-f, f)
x_limits <- pad(pca_df$PC1, 0.05)
y_limits <- pad(pca_df$PC2, 0.05)

# --- Mapping Colours & Shapes ---
classes <- levels(pca_df$Class)

col_vals <- c("#F8766D", "#00BA38", "#619CFF")[seq_along(classes)]
col_map  <- setNames(col_vals, classes)

shape_vals <- c(16, 17, 15)[seq_along(classes)]
shape_map  <- setNames(shape_vals, classes)

# --- Helper Function for 95% Confidence Ellipses ---
get_ellipse_coords <- function(df, level = 0.95, segments = 200) {
  cov_mat <- cov(df[, c("PC1", "PC2")])
  center  <- colMeans(df[, c("PC1", "PC2")])
  as.data.frame(
    car::ellipse(center = center,
                 shape  = cov_mat,
                 radius = sqrt(qchisq(level, df = 2)),
                 segments = segments,
                 draw = FALSE)
  )
}

# --- Pre-calculate ellipse coordinates for each wine class ---
ell_list <- split(pca_df, pca_df$Class)
ell_data <- bind_rows(lapply(ell_list, function(d) {
  coords <- get_ellipse_coords(d, level = 0.95, segments = 200)
  cbind(coords, Class = d$Class[1])
}))
names(ell_data)[1:2] <- c("x", "y")

# --- Grey-scale PCA plot ---
p1 <- ggplot(pca_df, aes(PC1, PC2, shape = Class)) +
  geom_point(size = 2, color = "grey40") +
  scale_shape_manual(values = shape_map) +
  xlim(x_limits) + ylim(y_limits) +
  labs(x = x_lab, y = y_lab, shape = "Wine type") +
  theme_bw(base_size = 14)
p1

ggsave("wine_pca_stage1.png", p1, width = 7, height = 5.75, dpi = 300)

# --- Coloured PCA plot ---
p2 <- ggplot(pca_df, aes(PC1, PC2, color = Class)) +
  geom_point(size = 2) +
  scale_color_manual(values = col_map) +
  xlim(x_limits) + ylim(y_limits) +
  labs(x = x_lab, y = y_lab, color = "Wine type") +
  theme_bw(base_size = 14)

p2

ggsave("wine_pca_stage2.png", p2, width = 7, height = 5.75, dpi = 300)

# --- Coloured PCA plot with ellipses added ---
p3 <- ggplot(pca_df, aes(PC1, PC2, color = Class)) +
  geom_point(size = 2) +
  geom_path(data = ell_data,
            aes(x = x, y = y, color = Class, group = Class),
            linewidth = 1) +
  scale_color_manual(values = col_map) +
  xlim(x_limits) + ylim(y_limits) +
  labs(x = x_lab, y = y_lab, color = "Wine type") +
  theme_bw(base_size = 14)

p3

ggsave("wine_pca_stage3.png", p3, width = 7, height = 5.75, dpi = 300)

# --- Coloured PCA plot with shaded ellipses included ---
p4 <- ggplot(pca_df, aes(PC1, PC2, color = Class, fill = Class)) +
  geom_point(size = 2) +
  geom_polygon(data = ell_data,
               aes(x = x, y = y, fill = Class, group = Class),
               alpha = 0.2, color = NA) +
  geom_path(data = ell_data,
            aes(x = x, y = y, color = Class, group = Class),
            linewidth = 1) +
  scale_color_manual(values = col_map) +
  scale_fill_manual(values = col_map) +
  xlim(x_limits) + ylim(y_limits) +
  labs(x = x_lab, y = y_lab, color = "Wine type", fill = "Wine type") +
  theme_bw(base_size = 14)

p4

ggsave("wine_pca_stage4.png", p4, width = 7, height = 5.75, dpi = 300)
