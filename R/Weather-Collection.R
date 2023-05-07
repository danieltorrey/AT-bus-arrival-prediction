# This is intialisation. Just have a play around 

#Initialisation

library(httr)
library(jsonlite)

#Also free API, I can only make max 1million calls to API, be mindful of that though 1million LOL that's enough
api_key <- "d0d5efa738a7493db8a61211231203"


#https://www.weatherapi.com/api-explorer.aspx look at this, shows what data will look like

# Function to get weather data for a specific

#My file loctaion
file_path = "/Users/leonardophu/Desktop/2023/STATS 765/PROJECT/TEMPORARY/rawdata/weather_info"

#Takes in a suburb, lat, lon and date. Suburb is just used 
weather_data = function(suburb = "", lat = NA, lon = NA, date) {
  #Location we can give latitude,longitude 
  
  if (is.na(lat) | is.na(lon)) {
    location <- suburb
  } else if (suburb == "") {
    stop("Need to input valid suburb, or valid latitude and longitude")
  } else {
    location <- paste(lat, ",", lon, sep = "")
  }
  
  #Also for the start date can only get previous 7 days be mindful of that
  
  #Format is yyyy-mm-dd
  start_date <- date
  
  #Getting data from API
  response <- GET(paste0("https://api.weatherapi.com/v1/history.json?key=", api_key, "&q=", location, "&dt=", start_date))
  
  #Getting contents from JSON file
  weather_data <- content(response, "parsed")
  
  #Set file path and name (currently doing local directory, with date-suburb.rds)
  
  #Feel free to change weather_file_location to the required file path - file_path/date-suburb.rds
  
  weather_file_location = paste(file_path, "/", date, "/", suburb, ".rds", sep = "")
  weather_file_location2 = paste(date, "-", suburb, ".rds", sep = "")
  
  #Save the file into directory
  saveRDS(weather_data, file=weather_file_location)
  saveRDS(weather_data, file=weather_file_location2)
}


# TO GET DATASET USE CODE BELOW

#day we want to collect data
collection_date = "2023-05-03"
  
#Please put the city or suburb you want to do
suburb_df =  all_location
  
#Uses the weather_data function to download dataset for a given lat lon location in a certain day
donwload_data <- apply(suburb_df, 1, function(x) {
    weather_data(x[["suburb"]],x[["lat"]], x[["lon"]], date = collection_date)
})


