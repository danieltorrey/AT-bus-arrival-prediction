# Saving folder directories
dir = getwd()
dir_scripts = paste0(dir, '/R/', sep = "")
dir_rawdata = paste0(dir, '/rawdata/', sep = "")
dir_businfo = paste0(dir_rawdata, '/businfo/', sep = "")
dir_busarrivals = paste0(dir_rawdata, '/busarrivals/', sep = "")

source(paste0(dir_scripts, 'Initialise.R'))

source(paste0(dir_scripts, 'GetBusInfoData.R'))

#source(paste0(dir_scripts, '/DataCleansing.Rmd'))
#source(paste0(dir_scripts, '/DataExploration'))