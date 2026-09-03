library(tidyverse)
library(matrixStats)

# ---- INPUTS ----
# first, load DGE_analysis environment
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("Provide a metric to extract TPM counts", call.=FALSE)
}

dir <- args[2]
coverage_filtered_table <- args[3]
full_table <- args[4]
output_path <- args[5]

# ---- READ DATA ----
setwd(dir)

filt.events <- read_delim(coverage_filtered_table)  # events filtered with perl
all.events <- read_delim(full_table)  # raw data

events <- filt.events$EVENT  # list of passing events

# ---- FILTER BY COVERAGE ----

# filter events with min VLOW in 70% of samples
all.events.filt <- all.events %>%
    dplyr::filter(EVENT %in% events) %>%
    column_to_rownames("EVENT")

# remove Q columns
no.q.cols <- which(!str_detect(colnames(all.events.filt), "-Q"))
all.events.filt <- all.events.filt[, no.q.cols]

# ---- FILTER BY VARIANCE ----
# get samples
samples <- colnames(all.events.filt)[6:ncol(all.events.filt)]

# get PSI matrix
psi.matrix <- all.events.filt[, samples] %>% as.matrix()

# get variance
variance <- rowVars(psi.matrix) 
variance <- variance / if_else(rowMeans(psi.matrix) != 0, rowMeans(psi.matrix), 1)
variance[is.na(variance)] <- 0

threshold <- quantile(variance)[4] # 25% 190k = 47k
keep <- which(variance >= threshold)

all.events.filt <- all.events.filt[keep,] %>%
    rownames_to_column(var = "EVENT") %>%
    left_join(filt.events, by="EVENT", suffix=c("",".y")) %>%
    dplyr::select(-ends_with(".y"))

# save filtered table
write_delim(all.events.filt, file = output_path, delim = "\t")
