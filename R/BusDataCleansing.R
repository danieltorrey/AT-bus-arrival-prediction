# Extract data combines the tripupdates and alert JSON files to a single dataframe 

extract_data = function(trip_updates, alerts){
  trip_content = trip_updates[[2]][[2]]   # All the required information is in a nested list
  
  # Null check is a function that checks if a feature for an entity (individual buses) exist, if they don't we will replace that column as NA 
  null_check = function(x) if(is.null(x)) NA else x
  
  # Filtering for invalid trip ID entries
  trips = trips %>% filter(trip_id != "trip_id")
  
  # Extracting all relevant columns from the trip_updates GTFS file.
  trip_data = as.data.frame(do.call(rbind, lapply(trip_content, 
                                                  function(x) c(null_check(x$trip_update$trip$trip_id[[1]][1]),
                                                                null_check(x$trip_update$trip$direction_id),
                                                                null_check(x$trip_update$trip$route_id),
                                                                null_check(x$trip_update$stop_time_update$stop_id),
                                                                null_check(x$trip_update$trip$schedule_relationship),
                                                                null_check(x$trip_update$delay), 
                                                                null_check(x$trip_update$stop_time_update$stop_sequence),
                                                                null_check(x$trip_update$stop_time_update$arrival$time),
                                                                null_check(x$trip_update$stop_time_update$arrival$delay),
                                                                null_check(x$trip_update$stop_time_update$departure$time),
                                                                null_check(x$trip_update$stop_time_update$departure$delay)
                                                  ))))
  
  trip_data = as.data.frame(lapply(trip_data, unlist))    # Converting to data frame
  
  # Setting column names
  colnames(trip_data) = c("trip_id", 
                          "direction_id", 
                          "route_id", 
                          "stop_id", 
                          "schedule_relationship", 
                          "delay", 
                          "stop_sequence", 
                          "act_arrival_time", 
                          "arrival_delay", 
                          "act_departure_time", 
                          "act_departure_delay")
  
  trip_data$stop_sequence = as.integer(trip_data$stop_sequence)   # Fixing stop sequence type
  
  # Sorting out cancellations from the Alert dataset
  
  alert_contents = alerts[[2]][[2]]
  
  #Extract the relevant information we want from the alert data set, Here we want the id and the effect (NO SERVICE, "MODIFIED SERVICE", etc)
  alert_data = as.data.frame(do.call(rbind, lapply(alert_contents, function(x) c(null_check(x$id), 
                                                                                 null_check(x$alert$effect), 
                                                                                 null_check(x$alert$header_text$translation[[1]]$text), 
                                                                                 null_check(x$alert$informed_entity[[1]]$trip$trip_id)))))
  
                                                                              
  alert_data = as.data.frame(lapply(alert_data, unlist))  # All the required information is in a nested list
  
  colnames(alert_data) = c("id", "effect", "text", "trip_id") # Setting alert dataset column names
  
  # Getting all cancelled busses, i.e. ones with no service
  cancelled_buses <- alert_data %>% 
    filter(effect == "NO_SERVICE")
  # Filtering for cancellation 
  cancelled_buses <- cancelled_buses %>% 
    # When a bus' text entry is "Cancellation", these indicates the buses were cancelled
    filter(grepl("Cancellation", text) == TRUE) %>% 
    select(trip_id) %>% 
    mutate(cancelled = TRUE)
  
  # Joining all relevant bus info datasets together
  bus_arrivals_full = trip_data %>% 
    left_join(stop_times %>% 
                select("trip_id", "stop_sequence", "arrival_time", "departure_time"), 
              by = c("trip_id" = "trip_id", "stop_sequence" = "stop_sequence")) %>%
    left_join(stops %>% select("stop_id", "stop_lat", "stop_lon"), 
              by = c("stop_id" = "stop_id")) %>%
    left_join(routes %>% select("route_id", "route_short_name"), 
              by = c("route_id" = "route_id")) %>% 
    left_join(cancelled_buses, 
              by = c("trip_id" = "trip_id"))
  
  return(bus_arrivals_full)
}

full_bus_data <- data.frame()

for (date in dates) {
  dates_dir <- paste(dir_busarrivals, date, sep = "/")
  
  # Getting unique times for each specific date
  times <- list.files(dates_dir, recursive = FALSE)
  
  # Loop to get dataset
  for(time in times) {
    
    # For a given time for a given day, go into that file directory
    dates_time_dir <- paste(dates_dir, time, sep = "/")
    trip_updates <- read_json(paste(dates_time_dir, "tripupdates.json", sep = "/"))
    alerts <- read_json(paste(dates_time_dir, "alerts.json", sep = "/"))
    
    # Get the required dataset for a given day 
    date_time_data <- extract_data(trip_updates, alerts)
    
    # Store the date the data was collected
    date_time_data$date <- date
    
    # Combine date_time_data with the existing combined_data
    full_bus_data <- rbind(full_bus_data, date_time_data)
  }
}

save(full_bus_data, file=paste0(dir_rawdata, "/FullBusData.RData"))