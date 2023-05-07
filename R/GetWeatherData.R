# Data grabbed from https://www.weatherapi.com/api-explorer.aspx

api_key <- "d0d5efa738a7493db8a61211231203"

# Takes in a suburb, lat, lon and date. Suburb is just used 
weather_data = function(suburb = "", lat = NA, lon = NA, date) {
  #Location we can give latitude,longitude 
  
  if (is.na(lat) | is.na(lon)) {
    location <- suburb
  } else if (suburb == "") {
    stop("Need to input valid suburb, or valid latitude and longitude")
  } else {
    location <- paste(lat, ",", lon, sep = "")
  }
  
  # For the start date we can only get previous 7 days
  
  # Getting data from API
  response <- GET(paste0("https://api.weatherapi.com/v1/history.json?key=", api_key, "&q=", location, "&dt=", date))
  
  # Getting contents from JSON file
  weather_data <- content(response, "parsed") 
  
  #Save the file into directory
  saveRDS(weather_data, file=paste(dir_weather, "/", date, "/", suburb, ".rds", sep = ""))
}

# Day we want to collect data for
collection_dates = list.files(dir_busarrivals)

# Uses the weather_data function to download dataset for a given lat lon location in a certain day
for (date in collection_dates) {
  if (!(file.exists(paste0(dir_weather, '/', date)))) {
    dir.create(paste0(dir_weather, '/', date))
  }
  apply(all_location, 1, function(x) {
    weather_data(x[["suburb"]],x[["lat"]], x[["lon"]], date)
  })
}