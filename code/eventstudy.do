*** cohort event study
* interact measles_pc with birthyr, omit 1948 as last cohort with vaccine exposure=0
* want 16 years before and after 1948-64
    * 32-48, 64-80

* close chrome to save memory

*-------------------------------------------------
*** event study by race and sex

timer clear 1
timer on 1

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
  
    use year sex age birthyr black bpl female cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked avg_12yr_measles_rate bpl_region9 if inrange(birthyr,1932,1980) & missing(avg_12yr_measles_rate)==0 & black==`dblack' & female==`dfemale' using "$data/acs_cleaned.dta", clear

    gen measles_pc = avg_12yr_measles_rate/100000

    forvalues i = 1932/1980 {
        gen d`i' = (birthyr==`i')
        gen int_`i' = d`i'*measles_pc
        lab var int_`i' " "
        drop d`i'
    }
    * label ticks on graph
    foreach i in 1940 1950 1960 1970 1980 {
        lab var int_`i' "`i'"
    }

    * put 1948 last, as omitted year
    local interactions int_1932 int_1933 int_1934 int_1935 int_1936 int_1937 int_1938 int_1939 int_1940 int_1941 int_1942 int_1943 int_1944 int_1945 int_1946 int_1947 int_1949 int_1950 int_1951 int_1952 int_1953 int_1954 int_1955 int_1956 int_1957 int_1958 int_1959 int_1960 int_1961 int_1962 int_1963 int_1964 int_1965 int_1966 int_1967 int_1968 int_1969 int_1970 int_1971 int_1972 int_1973 int_1974 int_1975 int_1976 int_1977 int_1978 int_1979 int_1980 int_1948
    local int_ordered int_1932 int_1933 int_1934 int_1935 int_1936 int_1937 int_1938 int_1939 int_1940 int_1941 int_1942 int_1943 int_1944 int_1945 int_1946 int_1947 int_1948 int_1949 int_1950 int_1951 int_1952 int_1953 int_1954 int_1955 int_1956 int_1957 int_1958 int_1959 int_1960 int_1961 int_1962 int_1963 int_1964 int_1965 int_1966 int_1967 int_1968 int_1969 int_1970 int_1971 int_1972 int_1973 int_1974 int_1975 int_1976 int_1977 int_1978 int_1979 int_1980

    local subsample_fes year bpl age bpl_region9#birthyr
    * interaction makes separate birthyr collinear

    set scheme plotplainblind

    gegen bplbirthyr = group(bpl birthyr)

    foreach x in cpi_incwage cpi_incwage_no0 ln_cpi_income poverty100 employed hrs_worked {
        timer clear 2
        timer on 2
        
        reghdfe `x' `interactions', ab(`subsample_fes') vce(cluster bpl#birthyr)
        
        coefplot, drop(_cons) vert order(`int_ordered') omitted xline(17.5, lcolor(reddish)) xline(33.5, lcolor(reddish)) yline(0, lcolor(black)) xtitle("Birth year")
        graph export "$figures/es_`g'_`x'.png", replace
        graph export "$figures/es_`g'_`x'.pdf", replace
        graph close
        
        timer off 2
        timer list 2
}

timer off 1
timer list 1