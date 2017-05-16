start.time=Sys.time()
suppressMessages(library(ncdf4)) #Load necessary R packages
suppressMessages(library(fields))
suppressMessages(library(quantreg))

source('tmax.annual.fxn.R') #Load tmax.quantile.reg function
source('tmax.lon.loop.specifications.R') #Load in the data specifications

##### Run the code #####
iters=c(1:200) #longitude values (range from 1 to 4823)
sapply(iters,tmax.quantile.reg,month=month,month.index=month.index,lat.start=1,n.lat=n.lat,yr.start=yr.start,yr.end=yr.end)


print(Sys.time()-start.time) #prints total computation time

#sapply applies the tmax.quantile.reg function to 'iters', with the inputs to the 
#tmax.quantile.reg function defined after, such as the value for month.