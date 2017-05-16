# quantile_regression
Applies monthly quantile regression to Daymet tmax daily data (tmin scripts not shown). Example scripts shown, which need to be run in parallel over longitude bins given Daymet's high resolution.

tmax.annual.fxn.R: Contains most of the general code for reading in data and running quantile regression according to user specifications.

tmax.lon.loop: Takes the raw Daymet tmax data and runs quantile regression on it. Output
needs to be reordered/cleaned using the compile.coef and compile.se scripts.

compile.coef: Takes the raw metadata output from running either the tmax.lon.loop or 
tmin.lon.loop and creates .csv files that contain just the coefficient values from the 
regression for a particular quantile. 

compile.se: Takes the raw metadata output from running either the tmax.lon.loop or 
tmin.lon.loop and creates .csv files that contain just the standard error values from the 
regression for a particular quantile. 

plot.coef: Makes plots for each quantile of the coefficient values from quantile 
regression. Makes both a normal plot and a plot adjusted so that values within 2 SE's
are assigned a value of NA.
