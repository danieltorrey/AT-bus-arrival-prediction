# Loading libraries
library(tidyverse)
library(jsonlite)
library(httr)
library(lubridate)
library(ggplot2)

# Setting folder structures
wd = getwd()
wd_rawdata = paste(wd, '/rawdata', sep = "")
wd_businfo = paste(wd_rawdata, '/businfo', sep = "")
wd_busarrivals = paste(wd_rawdata, '/busarrivals', sep = "")