tmax.quantile.reg = function (month,month.index,lat.start,lon.start,n.lat,yr.start,yr.end){
print("DON'T PANIC")
start.time=Sys.time()

##### User specified inputs #####
#month="jan"
#month.index=jan #just enter it twice man
#lat.start=1
#lon.start=3000
#n.lat=5268
#yr.start=1980 ; yr.end=2014

##### Define tmax fileNames to read in #####
year=c(yr.start:yr.end)
fileName=c()
for (i in 1:length(year)){
  fileName[i]=paste("/scratch/PI/omramom/Daymet/tmax/tmax_",year[i],".nc4",sep="")
}

##### Extract Tmax Values #####
tmax.extract= function(lat.start,lon.start,n.lat,n.lon,month.index,fileName){
  pb = txtProgressBar(min = 0, max = length(fileName), style = 3) #progress bar in terminal output
  tmax=rep(NA,length(month.index)) #initialize
  d=matrix(data=NA,nrow=n.lat,ncol=length(month.index)) #initialize
  for (i in 1:length(fileName)){
    tmax = ncvar_get(nc_open(fileName[i]),"tmax",start=c(lat.start,lon.start,min(month.index)),count=c(n.lat,n.lon,length(month.index)))
    #tmax = tmax + rnorm(length(month.index)*length(fileName),mean=0,sd=.01)
    #opens each yearly data file, finds variable of interest, and extracts based on bounds specified
    d=data.frame(d,tmax) #each year's data is added as a new row to data frame 'd'
    setTxtProgressBar(pb, i) #for the progress bar
  }
  d=d[,-c(1:length(month.index))] #cleans out things left over from initializing
  close(pb) #close progress bar
  return(d) #output of function is the tmax values, each row a year 
  #output of this, if applied with n.lon=1, will be 5268 x 1085 (for Jan. 1085=35yr*31days).
} 

tmax.extracts=tmax.extract(lat.start,lon.start,n.lat,n.lon=1,month.index,fileName)
tmax.extracts=tmax.extracts+273.15 #I was getting a warning message that in summary.rq(...) "3 non-positive fis" where the number could change
#That error I guess means that the slope was so small that the algorithm actually calculated the slope's SE as a negative value. Making all the 
#observations larger by converting to Kelvin will increase the slope estimate sizes and hopefully avoid this
print(Sys.time()-start.time) #time elapsed



##### Define Tmax ocean mask #####
ncdfHandle = nc_open('/scratch/PI/omramom/Daymet/Daily/tmax/tmax_1980001.nc4')
tmax.grid = ncvar_get(ncdfHandle, "tmax"); rm(ncdfHandle)
tmax.mask=!is.na(tmax.grid); rm(tmax.grid) #tmax.mask is same x-y grid, but 0's if NAs, 1's if Land


##### Run quantile regression and save results #####
#Define your predictor variable, 'year'
n.years=yr.end-yr.start+1
n.days=length(month.index)
year=matrix(rep(NA,n.days*n.years),ncol=n.years)
for (years in yr.start:yr.end){
  #year[,years-yr.start+1]=rep(years,n.days) 
  year[,years-yr.start+1]=seq(years,years+1,length.out=365)[month.index]
}
year=as.vector(year)

#define quantile regressions you want to run, which quantiles, method for estimating standard error
fit.rq=function(year,tmax){
  a=tryCatch(summary(rq(tmax~year,.05))$coefficient[1,1:2], error=function(e) c(NA,NA)) #intercept and SE
  #b=summary(rq(tmax~year,.05),se="boot")$coefficient[2,1:2]
  b=tryCatch(summary(rq(tmax~year,.05))$coefficient[2,1:2], error=function(e) c(NA,NA)) #slope for 'year' and SE
  fit1=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.10))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.10))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit2=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.25))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.25))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit3=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.50))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.50))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit4=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.75))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.75))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit5=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.90))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.90))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit6=c(a,b)
  a=tryCatch(summary(rq(tmax~year,.95))$coefficient[1,1:2], error=function(e) c(NA,NA))
  b=tryCatch(summary(rq(tmax~year,.95))$coefficient[2,1:2], error=function(e) c(NA,NA))
  fit7=c(a,b)
  fit=c(fit1,fit2,fit3,fit4,fit5,fit6,fit7)
  return(fit)
}

#Run the quantile regression function on tmax data
start.time2=Sys.time()
tmax.extractss=as.matrix(tmax.extracts) #rq function prefers matrix format
#tmax.extractss=tmax.extractss+rnorm((dim(tmax.extracts)[1]*dim(tmax.extracts)[2]),mean=0,sd=.1) #Added small bit of random noise
#to the tmax values b/c getting error message "Error info = 2 in stepy: singular design" meaning the observation matrix was singular.
#That throws off the algorithm and can be due to lots of repeated values. There's only one observation per X value, so idk why this is 
#still coming up as an error, but hopefully this will fix it. It doesn't.
#year=year+rnorm(length(year),mean=0,sd=.1)

rm(tmax.extracts) #clear up memory
tmax.extracts.rq=data.frame() #initialize
n.na=0 #initialize
pb = txtProgressBar(min = 0, max = dim(tmax.extractss)[1], style = 3)

for (i in 1:dim(tmax.extractss)[1]) {
  
  #If true (land), compute the quantile regression and store results in a new row of tmax.extracts.rq
  if (tmax.mask[lat.start-1+i,lon.start]=='TRUE'){
    fits=fit.rq(year,tmax.extractss[i,])
    tmax.extracts.rq=rbind(tmax.extracts.rq,fits)
  }
  else { #If over ocean/lakes fill row with NA's
    fits=rep(NA,28) #28 comes from 4 values at 7 tau/quantile levels
    tmax.extracts.rq=rbind(tmax.extracts.rq,fits)
    n.na=n.na+1 #counts # of NA's; the # that you skip
  }
  setTxtProgressBar(pb, i)
}
close(pb)
print(Sys.time()-start.time2)
#Procedure check below; #times you skipped doing the quantile regression above should equal the number of NA's in the original tmax dataset that we extracted
n.na.true=sum((tmax.mask[lat.start:(lat.start+n.lat-1),lon.start])=='FALSE') #true number of NA's
if (n.na==n.na.true){
  print("YAY")
}  else {
  print("YA DUN GOOFED")
}


##### Output quantile regression results to a csv file #####
out.name=paste("/scratch/users/tballard/tmax.extracts/tmax.extracts.rq.",month,".",lat.start,
               ".",lon.start,".",n.lat,".csv",sep="")
write.csv(tmax.extracts.rq,out.name)

print(Sys.time()-start.time)
return(tmax.extracts.rq)
}
