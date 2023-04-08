source('Initialise.R')
source(paste0(wd, '/getBusInfoData.R'))

############################################
# Only run if intending to grab AT GTFS data
source(paste0(wd, "/getBusArrivalData.R"))
############################################

source(paste0(wd, '/dataCleansing.Rmd'))
