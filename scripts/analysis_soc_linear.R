library(ape)
library(geoR)
library(brms)
library(glue)
library(tidyverse)
library(ggplot2)

#num <- as.numeric(commandArgs(trailingOnly=TRUE))


tree <- ape::read.tree("../Data/wrangled.tree")

A <- vcv.phylo(tree, corr=TRUE)

d_final <- read.csv('../Data/compiled_table_20231010.csv') %>% 
  cbind(read.csv('../Data/compiled_table_20231213_pca.csv') %>% select(-Language, -Glottocode)) %>%
  filter(!is.na(Glottocode), !is.na(Longitude), !is.na(Latitude),
                        Glottocode %in% tree$tip.label,
                        ) %>%
  distinct() %>%
  group_by(Glottocode) %>% slice_sample(n=1) %>% # temporary solution
  mutate(Glottocode2 = Glottocode) %>%
  select(-Glottocode_original, -EGIDSorig, -family_Glottolog, -ID_WALS,
         -name_WALS, -ISO639P3code, -Subfamily, -Genus, -ISO_codes, -Samples_100, -Samples_200,
         -Country_ID, -language_name, -language_family_DPlace, -starts_with('code_label_'))

kappa = 1 
phi_1 = c(1, 1.25) # "Local" version: (sigma, phi) First value is not used

spatial_covar_mat_local = varcov.spatial(d_final[,c("Longitude", "Latitude")], cov.pars = phi_1, kappa = kappa)$varcov
dimnames(spatial_covar_mat_local) = list(d_final$Glottocode2, d_final$Glottocode2)
spatial_covar_mat_local <- spatial_covar_mat_local / max(spatial_covar_mat_local)


social_vs <- c("PC1")


grammatical_var_info <- read_csv('../Data/LP WALS_test_final_morph_vs_syntax, LP+ABB.csv') %>%
  filter(classification_binary %in% c('S', 'M')) %>%
  mutate(
    chapter = as.numeric(str_extract(feature_name, '\\d+')),
    label_r = paste0(gsub('[^A-Za-z0-9]', '\\.', label), '_',chapter),
    label_r = ifelse(label_r == '.and..and..with...identical...different._63', 'X.and..and..with...identical...different._63', label_r),
    num_levels = str_count(complexity_tier, '<') + 1)

grammatical_var_logistics <- grammatical_var_info %>%
  filter(num_levels == 2) %>%
  pull(label_r)

grammatical_var_linear <- grammatical_var_info %>%
  filter(num_levels > 2) %>%
  pull(label_r)

# do a bunch of linear regressions
for (social_var in social_vs){
  for (grammatical_var in grammatical_var_linear){
    f = glue('{grammatical_var} ~ {social_var} + (1 | gr(Glottocode2, cov=spatial_covar_mat_local)) + (1 | gr(Glottocode, cov=A))')
    print(f)
    output_name = paste0('../',gsub('\\.','_',glue('output_data_pca/{social_var}_{grammatical_var}')),'.RData')
    model <- brm(data=d_final,
      data2=list(A=A, spatial_covar_mat_local=spatial_covar_mat_local),
      family = 'gaussian',
      formula = as.formula(f),
      control = list(adapt_delta = 0.95),
      iter=4000,
      cores=4
    )
    save(model, file=output_name)
  }
}
  
