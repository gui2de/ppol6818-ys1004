clear all

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_05\03_assignment\01_data\"
}

if c(username)=="suyux" {
	
	global wd "/Users/suyux/Desktop/Education/GU/2025Spring/Experimental Design/ppol6618/week_05/03_assignment/01_data/"
}

cd "$wd"

********************************************************************************
* Q1
********************************************************************************

use "q1_psle_student_raw.dta", clear

gen student_num = ""
gen school_code = ""
gen cand_id = ""
gen gender = ""
gen prem_number = "" 
gen name = "" 
gen Kiswahili = "" 
gen English = "" 
gen maarifa = "" 
gen hisabati = "" 
gen science = "" 
gen uraia = "" 
gen average = ""
tostring s, replace
save "student.dta", replace

*setting up an empty tempfile
clear
tempfile student
save `student', replace emptyok

use "student.dta", replace

*identify all school codes
levelsof schoolcode, local(schools)

foreach school in `schools' {
	preserve
	keep if schoolcode == "`school'"
	replace student_num = regexs(1) if regexm(s, "WALIOFANYA MTIHANI : ([0-9]+)$")
	destring student_num, replace force
	local values = student_num[1]
	display "`values'" 
	display schoolcode
	save "schools.dta", replace

forvalues i = 1/`values' {
	use "schools.dta", clear
	
	*save school code for row i
	replace school_code = regexs(1) if regexm(s, "([A-Z][A-Z][0-9]{7})$")
	local varcode = school_code[1]
	
	*save the cand_id for row i
	replace cand_id = regexs(1) if regexm(s, "(PS[0-9]{7}\-[0-9]{4})")
	local varcand = cand_id[1]
	display "`varcand'"
	replace s = subinstr(s, "`varcand'", "", 1)
	
	*save the gender for row i
	replace gender = regexs(1) if regexm(s, ">([MF])</FONT>")
	local vargend = gender[1]
	display "`vargend'"
	replace s = subinstr(s, ">`vargend'</FONT>", "", 1)
	
	*save the prem_number for row i
	replace prem_number = regexs(1) if regexm(s, "(2015[0-9]{7})")
	local varprem = prem_number[1]
	display "`varprem'"
	replace s = subinstr(s, "`varprem'", "", 1)
	
	*save the name for row i
	replace name = regexs(1) if regexm(s, "<P>([A-Z]+ [A-Z]+ [A-Z]+)</FONT>")
	local varname = name[1]
	display "`varname'"
	replace s = subinstr(s, "`varname'", "", 1)
	
	*save Kiswahili grades for row i
	replace Kiswahili = regexs(1) if regexm(s, "Kiswahili - ([A-Z]),")
	local varKiswahili = Kiswahili[1]
	display "`varKiswahili'"
	replace s = subinstr(s, "Kiswahili - `varKiswahili'", "", 1)
	
	*save English grades for row i
	replace English = regexs(1) if regexm(s, "English - ([A-Z]),")
	local varEnglish = English[1]
	display "`varEnglish'"
	replace s = subinstr(s, "English - `varEnglish'", "", 1)
	
	*save maarifa grades for row i
	replace maarifa = regexs(1) if regexm(s, "Maarifa - ([A-Z]),")
	local varmaarifa = maarifa[1]
	display "`varmaarifa'"
	replace s = subinstr(s, "Maarifa - `varmaarifa'", "", 1)
	
	*save hisabati grades for row i
	replace hisabati = regexs(1) if regexm(s, "Hisabati - ([A-Z]),")
	local varhisabati = hisabati[1]
	display "`varhisabati'"
	replace s = subinstr(s, "Hisabati - `varhisabati'", "", 1)
	
	*save science grades for row i
	replace science = regexs(1) if regexm(s, "Science - ([A-Z]),")
	local varscience = science[1]
	display "`varscience'"
	replace s = subinstr(s, "Science - `varscience'", "", 1)
	
	*save uraia grades for row i
	replace uraia = regexs(1) if regexm(s, "Uraia - ([A-Z]),")
	local varuraia = uraia[1]
	display "`varuraia'"
	replace s = subinstr(s, "Uraia - `varuraia'", "", 1)
	
	*save average grades for row i
	replace average = regexs(1) if regexm(s, "Average Grade - ([A-Z])")
	local varaverage = average[1]
	display "`varaverage'"
	replace s = subinstr(s, "Average Grade - `varaverage'", "", 1)	
	
	save "schools.dta", replace
	
	clear
	display "`varcand'"
	set obs 1
	gen id = `i'
	
	gen school_code = ""
	replace school_code = "`varcode'"
	
	gen cand_id = ""
	replace cand_id = "`varcand'"
	
	gen gender = ""
	replace gender = "`vargend'"
	
	gen prem_number = ""
	replace prem_number = "`varprem'"
	
	gen name = ""
	replace name = "`varname'"
	
	gen Kiswahili = ""
	replace Kiswahili = "`varKiswahili'"
	
	gen English = ""
	replace English = "`varEnglish'"
	
	gen maarifa = "" 
	replace maarifa = "`varmaarifa'"
	
	gen hisabati = "" 
	replace hisabati = "`varhisabati'"
	
	gen science = "" 
	replace science = "`varscience'"
	
	gen uraia = "" 
	replace uraia = "`varuraia'"
	
	gen average = ""
	replace average = "`varaverage'"
	
	append using `student'
	save `student', replace
}
restore
}
use `student', clear
sort school_code
drop id
save "data/q1.dta", replace


********************************************************************************
* Q2
********************************************************************************

*transfer xlse into dta file
import excel "q2_CIV_populationdensity.xlsx", sheet("Population density") firstrow clear
rename NOMCIRCONSCRIPTION departemen 
replace departemen = lower(departemen)
keep if regexm(departemen, "departement")
replace departemen = regexs(1) if regexm(departemen, "departement d'(.+)")
replace departemen = regexs(1) if regexm(departemen, "departement de (.+)")
replace departemen = regexs(1) if regexm(departemen, "departement du (.+)")
replace departemen = trim(departemen)

tempfile population_density
save `population_density', replace emptyok


