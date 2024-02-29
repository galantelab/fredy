#args[1]=host_expression
#args[2]=chimeric_expression
#args[3]=MSTRG.X
library(ggplot2)
library(reshape2)

args = commandArgs(trailingOnly=TRUE)

df_host <- read.table(args[1], sep = "\t", header = T)
df_chimeric <- read.table(args[2], sep = "\t", header = T)

df_host <- melt(df_host, c("transcript_id"))
df_host$type <- c("Host")
colnames(df_host) <- c("id", "sample", "exp", "type")

df_chimeric  <- melt(df_chimeric, c("transcript_id"))
df_chimeric$type <- c("Chimeric")
colnames(df_chimeric) <- c("id", "sample", "exp", "type")

df_final <- rbind(df_host,df_chimeric)

boxplot = ggplot(df_final, aes(x= id, y=log2(exp+1), fill= type)) +
  geom_boxplot(outlier.alpha = 0.1) +
  theme_classic() +
  theme(legend.position="top",
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "grey")) +
  xlab("") + 
  ylab("Expression (TPM)") +
  ggtitle("")

svg(filename = paste(c(args[3],".svg"), sep = ""))
boxplot
dev.off()