#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            
            # Plot: Histogram
            h3("Histogram Attributes"),
            selectizeInput("quantVar", "Select Variable", 
                           choices = list("Age", "CPK", "Ejection Fraction", "Platelets", "Serum Creatinine", "Serum Sodium", "Follow-up Period"), 
                           selected = "Age"),
            checkboxInput("survival", h4("Compare Deceased vs. Survived")),
            
            sliderInput("bins", "Size of bins",
                        min = 10, max = 40, value = 25),
            br(),
            
            # Table: Quantitative Summary
            h3("Table Attributes"),
            selectInput("varType", "Select Variable Type",
                        choices = list("Qualitative", "Quantitative"),
                        selected = "Quantitative"),
            
            conditionalPanel(condition = "input.varType == 'Qualitative'",
                             selectizeInput("qualVar", "Select Variable", 
                                            choices = list("Anaemia", "Diabetes", "High Blood Pressure", "Sex", "Smoking"), 
                                            selected = "Anaemia"),
                             checkboxInput("addmargins", "Show marginal total?"))
            
            
        ),
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("histPlot")
        )
    )
))
