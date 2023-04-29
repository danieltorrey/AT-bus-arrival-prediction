# Saving folder directories
dir = getwd()
dir_scripts = paste0(dir, '/scripts/', sep = "")
dir_rawdata = paste0(dir, '/rawdata/', sep = "")
dir_businfo = paste0(dir_rawdata, '/businfo/', sep = "")
dir_busarrivals = paste0(dir_rawdata, '/busarrivals/', sep = "")

source(paste0(dir_scripts, 'Initialise.R'))

source(paste0(dir_scripts, 'GetBusInfoData.R'))

############################################
# Only run if intending to grab AT GTFS data
source(paste0(dir_scripts, "GetBusArrivalData.R"))
############################################

#source(paste0(dir_scripts, '/DataCleansing.Rmd'))
#source(paste0(dir_scripts, '/DataExploration'))