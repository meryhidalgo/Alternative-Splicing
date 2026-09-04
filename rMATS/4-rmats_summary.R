library(maser)
library(tidyverse)
library(factoextra)
library(patchwork)


# ---- set input values -----
conditions <- c("contrast", "control")
num_conditions <- c(3, 3)
fdr_value <- 0.05
dpsi_value <- 0.1

dir.create("tables")
dir.create("plots")


events <- maser(path="output/",cond_labels = conditions, ftype = c("JC")) # --------- CHECK ------------
masers <- filterByCoverage(events, avg_reads = 20)

MY_THEME <-
  theme(
    #text = element_text(family = "Roboto"),
    axis.ticks = element_blank(),
    axis.line = element_line(colour = "grey50"),
    panel.grid = element_line(color = "#b4aea9"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(linetype = "dashed"),
    panel.background = element_rect(fill = "white", color = "white"),
    plot.background = element_rect(fill = "white", color = "white"),
    legend.background = element_rect(fill = "white"),
    plot.title = element_text(
      #family = "Roboto",
      size = 16,
      face = "bold",
      color = "#2a475e",
      margin = margin(b = 20)
    )
  )

# ---- Volcano ----
events <- c("A3SS", "A5SS", "SE", "RI", "MXE") 

volcano <- function (events, type = c("A3SS", "A5SS", "SE", "RI", "MXE"), 
          fdr = 0.05, deltaPSI = 0.1) {
  if (!is(events, "Maser")) {
    stop("Parameter events has to be a maser object.")
  }
  
  type <- match.arg(type)
  events <- as(events, "list")
  IncLevelDifference <- NULL
  Status <- NULL
  
  stats <- events[[paste0(type, "_", "stats")]]
  events_info <- events[[paste0(type, "_", "events")]]
  cond1 <- dplyr::filter(stats, FDR < fdr, IncLevelDifference > deltaPSI)
  cond2 <- dplyr::filter(stats, FDR < fdr, IncLevelDifference < (-1 * deltaPSI))
  
  status <- rep("Not significant", times = nrow(stats))
  status[stats$ID %in% cond1$ID] <- events$conditions[1]
  status[stats$ID %in% cond2$ID] <- events$conditions[2]
  
  FDR <- stats$FDR
  idx_zero <- which(stats$FDR == 0)
  #idx_min_nonzero <- max(which(stats$FDR == 0)) + 1
  #FDR[idx_zero] <- FDR[idx_min_nonzero]
  
  log10pval <- -1 * log10(FDR)
  #print(stats)
  # Merge stats with gene_info based on the ID
  plot.df <- merge(stats, events_info, by = "ID")
  
  # Then, create the plot.df with relevant columns
  plot.df <- data.frame(ID = plot.df$ID, 
                        deltaPSI = plot.df$IncLevelDifference, 
                        log10pval = log10pval, 
                        Status = factor(status, levels = c("Not significant", 
                                                           events$conditions[1], 
                                                           events$conditions[2])),
                        geneSymbol = plot.df$geneSymbol)  # Add geneSymbol
  
  #if (length(unique(status)) < 3) {
  #  colors <- c("blue", "red")
  #} else {
    colors <- c("grey", "navy", "red")
  #}
  
  # Adjusted plot with larger dots and gene labels for significant points
  ggplot(plot.df, aes(x = deltaPSI, y = log10pval, colour = Status)) + 
    geom_point(aes(colour = Status), size = 3) +  # Increase point size
    #geom_text_repel(
    #  data = subset(plot.df, Status != "Not significant"),  # Only label significant points
    #  aes(label = geneSymbol),
    #  size = 3,  # Label text size
    #  box.padding = 0.3, 
    #  point.padding = 0.2,
    #  max.overlaps = 30
    #) +
    scale_colour_manual(values = colors) + 
    theme_bw() + 
    theme(axis.text.x = element_text(size = 12), 
          axis.text.y = element_text(size = 12), 
          axis.title.x = element_text(face = "plain", colour = "black", size = 12), 
          axis.title.y = element_text(face = "plain", colour = "black", size = 12), 
          panel.grid.minor = element_blank(), 
          plot.background = element_blank()) + 
    labs(title = "", x = "Delta PSI", y = "Log10 Adj. Pvalue")
}

volcanos <-
  lapply(events, function(t) {
    volcano(masers, type = t, deltaPSI = dpsi_value, fdr = fdr_value) + ggtitle(t)
  })

y.max <- max(sapply(volcanos, function(p) max(p$data$log10pval)))
y.max <- 15
y.min <- max(sapply(volcanos, function(p) min(p$data$log10pval)))

legend.levels <- levels(lapply(volcanos, function(p) p$data$Status)[[1]])
color_scale <- c("gray", "tomato2", "navy")
names(color_scale) <- legend.levels

v.n <- wrap_plots(volcanos) +
  guide_area() +
  plot_annotation(title = str_glue("{conditions[1]} vs {conditions[2]}")) &
  scale_color_manual(values = color_scale) &
  ylim(c(y.min, y.max)) &
  MY_THEME

v.n

ggsave(
  filename = str_glue("plots/volcano_{conditions[1]}_vs_{conditions[2]}_fdr{fdr_value}_dpsi{dpsi_value}.png"),
  plot = v.n,
  device = "png",
  width = 400,
  height = 250,
  units = "mm",
  dpi = 320,
  bg = "white"
)


# Extract data from each volcano plot and combine
combined_data <- do.call(rbind, lapply(events, function(t) {
  p <- volcano(masers, type = t, deltaPSI = .1, fdr = .01) # Generate the volcano plot object
  df <- p$data  # Extract the data used in the plot
  df$event <- t  # Add a column to label the event type
  df
}))

combined_data$color_group <- ifelse(
  combined_data$Status == "Not significant", 
  "Not significant", 
  combined_data$event
)
combined_data$color_group <- factor(combined_data$color_group)

# Define colors for each status and event combination
combined_colors <- c(
  "Not significant" = "gray",
  "A3SS" = "tomato2",
  "A5SS" = "navy",
  "SE" = "purple",
  "RI" = "green",
  "MXE" = "orange"
)

# Create the volcano plot with customized colors
v.n <- ggplot(combined_data, aes(x = deltaPSI, y = log10pval, color = color_group)) +
  geom_point(alpha = 0.7, size = 4) +
  scale_color_manual(values = combined_colors) +
  ggtitle(str_glue("{conditions[1]} vs {conditions[2]}")) +
  ylim(c(min(combined_data$log10pval), max(combined_data$log10pval))) +
  labs(color = "Event Status") +
  ylim(c(y.min, y.max)) +
  MY_THEME

v.n

ggsave(
  filename = str_glue("plots/full_volcano_{conditions[1]}_vs_{conditions[2]}.png"),
  plot = v.n,
  device = "png",
  width = 400,
  height = 250,
  units = "mm",
  dpi = 320,
  bg = "white"
)

print("Volcano plots saved")

# ---- PCA ----
events <- c("A3SS", "A5SS", "SE", "RI", "MXE") # --------- CHECK ------------

# Function to compute and plot PCA for each event type
plot_pca_for_event <- function(event) {
  psis <- PSI(masers, type = event) %>%
    as.data.frame() %>%
    drop_na() %>%
    scale() %>%
    t() %>%
    as.matrix()
  
  PCs <- prcomp(psis, center = TRUE, scale. = TRUE)
  #PCFs <- prcomp(psis, center = TRUE, scale. = FALSE)
  
  pca_plot <- fviz_pca_ind(
    PCs,
    col.ind = c(rep(conditions[1], num_conditions[1]), rep(conditions[2], num_conditions[2])), ### CHANGE 20/08
    geom = c("point"),
    pointsize = 4
  ) +
    scale_shape_manual(values = rep(20, nrow(psis))) +
    ggtitle(str_glue("{event}: {conditions[1]} vs {conditions[2]}")) #+
    #MY_THEME
  
  return(pca_plot)
}

#plot_pca_for_event('A3SS')

# Generate PCA plots for each event type
pca_plots <- lapply(events, plot_pca_for_event)

# Combine PCA plots into a single figure
combined_pca_plots <- wrap_plots(pca_plots) +
  plot_annotation(title = str_glue("PCA: {conditions[1]} vs {conditions[2]}")) &
  MY_THEME

combined_pca_plots

ggsave(
  filename = str_glue("plots/PCA_{conditions[1]}_vs_{conditions[2]}_fdr{fdr_value}_dpsi{dpsi_value}.png"),
  plot = combined_pca_plots,
  device = "png",
  width = 400,
  height = 250,
  units = "mm",
  dpi = 320,
  bg = "white"
)

print("PCA plots saved")

# ---- Tables ----
tables <- list()

# All events per sample (only common columns included)
events <- c("A3SS", "A5SS", "SE", "RI", "MXE")
all.events <- lapply(as.list(events), function(event)
  summary(masers, type = event) %>% dplyr::select(all_of(
    c(
      "ID",
      "GeneID",
      "geneSymbol",
      "FDR",
      "IncLevelDifference",
      "PSI_1",
      "PSI_2",
      "Chr",
      "Strand"
    )
  )) %>%
    filter(FDR <= fdr_value, abs(IncLevelDifference) >= dpsi_value) %>%
    mutate(Type = event)
)
contrast <- paste(masers@conditions, collapse = "_vs_")
tables[[contrast]] <- do.call(rbind, all.events)

for (ii in seq_along(tables)) {
  table.name <- names(tables)[ii]
  write_delim(
    tables[[ii]],
    file = str_glue("tables/ALL_SIGNIF_EVENTS_{table.name}_fdr{fdr_value}_dpsi{dpsi_value}.tab"),
    delim = "\t"
  )
}

# One table per event and sample (full tables)
tables <- list()
event.tables <- lapply(as.list(events), function(event)
  summary(masers, type = event) %>%
    filter(FDR <= fdr_value, abs(IncLevelDifference) >= dpsi_value)
)
names(event.tables) <- events

contrast <- paste(masers@conditions, collapse = "_vs_")
tables[[contrast]] <- event.tables

for (ii in seq_along(tables)) {
  exp.name <- names(tables)[ii]
  dir.create(str_glue("tables/{exp.name}"))
  for (jj in seq_along(tables[[ii]])) {
    event.name <- names(tables[[ii]])[jj]
    write_delim(
      tables[[ii]][[jj]],
      file = str_glue("tables/{exp.name}/{exp.name}_fdr{fdr_value}_dpsi{dpsi_value}_{event.name}.tab"),
      delim = "\t"
    )   
  }
}

diff.summary <- bind_rows(lapply(names(event.tables), function(event.name) {
  event.tables[[event.name]] %>%
    summarise(
      event = event.name,
      n_diff = n(),
      n_positive_dPSI = sum(IncLevelDifference > 0),
      n_negative_dPSI = sum(IncLevelDifference < 0)
    )
}))

print(diff.summary)