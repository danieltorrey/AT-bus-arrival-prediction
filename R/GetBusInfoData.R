# Reading in bus static files 
stops = read.table(paste0(dir_businfo, "/stops.txt"), header = TRUE, sep = ",", quote = "")
stop_times = read.table(paste0(dir_businfo, "/stop_times.txt"), header = TRUE, sep = ",", quote = "") %>% 
  mutate(stop_code = substring(stop_id, 1, regexpr("-", stop_id)[1] - 1))
trips = read.table(paste0(dir_businfo, "/trips.txt"), header = TRUE, sep = ",", quote = ",", fill = TRUE)
routes = read.table(paste0(dir_businfo, "/routes.txt"), header = TRUE, sep = ",", quote = "")
shapes = read.table(paste0(dir_businfo, "/shapes.txt"), header = TRUE, sep = ",", quote = "")