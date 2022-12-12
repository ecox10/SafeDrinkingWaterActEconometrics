*************************
**** ECONOMICS CAPSTONE PROJECT
**** Safe Drinking Water Act
*************************

*************************
*** Regression Analysis
*** On EMPLOYED individuals
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
use "/Users/elizabeth/Documents/Capstone Paper/EventStudyData_Employed.dta"

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
reghdfe hrs Intensity_post $controls [aw = perwt], abs(i.nyear i.nFIPS) vce(cluster nFIPS)
* Save with estout
estimates store m1, title(DiffinDiff)
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/RegResults_Employed", tex replace ctitle(DiffInDiff) label

*************************
*************************
*** Diff in diff in diff #1 
*************************

reghdfe hrs Intensity_post Intensity_down down_post Intensity_down_post $controls [aw = perwt], abs(i.nyear i.nFIPS) vce(cluster nFIPS) resid
estimates store m2, title(TripleDiff)
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/RegResults_Employed", tex ctitle(TripleDiff) label 

***********************************
*** Goodness of fit diagnostics *** 
*** Residual analysis is used to indicate whether or not there is evidence of heteroskedastic residuals
*** I tend to only include clustered standard errors if this initial analysis suggests that 
*** the residuals are not normally distributed.
* plot the residuals - these should be centered around 0 and not change over the x axis
predict Fitted, xb
predict resid, r

twoway (scatter resid Fitted), ytitle(Epsilon residuals) xtitle(Fitted values)
* These don't look great. The magnitude is higher in the center fitted values.
* make qq plot to check the distribution 
qnorm resid
* These are a bit heavy tailed, but really only for a few outliers. Since this isn't really being used for prediction and more for the esimates, this isn't necessarily a big deal
* These *could* be heteroskedastic. 

* Let's use the swilk test to go one step further
swilk resid
* This is significant, so I added clustered standard errors 

*************************
*************************
*** Reduced Form - Just using downstream 
*************************

reghdfe hrs down_post $controls [aw = perwt], abs(i.nyear i.nFIPS) 
estimates store m2, title(TripleDiff)
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/RegResults_ReducedForm_Hours", replace tex ctitle(DiffinDiff) label 








