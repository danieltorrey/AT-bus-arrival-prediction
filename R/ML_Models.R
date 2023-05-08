# Implementing DT

# We will consider a bus delayed if late by 3 minutes
full_processed_data = full_processed_data %>% mutate(is_delay = if_else(delay > 180, TRUE, FALSE))

# Checking for imbalanced data
table(full_processed_data$is_delay)

# Creating DT

library(rpart)
set.seed(500)
bus_tree = rpart(is_delay ~ factor(weather) + stop_sequence +
                   stop_lat + stop_lon + day_of_week + 
                   time_frame + route_short_name, data = full_processed_data, cp = 0.001)
plot(bus_tree)

# To prune tree, look at CP table

bus_tree$cptable

# New pruned tree
bus_tree_best = rpart(is_delay ~ factor(weather) + 
                        stop_sequence + 
                        stop_lat + stop_lon + 
                        day_of_week + time_frame + 
                        route_short_name, data = full_processed_data, 
                      #Replace CP with the best CP found in cptable
                      control = rpart.control(cp = 0.001044391))
plot(bus_tree_best)