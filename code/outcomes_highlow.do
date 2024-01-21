*** plot outcomes by above/below median measles prevalence, by birth year
use cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked birthyr bpl birthyr age year high_measles if missing(high_measles)==0 using "$data/acs_cleaned.dta", clear

set scheme plotplainblind

preserve
gcollapse cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked, by(birthyr high_measles)

tw (line cpi_incwage birthyr if high_measles==0) (line cpi_incwage birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_cpi_incwage.png", replace
graph export "$figures/highlow_cpi_incwage.pdf", replace

tw (line cpi_incwage_no0 birthyr if high_measles==0) (line cpi_incwage_no0 birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_cpi_incwage_no0.png", replace
graph export "$figures/highlow_cpi_incwage_no0.pdf", replace

tw (line ln_cpi_income birthyr if high_measles==0) (line ln_cpi_income birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_ln_cpi_income.png", replace
graph export "$figures/highlow_ln_cpi_income.pdf", replace

tw (line poverty100 birthyr if high_measles==0) (line poverty100 birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_poverty100.png", replace
graph export "$figures/highlow_poverty100.pdf", replace

tw (line employed birthyr if high_measles==0) (line employed birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_employed.png", replace
graph export "$figures/highlow_employed.pdf", replace
 
tw (line hrs_worked birthyr if high_measles==0) (line hrs_worked birthyr if high_measles==1), xline(1948 1964, lcolor(black) lpattern(-)) legend(label (1 "Low") label (2 "High")) ytitle("") xtitle("Birthyear") legend(pos(6) rows(1))
graph export "$figures/highlow_hrs_worked.png", replace
graph export "$figures/highlow_hrs_worked.pdf", replace

restore

*** plot difference

preserve
gcollapse cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked, by(birthyr high_measles)

reshape wide cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked, i(birthyr) j(high_measles)

foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
    gen diff_`x' = `x'1 - `x'0
}

tw line diff_cpi_incwage birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_cpi_incwage.png", replace
graph export "$figures/diff_cpi_incwage.pdf", replace

tw line diff_cpi_incwage_no0 birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_cpi_incwage_no0.png", replace
graph export "$figures/diff_cpi_incwage_no0.pdf", replace

tw line diff_ln_cpi_income birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_ln_cpi_income.png", replace
graph export "$figures/diff_ln_cpi_income.pdf", replace

tw line diff_poverty100 birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_poverty100.png", replace
graph export "$figures/diff_poverty100.pdf", replace

tw line diff_employed birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_employed.png", replace
graph export "$figures/diff_employed.pdf", replace
 
tw line diff_hrs_worked birthyr, xline(1948 1964, lcolor(black) lpattern(-)) ytitle("") xtitle("Birthyear")
graph export "$figures/diff_hrs_worked.png", replace
graph export "$figures/diff_hrs_worked.pdf", replace

restore

* spikes in average age from combining censuses
preserve
gcollapse age, by(birthyr)
tw line age birthyr, ytitle("") xtitle("Birth year")
graph export "$figures/age_birthyear.png", replace
graph export "$figures/age_birthyear.pdf", replace
restore