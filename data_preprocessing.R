df <- read.csv2("data/preliminary_data.csv")

year_column <- df[1,] 

df <- df[-1,]
# extract proportions
y <- data.frame(df$Stimmenanteile.AfD,df$Stimmenanteile.CDU.CSU, df$Stimmenanteile.FDP,df$Stimmenanteile.SPD ,df$Stimmenanteile.Grüne, df$Stimmenanteile.Die.Linke, df$Stimmenanteile.Sonstige.Parteien)
colnames(y) <- gsub("^df\\.", "", colnames(y))
y <- y/100 # convert proportions to interval [0,1]
rowSums(y) # do not all sum up to exactly 1

# exclude proportions from data frame containing explanatory variables
X <- df[, !names(df) %in% colnames(y)]


library(DirichletReg)
