# Linguistic correlates of societal variation: A quantitative analysis
Sihan Chen, David Gil, Sergey Gaponov, Jana Reifegerste, Tessa Yuditha, Tatiana Tatarinova, Ljiljana Progovac, and Antonio Benitez-Burraco

This Github repository contains the data, the analysis script, and the figures in the paper.

## A description of the repository content

### Data
This folder contains the data used in our analysis:
- sociopolitical features from D-Place (Kirby et al., 2016): {B014, EA031, EA033, EA202, SCCS150, SCCS156}.csv
- database of 2000+ languages maintained by David Gil, containing each language's Glottocode (Hammarström et al., 2022), family size from Glottocode, EGIDS value from Ethnologue (Eberhard et al., 2022), and the family each language belongs to according to Glottocode: exotericity.csv
- information of each language from WALS (Dryer and Haspelmath, 2013), including their coordinates: languages.csv
- a collection of WALS features of each language: wals_compiled.csv
- a classification on whether each feature classification pertains to morphology, syntax, or a mixture of morphology and syntax, by Antonio Benitez-Burraco, David Gil, and Ljiljana Progovac: LP WALS_test_final_morph_vs_syntax, LP+ABB.csv
- phylogenical information of languages in the EDGE tree (Bouckaert et al., 2022), taken from Shcherbakova et al. (2023): wrangled.tree
- resulting main tables to be used in our analysis: compiled_table_20231010.csv, compiled_table_20231213_pca.csv