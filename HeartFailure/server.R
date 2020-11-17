#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)

# Read In Data
URL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00519/heart_failure_clinical_records_dataset.csv"
df <- read.csv(URL) %>%
    mutate(platelets = round(platelets/1000,2))
# colnames(df) <- c("Age", "Anaemia", "CPK", "Diabetes", "Ejection Fraction",
#                  "Blood Pressure", "Platelets", "Creatinine", "Sodium", "Sex",
#                  "Smoking", "Time", "Survival")


shinyServer(function(input, output) {

#EDA
    #create plot
    output$histPlot <- renderPlot({

        df <- df %>%
            mutate(DEATH_EVENT = ifelse(DEATH_EVENT == 1, "Deceased", "Survived"))

        var <- switch(input$quantVar,
                      "Age" = df$age,
                      "CPK" = df$creatinine_phosphokinase,
                      "Ejection Fraction" = df$ejection_fraction,
                      "Platelets" = df$platelets,
                      "Serum Creatinine" = df$serum_creatinine,
                      "Serum Sodium" = df$serum_sodium,
                      "Follow-up Period" = df$time)

        label <- switch(input$quantVar,
                        "Age" = "Age of patient (years)",
                        "CPK" = "Level of CPK enzyme in blood(mcg/L)",
                        "Ejection Fraction" = "% of blood leaving the heart at each contraction (%)",
                        "Platelets" = "Platelets in the blood (kiloplatelets/mL)",
                        "Serum Creatinine" = "Level of serum creatinine in blood (mg/dL)",
                        "Serum Sodium" = "Level of serum sodium in blood(mEq/L)",
                        "Follow-up Period" = "Follow-up Period (days)")

        g <- ggplot(df, aes(x = var)) +
            geom_histogram(bins = input$bins) +
            xlab(label) +
            theme(axis.title = element_text(size = 15))

        if(input$survival){
            g  + facet_wrap(~DEATH_EVENT, scales = "free")
        } else {
            g
        }
    })


    #create table
    #summary statistics on variable selected by user rounded to the digit also selected by user
    output$desctable <- renderPrint({
      qual.var <- switch(input$qualVar,
                    "Anaemia" = df$anaemia,
                    "Diabetes" = df$diabetes,
                    "High Blood Pressure" = df$high_blood_pressure,
                    "Sex" = df$sex,
                    "Smoking" = df$smoking)

      if(input$varType == "Quantitative"){
        df.quant <- df %>%
          select(age, creatinine_phosphokinase, ejection_fraction, platelets, serum_creatinine, serum_sodium, time)
        summary(df.quant)
        } else{
          if(input$addmargins){
            addmargins(table(qual.var, df$DEATH_EVENT))
            } else{
              table(qual.var, df$DEATH_EVENT)
              }
          }
      })

# Data

    #create output of observations
    output$obs <- renderTable({
      df
    })

})
