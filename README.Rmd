---
title: "README"
author: "Hannah Park"
date: "11/17/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

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


## Run Repo from R Stuido  
```{r}
library(shiny)
runGitHub(repo = "ST558-Project3", username = "hyeonhpark", ref = "main", subdir = "/HeartFailure/", launch.browser = TRUE)
```

