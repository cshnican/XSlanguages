library(ape)
library(geoR)
library(brms)
library(glue)
library(tidyverse)
library(ggplot2)

# helper function
get_complexity_tier <- function(code, value){
  # code: David's complexity tier values (e.g. '1<2<3/4<5') as strings
  # value: the WALS feature value (e.g. 1,2,...) as numerals
  loc_value = unlist(gregexpr(as.character(value), code))[1]
  if (loc_value != -1){
    substring = str_sub(code, 1, loc_value)
    if (!grepl('~', substring)){
      tiernum = str_count(substring, '<') # start from 0
      return(tiernum)
    } else {
      tiernum = str_count(substring, '~') # start from 0
      return(tiernum)
    }
  } else {
    return(NA)
  }
  
}

glottocode <- read.csv('../Data/exotericity.csv') %>% rename(EGIDSorig = EGIDS) %>% rowwise() %>% mutate(Glottocode = ifelse(Glottocode == 'Ø', NA, Glottocode),
                                                                   EGIDSorig = gsub('\\*', '', EGIDSorig),
                                                                   EGIDS = case_when(
                                                                     EGIDSorig == '0' ~ 13,
                                                                     EGIDSorig == '1' ~ 12,
                                                                     EGIDSorig == '2' ~ 11,
                                                                     EGIDSorig == '3' ~ 10,
                                                                     EGIDSorig == '4' ~ 9,
                                                                     EGIDSorig == '5' ~ 8,
                                                                     EGIDSorig == '6a' ~ 7,
                                                                     EGIDSorig == '6b' ~ 6,
                                                                     EGIDSorig == '7' ~ 5,
                                                                     EGIDSorig == '8a' ~ 4,
                                                                     EGIDSorig == '8b' ~ 3,
                                                                     EGIDSorig == '9' ~ 2,
                                                                     EGIDSorig == '10' ~ 1
                                                                   ),
                                                                   EGIDSnat = case_when(
                                                                     EGIDSorig %in% c("0", '1') ~ 2,
                                                                     EGIDSorig %in% c("2", '3', "4", "5", "6a",
                                                                                      "6b", "7", "8a", "8b", "9", "10") ~ 1,
                                                                   )) %>%
  ungroup() # from glottologue

languages <- read.csv('../Data/languages.csv') # language information from WALS

ea023 <- read.csv('../Data/EA023.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA023 = code,
                                          code_label_EA023 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA023, code_label_EA023) # from D-Place feature EA023

ea024 <- read.csv('../Data/EA024.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA024 = code,
                                          code_label_EA024 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA024, code_label_EA024) # from D-Place feature EA024

ea025 <- read.csv('../Data/EA025.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA025 = code,
                                          code_label_EA025 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA025, code_label_EA025) # from D-Place feature EA025


ea033 <- read.csv('../Data/EA033.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA033 = code,
                                          code_label_EA033 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA033, code_label_EA033) # from D-Place feature EA033


ea031 <- read.csv('../Data/EA031.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA031 = code,
                                          code_label_EA031 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA031, code_label_EA031)

ea202 <- read.csv('../Data/EA202.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_EA202 = code,
                                          code_label_EA202 = code_label) %>%
  mutate(code_EA202 = log(code_EA202)) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_EA202, code_label_EA202)


sccs156 <- read.csv('../Data/sccs156.csv') %>% rename(Glottocode = language_glottocode,
                                          society_name_DPlace = society_name,
                                          language_family_DPlace = language_family,
                                          code_SCCS156 = code,
                                          code_label_SCCS156 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_SCCS156, code_label_SCCS156)

sccs150 <- read.csv('../Data/sccs150.csv') %>% rename(Glottocode = language_glottocode,
                                              society_name_DPlace = society_name,
                                              language_family_DPlace = language_family,
                                              code_SCCS150 = code,
                                              code_label_SCCS150 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_SCCS150, code_label_SCCS150)

b014 <- read.csv('../Data/b014.csv') %>% rename(Glottocode = language_glottocode,
                                              society_name_DPlace = society_name,
                                              language_family_DPlace = language_family,
                                              code_B014 = code,
                                              code_label_B014 = code_label) %>%
  select(Glottocode, society_name_DPlace, language_name, language_family_DPlace, code_B014, code_label_B014)

wals <- read.csv('../Data/wals_compiled.csv') %>% #filter(chapter %in% c(1, 19, 13, 30, 66, 28, 110)) %>% 
  filter(str_extract(feature_ID, '[A-Z]') == 'A') %>%
  rename(ID_WALS = Language_ID) %>% select(ID_WALS, feature_ID, Value, chapter) 

