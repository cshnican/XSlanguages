library(ape)
library(geoR)
library(brms)
library(glue)
library(tidyverse)
library(ggplot2)

num <- as.numeric(commandArgs(trailingOnly=TRUE))

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
