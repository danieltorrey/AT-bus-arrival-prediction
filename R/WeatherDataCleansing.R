# Extracting weather information

extract_weather = function(suburb_RDS) {
  
  weather_times <- list()   # Create empty list to store data frames
  suburb_data = readRDS(suburb_RDS)
  
  # Loop over all hours
  hours <- suburb_data$forecast$forecastday[[1]]$hour
  
  for (i in seq_along(hours)) {
    # Extract time and text
    time <- hours[[i]]$time
    weather <- hours[[i]]$condition$text
    
    #Current format of time is (date - time), time numeric just gets the hour
    time_numeric = as.numeric(sub(".*\\s(\\d{1,2}):.*", "\\1", time))
    
    # Create data frame
    weather_time <- data.frame(time = time_numeric, weather = weather, lat = suburb_data$location$lat, lon = suburb_data$location$lon)
    
    # Add data frame to list
    weather_times[[i]] <- weather_time
  }
  
  # Combines all the unique times into one data frame
  weather_hours_data <- do.call(rbind, weather_times)
  
  return(weather_hours_data)
}


full_weather <- data.frame()
dates <- list.files(dir_weather)

for (date in dates) {
  dates_dir <- paste(dir_weather, date, sep = "/")
  
  suburbs <- list.files(dates_dir, recursive = FALSE) # Gets all unique suburb for that specific date
  
  for (suburb in suburbs) {
    
    #For a given time for a given day, go into that file directory
    dates_suburb_dir <- paste(dates_dir, suburb, sep = "/")
    
    # Gets the required dataset for a given day 
    dates_suburb_data <- extract_weather(dates_suburb_dir)
    
    dates_suburb_data$date <- date
    dates_suburb_data$suburb <-gsub(".rds", "", suburb)
    
    # Combines date_time_data with the existing combined_data
    full_weather = rbind(full_weather, dates_suburb_data)
  }
}