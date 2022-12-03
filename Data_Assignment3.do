
* Mikayla Cheng 
* Data Assignment 3

*Open Log
capture log close
log using Data_Assignment3, replace

*Upload Data for ZIP-county Crosswalks
import excel "C:\Users\miki2000\Downloads\ZIP_COUNTY_122021.xlsx", firstrow clear

*Drop unecessary columns
drop county
drop res_ratio
drop bus_ratio
drop oth_ratio
drop tot_ratio

*Drop duplicates
duplicates drop

*Rename the following variables 
rename usps_zip_pref_city USPS_ZIP_PREF_CITY
rename usps_zip_pref_state USPS_ZIP_PREF_STATE
rename zip ZIP

*Save Data
save "zip_county.dta", replace

*Upload Data for State abbreviations used as reference later on
import delimited "C:\Users\miki2000\Downloads\stateAbbreviations.csv", clear

*Rename the following variables
rename v1 state
rename v2 USPS_ZIP_PREF_STATE

*Save data as state_abbrev.dta
save "state_abbrev.dta", replace

*Upload Data for ZIP-level Housing Prices
import excel "C:\Users\miki2000\Downloads\HPI_AT_BDL_ZIP5.xlsx", firstrow clear

*Convert Year type to int
destring Year, replace

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

*Cast HPI as a long
destring HPI, replace

*Collapse HPI by USPS_ZIP_PREF_CITY and USPS_ZIP_PREF_STATE
collapse HPI, by(USPS_ZIP_PREF_CITY USPS_ZIP_PREF_STATE)

*Merge with state_abbrev.dta
merge m:1 USPS_ZIP_PREF_STATE using "state_abbrev.dta"

*Generate county_full variable
gen county_full = lower(USPS_ZIP_PREF_CITY) + " county, " + lower(state)

*Drop Merge
drop _merge

*Save it as county_hpi.dta.
save "county_hpi.dta", replace

*Upload County Census Data
import delimited "C:\Users\miki2000\Downloads\census.csv", clear 

*rename variables
rename v1 county_full
rename v2 population 
rename v3 white_only 
rename v4 black_only 
rename v5 native_american_only 
rename v6 asian_only 
rename v7 pacific_islander_only 

*Drop unecessary columns
drop v8

*Lowercase county_full data
replace county_full = lower(county_full)

*Save it as county_census.dta"
save "county_census.dta", replace

*Upload County COVID Mortality Deaths Data
import delimited "C:\Users\miki2000\Downloads\us-counties-2020.csv", clear 

*Sort data by county 
sort county_full

*Collapse COVID-19 deaths by county 
collapse (sum) deaths, by(county_full)

*Lowercase county_full data
replace county_full = lower(county_full)

*Merge with County Census Data on county_full 
merge 1:1 county_full using "county_census.dta"

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

*Drop Merge
drop _merge

*Save it as county_deaths.dta"
save "county_mortality.dta", replace

*Upload County HPI Data
use county_hpi.dta

*Merge County HPI Data with County Mortality Data on County Full
merge 1:1 county_full using "county_mortality.dta"

*Drop observations missing data for population and HPI
drop if missing(population)
drop if missing(HPI)

*Regress HPI mortality rate on white, black, asian, native american races. 
regress HPI mortality_rate white_only black_only asian_only native_american_only

*Close Log
log close




