library(tidyverse)
library(xgboost)
library(Matrix)
load(paste0(dir_rawdata, '/FullProcessedData.RData'))
library(ggplot2)

# Preprocessing 

set.seed(500)

# We will consider a bus on time if no earlier and no later than 3 minutes 
model_buses <- full_processed_data %>% 
  select(c(route_short_name, stop_sequence, stop_lat, stop_lon, delay, dow=day_of_week, 
           hod=time_frame, suburb, weather)) %>%
  mutate(route_short_name = as.factor(route_short_name),
         suburb=as.factor(suburb),
         weather=as.factor(weather)) %>%
  filter(delay > -10000 & delay < 10000) %>%
  mutate(on_time = if_else(delay > -180 & delay < 180, TRUE, FALSE)) %>% 
  mutate(work_day = !(dow %in% c('Sat', 'Sun'))) %>%
  mutate(peak_hours = work_day & (hod %in% c(6:8, 16:18))) %>%
  na.omit() 

# Checking for imbalanced data
table(model_buses$on_time)

# Partitioning data into training and testing sets (80/20 split)
train_idx <- sample(nrow(model_buses), 0.8*nrow(model_buses))
train_buses <- model_buses[train_idx,]
test_buses <- model_buses[-train_idx,]

# Create a sparse matrix, we do not want delay and on time in this for our model
sparse_matrix <- sparse.model.matrix(~ . - 1, data = train_buses %>% select(-on_time, -delay))
sparse_matrix_test <- sparse.model.matrix(~ . - 1, data = test_buses %>% select(-on_time, -delay))

# Labels used for prediction and XGBoost
actual = train_buses$on_time
actual_test = test_buses$on_time

# Cross Validation 

cv_errors = xgb.cv(data = sparse_matrix,
       label = actual,
       max_depth=2, eta=0.1, nrounds = 10, nfold = 5,
       objective = 'binary:logistic',
       metrics = 'error') 

# Extract train and test error values
train_error <- cv_errors$evaluation_log$train_error_mean
test_error <- cv_errors$evaluation_log$test_error_mean

train_error_std <- cv_errors$evaluation_log$train_error_std
test_error_std <- cv_errors$evaluation_log$test_error_std

# Create data frame for plotting
results <- data.frame(
  Rounds = 1:length(train_error),
  Train_Error = train_error,
  Test_Error = test_error,
  Train_Error_Std = train_error_std,
  Test_Error_Std = test_error_std
)

# Plot train and test errors
ggplot(results, aes(x = Rounds)) +
  geom_line(aes(y = Train_Error, color = "Train Error"), size = 1) +
  geom_line(aes(y = Test_Error, color = "Test Error"), size = 1) +
  scale_color_manual(values = c("Train Error" = "blue", "Test Error" = "red")) +
  labs(x = "Number of Rounds", y = "Error") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(1, max(results$Rounds), 1), labels = scales::number_format(accuracy = 1)) +
  ggtitle("XGBoost Cross Validation Error")


# Here could either opt in for 3 if we using minimum or 2 using Test_Error + 1 Test_Error_Std. I opted in for minimum.
xg_model <- xgboost(data = sparse_matrix,
                label = actual,
                max_depth=2, 
                eta=0.1, 
                nthread=2, 
                nrounds = 3,
                objective = 'binary:logistic')


#If we wanna see tree structure
xgb.plot.tree(model = xg_model)

#Predicting our whole dataset
XG_predicted = predict(xg_model, sparse_matrix_test) 
XG_predicted = ifelse(XG_predicted > 0.5, TRUE, FALSE)
XG_confuse_table = table(actual_test, XG_predicted)

#Print the confusion table
print(XG_confuse_table)

# Compute TN, FN, FP, TP
XG_TN <- XG_confuse_table[1]
XG_FP <- XG_confuse_table[2]
XG_FN <- XG_confuse_table[3]
XG_TP <- XG_confuse_table[4]

# Compute accuracy, precision, recall, and specificity
XG_accuracy <- (XG_TN + XG_TP) / sum(XG_confuse_table)
XG_precision <- XG_TP / (XG_FP + XG_TP)
XG_recall <- XG_TP / (XG_FN + XG_TP)
XG_specificity <- XG_TN / (XG_TN + XG_FP)

# Create a table with the results
XG_results_table <- data.frame(Metric = c("Accuracy", "Precision", "Recall", "Specificity"),
                            Value = c(XG_accuracy, XG_precision, XG_recall, XG_specificity))

# Print the results table
print(XG_results_table)
