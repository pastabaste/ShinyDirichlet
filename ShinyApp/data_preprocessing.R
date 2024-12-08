source("global.R")

## Load and preprocess data 
# remotes::install_github("sumtxt/bonn", force=TRUE)
# library(bonn)

# Load INKAR data
df <- read.csv2("/Users/lukas/Desktop/Desktop copy/Studium/GAU/HWS24/shiny/data/preliminary_data.csv")
# store year of column creation
years <- df[1,] # question about the year column
df <- df[-1,]

# Load SRF Data
germany_nuts3 <- st_read("/Users/lukas/Desktop/Desktop copy/Studium/GAU/HWS24/shiny/data/nuts3_germany/NUTS5000_N3.shp")
# Transform sf object to WGS84
germany_nuts3_wgs84 <- st_transform(germany_nuts3, crs = 4326)

### combine data set

# Check for differences in number of unique regions
length(unique(df$Raumeinheit)) != length(unique(germany_nuts3_wgs84$NUTS_NAME))

# Identify kreis which is not available in Inkar & remove it from srf data ("Eisenach, Kreisfreie Stadt")
same_kreis <- which(unique(substr(df$Raumeinheit, 1, 3)) %in% unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3)))
germany_nuts3_wgs84$NUTS_NAME[-which(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3) %in% unique(substr(germany_nuts3_wgs84$NUTS_NAME, 1, 3))[same_kreis])]


# merge Eisenach, Kreisfreie Stadt with Wartburgkreis 
polygons_to_merge <- germany_nuts3_wgs84 %>%
  filter(NUTS_NAME %in% c("Wartburgkreis", "Eisenach, Kreisfreie Stadt"))
merged_polygon <- st_union(polygons_to_merge)


# Remove the original polygons and add the merged one
germany_nuts3_wgs84 <- germany_nuts3_wgs84 %>%
  filter(!NUTS_NAME %in% c("Wartburgkreis", "Eisenach, Kreisfreie Stadt")) %>% # Remove old polygons
  bind_rows(
    tibble(
      NUTS_NAME = "Wartburgkreis",
      NUTS_CODE = "DEG0P", #  NUTS_CODE for Wartburgkreis
      geometry = st_sfc(merged_polygon)
    ) %>%
      st_as_sf()
  )
#  NUTS_CODE for new Wartburgkreis


#  Identify differing regions
unmatched_regions <- setdiff(unique(df$Raumeinheit), unique(germany_nuts3_wgs84$NUTS_NAME))

# Fix known cases with a mapping approach
correction_map <- c(
  "Berlin, Kreisfreie Stadt" = "Berlin",
  "Hamburg, Freie und Hansestadt" = "Hamburg",
  "Darmstadt, Wissenschaftsstadt" = "Darmstadt, Kreisfreie Stadt",
  "Friesland" = "Friesland (DE)",
  "Hagen, Stadt der FernUniversität" = "Hagen, Kreisfreie Stadt",
  "Kassel, documenta-Stadt" = "Kassel, Kreisfreie Stadt",
  "Solingen, Klingenstadt" = "Solingen, Kreisfreie Stadt",
  "Lübeck, Hansestadt" = "Lübeck, Kreisfreie Stadt",
  "Wunsiedel i.Fichtelgebirge" = "Wunsiedel i. Fichtelgebirge",
  "Mühldorf a.Inn" = "Mühldorf a. Inn"
)

df$Raumeinheit <- ifelse(df$Raumeinheit %in% names(correction_map), 
                         correction_map[df$Raumeinheit], 
                         df$Raumeinheit)

# General fixes using gsub with regex
df$Raumeinheit <- gsub("kreisfreie", "Kreisfreie", df$Raumeinheit, ignore.case = TRUE)
df$Raumeinheit <- gsub("(?<!kreis),\\s*Stadt$", ", Kreisfreie Stadt", df$Raumeinheit, perl = TRUE)
df$Raumeinheit <- gsub("Landeshauptstadt", "Kreisfreie Stadt", df$Raumeinheit)
df$Raumeinheit <- gsub("\\ba\\.d\\.(?=\\S)", "a.d. ", df$Raumeinheit, perl = TRUE)
df$Raumeinheit <- gsub("\\bi\\.d\\.(?=\\S)", "i.d. ", df$Raumeinheit, perl = TRUE)
#df$Raumeinheit <- gsub("\\bi\\.(?=\\S)", "i. ", df$Raumeinheit, perl = TRUE)
df$Raumeinheit <- gsub("\\.$", "", df$Raumeinheit)

