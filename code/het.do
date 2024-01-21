*-------------------------
*** subsample regressions

local new_fes year birthyr age#black#female bpl#black#female
local robust_fes year birthyr age#black#female bpl#black#female bpl_region9#birthyr
local subsample_fes year bpl age bpl_region9#birthyr

* race and sex
foreach g in "bm" "bf" "wm" "wf" {

    if "`g'" == "bm" | "`g'" == "bf" {
        local dblack = 1
    }
    else {
        local dblack = 0
    }

    if "`g'" == "bf" | "`g'" == "wf" {
        local dfemale = 1
    }
    else {
        local dfemale = 0
    }
  
    use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region4 bpl_region9 if black==`dblack' & female==`dfemale' & missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear
    
    eststo clear

    local i = 1
    foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
        
        reghdfe `x' M12_exp_rate, ab(`subsample_fes') vce(cluster bpl#birthyr)
        est sto m`i'

        local i = `i' + 1
    }

    lab var M12_exp_rate "Measles $\times$ Exposure"

    esttab m*, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
    esttab m* using "$tables/t2_`g'.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
    esttab m* using "$tables/t2_`g'_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar

}

panelcombine, use($tables/t2_bm.tex $tables/t2_bf.tex $tables/t2_wm.tex $tables/t2_wf.tex)  columncount(6) paneltitles("Black men" "Black women" "White men" "White women") save($tables/het_racesex_combined.tex)

* region

forvalues g = 1/4 {

    use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region4 bpl_region9 if bpl_region4==`g' & missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear
    
    eststo clear

    local i = 1
    foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
        
        reghdfe `x' M12_exp_rate, ab(`robust_fes') vce(cluster bpl#birthyr)
        est sto m`i'

        local i = `i' + 1
    }

    lab var M12_exp_rate "Measles $\times$ Exposure"

    esttab m*, se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
    esttab m* using "$tables/t2_region`g'.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2
    esttab m* using "$tables/t2_region`g'_nostar.tex", se label compress replace mtitles("Income" "Income ($>$0)" "Log income" "Poverty" "Employed" "Hours worked") nocons r2 nostar
}

panelcombine, use($tables/t2_region1.tex $tables/t2_region2.tex $tables/t2_region3.tex $tables/t2_region4.tex)  columncount(6) paneltitles("Northeast" "Midwest" "South" "West") save($tables/het_region_combined.tex)


*-------------------------
*** heterogeneity: interaction
use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked M12_exp_rate bpl_region4 bpl_region9 exposure avg_12yr_measles_rate if missing(M12_exp_rate)==0 using "$data/acs_cleaned.dta", clear

gen M12Xfemale = M12_exp_rate*female
gen M12Xblack = M12_exp_rate*black
gen M12XfemaleXblack = M12_exp_rate*female*black
gen expXfemale = exposure*female
gen expXblack = exposure*black
*gen measlesXfemale = avg_12yr_measles_rate*female
*gen measlesXblack = avg_12yr_measles_rate*black
* exposure is collinear with birthyr
* M12_exp_rate is measlesXexp
* already have bpl#female, which is collinear with measlesXfemale

lab var M12_exp_rate "Measles $\times$ Exposure"
lab var M12Xfemale "Measles $\times$ Exposure $\times$ Female"
lab var M12Xblack "Measles $\times$ Exposure $\times$ Black"
lab var M12XfemaleXblack "Measles $\times$ Exposure $\times$ Female $\times$ Black"
lab var expXfemale "Exposure $\times$ Female"
lab var expXblack "Exposure $\times$ Black"

* regionXbirthyear FE
eststo clear
reghdfe ln_cpi_income M12_exp_rate expXfemale M12Xfemale, ab(`robust_fes') vce(cluster bpl#birthyr)
eststo m1
reghdfe ln_cpi_income M12_exp_rate expXblack M12Xblack, ab(`robust_fes') vce(cluster bpl#birthyr)
eststo m2
reghdfe ln_cpi_income M12_exp_rate expXfemale M12Xfemale expXblack M12Xblack M12XfemaleXblack, ab(`robust_fes') vce(cluster bpl#birthyr)
eststo m3

esttab m*, se label compress replace star(* 0.10 ** 0.05 *** 0.01) nomtitles nocons r2 drop(expXfemale expXblack)
esttab m* using "$tables/het_sex_race_robust.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) nomtitles nocons r2 drop(expXfemale expXblack)
esttab m* using "$tables/het_sex_race_robust_nostar.tex", se label compress replace nomtitles nostar nocons r2 drop(expXfemale expXblack)


*** region
gen midwest = bpl_region4==2
gen M12Xmidwest = M12_exp_rate*midwest
gen expXmidwest = exposure*midwest
gen south = bpl_region4==3
gen M12Xsouth = M12_exp_rate*south
gen expXsouth = exposure*south
gen west = bpl_region4==4
gen M12Xwest = M12_exp_rate*west
gen expXwest = exposure*west

* 1= northeast
* 2= midwest
* 3= south
* 4= west

lab var M12Xmidwest "Measles $\times$ Exposure $\times$ Midwest"
lab var M12Xsouth "Measles $\times$ Exposure $\times$ South"
lab var M12Xwest "Measles $\times$ Exposure $\times$ West"

reghdfe ln_cpi_income M12_exp_rate M12Xmidwest M12Xsouth M12Xwest expXmidwest expXsouth expXwest, ab(`new_fes') vce(cluster bpl#birthyr)
eststo m4

* regionXbirthyear FE
reghdfe ln_cpi_income M12_exp_rate M12Xmidwest M12Xsouth M12Xwest expXmidwest expXsouth expXwest, ab(`robust_fes') vce(cluster bpl#birthyr)
eststo m5

* combined
esttab m4 m5, se label compress replace star(* 0.10 ** 0.05 *** 0.01) nomtitles nocons r2 drop(expXmidwest expXsouth expXwest)
esttab m4 m5 using "$tables/het_region_all.tex", se label compress replace star(* 0.10 ** 0.05 *** 0.01) nomtitles nocons r2 drop(expXmidwest expXsouth expXwest)
esttab m4 m5 using "$tables/het_region_all_nostar.tex", se label compress replace nomtitles nostar nocons r2 drop(expXmidwest expXsouth expXwest)
