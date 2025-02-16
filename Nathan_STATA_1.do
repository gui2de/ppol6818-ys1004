clear all
global projdir "/Users/suyux/Desktop/Education/GU/2025Spring/Experimental Design/ppol6618/week_03/04_assignment/01_data"
cd "$projdir"

********************************************************************************
* Q1
********************************************************************************

* merge all .dta in one dataset
use "q1_data/student.dta", clear

** using teacher.dta merge with student.dta in memory
rename primary_teacher teacher
merge m:1 teacher using q1_data/teacher
drop _merge

** using school.dta merged combined dataset in memory
merge m:1 school using q1_data/school
drop _merge

** using subject.dta merged combined dataset in memory
merge m:1 subject using q1_data/subject
drop _merge

save merged.dta, replace

* a) mean attendance of students at southern schools
sum attendance if loc == "South"

* b) Of all students in high school, what proportion of them have a 
* primary teacher who teaches a tested subject?
sum tested

* c) What is the mean gpa of all students in the district?
sum gpa // This already accounting for population in each school

* d) What is the mean attendance of each middle school? 
preserve 
keep if level == "Middle"
bysort school level: sum attendance
restore

********************************************************************************
* Q2
********************************************************************************

use "q2_village_pixel.dta", clear

* a) confirm if Payout variable is consistent within a pixel
bysort pixel: gen num_pixel = _N
egen num_payout1 = total(payout == 1), by(pixel)
egen num_payout0 = total(payout == 0), by(pixel)
gen pixel_consistent = (num_payout0 == num_pixel | num_payout1 == num_pixel)
tab pixel_consistent
drop num_payout0 num_payout1 num_pixel

* b) confirm if the households in a particular village are within the same pixel

** option 1
bysort village pixel: gen pixel_flag = _n
bysort village: gen num_hvillage = _N // num of hh in each village
bysort village: gen pixel_village = (pixel_flag[_N] < num_hvillage)
tab pixel_village
drop pixel_flag num_hvillage pixel_village

** option 2
bysort village pixel: gen pixel_flag = (_n == 1)
bysort village: egen sum_pixel = sum(pixel_flag)
gen pixel_village = (sum_pixel > 1)
tab pixel_village
drop pixel_flag sum_pixel

* c) divide the households into three categories
bysort village payout: gen pixel_flag = (_n == 1)
bysort village: egen sum_pixel = sum(pixel_flag)
gen village_pixel_payout = .
replace village_pixel_payout = 1 if pixel_village == 0
replace village_pixel_payout = 2 if pixel_village == 1 & sum_pixel == 1
replace village_pixel_payout = 3 if pixel_village == 1 & sum_pixel > 1
tab village_pixel_payout

********************************************************************************
* Q3
********************************************************************************

use "q3_proposal_review.dta", clear

*rename variables for reshaping
rename Rewiewer1 Reviewer_1
rename Reviewer2 Reviewer_2
rename Reviewer3 Reviewer_3
rename Review1Score ReviewScore_1
rename Reviewer2Score ReviewScore_2
rename Reviewer3Score ReviewScore_3

*reshape long
reshape long Reviewer_ ReviewScore_, i(proposal_id) j(round)
bysort Reviewer_: egen ReviewerMean = mean(ReviewScore_)
bysort Reviewer_: egen ReviewerSd = sd(ReviewScore_)

*reshape wide for calculating standardized round score
reshape wide Reviewer_ ReviewScore_ ReviewerMean ReviewerSd, i(proposal_id) j(round)
gen stand_r1_score = (AverageScore-ReviewerMean1)/ReviewerSd1 
gen stand_r2_score = (AverageScore-ReviewerMean2)/ReviewerSd2 
gen stand_r3_score = (AverageScore-ReviewerMean3)/ReviewerSd3
gen average_stand_score = (stand_r1_score+stand_r2_score+stand_r3_score)/3

*generate rank column
egen rank = rank(average_stand_score)
sum rank

********************************************************************************
* Q4
********************************************************************************

