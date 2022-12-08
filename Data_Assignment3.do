
* Mikayla Cheng 
* Data Assignment 3

*Open Log
capture log 
log using Data_Assignment3, replace

** CREATE ZIP TO FIPS TABLE **

*Upload Data for ZIP-county Crosswalks
import excel "C:\Users\miki2000\Downloads\ZIP_COUNTY_122021.xlsx", firstrow clear

*Drop unecessary columns
drop res_ratio
drop bus_ratio
drop oth_ratio
drop tot_ratio

*Drop duplicates
duplicates drop zip, force

*Rename the following variables 
rename usps_zip_pref_city USPS_ZIP_PREF_CITY
rename usps_zip_pref_state USPS_ZIP_PREF_STATE
rename zip ZIP

*Save Data
save "zip_county.dta", replace

** END ZIP TO FIPS TABLE **

*Upload Data for ZIP-level Housing Prices
import excel "C:\Users\miki2000\Downloads\HPI_AT_BDL_ZIP5.xlsx", firstrow clear

*Convert following variables to numeric type
destring Year, replace
destring AnnualChange, replace

*Drop observations with year < 2021 
drop if Year < 2021

*Rename FiveDigitZIPCode to ZIP
rename FiveDigitZIPCode ZIP

*Save Zip-level Housing Prices Data
save "zip_hpi.dta", replace

*Obtain Data for County-level Housing Prices
merge m:1 ZIP using "zip_county.dta"

*Drop observations with no data for year
drop if missing(Year)

*Collapse HPI by USPS_ZIP_PREF_CITY and USPS_ZIP_PREF_STATE
collapse AnnualChange, by(county)

rename county fips
destring fips, replace ignore(",")

*rename AnnualChange to HPI_change_2021
rename AnnualChange HPI_change_2021

*Save it as county_hpi.dta.
save "county_hpi.dta", replace


*Import Fips-Codes data
import delimited "C:\Users\miki2000\Downloads\county_fips_master.csv", clear
duplicates drop county_name state_name, force

gen merge_key = county_name + " " + strtrim(state_name)
save "fips_county.dta", replace

*Upload County Census Data
import delimited "C:\Users\miki2000\Downloads\census.csv", clear 

*rename variables
rename v1 old_county
rename v2 county_name
rename v3 state_name
rename v4 population 
rename v5 white_only 
rename v6 black_only 
rename v7 native_american_only 
rename v8 asian_only 
rename v9 pacific_islander_only 

*Drop unecessary columns
drop old_county
drop v10

* Gen merge column
gen merge_key = county_name + " " + strtrim(state_name)

merge 1:1 merge_key using "fips_county.dta"

drop if missing(fips)
drop _merge

*Save it as county_census.dta"
save "county_census.dta", replace

*Upload County COVID Mortality Deaths Data
import delimited "C:\Users\miki2000\Downloads\us-counties-2020.csv", clear 

*Collapse COVID-19 deaths by county 
collapse (sum) deaths, by(fips)

*Merge with County Census Data on county_full 
merge 1:1 fips using "county_census.dta"

*Drop observations missing data for population and deaths
drop if missing(population)
drop if missing(deaths)

*Cast the following variables as longs
destring white_only, replace ignore(",")
destring black_only, replace ignore(",")
destring native_american_only, replace ignore(",")
destring asian_only, replace ignore(",")
destring pacific_islander_only, replace ignore(",")
destring population, replace ignore(",")

*Generate mortality rate data 
gen mortality_rate = deaths / population
gen white_rate = white_only/ population
gen black_rate = black_only / population
gen native_american_rate = native_american_only/ population
gen asian_rate = asian_only / population
gen pacific_islander_rate = pacific_islander_only / population


*Drop Merge
drop _merge

*Save it as county_deaths.dta"
save "county_mortality.dta", replace

*Upload County HPI Data
use county_hpi.dta

*Merge County HPI Data with County Mortality Data on County Full
merge 1:1 fips using "county_mortality.dta"

*Drop observations missing data for population and HPI
drop if missing(population)
drop if missing(HPI_change_2021)

*Regress 2021 HPI change on 2020 COVID19 mortality rate, white, black, asian, native american races. 
regress HPI_change_2021 mortality_rate white_rate black_rate asian_rate native_american_rate

*Regress 2021 HPI change on 2020 COVID19 mortality rate 
regress HPI_change_2021 mortality_rate 

*Regress 2021 HPI change on 2020 white, black, asian, native american races. 
regress HPI_change_2021 white_rate black_rate asian_rate native_american_rate

*Regress 2021 HPI change on 2020 COVID19 mortality rate, and white, black races
regress HPI_change_2021 mortality_rate white_rate black_rate

*Regress 2021 HPI change on 2020 COVID19 mortalit rate, and white, black, asian races
reg HPI_change_2021 mortality_rate white_rate black_rate asian_rate

*Plot twoway scatter plot on HPI and mortality_rate variables. 
twoway (scatter HPI_change_2021 mortality_rate), ytitle(HPI Change in 2021) xtitle(2020 COVID-19 Per Capita Mortality Rate)

*Sum variables
sum HPI_change_2021 mortality_rate white_rate black_rate asian_rate native_american_rate

*Close Log
log close




