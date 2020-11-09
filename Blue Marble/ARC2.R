# ARC2downloader.R
# Bilal Mughal; bilal@bluemarblemicro.com
# All rights reserved
#
# Download ARC2 daily means files from 1983 01 01 to today and save in working directory

# Clear everything
#rm(list=ls(all=TRUE))

# INPUT working directory
#setwd("E:/Blue Marble")

# INPUT start and end dates as "YYYY-MM-DD", or use system date function for upto latest data
start.date <- match.arg(start_date)
end.date   <- match.arg(end_date) # use this for upto latest data

# create a vector of dates in required character format
date.list  <- c(as.Date(start.date): as.Date(end.date))             # returns as an integer vector
date.chr   <- format(as.Date(date.list, origin = "1970-01-01"), "%Y%m%d")

# Main loop
for(day in 1:length(date.list)) {
  date.chr.d <- date.chr[day]
  print(paste0("Downloading data for ", date.chr.d)) 
  
  noaa.url   <- "ftp://ftp.cpc.ncep.noaa.gov/fews/fewsdata/africa/arc2/bin/daily_clim.bin."
  download.file(paste0(noaa.url,date.chr.d,".gz"), paste0(getwd(),"/daily_clim.bin.",date.chr.d,".gz"))
  
  closeAllConnections()
  
}
