library("ggplot2")

df <- read.table("Documentos/DD/Validação/READ_exp.tsv", sep = "\t", header = T)
host_chimeric <- c("ENST00000435504.9","MSTRG.5060.3")

df_plot <- subset(df, subset = transcript_id %in% host_chimeric)
row.names(df_plot) <- df_plot$transcript_id

#res2 <- rcorr(as.matrix(t(df_plot[,-1])))

#corrplot(res2$r, type="upper", order="hclust", 
#         p.mat = res2$P, sig.level = 0.01, insig = "blank")
df_plot <- melt(df_plot, c("transcript_id"))

#df_plot <- df_plot %>% gather(sample,exp)

ggplot(df_plot, aes(x= transcript_id, y=exp, fill= Host)) + 
  geom_boxplot(outlier.alpha = 0.1) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
  panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "grey")) +
  #scale_x_discrete(limits=target) +
  xlab("") + 
  ylab("Expression (TPM)") +
  annotate(geom="text", x=2, y=max(df_plot[,"exp"]), label=paste("Chimeric ratio:",round(sum(df_plot[which(df_plot$Host == "Chimeric"),"exp"])/sum(df_plot[,"exp"]),digits = 3),sep = ""),
           color="red")
  #ggtitle(paste(c("Chimeric ratio ",sum(df_plot[which(df_plot$Host == "Chimeric"),"exp"])/sum(df_plot[,"exp"])),sep = ""))
  #ylim(0, 100)

