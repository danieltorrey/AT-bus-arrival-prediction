# Subsetted datasets

#Counts of total number of busses
total_buses = full_bus_data %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>% 
  group_by(route_short_name) %>% 
  summarise(total_counts = n()) %>% 
  filter(total_counts > 20)

#Getting the cancelled buses information 
cancelled_buses = subset(full_bus_data, is.na(cancelled) == FALSE) %>% 
  filter(!(route_short_name %in% c("WEST", "NORTH","SOUTH", "EAST"))) %>% 
  group_by(route_short_name) %>% 
  summarise(Tally = n()) 

#Distribution of delay by the day of week

#Note we removed delays that are an hour or more
ggplot(full.df %>% 
         filter(delay > -3600 & delay < 3600), 
       mapping = aes(x = day_of_week, y = delay)) + 
  geom_boxplot()

#Note we removed delays that are an hour or more
ggplot(full.df %>% 
         filter(delay > -3600 & delay < 3600), 
       mapping = aes(x = time_frame, y = delay)) + 
  geom_boxplot()

#Cancelled bus proportion dataset
cancelled_buses_proportion = cancelled_buses %>% 
  left_join(total_buses, by = "route_short_name") %>% 
  mutate(Cancelled_Proportion = Tally/total_counts) %>% 
  select(route_short_name, Cancelled_Proportion) %>% 
  arrange(desc(Cancelled_Proportion)) %>% 
  filter(is.na(route_short_name) != TRUE) %>% 
  #This is just to get the ordering we want in the barplot, can remove later on
  mutate(Position = factor(route_short_name, route_short_name))

print(cancelled_buses_proportion)

#Proportion of bus cancellation via histogram of proportions
ggplot(cancelled_buses_proportion %>% filter(Cancelled_Proportion > 0.010), 
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
  ggtitle("Proportion of bus cancellation (that has at least 1%)") + 
  xlab("Bus routes") +
  scale_y_continuous(expand = expansion(c(0,0.05)))






