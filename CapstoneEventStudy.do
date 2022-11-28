*************************
**** ECONOMICS CAPSTONE PROJECT
**** Safe Drinking Water Act
*************************

*************************
*** Regression Analysis
*************************
*** Ellie Cox
*************************

   set more off
   capture log close
   log using econCapstoneEventStudy_Cox.log, replace

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
// unemployed is omitted
// male is omitted

*************************
*************************
*** Event Study
*************************
*** generate event study year
* et_1: 1960
* et_2: 1970
* et_3: 1980
* et_4: 1990

tab nyear, gen(yr) // indicators for each year
forvalues t = 1(1)6{
		gen et_`t' = (yr`t'==1) * nTreatmentIntensity // indicator for that election year * HIVrate
	}
	egen chk = rowtotal(et_*) // assert made correctly
	assert chk==nTreatmentIntensity
	drop chk
	
* Select to omit 1980
rename et_3 omit_var

* Run the regression
reghdfe inlaborforce et_* [aw = perwt], abs(i.nyear i.nFIPS) 
outreg2 using "/Users/elizabeth/Documents/Capstone Paper/EventStudyResults_Employment", replace tex ctitle(Event Study Coefficients) label 

forvalues t = 1(1)2{
		local b_`t' = _b[et_`t']
		local se_`t' = _se[et_`t']
	}
		
forvalues t = 4(1)6{
		local b_`t' = _b[et_`t']
		local se_`t' = _se[et_`t']
	}
		

// Create figure
preserve
clear
set obs 6
				
gen b = .
gen se = .
gen t = _n
				
forvalues t = 1(1)2{
	replace b = `b_`t'' in `t' / `t'
	replace se = `se_`t'' in `t' / `t'	
	}
				
forvalues t = 4(1)6{
	replace b = `b_`t'' in `t' / `t'
	replace se = `se_`t'' in `t' / `t'	
	}
			
// Leaveout point
foreach i in b se{
	forvalues t = 3(1)3{
			replace `i' = 0 in `t'/`t'
				
	}
}	

// 90 percent CI
gen ub = b + 1.645 * se
gen lb = b - 1.645 * se
replace t = t+.5 if t>=9
					
					
// Figure
twoway (line b t if t<=4, lc(black) lp(solid) lwidth(thick)) (line b t if t>=3.5, lc(black) lp(solid) lwidth(thick)) ///
	(line ub lb t if t<=3, lc(black black) lp(dash dash)) ///
	(line ub lb t if t>=3, lc(black black) lp(dash dash)), ///
	yline(0, lc(black) lwidth(thin)) ///
	xline(3, lc(black) lwidth(thin)) ///
	ytitle("Labor Force Participation") ///
	xtitle("Year") ///
	ylab(-1(0.2)1, nogrid) ///
	xlab( 1 "1960" 2 "1970" 3 "1980" 4 "1990" 5 "2000", nogrid) ///
	legend(off)
				
	graph export "/Users/elizabeth/Documents/Capstone Paper/EventStudyPlot_Employment.pdf", replace	
	restore	
		
		





