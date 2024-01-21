use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region4 bpl_region9 exposure avg_12yr_measles_rate pertussis_exp mumps_exp chicken_pox_exp rubella_exp avg_measles_rate  avg_pertussis_rate avg_mumps_rate avg_chicken_pox_rate avg_rubella_rate if missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear

*-------------------------------------------------------------------
*** use other diseases instead of measles

lab var pertussis_exp "Pertussis $\times$ Exposure"
lab var mumps_exp "Mumps $\times$ Exposure"
lab var chicken_pox_exp "Chicken pox $\times$ Exposure"
lab var rubella_exp "Rubella $\times$ Exposure"

local robust_fes year birthyr age#black#female bpl#black#female bpl_region9#birthyr

eststo clear

foreach j in pertussis mumps chicken_pox rubella {
    local i = 1
    foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
        
        reghdfe `x' `j'_exp, ab(`robust_fes') vce(cluster bpl#birthyr)
        est sto m`i'

        local i = `i' + 1
    }

    esttab m1 m2 m3 m4 m5 m6, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 
    esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_`j'.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
    esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_`j'_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar

}

panelcombine, use($tables/t2_pertussis.tex $tables/t2_mumps.tex $tables/t2_chicken_pox.tex $tables/t2_rubella.tex)  columncount(6) paneltitles("Pertussis" "Mumps" "Chicken pox" "Rubella") save($tables/t2_otherdisease_combined.tex)
panelcombine, use($tables/t2_pertussis_nostar.tex $tables/t2_mumps_nostar.tex $tables/t2_chicken_pox_nostar.tex $tables/t2_rubella_nostar.tex)  columncount(6) paneltitles("Pertussis" "Mumps" "Chicken pox" "Rubella") save($tables/t2_otherdisease_combined_nostar.tex)

*** test correlation between diseases
preserve
gcollapse avg_12yr_measles_rate avg_pertussis_rate avg_mumps_rate avg_chicken_pox_rate avg_rubella_rate avg_measles_rate, by(bpl)

corr avg_12yr_measles_rate avg_pertussis_rate avg_mumps_rate avg_chicken_pox_rate avg_rubella_rate
* averages over 1952-62 (measles) and 56-62 (other)
* pertussis: 0.53; mumps: 0.91; chickenpox: 0.93; rubella: 0.78

corr avg_measles_rate avg_pertussis_rate avg_mumps_rate avg_chicken_pox_rate avg_rubella_rate
* averages over 1956-62
* pertussis: 0.55; mumps: 0.89; chickenpox: 0.89; rubella: 0.71
