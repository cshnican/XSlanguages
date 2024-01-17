library(tidyverse)
library(brms)

pth <- '../output_data_pca'
files <- dir(pth, pattern='*.RData')

# d_final <- read.csv('../Data/compiled_table_20231010.csv') %>% ungroup()

social_vars <- c()
grammatical_vars <- c()
estimates <- c()
lower_qts <- c()
higher_qts <- c()
numbers_of_languages <- c()

for (file in files){
    load(paste0(pth, '/', file))
    grammatical_var <- as.character(model$formula$formula[[2]]) 
    social_var <- as.character(model$formula$formula[[3]][[2]][[2]])
    
    number_of_language <- nrow(model$data)
    numbers_of_languages <- c(numbers_of_languages, number_of_language)

    social_vars <- c(social_vars, social_var)
    grammatical_vars <- c(grammatical_vars, grammatical_var)

    b <- fixef(model)

    estimate <- b[social_var, 'Estimate']
    lower_qt <- b[social_var, 'Q2.5']
    higher_qt <- b[social_var, 'Q97.5']

    estimates <- c(estimates, estimate)
    lower_qts <- c(lower_qts, lower_qt)
    higher_qts <- c(higher_qts, higher_qt)
}

df <- tibble(
    social_vars = social_vars,
    grammatical_vars = grammatical_vars,
    estimates = estimates,
    lower_qts = lower_qts,
    higher_qts = higher_qts,
    numbers_of_languages = numbers_of_languages
)

write.csv(df, '../output_table/fixefs_pca.csv', row.names=FALSE)

grammatical_var_info <- read_csv('../Data/LP WALS_test_final_morph_vs_syntax, LP+ABB.csv') %>%
  filter(classification_binary %in% c('S', 'M')) %>%
  mutate(
    chapter = as.numeric(str_extract(feature_name, '\\d+')),
    label_r = paste0(gsub('[^A-Za-z0-9]', '\\.', label), '_',chapter),
    label_r = ifelse(label_r == ".and..and..with...identical...different._63", "X.and..and..with...identical...different._63", label_r),
    num_levels = str_count(complexity_tier, '<') + 1,
    classification_finegrained = case_when(
      classification_binary == 'M' & combined == 'both' ~ 'Ms',
      classification_binary == 'M' & combined == 'morphology' ~ 'M',
      classification_binary == 'S' & combined == 'both' ~ 'mS',
      classification_binary == 'S' & combined == 'syntax' ~ 'S'
    )
  )

compiled_res <- df %>% 
  left_join(grammatical_var_info %>% select(
    feature_name, label_r, classification_binary, classification_finegrained, chapter
  ) %>%
    rename(
      grammatical_vars = label_r
    ), by = 'grammatical_vars')


pdf('../imgs/fig3.pdf', height=20, width=15)
ggplot(compiled_res %>%
         mutate(estimate_sgn=ifelse(estimates<0, 'negative', ifelse(estimates>0, 'positive', 'zero')),
                significant = lower_qts > 0 | higher_qts < 0,
                classification_binary = ifelse(classification_binary == 'M', 'morphology', 'syntax')), 
        aes(y=reorder(grammatical_vars, -chapter))
        ) +
  #facet_grid(rows = vars(classification_binary), cols = vars(social_vars), scales = 'free') +
  facet_grid(classification_binary + classification_finegrained ~ social_vars, space='free_y', scales='free') +
  geom_vline(xintercept = 0, linetype='dashed') +
  geom_point(aes(x=lower_qts), alpha=0.3) +
  geom_point(aes(x=higher_qts), alpha=0.3) +
  geom_point(aes(x=estimates, color=estimate_sgn, alpha=significant)) +
  scale_colour_manual(values=c('blue', 'red','black')) +
  geom_segment(aes(x=lower_qts, y=grammatical_vars, xend=higher_qts, yend=grammatical_vars, alpha=significant)) +
  xlab('slope estimate') +
  ylab('grammatical classifications') +
  theme_classic() 

dev.off()


# another graph showing the mean posterior distribution of each classification, binned by their category
pdf('../imgs/supp_posterior_estimate.pdf', height=10, width=15)
ggplot(compiled_res %>%
      mutate(classification_finegrained = factor(classification_finegrained, levels=c('M', 'Ms', 'mS', 'S'))), 
      aes(x=estimates, fill=classification_finegrained)) +
  facet_grid(rows=vars(classification_finegrained), scale='free_y') +
  geom_density(alpha=0.7) +
  geom_vline(xintercept=0,linetype='dashed') +
  xlab('posterior mean') + 
  theme_classic(18) 

dev.off()

