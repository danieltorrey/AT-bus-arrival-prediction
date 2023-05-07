## Hi Daniel, possible to sus this out. Just need to load in the static bus files 

# Read datasets 
dir_info = "/Users/leonardophu/Desktop/2023/STATS 765/PROJECT/TEMPORARY/rawdata/businfo"

# Reading in bus static files 
stops = read.table(paste(dir_info, "stops.txt", sep = "/"), header = TRUE, sep = ",", quote = "")
stop_times = read.table(paste(dir_info, "stop_times.txt", sep = "/"), header = TRUE, sep = ",", quote = "") %>% 
  mutate(stop_code = substring(stop_id, 1, regexpr("-", stop_id)[1] - 1))
trips = read.table(paste(dir_info, "trips.txt", sep = "/"), header = TRUE, sep = ",", quote = ",", fill = TRUE)
routes = read.table(paste(dir_info, "routes.txt", sep = "/"), header = TRUE, sep = ",", quote = "")
shapes = read.table(paste(dir_info, "shapes.txt", sep = "/"), header = TRUE, sep = ",", quote = "")


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------

#Extract data is a function which takes in a JSON trip_updates file and a JSON alert files. The goal of this is to create 1 dataframe with all the required information for that given day
extract_data = function(trip_updates, alerts){
  
  #Json file strucutre, all the information is in the 2nd list within that 2nd list (I know confusing)
  trip_content =trip_updates[[2]][[2]]
  
  #Null check is a function that checks if a feature for an entity (individual buses) exist, if they don't we will replace that column as NA for that entity 
  null_check = function(x) if(is.null(x)) NA else x
  
  #
  trips = trips %>% filter(trip_id != "trip_id")
  
  #We will extract all the relevant columns from the trip_updates GTFS file.
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
  
  #For some reason, my dataframe returns a dataframe of lists when we store it as JSON instead of reading directly from the website, code to sort this issue
  trip_data = as.data.frame(lapply(trip_data, unlist))
  
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
  # Fixing stop sequence type
  trip_data$stop_sequence = as.integer(trip_data$stop_sequence)
  
  ## Now we want to sort out cancellation from the Alert data set
  
  #Again with the trip_updates, JSON files are weird. The important information is stored in the 2nd item of a list, within that there's another list
  alert_contents = alerts[[2]][[2]]
  
  #Extract the relevant information we want from the alert data set, Here we want the id and the effect (NO SERVICE, "MODIFIED SERVICE", etc)
  alert_data = as.data.frame(do.call(rbind, lapply(alert_contents, function(x) c(null_check(x$id), 
                                                                                 null_check(x$alert$effect), 
                                                                                 null_check(x$alert$header_text$translation[[1]]$text), 
                                                                                 null_check(x$alert$informed_entity[[1]]$trip$trip_id)))))
  
  
  #Again dataframe issue, just solving it here                                                                             
  alert_data = as.data.frame(lapply(alert_data, unlist))
  
  #Relevant column names
  
  colnames(alert_data) = c("id", "effect", "text", "trip_id")
  
  #Get the cancelled busses, these are the ones with no service
  cancelled_buses = alert_data %>% 
    filter(effect == "NO_SERVICE")
  #Then filter about by cancellation 
  cancelled_buses = cancelled_buses %>% 
    #In their text they say Cancellation, these means that the buses were cancelled.
    filter(grepl("Cancellation", text) == TRUE) %>% 
    #Now to join to our trip_updates GTFS, we just want the TRIP_ID and a column that says these TRIP_IDs were cancelled
    select(trip_id) %>% 
    mutate(cancelled = TRUE)
  
  #Now for the FULL DATASET, joining them all together (including the static files)
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
  
  #Return dataset
  return(bus_arrivals_full)
}


#Hi Daniel please change file directory, I don't know how :(, just need to get into the rawdata/busarrivals

bus_arrival_dir <- "/Users/leonardophu/Desktop/2023/STATS 765/PROJECT/TEMPORARY/rawdata/busarrivals"

#Get all the unique dates for that file 

dates <- list.files(bus_arrival_dir)

for (date in dates) {
  #So, for each date, we will go into that file path
  dates_dir <- paste(bus_arrival_dir, date, sep = "/")
  
  #Get unique times for that specific date
  times <- list.files(dates_dir, recursive = FALSE)
  
  # Loop through each time for a given day
  for(time in times) {
    
    #For a given day and time, go into that file directory
    dates_time_dir <- paste(dates_dir, time, sep = "/")
    
    #Get the file names
    files <- list.files(dates_time_dir)
    
    #Rename the files
    files_to_rename <- files[!stringr::str_ends(files, ".json")]
    
    # Generate new file names with ".json" extension
    new_names <- paste0(files_to_rename, ".json")
    
    # Rename the files
    file.rename(file.path(dates_time_dir, files_to_rename), file.path(dates_time_dir, new_names))
    
  }
}


library(dplyr)
library(jsonlite)

# Create an empty data frame to store the combined data
full_bus_data <- data.frame()

# Get list of file names

#Hi Daniel please change file directory, I don't know how :(, just need to get into the rawdata/busarrivals

bus_arrival_dir <- "/Users/leonardophu/Desktop/2023/STATS 765/PROJECT/TEMPORARY/rawdata/busarrivals"

dates <- list.files(bus_arrival_dir)

for (date in dates) {
  #So, for each date, we will go into that file path
  dates_dir <- paste(bus_arrival_dir, date, sep = "/")
  
  #Get unique times for that specific date
  times <- list.files(dates_dir, recursive = FALSE)
  
  #Loop to get dataset
  for(time in times) {
    
    #For a given time for a given day, go into that file directory
    dates_time_dir <- paste(dates_dir, time, sep = "/")
    
    trip_updates <- read_json(paste(dates_time_dir, "tripupdates.json", sep = "/"))
    
    alerts <- read_json(paste(dates_time_dir, "alerts.json", sep = "/"))
    
    #Get the required dataset for a given day 
    date_time_data <- extract_data(trip_updates, alerts)
    
    #Store the date the data was collected
    date_time_data$date <- date
    
    # Combine date_time_data with the existing combined_data
    full_bus_data <- rbind(full_bus_data, date_time_data)
  }
}







