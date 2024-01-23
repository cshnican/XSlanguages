# Linguistic correlates of societal variation: A quantitative analysis
Sihan Chen, David Gil, Sergey Gaponov, Jana Reifegerste, Tessa Yuditha, Tatiana Tatarinova, Ljiljana Progovac, and Antonio Benitez-Burraco

This Github repository contains the data, the analysis script, and the figures in the paper.

## A description of the repository content

### Data
This folder contains the data used in our analysis:
- sociopolitical features from D-Place (Kirby et al., 2016): `{B014, EA031, EA033, EA202, SCCS150, SCCS156}.csv`
- database of 2000+ languages maintained by David Gil, containing each language's Glottocode (Hammarström et al., 2022), family size from Glottocode, EGIDS value from Ethnologue (Eberhard et al., 2022), and the family each language belongs to according to Glottocode: `exotericity.csv`
- information of each language from WALS (Dryer and Haspelmath, 2013), including their coordinates: `languages.csv`
- a collection of WALS features of each language: wals_compiled.csv
- a classification on whether each feature classification pertains to morphology, syntax, or a mixture of morphology and syntax, by Antonio Benitez-Burraco, David Gil, and Ljiljana Progovac: `LP WALS_test_final_morph_vs_syntax, LP+ABB.csv`
- (deprecated) phylogenical information of languages in the EDGE tree (Bouckaert et al., 2022), taken from Shcherbakova et al. (2023): `wrangled.tree`
- phylogenical information of languages in the EDGE tree (Bouckaert et al., 2022): `new.tree`
- resulting main tables to be used in our analysis: `compiled_table_20231010.csv, compiled_table_20231213_pca.csv`

### imgs
This folder contains the images generated:
- loading plot: `fig1.pdf`
- global analysis results: `fig2.pdf`
- controlled analysis results: `fig3.pdf`
- posterior means of the controlled analysis: `fig4.pdf`

### output_table
This folder contains the main results:
- global analysis results: `fixefs_pca_global.csv`
- controlled analysis results: `fixefs_pca.csv`

### scripts
This folder contained the scripts conducting the analysis. Since the analysis was carried out on a computational cluster, for each script `*.R`, there's a bash script `*.sh` to run it on the cluster. The script `run_all.sh` runs everything in order. Below is a description of the files in the order they should be executed:

- `make_table.R`: it takes in all the data in the data folder and generates a compiled table `compiled_table_20231010.csv`
- `impute_soc_data.R`: it imputes the missing values in societal features, conducts a principal component analysis, and appends the results to the compiled table. The new compiled table is `compiled_table_20231213_pca.csv`
- `prune_tree.R`: it loads the global phylogenic tree generated in Bouckeart et al. (2022) and takes the subset of languages in our database. The resulting tree is `new.tree`.
- `analysis_soc_linear_global.R` / `analysis_soc_logic_global.R`: they perform a simple linear regression / logistic regression (hence the global analysis) between grammatical classifications and the principal component. The results are stored in the folder `output_data_pca_global`. NOTE: the output files are too big to be included on Github, so neither the files nor the directory was in this repository.
- `analysis_soc_linear.R` / `analysis_soc_logic.R`: they perform a Bayesian mixed-effects linear regression / logistic regression (hence the controlled analysis) between grammatical classifications and the principal component, controlling for language relatedness and geographical proximity. The results are stored in the folder `output_data_pca`. NOTE: the output files are too big to be included on Github, so neither the files nor the directory was in this repository.
- `extract_fit_global.R` / `extract_fit.R`: they read output files from the analysis, compiled them, and generate figures. The figues are stored in the `imgs` folder.
- `extract_fit_detailed.R`: it generates the fitted values for each grammatical classifications, given the model. NOTE: the output files are too big and are not discussed in the main paper, but they would be stored at `imgs/detailed`.






