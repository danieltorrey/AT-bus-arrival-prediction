# Reading in bus static files 
setwd(paste(wd_rawdata, '/businfo', sep = ""))
stops = read.table("stops.txt", header = TRUE, sep = ",", quote = "")
stop_times = read.table("stop_times.txt", header = TRUE, sep = ",", quote = "")
trips = read.table("trips.txt", header = TRUE, sep = ",", quote = ",", fill = TRUE)
routes = read.table("routes.txt", header = TRUE, sep = ",", quote = "")
shapes = read.table("shapes.txt", header = TRUE, sep = ",", quote = "")
stop_times = stop_times %>% mutate(stop_code = substring(stop_id, 1, regexpr("-", stop_id)[1] - 1))