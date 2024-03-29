library(dplyr)
library(ggplot2)
library(ggpattern)
library(reshape2)
library(cowplot)
library(Seurat)
library(dplyr)
library(RColorBrewer)

load("F:/4-7-20m-Final-1030/Figure 2+S2/Add_ADvsPso_New_1102.Rda")

####################### Figure 2A and B
rash_lfc = as.data.frame(foldchange[,6])
colnames(rash_lfc) = "Rash vs N"
rash_p = as.matrix(pvals_prop[,6])

vis_coef <- rash_lfc
pvals_adj <- p.adjust(rash_p, method = "BH")
vis_pvals_adj <- abs(log10(pvals_adj+1e-10))
#knitr::kable(  vis_coef  )


vis_coef <- as.data.frame(vis_coef)
vis_coef$CellType = rownames(vis_coef)
vis_coef$CellType <- factor(vis_coef$CellType, levels = cell_identity$Identities)
#vis_coef$CellType <- factor(vis_coef$CellType, levels = 1:41)
vis_coef = melt(vis_coef)
colnames(vis_coef)[2:3] = c("Comparison", "coefs")
vis_coef$IsSig = abs(vis_pvals_adj) >= abs(log10(0.05+1e-10))

new_meta = meta %>% filter(dis %in% c("AD1","AE", "Pso", "LP", "BP", "NML")) %>%
  group_by(new_level, identity) %>% summarise(n = n()) %>% 
  mutate(freq = n / sum(n))

new_meta$new_level2 <- ""
new_meta$new_level2 <- ifelse(new_meta$new_level=="NML",
                         "NML(7)", "Rash(24)")


vis_coef$p_val <- ""
vis_coef$p_val <- ifelse(vis_coef$IsSig=="TRUE",
                         "P-value < 0.05", "P-value> 0.05")

###################################  save for tables ##################################
write.xlsx(vis_coef, "F:/4-7-20m-Final-1030/Figure 2+S2/Final/vis_coef_Rash_N.xlsx")
write.xlsx(rash_lfc, "F:/4-7-20m-Final-1030/Figure 2+S2/Final/rash_lfc_Rash_N.xlsx")
write.xlsx(as.matrix(new_meta), "F:/4-7-20m-Final-1030/Figure 2+S2/Final/new_meta_Rash_N.xlsx")
write.xlsx(as.matrix(pvals_adj), "F:/4-7-20m-Final-1030/Figure 2+S2/Final/p_value_adj_Rash_N.xlsx")


########################################################################################

p1 = ggplot(data = new_meta, aes(x = identity, y = freq, 
                                 group = new_level, fill = new_level2)) +
  geom_bar(stat= "identity", position = "dodge")+
  theme_classic()+ylab("proportion") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(fill = "") + xlab("CD45+ Cell Types")+ylab("Proportion of CD45+ Cells")+
  scale_fill_manual(values =  colorRampPalette(brewer.pal(12, "Paired"))(2))

p2 = ggplot(vis_coef, aes(x = CellType, y = coefs, fill = p_val)) + 
  geom_bar(stat = "identity") + 
  scale_fill_manual(values = c("red4", "gray")) +      
  theme_classic() + 
  labs(fill = "") + xlab("CD45+ Cell Types")+ylab("Log2FC Rash vs NML")+
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) 

pp <- list(p1, p2)
plot_grid(plotlist=pp, ncol=1, align='v')


####################### Figure 2C
our <- readRDS("F:/4-7-20m-Final-1030/our_no_218_203.rds")

Idents(our) <- our$ID
our <- RenameIdents(our, `1` = "Tcm", `2` = "Trm1", `3` = "eTreg1", `4` = "Trm2", `5` = "CTLex", `6` = "CTLem",
                    `7` = "Tet", `8` = "Tmm1", `9` = "ILC/NK", `10` = "NK", `11` = "Trm3", `12` = "cmTreg", 
                    `13` = "Tmm2", `14` = "eTreg2", `15` = "Tmm3", `16` = "ILC2",  `17` = "Tn", 
                    `18` = "moDC1", `19` = "LC1", `20` = "InfMono", `21` = "Mac1", `22` = "Mono",
                    `23` = "LC2", `24` = "moDC2", `25` = "moDC3", `26` = "DC1",  `27` = "DC2",
                    `28` = "LC3", `29` = "Mac2", `30` = "Plasma", `31` = "B", `32` = "Mac3", 
                    `33` = "DC3", `34` = "migDC", `35` = "Mac4", `36` = "Mast", `37` = "Trm-c",
                    `38` = "Treg-c", `39` = "Mast-c", `40` = "ILC/NK-c", `41` = "CTL-c")

our[["Ident2"]] <- Idents(object = our)
Idents(our) <- our$ID
  
plot_df <- as.data.frame.matrix(our@meta.data)

plot_df$sample_name <- plot_df$donor

test_df <- plot_df %>% group_by(donor, Ident2, dis) %>% 
  summarise(n = n())
test_df <- test_df %>% group_by(donor, dis) %>% mutate(Freq = n / sum(n))

