suppressMessages(library(ncdf4))
suppressMessages(library(fields))
suppressMessages(library(RColorBrewer))

source('plot.coef.month.specification.R') #contains the 'month' value
source('/scratch/users/tballard/code/plot.coef/tmax/plot.coef.specifications.R') #contains some plot specs and directory for saving plots

quantile=.05; quant=".05" #just type it twice OK

filename=paste("/scratch/users/tballard/tmax.extracts/cleaned/tmax.",month,".coef",quant,".csv",sep="")
filename2=paste("/scratch/users/tballard/tmax.extracts/cleaned/tmax.",month,".se",quant,".csv",sep="")

#### Read in coefficient values from quantile regression ####
coef=read.csv(filename,head=T)

#### Read in Standard Error values from quantile regression ####
se=read.csv(filename2,head=T)


#### Use one of the tmax files to get the lat and lon grids loaded ####
ncdfHandle <- nc_open('/scratch/PI/omramom/Daymet/Daily/tmax/tmax_1980001.nc4')
#Longitudinal coordinates
lon = ncvar_get(ncdfHandle, "lon")
#Latitudinal coordinates  
lat = ncvar_get(ncdfHandle, "lat")

#lat, lon, and coef are all grids/matrices (5268x4283) but for the plotting command it wants
#them as single vectors of length 5268*4823=25,407,564. Note lon and lat are both matrices, whereas
#coef is a data.frame that needs to be converted to a matrix.

lon2=as.vector(lon); rm(lon) 
lat2=as.vector(lat); rm(lat)
coef2=as.vector(as.matrix(coef)); rm(coef)
se2=as.vector(as.matrix(se)); rm(se)


#### Plot and save to PDF ####
plot.name=paste(dir,"plot.tmax.",month,".coef",quant,".png",sep="")
#color.scale=colorRampPalette(brewer.pal(9,"Reds"))(100)
png(plot.name, units="px", width=plot.width, height=plot.height, res=plot.res)

	quilt.plot(lon2,lat2,coef2,nx=5268,ny=4823,nlevel=64,
    	       ,zlim=legend.lim) 
	US(add=T,col="black",lwd=.7)
dev.off() #close plotting window (saves png results)


#### Adjust for +/- 2 Standard Errors ####
diffs= abs(coef2)-1.96*abs(se2) #if negative, than 2SE's will contain zero
coef.adj=rep(NA,length(coef2))
for (i in 1:length(coef2)) {
	if (diffs[i]>0 & !is.na(diffs[i])){
		coef.adj[i]=coef2[i]
	}
}

rm(coef2); rm(diffs); rm(se2)
plot.name=paste(dir,"plot.tmax.",month,".coef",quant,".adj.se.png",sep="")
png(plot.name, units="px", width=plot.width, height=plot.height, res=plot.res)

	quilt.plot(lon2,lat2,coef.adj,nx=5268,ny=4823,nlevel=64,
           		,zlim=legend.lim) 
	US(add=T,col="black",lwd=.7)
dev.off() #close plotting window (saves png results)
