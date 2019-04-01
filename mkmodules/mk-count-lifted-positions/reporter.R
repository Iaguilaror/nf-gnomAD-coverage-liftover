## Read libraries
library("scales")
library("dplyr")
library("ggplot2")

## Read arguments from command line
args <- commandArgs(trailingOnly = TRUE)

## For debugging
# # arg 1 is $prereq
# args[1] <- "test/data/sample_gnomad.genomes.coverage.summary.tmp"
# # arg 2 is $target
# args[2] <- "test/data/sample_gnomad.genomes.coverage.summary.pdf"

## Read data
data.df <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = T)

## Reorder factor
data.df$Positions <- factor(data.df$Positions, levels = c("unmapped_positions", "mapped_positions"))

## extract total positions value
total_positions <- sum(data.df$Numbers)

## Calculate percentage of variants
data.df$percentage <- data.df$Numbers / total_positions *100

## Keep only informative rows for pie chart
pie.df <- data.df

## caculate values for plotting
pie.df$ymax = cumsum(pie.df$percentage)
pie.df$ymin = c(0, head(pie.df$ymax, n = -1))

#Create a custom color scale
myColors <- c("#F8766D","#619CFF")
names(myColors) <- levels(pie.df$Positions)
colScale <- scale_colour_manual(name = "Positions",values = myColors)

## plot donut chart

## Donut plot
library(ggrepel)
donut.p <- ggplot(pie.df, aes(fill = Positions, ymax = ymax, ymin = ymin, xmax = 100, xmin = 80)) +
  geom_rect(colour = "black") +
  coord_polar(theta = "y", start = 2.5) + 
  xlim(c(0, 140)) +
  geom_label_repel(data = pie.df[pie.df$Numbers >0,], aes(fill = Positions, 
                                      label = paste(round(percentage,2),"%","(",prettyNum(Numbers, big.mark = ","),")"),
                       x = 130, y = (ymin + ymax)/2),
                   inherit.aes = F, show.legend = F, 
                   size = 2,
                   label.padding = unit(0.2, "lines"))+
  scale_fill_manual(name = "gnomeAD coverage liftover results", values = myColors) +
    labs( caption = paste("Total positions:", total_positions, " \n", date())) +
  theme_minimal() +
  theme(
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        text = element_text(size=5),
        legend.spacing.x = unit(0.1, 'cm'),
        legend.text = element_text( size = 5, face = "bold"),
        legend.title = element_text( size = 6, face = "bold"),
        legend.key.height = unit(0.2, 'cm')
        )

ggsave(filename = args[2], plot = donut.p, device = "pdf", width = 10.8, height = 7.2 , units = "cm", dpi = 300)