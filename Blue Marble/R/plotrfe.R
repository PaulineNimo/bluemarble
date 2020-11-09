plotrfe <- function(start_date,end_date,clicklat,clicklong){
		
		start.date <- match.arg(start_date)
		end.date   <- match.arg(end_date) # use this for upto latest data
		clicklat <- match.arg(clicklat)
		clicklong <- match.arg(clicklong)
		
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
		
		# Set longitude, latitude, date corresponding to zim_rfe array [long index,lat index,date index]
		zim_long       <- seq(25.0,33.5,0.1)                        # longitude from 25.0E to 33.5E in increments of 0.1 degrees
		zim_lat        <- seq(-22.5,-15.5,0.1)                      # latitude from 25.0E to 33.5E in increments of 0.1 degrees
		zim_date       <- format(as.Date(date.list, origin = "1970-01-01"), "%d %b %Y")
		
		# Main loop: recursively add each date data to pre-existing zim_rfe vector and dimensionalize into 3d array in the end
		zim_rfe   <- NULL 
		for(day in 1:length(date.list)) {
			date.chr.d <- date.chr[day]
			print(paste0("Reading/downloading data for ", date.chr.d)) 
			
			# read an unzipped binary file on disk if the NOAA data is available locally in unzipped format
			nveclen   <- as.integer(751*801)
			myFile    <- paste0(getwd(), "/daily_clim.bin.", date.chr.d, ".gz")
			p         <- gzcon(file(myFile, "rb"))
			afr_rfe   <- readBin(p, "numeric", n=nveclen, size = 4, endian = "big")
			close(p)
			
			# read a zipped binary file from the NOAA ARC2 ftp server
			# noaa.url   <- "ftp://ftp.cpc.ncep.noaa.gov/fews/fewsdata/africa/arc2/bin/daily_clim.bin."
			# p          <- gzcon( url( paste0( noaa.url, date.chr.d, ".gz" ) ) )
			# afr_rfe    <- readBin( p, "numeric", n=1e6, size = 4, endian = "big" )
			# close (p)
			
			# afr_rfe is a numeric vector of rainfall estimates of length 601551 looping through longitudes and latitudes for all of africa
			# it's order is Southwest to Northeast, with outer loop being latitudes and inner loop being longitutes
			# Africa data extent in degrees is -20W to 55E in longitude and -40S to 40N in latitude in increments of 0.1 degree
			# This corresponds to a grid of 751 (longitude) x 801 (latitude)
			# Zimbabwe extent is +25.0E to +33.5E in longitude and -22.5S to -15.5S in latitude
			# This corresponds to array subset in indices of [long, lat] = [451:536, 176:246] (86*71) of the complete africa dataset
			
			# convert afr_rfe into a matrix (long,lat), extract zim_rfe subset and remove the larger africa data set
			# zim_rfe is a 3d array with dimensions [longitude index, lattitude index, date in R numeric format]
			dim(afr_rfe)   <- c(751,801)
			
			zim_rfe.t      <- afr_rfe[451:536,176:246]
			zim_rfe        <- c(zim_rfe, zim_rfe.t)
			
			rm(afr_rfe)
			
		}
		
		zim_file       <- paste0(getwd(),"/ARC2rfe",start.date,"_",end.date,".bin")
		writeBin(zim_rfe, zim_file , size = 4, endian = "big")
		
		dim(zim_rfe)   <- c(86,71,length(date.list))
		
		lat_index = zim_lat[clicklat]
		long_index = zim_long[clicklong]
		
		data <- zim_rfe[lat_index,long_index,]
		new_data <- data.frame(zim_date,data)
		library(ggplot2)
		rfeplot <- ggplot(new_data,aes(x=zim_date,y=data))+
			geom_bar(stat = "identity",fill = "steel blue")+
			ylab("Rainfall")+
			xlab("Time")+
			theme(axis.text.x = element_text(angle = 45, hjust = 1))
		
		
		print(rfeplot)

}
