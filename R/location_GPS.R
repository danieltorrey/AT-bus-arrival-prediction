#Locations of interest dataset 

#Didn't know where to put Mangere so chucked it here for now 

west = c("Massey", "Henderson", "Glen Eden", "New Lynn", "Avondale", "Mount Roskill", "Mangere")
west_lat = c(-36.83, -36.88, -36.91, -36.91, -36.89, -36.92, -36.97)
west_lon = c(174.62,  174.63, 174.64, 174.68, 174.69, 174.73, 174.79)

west.df = data.frame(suburb = west, lat = west_lat, lon = west_lon)

north = c("Albany", "Rosedale", "Wairau Valley", "Glenfield", "Takapuna")
north_lat = c(-36.73, -36.75, -36.77, -36.78, -36.79)
north_lon = c(174.70, 174.71, 174.74, 174.72, 174.77)

north.df = data.frame(suburb = north, lat = north_lat, lon = north_lon)

east = c("Howick", "East Tamaki", "Flat Bush")
east_lat = c(-36.89, -36.94, -36.97)
east_lon = c(174.92, 174.89, 174.92)

east.df = data.frame(suburb = east, lat = east_lat, lon = east_lon)

south = c("Otahuhu", "Papatoetoe", "Manukau City Centre", "Maurewa", "Papakura")
south_lat = c(-36.95, -36.97, -36.99, -37.02, -37.06)
south_lon = c(174.85, 174.86, 174.87, 174.89, 174.95)

south.df = data.frame(suburb = south, lat = south_lat, lon = south_lon)

#Note St Heliers isn't like a big city, but needed a city that was around that area
central = c("Auckland CBD", "Grey Lynn", "New Market", "Mount Eden", "Remuera", "Epsom", "Onehunga", "Penrose", "Ellerslie", "Mount Wellington", "St Heliers")
central_lat = c(-36.85, -36.86, -36.87,-36.89, -36.88, -36.89, -36.92, -36.92, -36.90, -36.91, -36.86)
central_lon = c(174.76,174.74, 174.78, 174.75, 174.80, 174.77, 174.79, 174.82, 174.82, 174.84, 174.86)

central.df = data.frame(suburb = central, lat = central_lat, lon = central_lon)

all_location = rbind(west.df, north.df, east.df, south.df, central.df)
