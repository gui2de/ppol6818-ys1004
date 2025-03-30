clear all

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_08\03_assignment\"
}

if c(username)=="suyux" {
	
	global wd "/Users/suyux/Desktop/Education/GU/2025Spring/Experimental Design/ppol6618/week_08/03_assignment/"
}

cd "$wd"

********************************************************************************
* Part 2
********************************************************************************

**1
clear all 
set more off
set seed 2025

capture program drop sample_regression
program define sample_regression, rclass
syntax, n(integer)

*a
clear
set obs `n'

gen x = rnormal(0,1)
gen y = 2*x + rnormal(0,1)

*b
reg y x

*c
return scalar N = _N
return scalar beta = _b[x]
return scalar SEM = _se[x]
return scalar pvalue = 2 * (1 - normal(abs(_b[x] / _se[x])))
return scalar ci_low = _b[x] - 1.96*_se[x]
return scalar ci_high = _b[x] + 1.96*_se[x]

end

**2
clear

preserve 
clear
set obs 0
gen N = .
gen beta = .
gen SEM = .
gen pvalue = .
gen ci_low = .
gen ci_high = .
save "part2_2.dta", emptyok replace
restore

local start = 2
local end = 21

*loop through powers of 2
forvalues i = `start'/`end' {
	local n = 2^`i'
	dis "simulating for N = `n'"
	
	simulate N=r(N) beta=r(beta) SEM=r(SEM) pvalue=r(pvalue) ci_low=r(ci_low) ci_high=r(ci_high), reps(500) nodots: ///
	 sample_regression, n(`n')
	
	append using "part2_2.dta"
	save "part2_2.dta", replace	
}

*loop through the extra values
local extras 10 100 1000 10000 100000 1000000

foreach n of local extras {
	display "Simulating for N = `n'"
    
    simulate N=r(N) beta=r(beta) SEM=r(SEM) pvalue=r(pvalue) ci_low=r(ci_low) ci_high=r(ci_high), reps(500) nodots: ///
        sample_regression, n(`n')

    append using "part2_2.dta"
	save "part2_2.dta", replace
}


**3
use "part2_2.dta", clear

*beta
table N, statistic(mean beta SEM ci_high ci_low) nformat(%9.6f)
preserve
collapse (mean) beta SEM ci_high ci_low, by(N)

*encode N
gen str_N = string(N)
gen Ni = _n
ssc install labutil
labmask Ni, values(str_N)

#delimit ;
twoway 
	(rcap ci_low ci_high Ni, lcolor(gs10))
	(scatter beta Ni, mcolor(black) sort(Ni)),
	xlabel(1(1)26, valuelabel angle(45) labsize(small))
	xtitle("")
	legend(order(1 2) pos(1) label(1 "Confidence Interval") label(2 "Coefficient Estimate") size(small))

;
#delimit cr;

graph save "Beta2.gph", replace
graph export "Beta2.jpg", replace

#delimit ;
graph bar
	SEM,
	over(N, label(angle(45) labsize(small)))
	bar(1, color(gs10%80))
	blabel(bar, format(%9.2f))
	ytitle("Average SE. of beta")

;
#delimit cr;

graph save "SEM2.gph", replace
graph export "SEM2.jpg", replace

restore

**5
*graph combine
graph use "Beta1.gph"
graph combine Beta1.gph Beta2.gph, col(2) ycommon title("Beta Estimates by Sample Size")
graph export "Beta.jpg", replace

graph use "SEM1.gph"
graph combine SEM1.gph SEM2.gph, col(2) ycommon title("SEM by Sample Size")
graph export "SEM.jpg", replace

*comparison table
use "part1_4.dta", clear

capture gen j = 1

save "part1_4.dta", replace

use "part2_2.dta", clear

keep if N == 10 | N == 100 | N == 1000 | N == 10000

gen j = 2

append using part1_4.dta

collapse (mean) beta SEM pvalue ci_low ci_high, by(N j)

reshape wide beta SEM pvalue ci_low ci_high, i(N) j(j)

format beta* SEM* pvalue* ci* %9.6f

order N beta1 beta2 SEM1 SEM2 pvalue1 pvalue2 ci_low1 ci_low2 ci_high1 ci_high2