use "q2_CIV_Section_0.dta", clear

*convert b06_departemen into strings
decode b06_departemen, gen(departemen)

*rename arrha
replace departemen = "arrah" if departemen == "arrha"

*merge with departmente-level density data
merge m:1 departemen using `population_density', keepusing(DENSITEAUKM)

keep if _merge == 3
drop _merge departemen
rename DENSITEAUKM density

********************************************************************************
* Q3
********************************************************************************

use "q3_GPS Data.dta", clear

*sort by latitude to find the southernmost household
gen assigned = 0  // Create a flag for assigned households
gen enumerator_id = . 
sort latitude
gen flag = _n

*assign households using Greedy approach
forvalues enum = 1/19 {
    
	*sort by latitude to find the southernmost unassigned household
	sort latitude
	qui sum flag if assigned == 0
	local first = r(min)
    
	display `first'
	
	gen latitude0 = latitude[`first']
	gen longitude0 = longitude[`first']
	
    *generate distances to all unassigned households
    geodist latitude longitude latitude0 longitude0, gen(dist)
	
    *sort by distance and pick the 6 closest unassigned households
    sort dist
    replace enumerator_id = `enum' if assigned == 0 & flag <= `first'+5 & `enum' < 17
	replace enumerator_id = `enum' if assigned == 0 & flag <= `first'+4 & `enum' >= 17
    replace assigned = 1 if enumerator_id == `enum'
    drop dist latitude0 longitude0
}

tab enumerator_id 
sort enumerator_id
drop flag assigned

********************************************************************************
* Q4
********************************************************************************

import excel "q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5) firstrow clear

drop SEX G ELECTEDCANDIDATE K
drop if missing(CAN)

*lower case the variable names
foreach var of varlist _all {
    local newname = lower("`var'")
    rename `var' `newname'_10
}

rename costituency_10 constituency_10

*foward filling region, district, costituency and ward
replace region_10 = region_10[_n-1] if region_10 == ""
replace district_10 = district_10[_n-1] if district_10 == ""
replace constituency_10 = constituency[_n-1] if constituency == ""
replace ward_10 = ward_10[_n-1] if ward_10 == ""

*lower case all the string values except political party
foreach var in region district ward_10 {
	replace `var' = lower(`var')
}

*turn total voting into numeric
replace ttlvotes_10 = "" if ttlvotes_10 == "UN OPPOSSED"
destring ttlvotes_10, replace

*generate ward id
bysort region_10 district_10 constituency_10 ward_10: gen ward_id_10 = _n == 1  
replace ward_id_10 = sum(ward_id_10)

*count the number of candidates per ward
bysort region_10 district_10 constituency_10 ward_10 (can): gen total_candidates_10 = _N

*count the number of total votes per ward
bysort ward_id_10: egen ward_total_votes_10 = sum(ttlvotes_10)

*generate the number of total votes per party in each ward
bysort ward_id_10 politicalparty (ward_id_10): egen votes_ = sum(ttlvotes_10)

*drop duplicated observation at party-level
drop candidatename_10 ttlvotes_10
duplicates drop

*reshape to wide
replace politicalparty = subinstr(politicalparty, " ", "", .)
replace politicalparty = subinstr(politicalparty, "-", "_", .)
reshape wide votes_, i(region_10 district_10 constituency_10 ward_10 total_candidates_10 ward_total_votes_10 ward_id_10) j(politicalparty) string

********************************************************************************
* Q5
********************************************************************************

*method 1: match by region, district, and school names

