# Safe Drinking Water Act - Economics Capstone Project

This repository includes a collection of files to evaluate the effects of access to clean drinking water on labor force outcomes. This is done using EPA Safe Drinking Water Information System Data and individual level Census data from 1960, 1970, 1980, 1990, 2000, and 2005. The files in this repository use EPA information to construct panel data in R, which is then fed into STATA for regression analysis, an event study, and various robustness checks.  

This repository includes 5 R Markdown files used to clean data for my Capstone project, and 4 Stata .do files which completed the final analysis. 
Replicating these results requires the following data:
1. violation_files (a collection of 212 .csv files containing violation information)
2. PWS (public water system data contained in 43 different .csv files)
3. frs (The Facility Registry Service, labeled national_single.csv)
4. elevationdata (The Geographic Information Names System, labeled NationalFile_20210825.txt)
5. county_adjacency (NBER County Adjacency Data)
6. controls (U.S. Individual level Census Data, labeled usa_0009.csv)

The files are meant to be run in the following order (earlier files create a data frame that is then used by later files)
1. SDWA_ConstructVariables.Rmd
2. NHD_Flowline.Rmd
3. ConstructIntensiveData.Rmd AND ConstructExtensiveData.Rmd 
4. .do files in any order

Following is a description of what each file does:

SDWA_ConstructVariables.Rmd: This file reads in a directory of 212 violation .csv data, a directory of 43 .csv files containing PWS data, and data from the EPA Facility Registry Service. This file merges these sources together to create a variable indicating the ratio of violating facilities to total facilities in a county by year. This file saves an .Rdata file labeled *SDWA_Data.Rdata*, which is used for further data construction.

NHD_Flowline.Rmd: This file namely creates an indicator variable for whether or not a county is downstream of a high violating county in 1985 (baseline). This is done by combining *SDWA_Data.Rdata* with county adjacency and elevation data. This file outputs another Rdata file which is fed into the next file, named *RightHandSide.Rdata*.

ConstructIntensiveData.Rmd and ConstructExtensiveData.Rmd: These two files are largely the same, except in that one is meant for regression using hours worked last week and one using the labor force participation rate. These files combine water data with Census labor data and save .dta files that are fed into STATA. These files are created separately because the use of hours worked last week requires that the sample be limited to individuals who are employed (to capture the intensive labor effect) but not when using labor force participation. 

SDWA_ConstructVariables.Rmd: Uses saved *RightHandSide.Rdata* to construct visual aids that describe the variation present in water data. Namely, this produces maps and several line plots. 

CapstoneRegression.do: Takes the panel data created in *ConstructIntensiveData.Rmd* to calculate difference-in-difference and triple difference effects using hours worked last week as an outcome. This also computes a reduced form result using only the downstream indicator and the post indicator variable. This additionally automatically generates .tex files that produce tables that are included in the Appendix of my report. 

CapstoneRegressionExtensive.do: Closely follows what *CapstoneRegression.do* does, except it computes results when using the extensive dataset. This also generates .tex files which output result tables. 

CapstoneEventStudy.do: Uses labor data to estimate event study results that accompany a difference-in-differences approach when using hours worked last week and labor force participation as outcome variables. This also generates event study plots and .tex files that creates tables with the estimated coefficients.

CapstoneRegression_Robustness.do: Follows *CapstoneRegression.do* closely, except that estimates are now computed using a sample of counties who had reported a violation in 1985. Generates a table of these results which uses both difference-in-differences and triple difference strategies.
