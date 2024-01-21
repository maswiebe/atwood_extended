clear all
set more off

*cd "$logs" 
* log using "census_false_cleaning", replace 

*clean the ACS data from IPUMS
/* cd "$raw_data"
use false_19601970_census.dta, clear */
use "$atwood_data/false_19601970_census.dta", clear

**********************************************
**********************************************
*Inclusion criteria 
**********************************************
**********************************************

*keep only the 25<age<=60
keep if inrange(age,25,60)
/* keep if age>25
keep if age<=60 */


*keep only those native born
keep if bpl<57
/* generate native=bpl<57
replace native=. if bpl==.

keep if native==1 */


*keep only black and white observations
/* gen white=race==1 */
gen black=race==2
/* gen other=race>2 */

/* gen blackwhite=1 if white==1 | black==1 */

/* keep if blackwhite==1 */



**********************************************
**********************************************
*OUTCOME VARIABLES
**********************************************
**********************************************

*labor force participation
gen labforcepart=labforce==2
*employed
gen employed=empstat==1

*generate years of schooling
*generate other educational groups
gen edu_years2=0 if educ==0
replace edu_years2=9 if educ==3
replace edu_years2=10 if educ==4
replace edu_years2=11 if educ==5
replace edu_years2=12 if educ==6
replace edu_years2=13 if educ==7
replace edu_years2=14 if educ==8
replace edu_years2=15 if educ==9
replace edu_years2=16 if educ==10
replace edu_years2=17 if educ==11

replace edu_years2=0 if educ==1 & educd==0
replace edu_years2=0 if educ==1 & educd==1
replace edu_years2=0 if educ==1 & educd==2
replace edu_years2=0 if educ==1 & educd==11
replace edu_years2=0 if educ==1 & educd==12

replace edu_years2=1 if educ==1 & educd==14
replace edu_years2=2 if educ==1 & educd==15
replace edu_years2=3 if educ==1 & educd==16
replace edu_years2=4 if educ==1 & educd==17

replace edu_years2=5 if educ==2 & educd==22
replace edu_years2=6 if educ==2 & educd==23
replace edu_years2=7 if educ==2 & educd==25
replace edu_years2=8 if educ==2 & educd==26

*interaction for birthplace and education years
gen bpl_edu=bpl*edu_years2
*interaction for birth year and education
gen byr_edu=birthyr*edu_years2



generate post_vaccine=year>=1964


*********************************************
**********************************************
*Create control variables
**********************************************
**********************************************


*female
gen female=sex==2

*interactions 
gen sexpost=sex*post
gen racepost=race*post
gen blackfemale=black*female
gen femalepost=female*post
gen blackfemalepost=blackfemale*post
gen blackpost=black*post


*metro has three categories - rural, city, suburbs
gen metropost=metro*post
gen rural=metro==1
replace rural=. if metro==.
gen ruralpost=rural*post


*family income cubed
*make negative values and 9999999 values = .
gen famincome=ftotinc
replace famincome=. if ftotinc<0
replace famincome=. if ftotinc==9999999
gen famincome2=famincome*famincome
gen famincome3=famincome*famincome*famincome


/* cd "$data"
save false_19601970_census_cleaned.dta, replace  */



*merge with inc_rate.dta
/* cd "$data"
use inc_rate.dta, clear

rename state bpl_state
rename statefip bpl

keep avg_12yr_measles_rate bpl_state bpl */

/* cd "$data" */
/* merge 1:m bpl using false_19601970_census_cleaned.dta */
merge m:1 bpl using "$data/inc_rate.dta"
drop _merge

generate M_post_rate=avg_12yr_measles_rate*post_vaccine 
generate M_post_rate_scale=(avg_12yr_measles_rate*post_vaccine)/100000

/* cd "$data"
save false_19601970_census_cleaned.dta, replace  */
*save $data/false_19601970_census_cleaned.dta, replace 
** MW: not used



*---------------------------------------------------
* 1960 census data: state characteristics

gen logfamincome = log(famincome)
* drop zeros

collapse employed1960=employed edu1960=edu_years2 logfamincome1960=logfamincome if year==1960, by(statefip)
* use state of residence, not state of birth
    * want contemporaneous values by state
rename statefip bpl
* need same key name for merging

save "$data/census1960.dta", replace

*log close
