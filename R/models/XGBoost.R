library(tidyverse)
library(xgboost)
library(Matrix)
load(paste0(dir_rawdata, '/FullProcessedData.RData'))
library(ggplot2)

# Preprocessing 


set.seed(1)


model <- full_processed_data %>% 
  select(c(route_short_name, 
           stop_sequence, 
           stop_lat, 
           stop_lon, 
           delay, 
           dow=day_of_week, 
           hod=time_frame, 
           suburb, 
           weather)) %>%
  filter(delay < 10000 & delay > -10000) %>% 
  mutate(on_time = if_else(delay > -180 & delay < 180, TRUE, FALSE)) %>% 
  mutate(work_day =! dow %in% c('Sat', 'Sun')) %>%
  mutate(peak_hours = work_day & (hod %in% c(6:8,16:18))) %>%
  mutate(weather = as.factor(weather)) %>% 
  mutate(suburb = as.factor(suburb)) %>%
  na.omit() 

# Checking for imbalanced data - not too imbalanced
table(model$on_time)

# Create a sparse matrix, we do not want delay and on time in this for our model
sparse_matrix <- sparse.model.matrix(~ . - 1, data = model %>% select(-on_time, -delay))

# Labels used for prediction and XGBoost
actual = model$on_time

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


# We choose depth of 4. We choose Round 7 then subtract Test Error Std approx 0.358. Largest Train Error that is smaller than 0.358 is Round 4 test error. So we choose 4 rounds
xg_model <- xgboost(data = sparse_matrix,
                label = actual,
                max_depth=2, 
                eta=0.1, 
                nthread=2, 
                nrounds = 4,
                objective = 'binary:logistic')


#If we wanna see tree structure
xgb.plot.tree(model = xg_model)

#Predicting our whole dataset
predicted = predict(xg_model, sparse_matrix) 
predicted = ifelse(predicted > 0.5, TRUE, FALSE)
confuse_table = table(actual, predicted)

#Print the confusion table
print(confuse_table)

# Compute TN, FN, FP, TP
TN <- confuse_table[1]
FP <- confuse_table[2]
FN <- confuse_table[3]
TP <- confuse_table[4]

# Compute accuracy, precision, recall, and specificity
accuracy <- (TN + TP) / sum(confuse_table)
precision <- TP / (FP + TP)
recall <- TP / (FN + TP)
specificity <- TN / (TN + FP)

# Create a table with the results
results_table <- data.frame(Metric = c("Accuracy", "Precision", "Recall", "Specificity"),
                            Value = c(accuracy, precision, recall, specificity))

# Print the results table
print(results_table)
