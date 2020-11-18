#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)


dashboardPage(
    #add title
    dashboardHeader(title="Heart failure clinical records",titleWidth=1000),

    #define sidebar items
    dashboardSidebar(sidebarMenu(
        menuItem("Info Page", tabName = "info", icon = icon("archive")),
        menuItem("Exploratory Data Analysis", tabName = "eda"),
        menuItem("Unsupervised", tabName = "unsuperv"),
        menuItem("Supervised", tabName = "superv"),
        menuItem("Data", tabName = "data")
        )
    ),

    #define the body of the app
    dashboardBody(
        tabItems(

            #Info Page
            tabItem(tabName = "info",

                    fluidPage(
                        # Application title
                        titlePanel(""),

                        # Sidebar with a slider input for number of bins
                        sidebarLayout(
                            sidebarPanel(),

                            # Show a plot of the generated distribution
                            mainPanel()
                        )
                    )
            ),


            #Exploratory Data Analysis Page Layout
            tabItem(tabName = "eda",

                    fluidPage(
                        # Application title
                        titlePanel("FIX THIS: Old Faithful Geyser Data"),

                        # Sidebar with a slider input for number of bins
                        sidebarLayout(
                            sidebarPanel(
                                # Plot: Histogram
                                h3("Histogram Attributes"),
                                selectizeInput("quantVar", "Select Variable",
                                               choices = list("Age", "CPK", "Ejection Fraction", "Platelets",
                                                              "Serum Creatinine", "Serum Sodium", "Follow-up Period"),
                                               selected = "Age"),
                                checkboxInput("survival", h4("Compare Deceased vs. Survived")),

                                sliderInput("bins", "Size of bins",
                                            min = 10, max = 40, value = 25),
                                br(),
                                br(),
                                br(),
                                br(),
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
                                plotOutput("histPlot"),

                                br(),
                                br(),

                                verbatimTextOutput("desctable")
                            )
                        )
                    )
            ),


            #Unsupervised Learning
            tabItem(tabName = "unsuperv",

                    fluidPage(
                        # Application title
                        titlePanel(""),

                        verbatimTextOutput("PCAsummary"),
                        plotOutput("PVEplot"),

                        br(),

                        h4("Brush and double-click to zoom"),
                        plotOutput("PCAbiPlot",
                                   dblclick = "PCAbiPlot_dblclick",
                                   brush = brushOpts(
                                       id = "PCAbiPlot_brush",
                                       resetOnNew = TRUE
                                   ))
                    )
            ),


            #Supervised Learning
            tabItem(tabName = "superv",

                            fluidPage(tabsetPanel(
                                tabPanel("Logistic Regression",
                                         sidebarLayout(
                                             sidebarPanel(
                                                 # Logistic Regression Options
                                                 h3("Model: Logistic Regression"),
                                                 selectInput("logitModel", "Select Model",
                                                             choices = list("Full Model", "Best-Subset Model"),
                                                             selected = "Full Model")
                                                 ),

                                             # Show a plot of the generated distribution
                                             mainPanel(

                                                 verbatimTextOutput("logitSummary")
                                             )
                                         )
                                ),

                                tabPanel("Random Forest",
                                         sidebarLayout(
                                             sidebarPanel(

                                                 h3("Model: Random Forest"),
                                                 numericInput("ntree", "Number of Trees",
                                                              value = 500, min = 200, max = 1000, step = 100)
                                             ),

                                             # Show a plot of the generated distribution
                                             mainPanel(

                                                 verbatimTextOutput("rfSummary"),
                                                 plotOutput("rfVarImpPlot")

                                             )
                                         )
                                ),

                                tabPanel("Prediction",

                                         fluidPage(
                                             fluidRow(column(width = 12,
                                                             h3("Model Selection"),
                                                             selectInput("model", "Select Model for Prediction",
                                                                         choices = list("Logistic Full Model", "Logistic Best-Subset Model", "Random Forest Model"),
                                                                         selected = "Logistic Full Model"))),

                                             fluidRow(column(width = 4,
                                                             h3("Quantitative Variable Input Panel"),
                                                             sliderInput("age", "Age of patient (years)",
                                                                         value = 60, min = 40, max = 100, step = 1),
                                                             sliderInput("CPK", "Level of CPK enzyme in blood(mcg/L)",
                                                                         value = 580 , min = 20, max = 1000, step = 20),
                                                             sliderInput("EF", "% of blood leaving the heart at each contraction (%)",
                                                                         value = 40, min = 10, max = 80, step = 20),
                                                             sliderInput("platelets", "Platelets in the blood (kiloplatelets/mL)",
                                                                         value = 250, min = 25, max = 900, step = 25),
                                                             sliderInput("serumC", "Level of serum creatinine in blood (mg/dL)",
                                                                         value = 1.5, min = 0.5, max = 10, step = 0.5),
                                                             sliderInput("serumS", "Level of serum sodium in blood(mEq/L)",
                                                                         value = 135, min = 110, max = 150, step = 5),
                                                             sliderInput("time", "Follow-up Period (days)",
                                                                         value = 130, min = 1, max = 290, step = 10)),
                                                      column(width = 4,
                                                             h3("Qualitative Variable Input Panel"),
                                                             radioButtons("anaemia", "Has anaemia?",
                                                                          choices = list("Yes" = 1, "No" = 2), selected = 1),
                                                             radioButtons("diabetes", "Has diabetes?",
                                                                          choices = list("Yes" = 1, "No" = 2), selected = 1),
                                                             radioButtons("HBP", "Has high blood pressure?",
                                                                          choices = list("Yes" = 1, "No" = 2), selected = 1),
                                                             radioButtons("sex", "Sex",
                                                                          choices = list("Male" = 1, "Female" = 2), selected = 1),
                                                             radioButtons("smoking", "Smoking History",
                                                                          choices = list("Yes" = 1, "No" = 2), selected = 1))),
                                             fluidRow(column(width = 12,
                                                             h3("Selected Input and Prediction Result"),
                                                             tableOutput("predictTbl")))
                                         )

                                )


                        ))
                    ),

            #Data
            tabItem(tabName = "data",
                    DT::dataTableOutput("obs")
            )
        )
    )
)



