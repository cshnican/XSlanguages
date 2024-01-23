library(ape)
library(tidyverse)
library(ggtree)

tree_orig <- read.nexus('../Data/EDGE6635-merged-relabelled.tree')
languages <- read.csv('../Data/compiled_table_20231213_pca.csv') # pruned EDGE tree to include all languages in our database

to_keep <- tree_orig$tip.label %>% as.data.frame() %>% rename(tip.label = ".") %>% 
  separate(col = tip.label , into = c("Language_ID", "Name_EDGE"), remove = F, sep = 8) %>% 
  inner_join(languages, by=c('Language_ID'='Glottocode')) 

tree <- keep.tip(tree_orig, unique(to_keep$tip.label)) 
tree$tip.label <- to_keep$Language_ID %>% unique()


print(tree)
write.tree(tree, '../Data/new.tree')


# compare two trees
tree_sae <- read.tree('../Data/wrangled.tree') # taken from Shcherbakova et al. (2023) - pruned EDGE tree to include all languages in Grambank

pdf('../imgs/compare_trees/shcherbakova_et_al_tree.pdf', height=20, width=10)
print(ggtree(tree_sae) + geom_tiplab() + ggtitle(paste0('Shcherbakova et al. (2023) tree, n=', tree_sae$tip.label %>% length())))
dev.off()

pdf('../imgs/compare_trees/our_tree.pdf', height=20, width=10)
print(ggtree(tree) + geom_tiplab() + ggtitle(paste0('our tree, n=', tree$tip.label %>% length())))
dev.off()

print('ours - S et al.')
print(setdiff(tree$tip.label, tree_sae$tip.label))
print('S. et al. - ours')
print(setdiff(tree_sae$tip.label, tree$tip.label))