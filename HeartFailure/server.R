# Required packages
library(shiny)
library(dplyr)
library(ggplot2)
library(knitr)
library(ggfortify)
library(randomForest)

# Read In Data
URL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00519/heart_failure_clinical_records_dataset.csv"
df <- read.csv(URL) %>%
    mutate(platelets = round(platelets/1000,2))


shinyServer(function(input, output, session) {

    #EDA

    # Histogram title
    output$histTitle <- renderText({
      paste("Histogram of Variable ", input$quantVar)
    })

    # Create histogram
    plotInput <- reactive({
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

        hist <- if(input$survival){
          g  + facet_wrap(~DEATH_EVENT, scales = "free")
        } else {
          g
        }
    })

    # Output histogram
    output$histPlot <- renderPlot({
        print(plotInput())
    })

    # Output download button for histogram
    output$down <- downloadHandler(
        filename = 'histogram.png',
        content = function(file) {
          png(file)
          print(plotInput())
          dev.off()
    })

    # Update histogram binsize slider based on user input for deceased vs. survived
    observeEvent(input$survival, {updateSliderInput(session, "bins",
                                                    min = if(input$survival == FALSE){10}else{15},
                                                    max = if(input$survival == FALSE){35}else{40})})


    # Table title
    output$EDAtbl <- renderText({
      if(input$varType == "Quantitative"){
        print("Summary Statistics of Quantitative Variables")
      } else{
        paste("Contingency Table: Variable ", input$qualVar, " X Patient Status")
        }
    })

    # Create table
    # Summary statistics on variable selected by user rounded to the digit also selected by user
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
            # Contingency table for the qualitative variables
            if(input$addmargins){

              df.cont <- as.data.frame(cbind(qual.var, df$DEATH_EVENT))
              colnames(df.cont) <- c(input$qualVar, "Patient Status")

              addmargins(table(df.cont[,1],df.cont[,2]))

              } else{
                df.cont <- as.data.frame(cbind(qual.var, df$DEATH_EVENT))
                colnames(df.cont) <- c(input$qualVar, "Patient Status")
                table(df.cont[,1],df.cont[,2])
                }
            }
    })


    # Unsupervised Learning
    # df of only quantitative predictor variables
    df.quant <- df %>%
    select(age, creatinine_phosphokinase, ejection_fraction, platelets,
           serum_creatinine, serum_sodium, time)


    # PCA Output
    output$PCAsummary <- renderPrint({
      if(input$quantOnly){
        pr.out <- prcomp(df.quant, scale = TRUE)
      } else{
        pr.out <- prcomp(df, scale = TRUE)
      }
      summary(pr.out)
    })

    # PVE Plot
    output$PVEplot <- renderPlot({

      if(input$quantOnly){
        pr.out <- prcomp(df.quant, scale = TRUE)
      } else{
        pr.out <- prcomp(df, scale = TRUE)
      }

      pr.var <- pr.out$sdev^2
      pve <- pr.var/sum(pr.var)

      par(mfrow = c(1,2))
      plot(pve, xlab = "Principal Component", ylab = "Proportion of Variance Explained (PVE)", type ="o", col = "blue")

      plot(cumsum(pve), type="o", ylab="Cumulative PVE", xlab="Principal Component", col="brown3")
    })

    # BiPlot
    ranges <- reactiveValues(x = NULL, y = NULL)
    df.biplot <- df
    df.biplot$PatientStatus <- ifelse(df$DEATH_EVENT == 1, "Deceased", "Survived")

    output$PCAbiPlot <- renderPlot({

      if(input$quantOnly){
        pr.out <- prcomp(df.quant, scale = TRUE)
      } else{
        pr.out <- prcomp(df, scale = TRUE)
      }

      autoplot(pr.out, data = df.biplot, colour = 'PatientStatus',
               loadings = TRUE, loadings.colour = "blue",
               loadings.label = TRUE, loadings.label.colour = "blue",
               loadings.label.size = 4) +
        coord_cartesian(xlim = ranges$x, ylim = ranges$y,
                        expand = FALSE)
    })

    observeEvent(input$PCAbiPlot_dblclick, {
      brush <- input$PCAbiPlot_brush
      if(!is.null(brush)){
        ranges$x <- c(brush$xmin, brush$xmax)
        ranges$y <- c(brush$ymin, brush$ymax)

      } else {
        ranges$x <- NULL
        ranges$y <- NULL
      }
    })


    # Supervised Learning

    # Separate training vs. test data sets
    set.seed(1)
    train <- sample(1:nrow(df), size = nrow(df)*.7)
    test <- dplyr::setdiff(1:nrow(df), train)

    df.train <- df[train, ]
    df.test <- df[test, ]

    # Logistic Model Tab Title
    output$logitTabTitle <- renderText({
      paste("Summary of ", input$logitModel, " Fit")
    })

    # Logistic Fit Summary
    output$logitSummary <- renderPrint({
      # Logitstic Model Fits
      glm.full <- glm(DEATH_EVENT ~., data = df.train, family = binomial)
      glm.best <- bestglm::bestglm(df.train, IC = "AIC")

      logitModel <- switch(input$logitModel,
                           "Full Model" = glm.full,
                           "Best-Subset Model" = glm.best$BestModel)
      summary(logitModel)

    })

    # Confusion Matrix
    output$logitTestConf <- renderTable({
      glm.full <- glm(DEATH_EVENT ~., data = df.train, family = binomial)
      glm.best <- bestglm::bestglm(df.train, IC = "AIC")

      logitModel <- switch(input$logitModel,
                           "Full Model" = glm.full,
                           "Best-Subset Model" = glm.best$BestModel)

      if(input$logitTest == "Test Data"){
        # Test Error Rate
        probs.best <- predict(logitModel, newdata = df.test,
                              type = "response")
        pred.best <- rep(0, nrow(df.test))
        pred.best[probs.best > 0.5] <- 1

        df.cont <- as.data.frame(cbind(pred.best, df.test$DEATH_EVENT))
        colnames(df.cont) <- c("Predicted", "Patient Status")
        table(df.cont$Predicted, df.cont$`Patient Status`)

      } else{
        # Training Error Rate
        probs.best <- predict(logitModel, newdata = df.train,
                              type = "response")
        pred.best <- rep(0, nrow(df.train))
        pred.best[probs.best > 0.5] <- 1

        df.cont <- as.data.frame(cbind(pred.best, df.train$DEATH_EVENT))
        colnames(df.cont) <- c("Predicted", "Patient Status")
        table(df.cont$Predicted, df.cont$`Patient Status`)      }

    })

    # Error Rates
    output$logitTestError <- renderText({
      glm.full <- glm(DEATH_EVENT ~., data = df.train, family = binomial)
      glm.best <- bestglm::bestglm(df.train, IC = "AIC")

      logitModel <- switch(input$logitModel,
                           "Full Model" = glm.full,
                           "Best-Subset Model" = glm.best$BestModel)

      if(input$logitTest == "Test Data"){
        # Test Error Rate
        probs.best <- predict(logitModel, newdata = df.test,
                              type = "response")
        pred.best <- rep(0, nrow(df.test))
        pred.best[probs.best > 0.5] <- 1

        tbl.best <- table(pred.best, df.test$DEATH_EVENT)
        1-sum(diag(tbl.best))/sum(tbl.best)
      } else{
        # Training Error Rate
        probs.best <- predict(logitModel, newdata = df.train,
                              type = "response")
        pred.best <- rep(0, nrow(df.train))
        pred.best[probs.best > 0.5] <- 1

        tbl.best <- table(pred.best, df.train$DEATH_EVENT)
        1-sum(diag(tbl.best))/sum(tbl.best)
      }



    })

    # Random Forest Model Fit Summary
    output$rfSummary <- renderPrint({
      # Random Forest Model Fits
      fit.rf <- randomForest(as.factor(DEATH_EVENT) ~ ., data = df.train, ntree = input$ntree, importance = TRUE)

      print(fit.rf)
    })

    # Generate Variance of Importance Plot
    output$rfVarImpPlot <- renderPlot({
      fit.rf <- randomForest(as.factor(DEATH_EVENT) ~ ., data = df.train, ntree = input$ntree, importance = TRUE)
      varImpPlot(fit.rf,type=1)
    })

    # Confusion Matrix
    output$rfTestConf <- renderTable({
      fit.rf <- randomForest(as.factor(DEATH_EVENT) ~ ., data = df.train, ntree = input$ntree, importance = TRUE)

      if(input$rfTest == "Test Data"){
        # Test Error Rate
        pred <- predict(fit.rf, df.test, type = "response")

        df.cont <- as.data.frame(cbind(pred, df.test$DEATH_EVENT))
        colnames(df.cont) <- c("Predicted", "Patient Status")
        table(df.cont$Predicted, df.cont$`Patient Status`)

        table(pred, df.test$DEATH_EVENT)
      } else{
        # Training Error Rate
        pred <- predict(fit.rf, df.train, type = "response")


        df.cont <- as.data.frame(cbind(pred, df.train$DEATH_EVENT))
        colnames(df.cont) <- c("Predicted", "Patient Status")
        table(df.cont$Predicted, df.cont$`Patient Status`)
        }


    })

    # Error Rate
    output$rfTestError <- renderText({
      fit.rf <- randomForest(as.factor(DEATH_EVENT) ~ ., data = df.train, ntree = input$ntree, importance = TRUE)

      if(input$rfTest == "Test Data"){
        # Test Error Rate
        pred <- predict(fit.rf, df.test, type = "response")

        tbl.best <- table(pred, df.test$DEATH_EVENT)
        1-sum(diag(tbl.best))/sum(tbl.best)
      } else{
        # Training Error Rate
        pred <- predict(fit.rf, df.train, type = "response")

        tbl.best <- table(pred, df.train$DEATH_EVENT)
        1-sum(diag(tbl.best))/sum(tbl.best)
      }

    })

    # Make Predictions for User-Provided Predictor Variable Values
    output$predictTbl <- renderTable({
      glm.full <- glm(DEATH_EVENT ~., data = df.train, family = binomial)
      glm.best <- bestglm::bestglm(df.train, IC = "AIC")
      fit.rf <- randomForest(as.factor(DEATH_EVENT) ~ ., data = df.train, ntree = input$ntree)

      model <- switch(input$model,
                      "Logistic Full Model" = glm.full,
                      "Logistic Best-Subset Model" = glm.best$BestModel,
                      "Random Forest Model" = fit.rf)

      df.predict <- as.data.frame(cbind(age = input$age,
                                        anaemia = ifelse(input$anaemia == 1, 1, 0),
                                        creatinine_phosphokinase = input$CPK,
                                        diabetes = ifelse(input$diabetes == 1, 1, 0),
                                        ejection_fraction = input$EF,
                                        high_blood_pressure = ifelse(input$HBP == 1, 1, 0),
                                        platelets = input$platelets,
                                        serum_creatinine = input$serumC,
                                        serum_sodium = input$serumS,
                                        sex = ifelse(input$sex == 1, 1, 0),
                                        smoking = ifelse(input$smoking == 1, 1, 0),
                                        time = input$time))

      pred <- predict(model, df.predict, type = "response")


      df.predict$predicted <- pred

      if(input$model == "Random Forest Model"){
        df.predict$response <- ifelse(as.numeric(pred)==2, "Survived", "Deceased")
      } else {
        df.predict$response <- ifelse(pred > 0.5, "Survived", "Deceased")
      }


      print(df.predict)
    })



# Data

    #create output of observations

    datasetInput <- reactive({

      df <- df%>%
        mutate(anaemia = as.factor(ifelse(anaemia == 1, "Yes", "No")),
               diabetes = as.factor(ifelse(diabetes == 1, "Yes", "No")),
               high_blood_pressure = as.factor(ifelse(high_blood_pressure == 1, "Yes", "No")),
               sex = as.factor(ifelse(sex == 1, "Male", "Female")),
               smoking = as.factor(ifelse(smoking == 1, "Yes", "No")),
               DEATH_EVENT = as.factor(ifelse(DEATH_EVENT == 1, "Deceased", "Survived")))

      if (length(input$vars) == 0) return(df)
      df %>% dplyr::select(!!!input$vars)
    })


    output$obs <- DT::renderDT({
      datasetInput()
      }, filter = "top", rownames = TRUE)

    output$filtered_row <-
      renderPrint({
        input[["dt_rows_all"]]
      })

    output$downloadData <- downloadHandler(
      filename = function() {
        "heart_failure_clinical_records.csv"
      },
      content = function(file) {
        write.csv(datasetInput()[input[["obs_rows_all"]], ], file, row.names = FALSE)

      }
    )

})
