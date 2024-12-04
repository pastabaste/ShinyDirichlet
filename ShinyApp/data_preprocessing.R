source("global.R")


## Load and preprocess data 
# INKAR data
df <- read.csv2("/Users/lukas/Desktop/Desktop copy/Studium/GAU/HWS24/shiny/data/preliminary_data.csv")
# store year of column creation
years <- df[1,]
df <- df[-1,]

# extract voting shares
voting_shares <- data.frame(
  df$Stimmenanteile.AfD,
  df$Stimmenanteile.CDU.CSU,
  df$Stimmenanteile.FDP,
  df$Stimmenanteile.SPD ,
  df$Stimmenanteile.Grüne,
  df$Stimmenanteile.Die.Linke,
  df$Stimmenanteile.Sonstige.Parteien
)
colnames(voting_shares) <- gsub("^df\\.", "", colnames(voting_shares))
voting_shares <- voting_shares / 100
any(rowSums(voting_shares) != 1) # do not all sum up to one -> clarify how to handle this


# convert data into right format for dirichlet regression
voting_shares_dir <- DR_data(voting_shares)
head(voting_shares_dir)

# create vector with colors of political party with the most votes
max_positions <- apply(voting_shares_dir, 1, which.max)
set_winner_colors <- setNames(
  c("blue", "black", "yellow", "red", "green", "purple", "grey"),
  colnames(voting_shares_dir)[1:7]
)
winner_colors <- set_winner_colors[apply(voting_shares_dir, 1, function(x)
  colnames(voting_shares_dir)[which.max(x)])]


# SRF Data
germany_nuts3 <- st_read("/Users/lukas/Desktop/Desktop copy/Studium/GAU/HWS24/shiny/data/nuts3_germany/NUTS5000_N3.shp")


# Transform sf object to WGS84
germany_nuts3_wgs84 <- st_transform(germany_nuts3, crs = 4326)




# combine data set

length(sort(unique(germany_nuts3_wgs84$NUTS_NAME))) != length(sort(unique(df$Raumeinheit)))

# -> different number of kreise

# identify kreis which is not available in Inkar & remove it from srf data
same_kreis <- which(unique(substr(df$Raumeinheit, 1, 3)) %in% unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3)))
same_kreis2 <- which(unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3)) %in% unique(substr(df$Raumeinheit, 1, 3)))

germany_nuts3_wgs84$NUTS_NAME[-which(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3) %in% unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3))[same_kreis])]
germany_nuts3_wgs84<- germany_nuts3_wgs84[which(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3) %in% unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3))[same_kreis]),]


### Plot Kreise & Kreisstädte

leaflet(data = germany_nuts3_wgs84) %>%
  #addProviderTiles(providers$Esri.WorldImagery) %>% # background
  addPolygons(
    color = "black",
    weight = 1,
    fillColor = "gray",
    fillOpacity = 0.6,
    highlightOptions = highlightOptions(
      color = "white",      # Border color on highlight
      weight = 3,         # Border thickness on highlight
      fillOpacity = 0.9,  # Fill opacity on highlight
      bringToFront = TRUE # Brings the highlighted polygon to the front
    ),
    popup = ~paste0("<strong>County: </strong>", NUTS_NAME)
  ) %>%
  addEasyButton(
    easyButton(
      icon = "fa-crosshairs", title = "Zoom to Clicked County",
      onClick = JS(
        "function(btn, map) { 
           map.on('click', function(e) { 
              map.setView(e.latlng, map.getZoom()); 
           });
        }"
      )
    )
  )





same_name <- sort(df$Raumeinheit) == sort(germany_nuts3_wgs84$NUTS_NAME)
diff_name_inkar <- sort(df$Raumeinheit)[!same_name]
diff_name_wgs84 <- sort(germany_nuts3_wgs84$NUTS_NAME)[!same_name]

# replace "kreisfreie" with "Kreisfreie"
diff_name_inkar <- gsub("kreisfreie", "Kreisfreie", diff_name_inkar)

