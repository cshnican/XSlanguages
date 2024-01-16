library(tidyverse)

pth <- '../output_data_pca_global'
files <- dir(pth, pattern='*.RData')

# d_final <- read.csv('../Data/compiled_table_20231010.csv') %>% ungroup()

social_vars <- c()
grammatical_vars <- c()
estimates <- c()
p_values <- c()
numbers_of_observations <- c()
lower_qts <- c()
higher_qts <- c()

for (file in files){
    load(paste0(pth, '/', file))
    grammatical_var <- as.character(model$terms[[2]]) 
    social_var <- as.character(model$terms[[3]])
    number_of_observations <- nobs(model)

    social_vars <- c(social_vars, social_var)
    grammatical_vars <- c(grammatical_vars, grammatical_var)
    numbers_of_observations <- c(numbers_of_observations, number_of_observations)

    b <- summary(model)

    #print(b$coefficients[2,1])
    #print(b$coefficients[2,4])

    estimate <- b$coefficients[2,1]
    p_value <- b$coefficients[2,4]
    lower_qt <- estimate - 1.96*b$coefficients[2,2]
    higher_qt <- estimate + 1.96*b$coefficients[2,2]

    estimates <- c(estimates, estimate)
    p_values <- c(p_values, p_value)
    lower_qts <- c(lower_qts, lower_qt)
    higher_qts <- c(higher_qts, higher_qt)
}

df <- tibble(
    social_vars = social_vars,
    grammatical_vars = grammatical_vars,
    estimates = estimates,
    lower_qts = lower_qts,
    higher_qts = higher_qts,
    p_values = p_values,
    numbers_of_observations = numbers_of_observations
)

write.csv(df, '../output_table/fixefs_pca_global.csv', row.names=FALSE)

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

compiled_res_global <- df %>% 
  left_join(grammatical_var_info %>% select(
    feature_name, label_r, classification_binary, classification_finegrained, chapter
  ) %>%
    rename(
      grammatical_vars = label_r
    ), by = 'grammatical_vars')

pdf('../imgs/fig2.pdf', height=20, width=15)

ggplot(compiled_res_global %>% 
         mutate(relatioship_sign=ifelse(estimates<0, 'negative', ifelse(estimates>0, 'positive', 'zero')),
                significant = p_values < 0.05,
                significant_levels = case_when(
                  p_values >= 0.01 & p_values < 0.05 ~ '<0.05',
                  p_values < 0.01 & p_values >= 0.001 ~ '<0.01',
                  p_values < 0.001 ~ '<0.001',
                  TRUE ~ 'n.s.'
                ),
                significant_levels = factor(significant_levels, levels = c('n.s.', '<0.05', '<0.01', '<0.001')),
                classification_binary = ifelse(classification_binary == 'M', 'morphology', 'syntax')
                ), 
        aes(y=reorder(grammatical_vars, -chapter)),
        ) +
  #facet_grid(rows = vars(classification_binary), cols = vars(social_vars), scales = 'free') +
  facet_grid(classification_binary + classification_finegrained ~ social_vars, space='free_y', scales='free') +
  geom_vline(xintercept = 0, linetype='dashed') +
  geom_point(aes(x=estimates, color=relatioship_sign, alpha=significant, shape=significant_levels)) +
  geom_segment(aes(x=lower_qts, y=grammatical_vars, xend=higher_qts, yend=grammatical_vars, alpha=significant)) +
  ylab('grammatical classifications') +
  xlab('slope estimate')+
  scale_colour_manual(values=c('blue', 'red','black')) +
  theme_classic() 

dev.off()