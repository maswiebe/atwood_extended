** MW: my changes are denoted with "** MW"

clear all
set more off

/* cd "$logs" 
log using "acs_cleaning", replace  */
*log using "$logs/acs_cleaning", replace 

** MW: clean raw data from IPUMS
cd "$data"
* need to set working directory to folder containing the IPUMS extract
do "usa_00003.do"
* save "$data/acs_raw.dta", replace 
cd "$root"

use "$data/acs_raw.dta", clear

*clean the ACS data from IPUMS
/* cd "$raw_data"
use longrun_20002017_acs.dta, clear */

**********************************************
**********************************************
*Inclusion criteria 
**********************************************
**********************************************

*keep only those 25 < age < 60 
/* keep if age>25
keep if age<60 */

*keep only those native born
/* generate native=bpl<57
replace native=. if bpl==.
keep if native==1 */

*keep only black and white observations
/* gen white=race==1 */
gen black = (race==2)
/* gen other=race>2 */

/* gen blackwhite=1 if white==1 | black==1
keep if blackwhite==1 */

**********************************************
**********************************************
*Create control variables
**********************************************
**********************************************

* create exposure variable for interaction terms
gen exposure=0 if birthyr<=1948
replace exposure=16 if birthyr>=1964

forvalues i = 1/16 {
    local by = 1948 + `i'
    replace exposure = `i' if birthyr == `by'
}


/* replace exposure=1 if birthyr==1949
replace exposure=2 if birthyr==1950
replace exposure=3 if birthyr==1951
replace exposure=4 if birthyr==1952
replace exposure=5 if birthyr==1953
replace exposure=6 if birthyr==1954
replace exposure=7 if birthyr==1955
replace exposure=8 if birthyr==1956
replace exposure=9 if birthyr==1957
replace exposure=10 if birthyr==1958
replace exposure=11 if birthyr==1959
replace exposure=12 if birthyr==1960
replace exposure=13 if birthyr==1961
replace exposure=14 if birthyr==1962
replace exposure=15 if birthyr==1963
replace exposure=16 if birthyr>1963 */
* Note: Atwood assumes that someone born in 1963 has no exposure to the vaccine in 1963, which came out on March 21, 1963
* NYT article March 23, 1963: 100,000 doses distributed by Merck

*create female identifier
gen female = (sex==2)

*create control varaibles for regressions
*dummy for age*black
/* egen ageblack=group(age black)
*dummy for age*female
egen agefemale=group(age female)
*dummy for black*female
gen blackfemale=black*female
*dummy for age*black*female
egen ageblackfemale=group(age black female)
*interaction for birthplace and black
gen bpl_black=bpl*black
*interaction for birthplace and female
gen bpl_female=bpl*female
*interaction for birthplace and black female
gen bpl_black_female=bpl*black*female */

** MW: use interactions for fixed effects in reghdfe

**********************************************
**********************************************
*OUTCOME VARIABLES
**********************************************
**********************************************

*create log of income - wage and salary
/* gen ln_income=log(incwage) */

*CPI adjusted income (put in 1999 dollars and then adjusted to 2018 dollars)
/* gen cpi_incwage=incwage*cpi99*1.507 */
gen cpi_incwage=incwage*cpi99/0.663
** MW: https://usa.ipums.org/usa/cpi99.shtml
    * conversion factor from 2018 to 1999 dollars: 0.663
    * 1/0.663 = 1.5083

gen ln_cpi_income=log(cpi_incwage)

*create poverty identifier
gen poverty100=poverty<101
replace poverty100=. if poverty==0

*create hours worked per week variable
gen hrs_worked=uhrswork if !missing(uhrswork)

*create employment status variable 
gen employed=empstat==1
replace employed=. if empstat==3
 
*create a non-0 income variable 
gen cpi_incwage_no0=cpi_incwage
replace cpi_incwage_no0=. if cpi_incwage==0 

/* cd "$data"
save longrun_20002017acs_cleaned.dta, replace  */

*merge with inc_rate.dta
/* cd "$data"
use inc_rate.dta, clear

rename state bpl_state
rename statefip bpl

keep bpl* avg*

cd "$data"
merge 1:m bpl using longrun_20002017acs_cleaned.dta */

** MW: I renamed statefip in rates.do
merge m:1 bpl using "$data/inc_rate.dta"


*create the differnt M_exp_rate variables
*scale M_exp so coeficients are reader friendly
*from changes measles rate from 964 per 100000 to .00964
/* local i = 2
while `i' <= 12 {

generate M`i'_exp_rate=(avg_`i'yr_measles_rate*exposure)/100000 

local i = `i' + 1 
} */

** MW: not using 2-11
local i = 12
generate M`i'_exp_rate=(avg_`i'yr_measles_rate*exposure)/100000

** MW: other diseases
gen pertussis_exp = avg_pertussis_rate*exposure/100000
gen chicken_pox_exp = avg_chicken_pox_rate*exposure/100000
gen mumps_exp = avg_mumps_rate*exposure/100000
gen rubella_exp = avg_rubella_rate*exposure/100000

** MW: use reghdfe
/* xi i.bpl */

*create state of birth-cohort variable 
/* egen bplcohort=group(bpl birthyr) */

merge m:1 bpl using "$data/census1960.dta", nogen
* merge ACS data by state-of-birth (bpl) to 1960 census states
    * ie. assign each individual the 1960 state characteristic from their state-of-birth, not their state-of-residence


compress
/* cd "$data"
save longrun_20002017acs_cleaned.dta, replace  */
save "$data/acs_cleaned.dta", replace

*log close