use "q5_school_location.dta", clear

*transfer id column into string
destring SN, replace

*upper case Region and District
rename Region region_name
rename Council district_name
rename Ward ward_name
replace region_name = upper(region_name)
replace district_name = upper(district_name)

tempfile q5_1
save `q5_1', replace emptyok

use "q5_psle_2020_data.dta", clear

*generate variable only has school name strings
gen str School = regexs(1) if regexm(schoolname, "^(.*)\s*PRIMARY\s*SCHOOL")
replace School = regexs(1) if regexm(schoolname, "^(.*)\s*ACADEMY")
replace School = regexs(1) if regexm(schoolname, "^(.*)\s*PRE")
replace School = regexs(1) if regexm(schoolname, "^(.*)\s*ENGLISH")
replace School = regexs(1) if regexm(schoolname, "^(.*)\s*-\s*PS") & missing(School)
replace School = subinstr(School, " PRIMARY SCHOOL", "", .)
replace School = subinstr(School, " PRIMARY", "", .)
replace School = subinstr(School, " ELEMENTARY", "", .)
replace School = trim(School)

reclink region_name School using `q5_1', idmaster(serial) idusing(SN) gen(score) 
keep region_name district_name ward_name schoolname school_code_address region_code district_code serial
sort serial

*method 2: match by school codes

use "q5_school_location.dta", clear

*transfer id column into string
destring SN, replace

*upper case Region and District
rename NECTACentreNo schoolcode
rename Ward ward_name

tempfile q5_2
save `q5_2', replace emptyok

use "q5_psle_2020_data.dta", clear

gen str schoolcode = regexs(1) if regexm(schoolname, "([A-Z][A-Z][0-9]{7})$")

*fuzzey match
reclink schoolcode using `q5_2', idmaster(serial) idusing(SN) gen(score)  

*cancel invalid matching if score<1 as only score==1 observation has correct match
replace ward_name = "" if score < 1
keep region_name district_name ward_name schoolname school_code_address region_code district_code serial
sort serial

/* method 2 (exact matching) is more accurate and efficient as it only has to compare one column
and the result is easy to tell whether matching correctly or not if score lower 
than 1 means, but it may lose more observations than fuzzy matching. */

********************************************************************************
* Bonus Question
********************************************************************************

use "Tz_GIS_2015_2010_intersection.dta", clear

rename (region_gis_2017 district_gis_2017 ward_gis_2017) (region_15 district_15 ward_15)
rename (region_gis_2012 district_gis_2012 ward_gis_2012) (region_10 district_10 ward_10)

*create a tempfile for merging
tempfile gis
save `gis', replace emptyok


use "Tz_elec_15_clean.dta", clear

*merge gis data with 2015 data
reclink region_15 ward_15 using `gis', idm(ward_id_15) idu(fid_gis_2017) gen(score)

*keep location data in 2015 and ward in 2010
keep *_15 *_10 _merge
drop U* total_candidates_15 ward_total_votes_15
duplicates drop ward_id_15, force // the duplicates is due to district in 2010 data has been seperated into urban and rural, thus dropping it does not influence our result if we just want to match ward

tempfile ward_10_15
save `ward_10_15', replace emptyok

preserve

*check whether unmatched obervation has identical ward name with 2010 dataset
use `ward_10_15', clear
keep if _merge == 1
drop _merge *_10

*copy the location variables of 2015 for merging with 2010 dataset
gen region_10 = region_15
gen district_10 = district_15
gen ward_10 = ward_15
reclink region_10 ward_10 using Tz_elec_10_clean, idm(ward_id_15) idu(ward_id_10) gen(score)

*see unmatched result as missing
replace region_10 = "" if _merge == 1
replace district_10 = "" if _merge == 1
replace ward_10 = "" if _merge == 1

keep *_15 *_10
drop U* total_candidates_10 ward_total_votes_10 ward_id_10

tempfile unmatched1510
save `unmatched1510', replace emptyok
restore

drop if _merge == 1
drop _merge
append using `unmatched1510'
duplicates drop ward_id_15, force

*lastly check any unmatched result can be matched in 2012 observations in gis dataset
preserve 
use `gis', clear
duplicates drop fid_gis_2012, force
save `gis', replace
restore

preserve 
keep if ward_10 == ""
*temporarily fill 2010 location data with 2015 for matching
replace region_10 = region_15
replace district_10 = district_15
replace ward_10 = ward_15
reclink region_10 ward_10 using `gis', idm(ward_id_15) idu(fid_gis_2012) gen(score)

replace region_10 = "" if _merge == 1
replace district_10 = "" if _merge == 1
replace ward_10 = "" if _merge == 1

count if ward_10 == ""

keep *_15 *_10
drop U*
save `unmatched1510', replace
restore

drop if ward_10 == ""
append using `unmatched1510'

sort ward_id_15

