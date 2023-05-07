#Get file path of the locations

weather_dir <- "/Users/leonardophu/Desktop/2023/STATS 765/PROJECT/TEMPORARY/rawdata/weatherinfo"

#Extracting weather information

extract_weather = function(suburb_RDS) {
  # Create empty list to store data frames
  df_list <- list()
  
  suburb_data = readRDS(suburb_RDS)
  # Loop over hour list in temp
  
  hour_list <- suburb_data$forecast$forecastday[[1]]$hour
  
  for (i in seq_along(hour_list)) {
    # Extract time and text
    
    time <- hour_list[[i]]$time
    text <- hour_list[[i]]$condition$text
    
    #Current format of time is (date - time), time numeric just gets the hour
    time_numeric = as.numeric(sub(".*\\s(\\d{1,2}):.*", "\\1", time))
    
    # Create data frame
    df <- data.frame(time = time_numeric, text = text, lat = suburb_data$location$lat, lon = suburb_data$location$lon)
    
    # Add data frame to list
    df_list[[i]] <- df
  }
  
  #Puts all the unique times into one dataframe
  
  final_df <- do.call(rbind, df_list)
  #Returns the dataframe
  return(final_df)
}

# Create an empty data frame to store the combined data
full_weather <- data.frame()

dates <- list.files(weather_dir)

for (date in dates) {
  #So, for each date, we will go into that file path
  dates_dir <- paste(weather_dir, date, sep = "/")
  
  #Get unique suburb for that specific date
  suburb <- list.files(dates_dir, recursive = FALSE)
  
  #Loop to get dataset
  for(towns in suburb) {
    
    #For a given time for a given day, go into that file directory
    
    dates_suburb_dir <- paste(dates_dir, towns, sep = "/")
    
    #Get the required dataset for a given day 
    
    dates_suburb_data <- extract_weather(dates_time_dir)
    
    #Store the date the data was collected
    
    dates_suburb_data$date <- date
    
    dates_suburb_data$suburb <-gsub(".rds", "", towns)
    
    # Combine date_time_data with the existing combined_data
    full_weather = rbind(full_weather, dates_suburb_data)
  }
}

