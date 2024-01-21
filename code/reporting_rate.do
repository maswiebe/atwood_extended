use "$data/36603-0001-Data.dta", clear

rename YEAR year
rename STATEFIP statefip
rename BIRTHS_RES births

collapse (sum) births, by(statefip year)

xtset statefip year
gen lag5_births = L5.births

keep if inrange(year,1952,1962)

save "$data/births.dta", replace

use "$data/inc_rate_ES.dta", clear

keep if inrange(year,1952,1962)

merge 1:1 statefip year using "$data/births.dta"
drop _merge
keep if statefip!=2 & statefip!=20 & statefip!=15 & statefip!=25

* regress cumulative cases on cumulative births, save slope as reporting rate
bys statefip: gen cumul_cases = sum(measles_count)
bys statefip: gen cumul_births_lag = sum(lag5_births)

egen id = group(statefip)

gen rep_rate = .

forvalues i = 1/47 {
    qui reg cumul_cases cumul_births_lag if id==`i'
    qui replace rep_rate = _b[cumul_births] if id==`i'
}

collapse rep_rate avg_12yr_measles_rate, by(statefip state)
* statefip= 2, 20 (Alaska, Kansas) are missing measles data
* statefip= 15, 25 (Hawaii, Massachusetts) are missing birth data

reg avg_12yr_measles_rate rep_rate
* R2 = 0.86

scatter avg_12yr_measles_rate rep_rate

hist rep_rate
su rep_rate, d
* vary from 0.006 to 0.35

rename statefip bpl
keep bpl rep_rate
save "$data/reporting_rate.dta", replace
