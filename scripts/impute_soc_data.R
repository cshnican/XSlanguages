library(tidyverse)
library(missForest)
library(cluster)
library(factoextra)
library(ggfortify)


df <- read.csv('../Data/compiled_table_20231010.csv')

#df_social <- df[,c(4, 7, 8, 23, 25, 27, 29, 31, 33, 35, 37, 39)]
df_social <- df[,c(4, 7, 8, 23, 31, 33, 35, 37, 39)]

set.seed(42)
df_social_imputed <- missForest(df_social)$ximp 

df_social_imputed_normalized <- scale(df_social_imputed)

pca <- prcomp(df_social_imputed_normalized)

social_normalized_pca <- df %>% 
  select(Language, Glottocode, family_Glottolog) %>%
  cbind(df_social_imputed) %>%
  cbind(pca$x)

ggplot(social_normalized_pca %>% 
         filter(family_Glottolog %in% 
                  c('Indo-European', 'Sino-Tibetan', 'Austronesian', 'Atlantic-Congo')),
       aes(x=PC1, y=PC2, color=family_Glottolog)) +
  geom_point() +
  #geom_point(data=social_normalized_pca, aes(x=PC1, y=PC2), alpha=0.3, color='gray80') +
  #geom_text(data=social_normalized_pca %>% slice_sample(n=40), aes(x=PC1, y=PC2+0.1, label=Language), size=3, color='gray10') +
  theme_classic() 

pdf('../imgs/loading_plots.pdf', width=12, height = 12)
autoplot(pca, loadings=TRUE, loadings.label=TRUE) + coord_fixed() + theme_classic(15)
dev.off()

write.csv(social_normalized_pca %>% 
            select(Language, Glottocode, PC1, PC2),'../Data/compiled_table_20231213_pca.csv', row.names = FALSE)
