# Loading in previously saved datasets
load(paste0(dir_rawdata, '/FullBusData.RData'))
load(paste0(dir_rawdata, '/FullProcessedData.RData'))

# Subsetted datasets

#Counts of total number of busses
total_buses = full_bus_data %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>% 
  group_by(route_short_name) %>% 
  summarise(total_counts = n()) %>% 
  filter(total_counts > 20)

#Getting the cancelled buses route information 
cancelled_buses_route = subset(full_bus_data, cancelled == TRUE) %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>% 
  group_by(route_short_name) %>% 
  summarise(Tally = n()) 

#Getting the cancelled buses route information 
cancelled_buses_day= subset(full_bus_data, cancelled == TRUE) %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>% 
  group_by(day_of_week) %>% 
  summarise(Tally = n()) 

# Proportion of non-cancelled buses

nrow(full_processed_data) / nrow(full_bus_data)

#Distribution of delay by the day of week

#Note we removed delays that are an hour or more
ggplot(full_processed_data %>% 
         filter(delay > -3600 & delay < 3600), 
       mapping = aes(x = day_of_week, y = delay)) +geom_hline(yintercept = 0, col = "red", alpha  = 0.5) +
  geom_boxplot()

#Note we removed delays that are an hour or more
ggplot(full_processed_data %>% 
         filter(delay > -3600 & delay < 3600), 
       mapping = aes(x = time_frame, y = delay)) +geom_hline(yintercept = 0, col = "red", alpha  = 0.5) +
  geom_boxplot()

#Cancelled bus proportion route dataset
cancelled_buses_route_proportion = cancelled_buses_route %>% 
  left_join(total_buses, by = "route_short_name") %>% 
  mutate(Cancelled_Proportion = Tally/total_counts) %>% 
  select(route_short_name, Cancelled_Proportion) %>% 
  arrange(desc(Cancelled_Proportion)) %>% 
  filter(is.na(route_short_name) != TRUE) %>% 
  #This is just to get the ordering we want in the barplot, can remove later on
  mutate(Position = factor(route_short_name, route_short_name))

print(cancelled_buses_route_proportion)

#Proportion of bus cancellation via histogram of proportions - route
ggplot(cancelled_buses_route_proportion %>% filter(Cancelled_Proportion > 0.10), 
       aes(x = Position, y = Cancelled_Proportion)) + 
  geom_col() +
  theme_minimal() + 
  theme(axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        panel.grid.major.y = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 90)) +
  coord_flip() +
  ylab("") +
  ggtitle("Top proportion of bus cancellation") + 
  xlab("Bus routes") +
  scale_y_continuous(expand = expansion(c(0,0.05)))


# Getting proportion of busses being cancelled in a day
cancelled_buses_day_prop = cancelled_buses_day %>% 
  mutate(prop = Tally / sum(Tally))

#Proportion of bus cancellation via histogram of proportions - day of week
ggplot(cancelled_buses_day_prop, 
       aes(x = day_of_week, y = prop)) + 
  geom_col() +
  theme_minimal() + 
  theme(axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        panel.grid.major.y = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 90)) +
  coord_flip() +
  ylab("") +
  ggtitle("Proportion of bus cancellation by day") + 
  xlab("Day of week") +
  scale_y_continuous(expand = expansion(c(0,0.05)))