*** replicate Table 2 and robustness checks using extended sample

use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region9 exposure edu1960 employed1960 logfamincome1960 if missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear

*local orig_fes year birthyr bpl female black age#black#female bpl#black bpl#female bpl#black#female
** MW: note that interactions contain component terms; new_fes is faster
local new_fes year birthyr age#black#female bpl#black#female
local robust_fes year age#black#female bpl#black#female bpl_region9#birthyr

*---------------------------
*** Table 2 replication
eststo clear

local i = 1
foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
    
    reghdfe `x' M12_exp_rate, ab(`new_fes') vce(cluster bpl#birthyr)
    est sto m`i'

    local i = `i' + 1
}

lab var M12_exp_rate "Measles $\times$ Exposure"
esttab m1 m2 m3 m4 m5 m6, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 
* using m* switches employed and poverty100
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar

*---------------------------
*** robustness: include region X birthyear FEs
eststo clear

local i = 1
foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
    
    reghdfe `x' M12_exp_rate, ab(`robust_fes') vce(cluster bpl#birthyr)
    est sto m`i'

    local i = `i' + 1
}

esttab m*, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
esttab m* using "$tables/t2_robust.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
esttab m* using "$tables/t2_robust_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar

*---------------------------
*** control for 1960 characteristics

gen expXedu1960 = exposure*edu1960
gen expXemp1960 = exposure*employed1960
gen expXinc1960 = exposure*logfamincome1960

eststo clear

local i = 1
foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
    
    reghdfe `x' M12_exp_rate expXedu1960 expXemp1960 expXinc1960, ab(`robust_fes') vce(cluster bpl#birthyr)
    est sto m`i'

    local i = `i' + 1
}

esttab m1 m2 m3 m4 m5 m6, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 keep(M12_exp_rate)
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_1960.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 keep(M12_exp_rate)
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_1960_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar keep(M12_exp_rate)

*-------------------------
* combine all tables

panelcombine, use($tables/t2.tex $tables/t2_robust.tex $tables/t2_1960.tex)  columncount(6) paneltitles("Main results" "Division $\times$ birthyear fixed effects" "Exposure $\times$ 1960 characteristics") save($tables/t2_combined.tex)
panelcombine, use($tables/t2_nostar.tex $tables/t2_robust_nostar.tex $tables/t2_1960_nostar.tex)  columncount(6) paneltitles("Main results" "Division $\times$ birthyear fixed effects" "Exposure $\times$ 1960 characteristics") save($tables/t2_combined_nostar.tex)

*---------------------------
*** control for estimated reporting rates
/* gen expXrep = exposure*rep_rate

local i = 1
foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
    
    reghdfe `x' M12_exp_rate expXrep, ab(`robust_fes') vce(cluster bpl#birthyr)
    est sto m`i'

    local i = `i' + 1
}

esttab m1 m2 m3 m4 m5 m6, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 keep(M12_exp_rate)
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_reprate.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 keep(M12_exp_rate)
esttab m1 m2 m3 m4 m5 m6 using "$tables/t2_reprate_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar keep(M12_exp_rate) */


/* panelcombine, use($tables/t2.tex $tables/t2_robust.tex $tables/t2_reprate.tex)  columncount(6) paneltitles("Main results" "Division $\times$ birthyear fixed effects" "Exposure $\times$ reporting rate") save($tables/t2_combined.tex)
panelcombine, use($tables/t2_nostar.tex $tables/t2_robust_nostar.tex $tables/t2_reprate_nostar.tex)  columncount(6) paneltitles("Main results" "Division $\times$ birthyear fixed effects" "Exposure $\times$ reporting rate") save($tables/t2_combined_nostar.tex) */