test_df$sample_name_condition <- paste0(test_df$donor,' ', test_df$dis)


library(RColorBrewer)
test_df$dis <- factor(test_df$dis, levels = c("NML", "AD1", "Pso", "AE", "LP", "BP"))

#test_df <- subset(test_df, dis!= "AE")


test_df$Ident2 <- factor(test_df$Ident2, levels = c("Tcm", "Trm1", "eTreg1", "Trm2", "CTLex", "CTLem", "Tet",
                                                    "Tmm1", "ILC/NK", "NK", "Trm3", "cmTreg", "Tmm2", "eTreg2",
                                                    "Tmm3", "ILC2", "Tn", "moDC1", "LC1", "InfMono", "Mac1",
                                                    "Mono", "LC2", "moDC2", "moDC3", "DC1", "DC2", "LC3",
                                                    "Mac2", "Plasma", "B", "Mac3", "DC3", "migDC", "Mac4",
                                                    "Mast", "Trm-c", "Treg-c", "Mast-c", "ILC/NK-c", "CTL-c"))


write.xlsx(as.matrix(test_df), "F:/4-7-20m-Final-1030/Figure 2+S2/Final/Figure2C.xlsx")

ggplot(data=test_df, aes(x=sample_name_condition, y = Freq, fill=Ident2)) +
  geom_bar(stat="identity") + 
  facet_grid(cols = vars(dis), 
             labeller = label_wrap_gen(width = 16,multi_line = TRUE), 
             scales="free", space = "free") +
  xlab("Individual Sample") + ylab("Proportion of CD45+ Cells for each sample") +
  scale_fill_manual(values = colorRampPalette(brewer.pal(12, "Paired"))(41)) +
  theme_bw()+
  theme(legend.position="bottom", axis.text.x  = element_blank(), axis.ticks.x = element_blank())+
  guides(fill=guide_legend(nrow=5,byrow=TRUE))




######################################### S2AB ###############################################
dis_lfc = as.data.frame(foldchange[,c(1,3,7)])
colnames(dis_lfc) = colnames(foldchange)[c(1,3,7)]
dis_p = as.matrix(pvals_prop[,c(1,3, 7)])

vis_coef <- dis_lfc
pvals_adj <- p.adjust(dis_p, method = "BH")
vis_pvals_adj <- abs(log10(pvals_adj+1e-10))
#knitr::kable(  vis_cp.adjustoef  )


vis_coef <- as.data.frame(vis_coef)
vis_coef$CellType = rownames(vis_coef)
vis_coef$CellType <- factor(vis_coef$CellType, levels = cell_identity$Identities)
#vis_coef$CellType <- factor(vis_coef$CellType, levels = 1:41)
vis_coef = melt(vis_coef)
colnames(vis_coef)[2:3] = c("Comparison", "coefs")
vis_coef$IsSig = abs(vis_pvals_adj) >= abs(log10(0.05+1e-10))


new_meta = meta %>% filter(dis %in% c("AD1","Pso", "NML")) %>%
  group_by(dis, identity) %>% summarise(n = n()) %>% 
  mutate(freq = n / sum(n))

new_meta$dis = factor(new_meta$dis, levels = c("AD1","Pso", "NML"))

p1 =  ggplot(data = new_meta, aes(x = identity, y = freq, group = dis, fill = dis)) +
  geom_bar(stat = "identity",position = "dodge")+
  theme_classic()+ylab("Proportion of CD45+ Cells") + xlab(" ") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p2 = ggplot(vis_coef, aes(x = CellType, y = coefs, fill = Comparison, col = IsSig)) + 
  geom_col_pattern(
    pattern = ifelse(vis_coef$IsSig, "none", "stripe"), 
    pattern_density = 0.35,
    pattern_colour  = 'black',
    position = "dodge"
  ) +     
  theme_classic() + 
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5)) +
  ylab("Log2FC Rash vs NML of log(P)") +
  xlab("")+
  guides(col = guide_legend(override.aes = 
                              list(
                                pattern = c("none",  "stripe")
                              )
  )) +
  guides(fill = guide_legend(override.aes = 
                               list(
                                 pattern = c("none",  "none", "none")
                               )
  ))
pp <- list(p1, p2)
plot_grid(plotlist=pp, ncol=1, align='v')



write.xlsx(vis_coef, "F:/4-7-20m-Final-1030/Figure 2+S2/Final/vis_coef_AD_Pso_N.xlsx")
write.xlsx(dis_lfc, "F:/4-7-20m-Final-1030/Figure 2+S2/Final/dis_lfc_AD_Pso_N.xlsx")
write.xlsx(as.matrix(new_meta), "F:/4-7-20m-Final-1030/Figure 2+S2/Final/new_meta_AD_Pso_N.xlsx")
write.xlsx(dis_p, "F:/4-7-20m-Final-1030/Figure 2+S2/Final/dis_p_AD_Pso_N.xlsx")
write.xlsx(as.matrix(pvals_adj), "F:/4-7-20m-Final-1030/Figure 2+S2/Final/pvals_adj_AD_Pso_N.xlsx")
