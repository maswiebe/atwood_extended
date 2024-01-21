clear all
set more off

/* cd "$logs" 
log using "rates", replace  */
*log using "$logs/rates", replace


*CALCULATE MEASLES INCIDENCE RATES

/* cd "$raw_data" 
use case_counts_population.dta, clear */
use "$atwood_data/case_counts_population.dta", clear

** MW: errors in population variable
    * some in raw data (AGES_17 variable), most in `population` (and fixable by regenerating the variable)
replace AGE5_17 = 2618000 if state=="OH" & year==1963
replace AGE5_17 = 2859000 if state=="TX" & year==1965
replace AGE5_17 = 171000 if state=="NH" & year==1966
* https://www2.census.gov/library/publications/1968/demographics/P25-384.pdf
    * p.14: Ohio 1963 is 2618000, not 2168000
* https://www2.census.gov/library/publications/1969/demographics/P25-420.pdf
    * p.13: Texas 1965: 2859000, not 1285400
    * p.12: NH 1966: 171000, not 1717000

gen childpop = UNDER_5 + AGE5_17 if missing(UNDER_5)==0
replace childpop = population if missing(UNDER_5)
drop population
rename childpop population

replace measles = 0 if state=="WY" & year==1969
* actually 0, not missing: https://stacks.cdc.gov/view/cdc/838
    * Table 6 has a '—', but page 2 explains that this is 'quantity zero'.

* save corrections
save "$atwood_data/case_counts_population.dta", replace



** MW: testing
    * delete later
*use "$data/case_counts_population.dta", clear
* does this method give a different avg_12yr_measles_rate? yes, and different median, and composition of high/low
    * it does include Kansas
    * median: 1001.034, n=51
    * high=1 for 26, 0 for 25
    * alaska: high=1, kansas: high=1
    * mean cpi_incwage: high=0: 34535, high=1: 34755
        * could change the composition of high and low, since adding two states to high, pushing one to low
        * haven't reran table2 estimates
        * would be surprising if results were so sensitive
            * could make an argumen for excluding KS, only data for 52-56; but AK should be included
* original way:
    * median: 992
    * high=1 for 25, 0 for 24
    * missing: bpl=2, 20; alaska, kansas
    * mean cpi_incwage: high=0: 33513, high=1: 36121
        * difference is from including AK and KS to high_measles, pushing Idaho to Low
        * adding low income states to High




** MW: don't reshape
    * this defines a nonmissing average for Kansas: has data for 52-56
    * and Alaska: data for 1957-75
keep population state statefip bpl_region4 bpl_region9 year measles pertussis chicken_pox mumps rubella

gen measles_rate = (measles/population)*100000
gegen temp_avg_12yr_measles_rate = mean(measles_rate) if inrange(year,1952,1962), by(state)
gegen avg_12yr_measles_rate = max(temp_avg_12yr_measles_rate), by(state)

gegen temp_avg_6366 = mean(measles_rate) if inrange(year, 1963,1966), by(state)
gegen avg_6366 = max(temp_avg_6366), by(state)

foreach j in pertussis chicken_pox mumps rubella {
    gen `j'_rate = (`j'/population)*100000
    gegen temp_avg_`j'_rate = mean(`j'_rate) if inrange(year,1956,1962), by(state)
    gegen avg_`j'_rate = max(temp_avg_`j'_rate), by(state)
}
gegen temp_avg_measles_rate = mean(measles_rate) if inrange(year,1956,1962), by(state)
gegen avg_measles_rate = max(temp_avg_measles_rate), by(state)


collapse avg*, by(state statefip bpl_region4 bpl_region9)


/* 
keep population state statefip bpl_region4 bpl_region9 year measles pertussis chicken_pox mumps rubella
reshape wide population measles pertussis chicken_pox mumps rubella, i(state)  j(year)

*generate measles rate by year
foreach j in measles pertussis chicken_pox mumps rubella {
    local i = 1952 
    while `i' <= 1975 {
    gen `j'_rate_`i'=((`j'`i')/population`i')*100000
    *gen measles_rate_`i'=((measles`i')/population`i')*100000
    *label variable measles_rate_`i' "measles rate in `i' per 100,000"
    local i = `i' + 1 
    }
}

*generate average pre-vaccine measles rates  
** MW: exclude treatment year (1963); now an 11-year average over 1952-1962
    * keep variable name 'avg_12yr_measles_rate', since used in all other code
gen avg_12yr_measles_rate=(measles_rate_1952+measles_rate_1953+measles_rate_1954+measles_rate_1955+measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962)/11

/* gen avg_2yr_measles_rate=(measles_rate_1962+measles_rate_1963)/2
gen avg_3yr_measles_rate=(measles_rate_1961+measles_rate_1962+measles_rate_1963)/3
gen avg_4yr_measles_rate=(measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/4
gen avg_5yr_measles_rate=(measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/5
gen avg_6yr_measles_rate=(measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/6
gen avg_7yr_measles_rate=(measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/7
gen avg_8yr_measles_rate=(measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/8
gen avg_9yr_measles_rate=(measles_rate_1955+measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/9
gen avg_10yr_measles_rate=(measles_rate_1954+measles_rate_1955+measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/10
gen avg_11yr_measles_rate=(measles_rate_1953+measles_rate_1954+measles_rate_1955+measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/11
gen avg_12yr_measles_rate=(measles_rate_1952+measles_rate_1953+measles_rate_1954+measles_rate_1955+measles_rate_1956+measles_rate_1957+measles_rate_1958+measles_rate_1959+measles_rate_1960+measles_rate_1961+measles_rate_1962+measles_rate_1963)/12 */

