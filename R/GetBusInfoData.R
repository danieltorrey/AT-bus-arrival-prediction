setwd(paste(dir_rawdata, '/businfo', sep = ""))

# Reading in bus static files 
stops = read.table("stops.txt", header = TRUE, sep = ",", quote = "")
stop_times = read.table("stop_times.txt", header = TRUE, sep = ",", quote = "") %>% 
  mutate(stop_code = substring(stop_id, 1, regexpr("-", stop_id)[1] - 1))
trips = read.table("trips.txt", header = TRUE, sep = ",", quote = ",", fill = TRUE)
routes = read.table("routes.txt", header = TRUE, sep = ",", quote = "")
shapes = read.table("shapes.txt", header = TRUE, sep = ",", quote = "")