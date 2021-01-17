# ST558 Project 3  

## Purpose of the Repo  
This repository was created to keep track of my work related to Project 3 for ST558 at NCSU (Fall 2020). This project involved creating a shiny app that can be used to explore data and model it. Data used for the analysis is from the heart failure clinical records data set, which is publicly available in [https://archive.ics.uci.edu/ml/datasets/Heart+failure+clinical+records#].  

## Required Packages   

`shiny` - Create shiny app.  
`shinydashboard` - Utilize tabs in the app.  
`dplyr` - Data manipulation.  
`DT` - Create data tables.  
`knitr` - Generate report.  
`ggplot2` - Create exploratory plots.  
`ggfortify` - Create analysis plots.  
`bestglm` - Perform best subset selection analysis.  
`randomForest` - Perform random forest classification analysis.  

## Download Required Packages  
```{r}
## Packages of interest
packages = c("shiny", "shinydashboard", "dplyr", "DT", "knitr", 
             "ggplot2", "ggfortify", "bestglm", "randomForest")

## Load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)
```


## Run Repo from R Studio
```{r}
library(shiny)
runGitHub(repo = "ST558-Project3", username = "hyeonhpark", 
          ref = "main", subdir = "/HeartFailure/", launch.browser = TRUE)
```

