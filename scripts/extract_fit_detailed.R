library(tidyverse)
library(brms)
library(tidybayes)
library(ggtree)
library(ape)
library(aplot)

# this script extracts the detailed fit (i.e. the estimated effect of each language)

pth <- '../output_data_pca_newtree'
output_dir <- '../imgs/detailed_newtree/'
files <- dir(pth, pattern='*.RData')

# d_final <- read.csv('../Data/compiled_table_20231010.csv') %>% ungroup()

social_vars <- c()
grammatical_vars <- c()

refs <- read.csv('../Data/exotericity.csv') %>% 
    select(Glottocode, Family.Glottolog, Language)

tree <- read.tree('../Data/new.tree')

for (file in files){
    load(paste0(pth, '/', file))
    grammatical_var <- as.character(model$formula$formula[[2]]) 
    social_var <- as.character(model$formula$formula[[3]][[2]][[2]])

    social_vars <- c(social_vars, social_var)
    grammatical_vars <- c(grammatical_vars, grammatical_var)


    fitted_model <- model %>% spread_draws(b_Intercept, b_PC1, r_Glottocode[language, term], r_Glottocode2[language, term]) %>% 
        median_qi(language_mean = b_Intercept + b_PC1 + r_Glottocode + r_Glottocode2) %>% 
        left_join(refs, by=c('language'='Glottocode'))

    languages_included <- model$data$Glottocode
    reduced.tree <- keep.tip(tree, languages_included)

    p_tree <- ggtree(reduced.tree) 

        # geom_facet(panel='Posterior', data=fitted_model, geom=geom_point, mapping=aes(x=language_mean)) +
        # #geom_facet(panel='Posterior', data=fitted_model, geom=geom_segment, mapping=aes(x=.lower, xend=.upper, y=language, yend=language)) +
        # geom_facet(panel='Posterior', data=fitted_model, geom=geom_vline, xintercept=0, linetype='dashed') +
        # theme_tree2(legend.position='none')


    p <- fitted_model %>% 
            ggplot(aes(x=language_mean, y=language, color=Family.Glottolog)) +
                #facet_grid(rows = vars(Family.Glottolog), space='free_y', scale='free_y') +
                geom_point() +
                geom_segment(aes(x=.lower, xend=.upper, y=language, yend=language)) +
                ylab('') +
                ggtitle(grammatical_var) +
                theme_classic() +
                theme(legend.position='none')


    pdf(paste0(output_dir, social_var, '-', grammatical_var, '.pdf'), width=10, height=30)    
    print(p %>% insert_left(p_tree))
    dev.off()

}

# df <- tibble(
#     social_vars = social_vars,
#     grammatical_vars = grammatical_vars,

# )