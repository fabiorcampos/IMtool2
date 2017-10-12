# Load the package
installed.packages("eurostat")
library(devtools)
install_github("ropengov/eurostat")
library(eurostat)
library(rvest)
# Get Eurostat data listing
toc <-get_eurostat_toc()
# Check the first items
library(knitr)
kable(head(toc))

# Search for Themes
kable(head(search_eurostat("cars"), n = 15))

# Check Id
id <- search_eurostat("Passenger cars, by alternative motor energy and by power of vehicles",
                      type = "dataset")$code[1]

# Download Dataset
dat <-get_eurostat(id, time_format = "num", type = "label")

# Check data
str(dat)
head(dat)
df <- data.frame(dat)
table(df$prod_nrg); table(df$unit); table(df$time); table(df$geo)

# Subset by type of energy
elec <- subset(df, prod_nrg == "Electrical Energy", select = c(geo, time, values))
gas <- subset(df, prod_nrg == "Natural Gas", select = c(geo, time, values))
lpg <- subset(df, prod_nrg == "LPG", select = c(geo, time, values))
other <- subset(df, prod_nrg == "Other products", select = c(geo, time, values))
total <- subset(df, prod_nrg == "Total", select = c(geo, time, values)) 
      
# Total analysis
el.date <- aggregate(values ~ time, elec, sum)
gas.date <- aggregate(values ~ time, gas, sum)
lpg.date <- aggregate(values ~ time, lpg, sum)
other.date <- aggregate(values ~ time, other, sum)
total.date <- aggregate(values ~ time, total, sum)

# Plot by Sector/Years
p <- plot(el.date, type='o', 
          col="red", 
          ylab="Amount of Eur(millions)", 
          xlab="Years",
          ylim = c(0, 10000))

points(values ~ time, data=gas.date, type='b', col="green")
points(values ~ time, data=lpg.date, type='l',lty=2, col="blue")
points(values ~ time, data=other.date, type='l', col="orange")
title(main="Investiment in Automotive Sector in UE", col.main="black", font.main=4)
legend("topleft", 
       c("Electric", "Gas", "Lpg", "Other"), 
       lty = c(1,1,1,1), 
       col = c("red", "green", "blue", "orange"))


# Analysis by Country

# Total analysis
total.geo <- aggregate(values ~ geo, total, sum)
boxplot(total.geo$values)

# Dendogram
dd <- dist(scale(total.geo$values), method = "euclidean")
name <- as.factor(total.geo$geo)
hc <- hclust(dd, method = "ward.D2")
plot(hc)
