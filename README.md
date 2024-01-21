This repository contains Stata .do files and an R script for the [additional results](https://michaelwiebe.com/assets/atwood/atwood_extended.pdf) from my [comment](https://michaelwiebe.com/assets/atwood/atwood_comment) on "[The Long-Term Effects of Measles Vaccination on Earnings and Employment](https://www.aeaweb.org/articles?id=10.1257/pol.20190509)", Atwood (2022).

To combine my code with the data, first download this repository, then download the original [replication package](https://www.openicpsr.org/openicpsr/project/138401/version/V1/view) and extract the folder 'Replication_Files' to the directory 'data/'.
This requires signing up for an ICPSR account.
You also need to download the [ACS data](https://usa.ipums.org/usa/) (Ruggles et al. 2023); see IPUMS instructions below.
This requires signing up for an IPUMS account. 

To rerun the analyses, run the file `run.do` using Stata (version 15) and the file `splines.r` using R. 
Note that you need to set the path in `run.do` on line 2, to define the location of the folder that contains this README; you also need to set the path in `splines.r` on line 8.

Required Stata packages are included in 'code/libraries/stata/', so that the user does not have to download anything and the replication can be run offline. The file `code/_config.do` tells Stata to load packages from this location.
Figures and tables are saved in 'output/'; that directory is created by `code/_config.do`.
It helps to close web browsers to free up memory.

--- 
IPUMS instructions:

- Samples:  
2017 ACS 5yr  
2012 ACS 5yr  
2007 ACS 3yr  
2000-2004 ACS  
1990: 5% state  
1980: 5% state  
1970: 1% state fm1 and 1% state fm2  
1960: 5%

- Variables:  
Household -> Technical: CPI99  
Household -> Geographic: REGION, STATEFIP  
Person -> Demographic: SEX, AGE, BIRTHYR  
Person -> Race, ethnicity, and nativity: RACE, BPL  
Person -> Education: EDUC  
Person -> Work: EMPSTAT, LABFORCE, UHRSWORK  
Person -> Income: FTOTINC, INCWAGE, POVERTY

- Case selections:  
AGE: 25-60  
RACE: 1-2  
BPL: 001-056

Save the data and .do files to 'data/', and name them usa_00003.dat and usa_00003.do. 