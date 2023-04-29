# Saving folder directories
dir = getwd()
dir_busarrivals = paste0(dir, '/rawdata/busarrivals/', sep = "")

source(paste0(dir, '/R/Initialise.R'))

# Obtain AT API Key
AT_key = '567bb1fb7ab64582905c7812648075e1'

# Grabbing live bus arrival data for current day
combined_feed <- tryCatch(
  GET('https://api.at.govt.nz/realtime/legacy/',
      accept_json(),
      add_headers('Ocp-Apim-Subscription-Key' = AT_key)),
  error=function(e) NULL)
vehicle <- tryCatch(
  GET('https://api.at.govt.nz/realtime/legacy/vehiclelocations',
      accept_json(),
      add_headers('Ocp-Apim-Subscription-Key' = AT_key)),
  error=function(e) NULL)
trip_updates <- tryCatch(
  GET('https://api.at.govt.nz/realtime/legacy/tripupdates',
      accept_json(),
      add_headers('Ocp-Apim-Subscription-Key' = AT_key)),
  error=function(e) NULL)
alerts <- tryCatch(
  GET('https://api.at.govt.nz/realtime/legacy/servicealerts',
      accept_json(),
      add_headers('Ocp-Apim-Subscription-Key' = AT_key)),
  error=function(e) NULL)


# Creating folder for today's date and time
setwd(dir_busarrivals)
date <- format(Sys.time(), '%Y-%m-%d')
time <- format(Sys.time() + 12*60*60, '%H%M')   # Adding 12 hours on to account for UTC time in GitHub actions

if (!(file.exists(paste0(dir_busarrivals, date)))) {
  dir.create(date)
}

setwd(paste0(dir_busarrivals, paste0('/', date)))
dir.create(time)
setwd(paste0(paste0(dir_busarrivals, paste0('/', date)), paste0('/', time)))

# Saving data to JSON file
write_json(content(vehicle), 'vehicle', pretty = TRUE)
write_json(content(combined_feed), 'combined', pretty = TRUE)
write_json(content(trip_updates), 'tripupdates', pretty = TRUE)
write_json(content(alerts), 'alerts', pretty = TRUE)