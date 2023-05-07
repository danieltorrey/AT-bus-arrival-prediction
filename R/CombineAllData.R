non_cancelled <- subset(full_bus_data, cancelled==FALSE)

class(non_cancelled$act_arrival_time) = c('POSIXt','POSIXct')
class(non_cancelled$act_departure_time) = c('POSIXt','POSIXct')

non_cancelled <- non_cancelled %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>%
  filter(is.na(act_arrival_time) == FALSE)

non_cancelled$time_frame = as.factor(as.numeric(substr(non_cancelled$act_arrival_time, 12, 13)))

non_cancelled = subset(non_cancelled, is.na(stop_lat) == FALSE)

# Changing time variable to numeric (accounting for weird difference of 1 error)
non_cancelled$time = as.numeric(non_cancelled$time_frame) - 1

# Initialising suburb column
non_cancelled$suburb <- NA

# Function to calculate Euclidean distance
euclidean_distance <- function(x1, y1, x2, y2) {
  sqrt((x1 - x2)^2 + (y1 - y2)^2)
}

# Looping through each row of non-cancelled busses
for (i in 1:nrow(non_cancelled)) {
  
  # Calculate Euclidean distances between the current row's stop coordinates and each suburb's coordinates 
  distances = apply(all_location[, c("lat", "lon")], 1, function(x) 
    euclidean_distance(non_cancelled[i, "stop_lat"], non_cancelled[i, "stop_lon"], x[1], x[2]))
  
  # Find index of city with minimum distance
  min_index = which.min(distances)
  
  # Assign name of closest city to new column in non-cancelled
  non_cancelled[i, "suburb"] = all_location[min_index, "suburb"]
}

# Joining weather data to full dataset
full_processed_data <- non_cancelled %>% left_join(full_weather %>% 
                                                     select("weather", "suburb", "time", "date"), 
                                                   by = c("suburb" = "suburb", "time" = "time", "date" = "date"))

save(full_processed_data, file=paste0(dir_rawdata, "/FullProcessedData.RData"))