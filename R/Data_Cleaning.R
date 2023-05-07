# Data cleaning and preprocessing

full_bus_data = full_bus_data %>% mutate(day_of_week = wday(as.Date(date, format = "%Y-%m-%d"), label = TRUE))
full_bus_data = distinct(full_bus_data)

#Some bits of dataset don't have both arrival and departure time. If we don't have both, we would assume they are the same. 
full_bus_data$act_arrival_time = ifelse(is.na(full_bus_data$act_arrival_time) == TRUE & is.na(full_bus_data$act_departure_time) == FALSE, full_bus_data$act_departure_time, full_bus_data$act_arrival_time)
full_bus_data$act_departure_time = ifelse(is.na(full_bus_data$act_arrival_time) == FALSE & is.na(full_bus_data$act_departure_time) == TRUE,  full_bus_data$act_arrival_time, full_bus_data$act_departure_time)

non_cancelled = subset(full_bus_data, is.na(cancelled) == TRUE)

class(non_cancelled$act_arrival_time) = c('POSIXt','POSIXct')
class(non_cancelled$act_departure_time) = c('POSIXt','POSIXct')

non_cancelled = non_cancelled %>% filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>%
  #Also filtered buses that don't have any arrival time (appears to be a error with their system)
  filter(is.na(act_arrival_time) == FALSE)

non_cancelled$time_frame = as.factor(as.numeric(substr(non_cancelled$act_arrival_time, 12, 13)))

non_cancelled = subset(non_cancelled, is.na(stop_lat) == FALSE)

#For some reason it adds 1 into the time frame

#Need unlevel time variable to use for joining later on
non_cancelled$time = as.numeric(non_cancelled$time_frame) - 1

#Going to need to use the location_GPS.R that has all_location to get the city that it's associated with

# Function to calculate Euclidean distance
euclidean_distance <- function(x1, y1, x2, y2) {
  sqrt((x1 - x2)^2 + (y1 - y2)^2)
}

#Initalise the city variable
non_cancelled$suburb <- NA

# Loop through each row of non cancelled 
for (i in 1:nrow(non_cancelled)) {
  # Calculate Euclidean distances between current row and each city in location_GPS.R
  distances = apply(all_location[, c("lat", "lon")], 1, function(x) 
    euclidean_distance(non_cancelled[i, "stop_lat"], non_cancelled[i, "stop_lon"], x[1], x[2]))
  
  # Find index of city with minimum distance
  min_index = which.min(distances)
  
  # Assign name of closest city to new column in non-cancelled
  non_cancelled[i, "suburb"] = all_location[min_index, "suburb"]
}


#Full Weather in the code Weather-Preprocessing.R 
full.df = non_cancelled %>% left_join(full_weather %>% 
                                        select("text", "suburb", "time", "date"), 
                                      by = c("suburb" = "suburb", "time" = "time", "date" = "date"))

