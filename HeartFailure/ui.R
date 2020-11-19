library(shiny)
library(shinydashboard)

dashboardPage(
    #add title
    dashboardHeader(title="ST558 Project 3"),

    #define sidebar items
    dashboardSidebar(sidebarMenu(
        menuItem("Info Page", tabName = "info"),
        menuItem("Exploratory Data Analysis", tabName = "eda"),
        menuItem("Unsupervised Learning - PCA", tabName = "unsuperv"),
        menuItem("Supervised Learning & Prediction", tabName = "superv"),
        menuItem("Data", tabName = "data")
        )
    ),

    #define the body of the app
    dashboardBody(
        tabItems(

            #Info Page
            tabItem(tabName = "info",

                    fluidRow(
                        column(
                            width = 5,

                            #Description of App
                            h1("What does this app do?"),
                            #box to contain description
                            box(
                                width=12,
                                h4("This application analyzes a dataset of 299 patients with heart failure collected in 2015. Detailed description of the data is provided on the right."),
                                h4("Plots and tables are generated in the ",span("Exploratory Data Analysis (EDA) ",style = "font-style:italic"), "section to visualize the distribution of the different variables, and principal component analysis (PCA) is performed in the " ,span("Unsupervised Learning ",style = "font-style:italic"), "section to study the relationship between the predictor variables."),
                                h4("Two supervised learning methods are applied to a training data set, and the resulting models are used to make predictions about the test data set. A subsection is available in the " ,span("Supervised Learning ",style = "font-style:italic"), "section for a user to use the models for predicting the outcome of a random patient with predictor values selected by the user."),
                                h4("The original data set is available online at the",
                                   tags$a(href="https://archive.ics.uci.edu/ml/datasets/Heart+failure+clinical+records#", " UCI Machine Learning Repository."), "The data can be also accessed through this app via the " ,span("Data ",style = "font-style:italic"), "section.")
                            )
                        ),

                        column(
                            width = 7,

                            #Description of Variables
                            h1("Data Description"),
                            #box to contain description
                            box(
                                width = 12,
                                h4("The Heart Failure Clinical Records data set contains medical records of 299 patients who had heart failure. The data was collected during the patients' follow-up period, and each patient profile has 13 clinical features. The 13 clinical features are as follows: ",
                                   tags$ul(
                                       tags$li("age: age of the patient (years)"),
                                       tags$li("anaemia: decrease of red blood cells or hemoglobin (boolean)"),
                                       tags$li("high blood pressure: if the patient has hypertension (boolean)"),
                                       tags$li("creatinine phosphokinase (CPK): level of the CPK enzyme in the blood (mcg/L)"),
                                       tags$li("diabetes: if the patient has diabetes (boolean)"),
                                       tags$li("ejection fraction: percentage of blood leaving the heart at each contraction (percentage)"),
                                       tags$li("platelets: platelets in the blood (kiloplatelets/mL)"),
                                       tags$li("sex: woman or man (binary)"),
                                       tags$li("serum creatinine: level of serum creatinine in the blood (mg/dL)"),
                                       tags$li("serum sodium: level of serum sodium in the blood (mEq/L)"),
                                       tags$li("smoking: if the patient smokes or not (boolean)"),
                                       tags$li("time: follow-up period (days)"),
                                       tags$li("[target] death event: if the patient deceased during the follow-up period (boolean)")
                                   )
                                )
                            )
                        )
                    ),

                    fluidRow(
                        column(
                            width = 12,

                            #Explanation of controls
                            h1("How to navigate this app"),
                            #box to contain description
                            box(
                                width = 12,
                                h4("The controls for the app are generally located on the left of each tab. Specific controls for each tab are described below: "),

                                h3("Exploratory Data Anlaysis (EDA)"),
                                h4("There are two features on the EDA section: plot and table. The first provides a histogram of each of the quantitative variables from the data. You can select the variable for the histogram from the dropdown menu and click the box below to generate separate histograms for patients who died during the follow-up period and patients who survived. You can also change the bin size of the histograms using the slider. The bin size changes in increments of 5."),
                                h4("The second feature of the EDA section is a table. You can generate two different types of tables based on the variable type. By default, the table displays summary statistics of all quantitative variables. Choosing the ", span("Qualitative variable type ", style = "font-style:italic"), "from the dropdown menu will prompt another dropdown menu for selecting a specific qualitative variable to view a contingency table. The contingency table displays the frequency distribution of the selected qualitative variable and the target variable (DEATH_EVENT: whether a patient died during their follow-up period). You can check the box below variable selection to add marginal sums to the contingency table."),

                                h3("Unsupervised Learning - PCA"),
                                h4("An option to only select the quantitative variables is available for the principal component analysis at the top of the Unsupervised Learning section. It is possible to zoom in on the PCA biplot by selecting and double clicking on a region. A second double-click returns the plot to default."),

                                h3("Supervised Learning & Prediction"),
                                h4("The first two tabs of the Supervise Learning & Prediction section provide the summary of model fits for the logistic regression model and the random forest classification model, respectively. For the logistic regression results, you can select one of the two models that were used to fit the data from the dropdown menu: full model with all 12 predictor variables vs. best subset selection. For the random forest classification results, you can select the number of trees used to fit the data. For both methods, the confusion matrix and the error rate are provided on the bottom left. You can select the type of error rate from the dropdown menu."),
                                h4("The last tab of the Supervised Learning & Prediction section allows the users to input their own values for the predictor variables and choose one of the three models to make predictions about their selected predictor values. The result can be found at the bottom of the page in a data table format, along with the specific values the user selected for the predictor variables."),

                                h3("Data"),
                                h4("You can scroll through, subset, and filter the data on the Data section of this app. The filtered data set can be downloaded via the download button found at the top of the page."),
                                h4("By default, the data table on the Data section shows the first 10 observations of the full data set with an option to filter the data by each variable at the top of the data table. You can also subset the data with specific variables using the dropdown menu below the Download button.")
                            ),

                        )
                    )
            ),


            #Exploratory Data Analysis Page Layout
            tabItem(tabName = "eda",

                    fluidPage(

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
                                            min = 10, max = 35, value = 20, step = 5),
                                br(),
                                downloadButton(outputId = "down", label = "Download the histogram"),
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

                        checkboxInput("quantOnly", "Select only quantitative variables?"),

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
                                                             selected = "Full Model"),
                                                 br(),
                                                 br(),
                                                 selectInput("logitTest", "Training vs. Test Data",
                                                             choices = list("Training Data", "Test Data"),
                                                             selected = "Test Data"),
                                                 h3("Confusion Matrix"),
                                                 tableOutput("logitTestConf"),
                                                 h3("Error Rate"),
                                                 textOutput("logitTestError")
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
                                                              value = 500, min = 200, max = 1000, step = 100),
                                                 br(),
                                                 br(),
                                                 selectInput("rfTest", "Training vs. Test Data",
                                                             choices = list("Training Data", "Test Data"),
                                                             selected = "Test Data"),
                                                 h3("Confusion Matrix"),
                                                 tableOutput("rfTestConf"),
                                                 h3("Error Rate"),
                                                 textOutput("rfTestError")
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
                    fluidPage(
                        fluidRow(column(width = 12,
                                        downloadButton("downloadData", "Download Filtered Data"),
                                        br(),
                                        varSelectInput("vars", "Variable:",
                                                       read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/00519/heart_failure_clinical_records_dataset.csv"),
                                                       multiple = TRUE))),


                        fluidRow(column(width = 12,
                                        DT::dataTableOutput("obs")
                        ))
                    )
            )
    )
)
)