# Handle missing regions by appending ", Landkreis" to those not ending with "Stadt"
unmatched <- setdiff(unique(df$Raumeinheit), unique(germany_nuts3_wgs84$NUTS_NAME))
df$Raumeinheit <- ifelse(
  df$Raumeinheit %in% unmatched &
    !grepl("(Stadt|, Landkreis)$", df$Raumeinheit) & 
    !grepl("\\b(a.d.|i.d.)\\b", df$Raumeinheit),
  paste0(df$Raumeinheit, ", Landkreis"),
  df$Raumeinheit
)

# Handle some entries manually (can probably be done more efficiently)
df$Raumeinheit[df$Raumeinheit == "Berlin, Kreisfreie Stadt"] = "Berlin"
df$Raumeinheit[df$Raumeinheit == "Neumarkt i.d. OPf, Landkreis"] = "Neumarkt i.d. OPf."

same_name <- sort(df$Raumeinheit) == sort(germany_nuts3_wgs84$NUTS_NAME)
diff_name_inkar <- sort(df$Raumeinheit)[!same_name]



filter <- which(df$Raumeinheit %in% diff_name_inkar)
df$Raumeinheit[filter] <- gsub("Landkreis", "Kreisfreie Stadt", diff_name_inkar)


df$Raumeinheit[df$Raumeinheit == "Weiden i.d. OPf, Kreisfreie Stadt"] <- "Weiden i.d. Opf, Kreisfreie Stadt"


# Final matching check
unmatched_regions_after_correction <- setdiff(unique(df$Raumeinheit), unique(germany_nuts3_wgs84$NUTS_NAME))
if (length(unmatched_regions_after_correction) > 0) {
  message("Unmatched regions after correction: ", paste(unmatched_regions_after_correction, collapse = ", "))
} else {
  message("All regions matched successfully.")
}

# Combine datasets
germany_nuts3_wgs84 <- germany_nuts3_wgs84 %>% rename(KR = NUTS_NAME)
df <- df %>% rename(KR = Raumeinheit)
data <- germany_nuts3_wgs84 %>%
  left_join(df, by = "KR")

# extract voting shares
voting_shares <- data.frame(
  data$Stimmenanteile.AfD,
  data$Stimmenanteile.CDU.CSU,
  data$Stimmenanteile.FDP,
  data$Stimmenanteile.SPD ,
  data$Stimmenanteile.Grüne,
  data$Stimmenanteile.Die.Linke,
  data$Stimmenanteile.Sonstige.Parteien
)
colnames(voting_shares) <- gsub("^data\\.", "", colnames(voting_shares))
voting_shares <- voting_shares / 100
any(rowSums(voting_shares) != 1) # do not all sum up to one -> clarify how to handle this

# convert data into right format for dirichlet regression
#voting_shares_dir <- DR_data(voting_shares)

# create vector with colors of political party with the most votes
max_positions <- apply(voting_shares, 1, which.max)
set_winner_colors <- setNames(
  c("blue", "black", "yellow", "red", "green", "purple", "grey"),
  colnames(voting_shares)[1:7]
)
winner_colors <- set_winner_colors[apply(voting_shares, 1, function(x)
  colnames(voting_shares)[which.max(x)])]
names(winner_colors) <- gsub("Stimmenanteile\\.","",names(winner_colors))
data$incumbant_party <- names(winner_colors)
data$color_incumbant <- winner_colors

# voting_shares radarplot 
voting_shares_radar <- cbind(KR = data$KR, voting_shares)
colnames(voting_shares_radar)[2:ncol(voting_shares_radar)] <- gsub("Stimmenanteile\\.","",colnames(voting_shares_radar)[2:ncol(voting_shares_radar)])
