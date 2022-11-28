*************************
**** ECONOMICS CAPSTONE PROJECT
**** Safe Drinking Water Act
*************************

*************************
*** Regression Analysis
*** On all individuals
*************************
*** Ellie Cox
*************************

   set more off
   capture log close
   log using econCapstone_Cox.log, replace

   set linesize 255
   set varabbrev off

************************
************************
*  Load dataset

clear all
use "/Users/elizabeth/Documents/Capstone Paper/EventStudyData_All.dta"
//"/Users/elizabeth/Documents/Capstone Paper/FullData.dta"

************************
************************
*** Make appropriate variables
generate nyear = real(YEAR)
generate nFIPS = real(FIPS)
generate nTreatmentIntensity = real(Treatment_Intensity)

* post variable
generate post = 0
replace post = 1 if nyear > 1985

* downstream indicator
gen down = 0
replace down = 1 if Downstream == "downstream"

* interaction terms
gen Intensity_post = nTreatmentIntensity * post
gen female_Intensity_post = nTreatmentIntensity * post * female
gen Intensity_down = nTreatmentIntensity * down 
gen down_post = down * post
gen Intensity_down_post = nTreatmentIntensity * post * down 
gen female_Intensity_down_post = nTreatmentIntensity * post * down * female
************************
************************
*** save control variables
************************
global controls "female hispanic black asian native othrace" // white is omitted category

// male is omitted

*************************
*************************
*** Diff in diff #1
*************************
xtset nFIPS nyear 
reghdfe inlaborforce Intensity_post $controls [aw = perwt], abs(i.nyear i.nFIPS)
* Save with estout
estimates store m1, title(DiffinDiff)
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/RegResults_All", tex replace ctitle(DiffInDiff) label

*************************
*************************
*** Diff in diff in diff #1 
*************************

reghdfe inlaborforce Intensity_post Intensity_down down_post Intensity_down_post $controls [aw = perwt], abs(i.nyear i.nFIPS) 
estimates store m2, title(TripleDiff)
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/RegResults_All", tex ctitle(TripleDiff) label 

***********************************
*** Goodness of fit diagnostics *** 
*** I can't bring myself to NOT look at the residuals 
* plot the residuals - these should be centered around 0 and not change over the x axis
*predict Fitted, xb
*predict Epsilon, e

*twoway (scatter Epsilon Fitted), ytitle(Epsilon residuals) xtitle(Fitted values)
* These don't look bad
* make qq plot to check the distribution 
*qnorm Epsilon
* These are a bit heavy tailed, but really only for a few outliers. Since this isn't really being used for prediction and more for the esimates. 
* Doesn't seem to be much to suggest that this would benefit from transformation





