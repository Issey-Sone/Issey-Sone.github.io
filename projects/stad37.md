<!--
code: https://github.com/Issey-Sone/STAD37-Dashboards
link: https://issey-sone.github.io/STAD37-Dashboards/
-->
# STAD37 Methods of Multivariate Statistics Visualization Tools

*UofT Work Study Project under <a href="https://www.utsc.utoronto.ca/cms/shahriar-shams" class="accent-link">Prof. Shahriar Shams</a>, Summer 2025.*

![Bivariate Normality Assumption Tool](assets/images/D37.png)

## Summary
A set of statistical visualization tools for STAD37 - Multivariate Analysis made in R and RShiny. There are ten dashboards that cover various topics in the course. Such topics include but not limited to: Bivariate Normal distribution, Wishart Distribution, PCA, and Clustering. These tools were used to help students understand the material of the course in Fall 2025. The best way to run these interactive dashboards is through the ```runGist()``` command in the ```shiny``` library. The link is usually slow since Shinyapps.io is slow, and getting the dashboards on the school server is currently in the works. 
## Example Run
Run the following in an R terminal to install all the required packages. 
```
required_packages <- c(
  "tidyverse", "MASS", "shiny", "shinythemes", "plotly",
  "ellipse", "scales", "bslib", "ggforce", "patchwork",
  "metR", "mvtnorm", "DT", "readr", "gridExtra", "gganimate",
  "av", "gifski", "mclust", "factoextra", "corrplot"
)
installed <- rownames(installed.packages())
to_install <- setdiff(required_packages, installed)
if (length(to_install) > 0) {
  install.packages(to_install)
} else {
  message("All packages are already installed.")
}
```
If I wanted to run the classification dashboard tool you would run the following in an R terminal. 
```
runGist("b5db594b11236d9cd94ccd50203de99a") 
```

## Libraries and Frameworks
 - R
 - RShiny
 - Tidyverse


