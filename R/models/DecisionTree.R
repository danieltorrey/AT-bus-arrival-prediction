load(paste0(dir_rawdata, '/FullProcessedData.RData'))
set.seed(500)

##### Implementing Decision Tree #####

# We will consider a bus delayed if late by 3 minutes
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

# Creating classification decision tree model
bus_tree = rpart(on_time ~ route_short_name + stop_sequence + stop_lat + 
                   stop_lon + dow + hod + weather + suburb +
                   work_day + peak_hours, data=train_buses, method="class", cp=0.001)

# To prune tree, look at CP table
bus_tree$cptable

# New pruned tree
bus_tree_best = rpart(on_time ~ route_short_name + stop_sequence + stop_lat + 
                        stop_lon + dow + hod + weather + suburb + work_day + 
                        peak_hours, data=train_buses, method="class",
                      # Lowest xerror = 0.8069489, corresponding xstd = 0.002118031
                      # 1-SE threshold = 0.809066931
                      # Hence choose n=14 as 0.8079928 < 0.809066931
                      # Replace CP with the best CP found in cptable
                      control = rpart.control(cp = 0.001043866))

# Function to appropriately produce labels for DT plot (accounting for issues with very long labels)
split.fun <- function(x, labs, digits, varlen, faclen)
{
  # replace commas with spaces (needed for strwrap)
  labs <- gsub(",", " ", labs)
  for(i in 1:length(labs)) {
    # split labs[i] into multiple lines
    labs[i] <- paste(strwrap(labs[i], width=25), collapse="\n")
  }
  labs
}

# Using prp to plot pruned decision tree 
prp(bus_tree_best, split.fun=split.fun)
bus_tree_best

pred <- predict(bus_tree_best, test_buses, type="class")
pred_tab <- table(actual=test_buses$on_time, pred=pred)
pred_tab

# Calculating confusion matrix metrics
accuracy <- (pred_tab[1] + pred_tab[4]) / sum(pred_tab)
precision <- pred_tab[4] / (pred_tab[3] + pred_tab[4])
recall <- pred_tab[4] / (pred_tab[2] + pred_tab[4])
specificity <- pred_tab[1] / (pred_tab[1] + pred_tab[2])

# Create a table with the results
results_table <- data.frame(Metric = c("Accuracy", "Precision", "Recall", "Specificity"),
                            Value = c(accuracy, precision, recall, specificity))

print(results_table)

# Viewing variable importance
sort(bus_tree_best$variable.importance)
