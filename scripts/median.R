#args[1]=input file
#args[2]=output

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

df = read.table(args[1], sep="\t", header = T, row.names=1)

df[df == 0] <- NA

df_med <- as.data.frame(apply(df, 1, median, na.rm=T))

write.table(df_med,file=args[2],sep = "\t",row.names = TRUE)
