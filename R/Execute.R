source(paste0(getwd(), '/R/Initialise.R'))

source(paste0(dir_scripts, '/GetBusInfoData.R'))
source(paste0(dir_scripts, '/GetSuburbData.R'))
source(paste0(dir_scripts, '/GetWeatherData.R'))

source(paste0(dir_scripts, '/BusDataCleansing.R'))
source(paste0(dir_scripts, '/WeatherDataCleansing.R'))

source(paste0(dir_scripts, '/CombineAllData.R'))
source(paste0(dir_scripts, '/DataExploration.R'))

source(paste0(dir_models, '/DecisionTree.R'))
source(paste0(dir_models, '/RandomForest.R'))
source(paste0(dir_models, '/XGBoost.R'))
