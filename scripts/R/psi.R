#args[1]=host_expression
#args[2]=chimeric_expression
#args[3]=MSTRG.X

library(reshape2)

args = commandArgs(trailingOnly=TRUE)

df_host <- read.table(args[1], sep = "\t", header = T)
df_chimeric <- read.table(args[2], sep = "\t", header = T)

df_host <- melt(df_host, c("transcript_id"))
df_chimeric  <- melt(df_chimeric, c("transcript_id"))

ratio=round(sum(df_chimeric$value)/(sum(df_chimeric$value)+sum(df_host$value)),digits = 3)

cat(args[3],ratio,"\n")
