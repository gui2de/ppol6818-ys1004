clear all

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_08\03_assignment\"
}

if c(username)=="suyux" {
	
	global wd "/Users/suyux/Desktop/Education/GU/2025Spring/Experimental Design/ppol6618/week_08/03_assignment/"
}

cd "$wd"

********************************************************************************
* Part 1
********************************************************************************

**3
clear all

capture program drop regression
program define regression, rclass
syntax, n(integer)

*a
use "part1_2.dta", clear

*b
sample `n', count

*c
reg y x

*d
return scalar N = _N
return scalar beta = _b[x]
return scalar SEM = _se[x]
return scalar pvalue = 2 * (1 - normal(abs(_b[x] / _se[x])))
return scalar ci_low = _b[x] - 1.96*_se[x]
return scalar ci_high = _b[x] + 1.96*_se[x]

end

**4
preserve 
clear
set obs 0
gen N = .
gen beta = .
gen SEM = .
gen pvalue = .
gen ci_low = .
gen ci_high = .
save "part1_4.dta", emptyok replace
restore

foreach num of numlist 10 100 1000 10000{
	
	simulate N=r(N) beta=r(beta) SEM=r(SEM) pvalue=r(pvalue) ci_low=r(ci_low) ci_high=r(ci_high), reps(500): regression, n(`num')
	
	
	append using "part1_4.dta"
	save "part1_4.dta", replace

}

**5
use "part1_4.dta", clear
sort N

*beta
table N, statistic(mean beta SEM ci_high ci_low) nformat(%9.6f)
preserve
collapse (mean) beta SEM ci_high ci_low, by(N)

*encode N
gen str_N = string(N)
encode str_N, gen(Ni)

#delimit ;
twoway 
	(rcap ci_low ci_high Ni, lcolor(gs10))
	(scatter beta Ni, mcolor(black)),
	xlabel(1(1)4, valuelabel angle(45))
	xtitle("")
	legend(order(1 2) pos(1) label(1 "Confidence Interval") label(2 "Coefficient Estimate") size(small))
	fxsize(35)

;
#delimit cr;

graph save "Beta1.gph", replace

#delimit ;
graph bar
	SEM,
	over(N, label(angle(45)))
	bar(1, color(gs10%80))
	blabel(bar, format(%9.2f))
	ytitle("Average SE. of beta")
	fxsize(35)

;
#delimit cr;

graph save "SEM1.gph", replace

restore