wals_code <- read_csv('../Data/LP WALS_test_final_morph_vs_syntax, LP+ABB.csv') %>% 
  filter(!is.na(label)) %>% 
  mutate(chapter = as.numeric(str_extract(feature_name, '\\d+')),
         test = complexity_tier) %>%
  select(-complexity_tier) %>%
  left_join(wals, by = 'chapter') %>% rowwise() %>%
  mutate(complexity_level = get_complexity_tier(test, Value),
         feature_test = paste0(label, "_", chapter)) %>% ungroup() %>%
  filter(!is.na(complexity_level),
         classification_binary %in% c("S", "M")) %>% 
  select(ID_WALS, feature_test, complexity_level) %>%
  pivot_wider(id_cols = ID_WALS, names_from = feature_test, values_from = complexity_level)


d <- glottocode %>% left_join(languages, by = 'Glottocode') %>% rename(ID_WALS = ID,
                                                                       name_WALS = Name,
                                                                       family_WALS = Family,
                                                                       family_Glottolog = Family.Glottolog,
                                                                       macroarea_WALS = Macroarea) %>% select(-Source,
                                                                                                        -GenusIcon,
                                                                                                        Samples_100,
                                                                                                        Samples_200,
                                                                                                        Country_ID,
                                                                                                        -family_WALS) %>%
  mutate(same_language_name = Language == name_WALS) %>%
  
  left_join(ea033, by = 'Glottocode') %>% 
  left_join(ea023, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>% 
  left_join(ea024, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>% 
  left_join(ea025, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>% 
  left_join(ea031, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>% 
  left_join(ea202, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>%
  left_join(sccs156, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>%
  left_join(sccs150, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>%
  left_join(b014, by = c('Glottocode', 'language_name', 'language_family_DPlace', 'society_name_DPlace')) %>%
  left_join(wals_code, by = c('ID_WALS')) %>%
  select(-note, -Polity_Complexity_Rank, -polity_complexity, -macroarea_WALS, -same_language_name)

write.csv(d, '../Data/compiled_table_20231010.csv', row.names = FALSE)

tree <- ape::read.tree("../Data/wrangled.tree")

A <- vcv.phylo(tree, corr=TRUE)

d_final <- read.csv('../Data/compiled_table_20231010.csv') %>% filter(!is.na(Glottocode), !is.na(Longitude), !is.na(Latitude),
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


social_vs <- c("family_size_glottolog",                                                                                                    
  "EGIDS",                                                                                                                    
  "EGIDSnat",                                                                                                                 
  "code_EA033",                                                                                                               
  "code_EA023",                                                                                                               
  "code_EA024",                                                                                                               
  "code_EA025",                                                                                                               
  "code_EA031",                                                                                                               
  "code_EA202",                                                                                                               
  "code_SCCS156",                                                                                                             
  "code_SCCS150",                                                                                                             
  "code_B014")


grammatical_var_info <- read_csv('../Data/LP WALS_test_final_morph_vs_syntax, LP+ABB.csv') %>%
  filter(classification_binary %in% c('S', 'M')) %>%
  mutate(
    chapter = as.numeric(str_extract(feature_name, '\\d+')),
    label_r = paste0(gsub('[^A-Za-z]', '\\.', label), '_',chapter),
    label_r = ifelse(label_r == '.and..and..with...identical...different._63', 'X.and..and..with...identical...different._63', label_r),
    num_levels = str_count(complexity_tier, '<') + 1)

grammatical_var_logistics <- grammatical_var_info %>%
  filter(num_levels == 2) %>%
  pull(label_r)

grammatical_var_linear <- grammatical_var_info %>%
  filter(num_levels > 2) %>%
  pull(label_r)

# do a bunch of logistics regressions
for (social_var in social_vs[2]){
  for (grammatical_var in grammatical_var_logistics){
    f = glue('{grammatical_var} ~ {social_var} + (1 | gr(Glottocode2, cov=spatial_covar_mat_local)) + (1 | gr(Glottocode, cov=A))')
    print(f)
    output_name = paste0('../',gsub('\\.','_',glue('output_data/{social_var}_{grammatical_var}')),'.RData')
    model <- brm(data=d_final,
      data2=list(A=A, spatial_covar_mat_local=spatial_covar_mat_local),
      family = 'bernoulli',
      formula = as.formula(f),
      control = list(adapt_delta = 0.95),
      iter=4000,
      cores=4
    )
    save(model, file=output_name)
  }
}
  
