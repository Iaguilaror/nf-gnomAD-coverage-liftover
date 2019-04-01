## Disable scientific notation
options(scipen = 666)

## read command line args
args <- commandArgs(trailingOnly = TRUE)

## For debug only
# args[1] <- "test/data/sample_gnomad.genomes.coverage.summary.subsampled21.chunk0000.edited.tmp"

# args[2] <- "test/data/sample_gnomad.genomes.coverage.summary.subsampled21.chunk0000.edited.tsv"

## read data
data.df <- read.table(file = args[1], header = F, sep = "\t", stringsAsFactors = F)

## Round means
data.df$V3 <- round(data.df$V3, digits = 2)

## Repeat col 2 for bed end position
data.df$V5 <- data.df$V2

## Reorder columns
data.df <- data.df[,c(1,2,5,3,4)]

## save data
write.table(x = data.df, file = args[2], append = F, quote = F, sep = "\t", row.names = F, col.names = F)