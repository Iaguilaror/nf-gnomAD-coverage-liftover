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

## Copy col 2 and substract for bed start position
data.df$V4 <- data.df$V2 -1

## Reorder columns
# 1 is chromosome name
# 4 is bed start
# 2 is bed end
# 3 is mean coverage
data.df <- data.df[,c(1,4,2,3)]

## save data
write.table(x = data.df, file = args[2], append = F, quote = F, sep = "\t", row.names = F, col.names = F)
