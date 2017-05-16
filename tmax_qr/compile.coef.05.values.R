#This script takes the large tmin.extracts.csv files and takes a particular column 
#(all lat values for a particular coefficient or SE from the regression output), 
#loops over all the different values (over all the lon values) and combines them 
#all into the ouput, a 5268x4823 grid of coefficient or SE values for the quantile 
#you specified. Now these values can be plotted.

suppressMessages(library(ncdf4))
source('compile.month.specification.R')

quantile=.05; quant=".05" #just type it twice OK
#month="dec"
lat.start=1
n.lat=5268 
n.lon=4823

#Create the list of all 4823 tmin filenames to read in:
fileName=c()
for (i in 1:n.lon){
  fileName[i]=paste("/scratch/users/tballard/tmin.extracts/tmin.extracts.rq.",month,".",lat.start,
               ".",i,".",n.lat,".csv",sep="")
}

#Loop over all the file names, extract the regression output variable of interest
pb = txtProgressBar(min = 0, max = n.lon, style = 3)
d=matrix(data=NA,nrow=n.lat,ncol=1) #initialize with a column of NA's that you'll delete after
for (i in 1:n.lon){
  m=read.csv(fileName[i],head=T)
  coef=m[,4]; #se.05[i]=m[,5]
  d=data.frame(d,coef) #add this lon's coef files to a growing data frame 'd' of values
  setTxtProgressBar(pb, i)
}
d=d[,-1] #delete the first column of NA's you used to initialize it

#Output the resulting data frame to new .csv file
out.name=paste("/scratch/users/tballard/tmin.extracts/cleaned/tmin.",month,".coef",quant,".csv",sep="")
write.csv(d,out.name,row.names=F)
