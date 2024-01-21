use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region4 bpl_region9 exposure avg_12yr_measles_rate if missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear

*-------------------------------
* regression weights
set scheme plotplainblind
local robust_fes year birthyr age#black#female bpl#black#female bpl_region9#birthyr

reghdfe M12_exp_rate, ab(`robust_fes') vce(cluster bpl#birthyr) res(resid)

gen res2 = resid^2
gegen resid_tot = total(res2)
gen regweight = res2/resid_tot

preserve
gcollapse (sum) regweight (count) count=regweight, by(bpl)
*bro
scatter regweight bpl
restore
* WI has .36
* TX, NJ, LA > 0.05

preserve 
gcollapse (sum) regweight (count) count=regweight, by(black female)
gegen total = total(count)
gen frac = count/total
*bro black female regweight frac
restore
* pretty similar

preserve 
gcollapse (sum) regweight (count) count=regweight, by(birthyr)
gegen total = total(count)
gen frac = count/total
*bro birthyr regweight frac
tw (line regweight birthyr) (line frac birthyr), legend(pos(6) rows(1)) legend(label (1 "Regression weight") label (2 "Sample weight")) xtitle("Birthyear")
graph export "$figures/regweight_birthyear.png",replace
graph export "$figures/regweight_birthyear.pdf",replace
* weird drop from 1949-1964, minimum in 1955
    * big excess weight on 64-65
    * this is why results are the same in the robustness table, using only no- and full-exposure cohorts
* must be a Goodman-Bacon type result, observations in middle get low weight
* this affects the twfe regression, but not the event study (which uses birthyear#measlespc)
    * but ES and main results are consistent
restore

preserve 
gcollapse (sum) regweight (count) count=regweight, by(bpl_region4)
gegen total = total(count)
gen frac = count/total
*bro bpl_region4 regweight frac
restore
* extra weight on midwest, due to Wisconsin 