* this outputs missing if any variable is missing
gen avg_pertussis_rate = (pertussis_rate_1956+pertussis_rate_1957+pertussis_rate_1958+pertussis_rate_1959+pertussis_rate_1960+pertussis_rate_1961+pertussis_rate_1962)/7
gen avg_chicken_pox_rate = (chicken_pox_rate_1956+chicken_pox_rate_1957+chicken_pox_rate_1958+chicken_pox_rate_1959+chicken_pox_rate_1960+chicken_pox_rate_1961+chicken_pox_rate_1962)/7
gen avg_mumps_rate = (mumps_rate_1956+mumps_rate_1957+mumps_rate_1958+mumps_rate_1959+mumps_rate_1960+mumps_rate_1961+mumps_rate_1962)/7
gen avg_rubella_rate = (rubella_rate_1956+rubella_rate_1957+rubella_rate_1958+rubella_rate_1959+rubella_rate_1960+rubella_rate_1961+rubella_rate_1962)/7

*/


gen bpl_state = state
gen bpl = statefip

replace avg_12yr_measles_rate=. if bpl==2 | bpl==20
* exclude AK and KS, since Atwood's method doesn't allow any missings
* AK: data for 1957-75
* KS: data for 1952-56

** MW: split sample by above- and below-median measles states
gegen median_measles = median(avg_12yr_measles_rate) 
gegen median_measles_6366 = median(avg_6366)
gen high_measles = (avg_12yr_measles_rate > median_measles) if missing(avg_12yr_measles_rate)==0
gen high_measles_6366 = (avg_6366 > median_measles_6366) if missing(avg_6366)==0
    * for extended

keep state* bpl* avg* median_measles* high_measles*

/* cd "$data"
save inc_rate.dta, replace  */
save "$data/inc_rate.dta", replace


* for extended

*PREP DATA FOR EVENT STUDY ANALAYSIS

/* cd "$data"
use inc_rate.dta, clear

keep state* avg_12yr_measles_rate

cd "$data"
save inc_rate_ES.dta, replace  */

/* cd "$raw_data" 
use case_counts_population.dta, clear */

use "$data/case_counts_population.dta", clear

/* cd "$data"
merge m:1 statefip using inc_rate_ES.dta  */
merge m:1 statefip using "$data/inc_rate.dta"
drop _merge

*generate measles rate by year
gen measles_rate=((measles)/population)*100000
label variable measles_rate "measles rate in  per 100,000"

*generate pertussis rate by year
gen pertussis_rate=((pertussis)/population)*100000
label variable pertussis_rate "pertussis rate in  per 100,000"

*generate chicken pox rate by year
gen cp_rate=((chicken_pox)/population)*100000
label variable cp_rate "chicken pox rate in  per 100,000"

*generate mumps rate by year
gen mumps_rate=((mumps)/population)*100000
label variable mumps_rate "mumps rate in  per 100,000"

*generate rubella rate by year
gen rubella_rate=((rubella)/population)*100000
label variable rubella_rate "rubella rate in  per 100,000"

** MW: I will do disease event study using calendar time
/* xi i.statefip
gen exp = year - 1964
recode exp (.=-1) (-1000/-6=-6) (11/1000=11)
char exp[omit] -1
xi i.exp, pref(_T) */

gen measles_count = measles
drop measles pertussis chicken_pox mumps rubella
rename pertussis_rate  Pertussis
rename mumps_rate  Mumps
rename rubella_rate  Rubella
rename cp_rate ChickenPox
rename measles_rate Measles


/* cd"$data"
save inc_rate_ES.dta, replace  */
save "$data/inc_rate_ES.dta", replace

*winsorize data
/* cd"$data"
use inc_rate_ES.dta, clear */
/* use "$data/inc_rate_ES.dta", clear

rename Pertussis r_Pertussis
rename Mumps r_Mumps
rename Rubella r_Rubella
rename ChickenPox r_ChickenPox

winsor2 r_Pertussis r_Mumps r_Rubella r_ChickenPox

rename  r_Pertussis_w Pertussis
rename  r_Mumps_w Mumps
rename  r_Rubella_w Rubella
rename  r_ChickenPox_w ChickenPox

/* cd"$data"
save inc_rate_ES_winsor.dta, replace  */
save "$data/inc_rate_ES_winsor.dta", replace */


*log close
