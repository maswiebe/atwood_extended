*** fig 3, 4 event studies

use "$data/inc_rate_ES.dta", clear

* sample 1952-1975

forvalues i = 1952/1975 {
    gen d`i' = (year==`i')
    gen int_`i' = d`i'*avg_12yr_measles_rate
    drop d`i'
    lab var int_`i' " "
}
foreach i in 1952 1957 1962 1967 1972 {
    lab var int_`i' "`i'"
}

* put 1962 last, as omitted year
local interactions int_1952 int_1953 int_1954 int_1955 int_1956 int_1957 int_1958 int_1959 int_1960 int_1961 int_1963 int_1964 int_1965 int_1966 int_1967 int_1968 int_1969 int_1970 int_1971 int_1972 int_1973 int_1974 int_1975 int_1962
* only measles goes back to 1952
local interactions_56 int_1956 int_1957 int_1958 int_1959 int_1960 int_1961 int_1963 int_1964 int_1965 int_1966 int_1967 int_1968 int_1969 int_1970 int_1971 int_1972 int_1973 int_1974 int_1975 int_1962
* order for plotting
local int_ordered int_1952 int_1953 int_1954 int_1955 int_1956 int_1957 int_1958 int_1959 int_1960 int_1961 int_1962 int_1963 int_1964 int_1965 int_1966 int_1967 int_1968 int_1969 int_1970 int_1971 int_1972 int_1973 int_1974 int_1975

set scheme plotplainblind
*------
* measles
reghdfe Measles `interactions' population, ab(statefip year) cluster(statefip)
est sto m1
coefplot m1, drop(_cons population) vert order(`int_ordered') omitted xline(11, lcolor(black)) yline(0, lcolor(black))
graph export "$figures/disease_es_measles.png", replace
graph export "$figures/disease_es_measles.pdf", replace

*------
* mumps
reghdfe Mumps `interactions_56' population, ab(statefip year) cluster(statefip)
est sto m2
coefplot m2, drop(_cons population) vert order(`int_ordered') omitted xline(7, lcolor(black)) xline(12, lcolor(reddish) lpattern("_")) yline(0, lcolor(black))
* mumps vaccine 1967
graph export "$figures/disease_es_mumps.png", replace
graph export "$figures/disease_es_mumps.pdf", replace

*------
* rubella
reghdfe Rubella `interactions_56' population, ab(statefip year) cluster(statefip)
est sto m3
coefplot m3, drop(_cons population) vert order(`int_ordered') omitted xline(7, lcolor(black)) xline(14, lcolor(reddish) lpattern("_")) yline(0, lcolor(black))
* rubella vaccine 1969
graph export "$figures/disease_es_rubella.png", replace
graph export "$figures/disease_es_rubella.pdf", replace

*------
* pertussis
reghdfe Pertussis `interactions_56' population, ab(statefip year) cluster(statefip)
est sto m4
coefplot m4, drop(_cons population) vert order(`int_ordered') omitted xline(7, lcolor(black)) yline(0, lcolor(black))
graph export "$figures/disease_es_pertussis.png", replace
graph export "$figures/disease_es_pertussis.pdf", replace

*------
* chicken pox
reghdfe ChickenPox `interactions_56' population, ab(statefip year) cluster(statefip)
est sto m5
coefplot m5, drop(_cons population) vert order(`int_ordered') omitted xline(7, lcolor(black)) yline(0, lcolor(black))
graph export "$figures/disease_es_chickenpox.png", replace
graph export "$figures/disease_es_chickenpox.pdf", replace