global excel_t21 "$projdir/q4_Pakistan_district_table21.xlsx"

clear

*setting up an empty tempfile
tempfile table21
save `table21', replace emptyok

*Run a loop through all the excel sheets (135) this will take 1-5 mins because it has to import all 135 sheets, one by one
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' 
	save `table21', replace //saving the tempfile so that we don't lose any data
}
*load the tempfile
use `table21', clear
*fix column width issue so that it's easy to eyeball the data
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC


local cols "B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC"

* loop through each columns
foreach var in `cols' {
    *replace any value that contains a hyphen ("-") with an empty string
    replace `var' = "" if regexm(`var',"-")

    *trim whitespace and replace completely empty values with an empty string
    replace `var' = "" if trim(`var') == ""
}

*move the 'table' column to be the first column
order table, first
sort table

*rename columns systematically to col1, col2, col3, ... for reshaping
local i = 1
foreach var of varlist B-Z AA-AC { 
    rename `var' col`i' 
    local i = `i' + 1
}

* reshape data
reshape long col, i(table) j(variable) string

* remove rows where col values are empty after reshaping
drop if col == ""

* drop the original 'variable' column, as it is no longer needed
drop variable

* create a new 'variable' column that assigns a unique sequential number within each table group
bysort table: gen variable = _n

* reshape data back to wide format based on 'table' and 'variable'
reshape wide col, i(table) j(variable)

* rename col1, col2, ... to A, B, C, ..., L
local letters "A B C D E F G H I J K L"

local i = 1
foreach var of varlist col* {
    * remove leading and trailing spaces from the variable values
    replace `var' = strtrim(`var')

    * assign the next letter from the macro to the current column
    local newname: word `i' of `letters' 
    rename `var' `newname' 

    local i = `i' + 1 
}

* replace "OVERALL" in table21
replace table21 = "18 AND ABOVE" if regexm(table21, "OVERALL")

format %9s table21 A B C D E F G H I J K L

********************************************************************************
* Q5
********************************************************************************

use "q5_Tz_student_roster_html.dta", clear

* school name
gen str name = regexs(1) if regexm(s, "([A-Z]+)\s*PRIMARY\s*SCHOOL")

* school code
gen str code = regexs(1) if regexm(s, "([A-Z][A-Z][0-9]{7})$")

* num of students that took the test
gen str num = regexs(1) if regexm(s, "^WALIOFANYA MTIHANI\s*:\s*([0-9]+)$")
label variable num "number of students that took the test"

* school average 
gen str avg = regexs(1) + "." + regexs(2) if regexm(s, "^WASTANI WA SHULE\s*:\s*([0-9]+)\.([0-9]+)$")
label variable avg "school average"

* student group
gen group = 0 
replace group = 1 if regexm(s, "ya 40$") 
label variable group "student group (binary, either under 40 or >=40)"

* school ranking in the council
gen str council = regexs(1) if regexm(s, "KIHALMASHAURI\s*:\s*([0-9]+)\s*kati ya\s*[0-9][0-9]$")
label variable council "school ranking in council (out of 46)"

* school ranking in the region 
gen str region = regexs(1) if regexm(s, "KIMKOA\s*:\s*([0-9]+)\s*kati ya\s*[0-9][0-9][0-9]$")
label variable region "school ranking in the region (out of 290)"

* school ranking at the national level
gen str national = regexs(1) if regexm(s, "KITAIFA\s*:\s*([0-9]+)\s*kati ya\s*[0-9][0-9][0-9][0-9]$")
label variable national "school ranking at the national level (out of 5664)"

drop s

********************************************************************************
* Bonus Question
********************************************************************************

use "q5_Tz_student_roster_html.dta", clear
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
save "bonus.dta", replace

clear

*setting up an empty tempfile
tempfile student
save `student', replace emptyok

forvalues i = 1/16{
	use "bonus.dta", clear
	
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
	
	save "bonus.dta", replace
	
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

use `student', clear
sort id
drop id
save "bonus.dta", replace




