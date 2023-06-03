load(paste0(dir_rawdata, '/FullProcessedData.RData'))
set.seed(500)

##### Implementing Random Forest Model #####

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

# Creating random forest model, max number of trees of 50
bus_forest <- ranger(on_time ~ route_short_name + stop_sequence + stop_lat + 
                       stop_lon + dow + hod + weather + suburb + work_day + peak_hours, 
                     data=train_buses, importance='impurity', num.trees=50, 
                     verbose=TRUE, classification=TRUE)
bus_forest

forest_pred <- predict(bus_forest, test_buses)
forest_tab <- table(actual=test_buses$on_time, pred=forest_pred$predictions)
forest_tab

# Calculating confusion matrix metrics
accuracy <- (forest_tab[1] + forest_tab[4]) / sum(forest_tab)
precision <- forest_tab[4] / (forest_tab[3] + forest_tab[4])
recall <- forest_tab[4] / (forest_tab[2] + forest_tab[4])
specificity <- forest_tab[1] / (forest_tab[1] + forest_tab[2])

# Create a table with the results
forest_results <- data.frame(Metric = c("Accuracy", "Precision", "Recall", "Specificity"),
                            Value = c(accuracy, precision, recall, specificity))

print(forest_results)

# Viewing variable importance
sort(bus_forest$variable.importance)
