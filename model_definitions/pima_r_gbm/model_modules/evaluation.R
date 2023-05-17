LoadPackages <- function() {
    library("methods")
    library("jsonlite")
    library("caret")
    library("gbm")
    library("DBI")
    library("dplyr")
    library("tdplyr")
}

evaluate <- function(data_conf, model_conf, ...) {
    model <- readRDS(paste(ifelse(model_conf$inputPath != "" && !is.null(model_conf$inputPath), model_conf$inputPath, "artifacts/input/"), "model.rds", sep=""))
    print("Evaluating model...")

    suppressPackageStartupMessages(LoadPackages())

    # Connect to Vantage
    con <- aoa_create_context()

    table <- tbl(con, sql(data_conf$sql))

    # Create dataframe from tibble, selecting the necessary columns and mutating integer64 to integers
    data <- table %>% mutate(NumTimesPrg = as.integer(NumTimesPrg),
                                PlGlcConc = as.integer(PlGlcConc),
                                BloodP = as.integer(BloodP),
                                SkinThick = as.integer(SkinThick),
                                TwoHourSerIns = as.integer(TwoHourSerIns),
                                HasDiabetes = as.integer(HasDiabetes)) %>% as.data.frame()

    probs <- predict(model, data, na.action = na.pass, type = "response")
    preds <- as.integer(ifelse(probs > 0.5, 1, 0))

    cm <- confusionMatrix(table(preds, data$HasDiabetes))

    png(paste(ifelse(model_conf$outputPath != "" && !is.null(model_conf$outputPath), model_conf$outputPath, "artifacts/output/"), "confusion_matrix.png", sep=""), width = 860, height = 860)
    fourfoldplot(cm$table)
    dev.off()

    preds$pred <- preds
    metrics <- cm$overall

    # Save metrics
    write(jsonlite::toJSON(metrics, auto_unbox = TRUE, null = "null", keep_vec_names=TRUE), paste(ifelse(model_conf$outputPath != "" && !is.null(model_conf$outputPath), model_conf$outputPath, "artifacts/output/"), "metrics.json", sep=""))
}