clear all

if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818\week_10\03_assignment\"
}

if c(username)=="suyux" {
	
	global wd "/Users/suyux/Desktop/Education/GU/2025Spring/Experimental Design/ppol6618/week_10/03_assignment/"
}

cd "$wd"

********************************************************************************
* Part 1
********************************************************************************

**1
clear all 
set more off
set obs 10000

set seed 2025

gen y = rnormal(0,1)


**2
gen tau = runiform(0,0.2)

**3
gen rand = runiform()
sort rand

gen treat = 0
replace treat = 1 in 1/5000

drop rand

power twomeans 0 0.1, sd(1) power(0.8)

**4
/*if 15% of the sample attrite, there is only 85% of the sample left. If I want 
to have same number of effective sample size, I have to collect more number in 
required sample size, making the effective sample size is the same as estimated 
sample sizes we had in question 3, which is 3142. */

**5
/*The less balanced the group sizes, the larger the variance of the estimated 
treatment effect. As variance increases, the estimate becomes less precise.
Therefore, to maintain the same level of precision and statistical power, the 
total sample size must be increased. */ 

power twomeans 0 0.1, sd(1) power(0.8) nratio(0.7/0.3)

*the sample size has to be increased to 3244 from 3142. 

********************************************************************************
* Part 2
********************************************************************************

**1-4
clear all
set more off
set seed 2025

capture program drop sim_cluster
program define sim_cluster, rclass
syntax, numcluster(integer) clustersize(integer)
	
	clear
	
	*total number of obs
	local num = `numcluster'*`clustersize'
	set obs `num'
	
	*school id
    gen cluster_id = .
	replace cluster_id = floor((_n - 1) / `clustersize') + 1

    *assign treatment at cluster level evenly
	preserve
	keep cluster_id
	duplicates drop
	gen rand = runiform()
	tempfile rands
	save `rands'
	restore

	merge m:1 cluster_id using `rands', nogen

	gen treatment = 0
	quietly {
		count
		local N=r(N)
		replace treatment = 1 in 1/`=`N'/2'
	}
	
	
    *set icc 0.3
    scalar sigma_u = sqrt(0.3)
    scalar sigma_e = sqrt(0.7)

    *generate cluster-level random effects (same for each student in the school)
    gen u = .
    qui forvalues i = 1/`numcluster' {
        local u_val = rnormal(0, sigma_u)
        replace u = `u_val' if cluster_id == `i'
    }

    *generate individual-level residuals
    gen e = rnormal(0, sigma_e)
	
	*general treatment effective
	gen treat_eff = runiform(0.15, 0.25)
	
    *set outcome Y
    gen Y = 50 + 0.2 * treatment + u + e
	
	reg Y treatment
	
	return scalar p = 2 * (1 - normal(abs(_b[treatment] / _se[treatment])))


end

**5
clear
tempfile cluster
save `cluster', replace emptyok

local sizes 1 2 4 8 16 32 64 128 256 512
local i = 1

foreach s of local sizes {
    display "Running simulations for cluster size = `s'..."
	
	clear
    
    simulate p=r(p), reps(100): sim_cluster, numcluster(200) clustersize(`s')
	
	sum p
	
	local p = r(mean)
	
	clear 
	set obs 1
	gen cluster_size = `s'
	gen p = `p'
	
	append using `cluster'
	save `cluster', replace
	
}

/* Based on my simulation results, I recommend a cluster size of 32 students per school.
As cluster size increases, statistical power initially improves because more individual-level data reduces variance in outcome estimates. However, due to the high intraclass correlation (ICC = 0.3), students within a cluster (school) are highly similar. This means that beyond a certain point, adding more students per school provides diminishing returns in terms of statistical information.
My simulations show that power improves substantially up to around cluster size = 32, but gains become minimal after that, and in some cases, p-values actually increase. This is because the number of independent units — the clusters — is fixed at 200, so adding more individuals per cluster does little to improve power.
Therefore, 32 students per school is an efficient and effective choice: it provides strong statistical power without the cost or complexity of significantly larger sample sizes. */


**6
power twomeans 0 0.2, cluster m1(15) m2(15) rho(0.3) power(0.8)

/* We need 274(137+137) clusters to ensure our RCT to get 80% power to 
detect 0.2 sd treatment effect. */

**7
*if 30% schools do not comply treatment, the true observed effect is 0.14(0.2*70%)
power twomeans 0 0.14, cluster m1(15) m2(15) rho(0.3) power(0.8)

/* we need 556 schools to maintain 80% power */

********************************************************************************
* Part 3
********************************************************************************

**1-3
clear all
set obs 10000 

*create strata groups
gen strata = ceil(runiform()*5)

*create covariates
gen X1 = rnormal()   // confounder
gen X2 = rnormal()  // affects Y only
gen X3 = rnormal()  // affects T only

*treatment assignment based on X1 and X3
gen p_treat = 0.4*X1 + 0.7*X3
gen T = (runiform() < p_treat)

/* we create covariates that is confounder or affects Y and T only for testing
whether these three types of covariates have omitted variables bias. */

*error term
gen e = rnormal(0, 1)

*outcome with true effect of treatment = 0.5
gen Y = 0.5*T + 0.8*X1 + 0.3*X2 + strata + e

save "part3.dta", replace

**4
capture program drop regression
program define regression, rclass
    syntax, n(integer)

	use "part3.dta", clear
    sample `n', count

    * Model 1: No controls
    reg Y T
    return scalar b1 = _b[T]
	return scalar ci_low1 = _b[T] - 1.96*_se[T]
	return scalar ci_high1 = _b[T] + 1.96*_se[T]

    * Model 2: Add X1
    reg Y T X1
    return scalar b2 = _b[T]
	return scalar ci_low2 = _b[T] - 1.96*_se[T]
	return scalar ci_high2 = _b[T] + 1.96*_se[T]

    * Model 3: Add X1 + X2
    reg Y T X1 X2
    return scalar b3 = _b[T]
	return scalar ci_low3 = _b[T] - 1.96*_se[T]
	return scalar ci_high3 = _b[T] + 1.96*_se[T]

    * Model 4: Fixed effects (strata)
    xtset strata
    xtreg Y T X1 X2, fe
    return scalar b4 = _b[T]
	return scalar ci_low4 = _b[T] - 1.96*_se[T]
	return scalar ci_high4 = _b[T] + 1.96*_se[T]

    * Model 5: Add X3 (which shouldn't help)
    xtreg Y T X1 X2 X3, fe
    return scalar b5 = _b[T]
	return scalar ci_low5 = _b[T] - 1.96*_se[T]
	return scalar ci_high5 = _b[T] + 1.96*_se[T]
end

clear
tempfile results
save `results', replace emptyok

local sizes 100 250 500 1000 5000 10000

foreach N of local sizes {
    di "Running simulations for N = `N'"

    simulate b1=r(b1) ci_low1=r(ci_low1) ci_high1=r(ci_high1) b2=r(b2) ci_low2=r(ci_low2) ci_high2=r(ci_high2) b3=r(b3) ci_low3=r(ci_low3) ci_high3=r(ci_high3) b4=r(b4) ci_low4=r(ci_low4) ci_high4=r(ci_high4) b5=r(b5) ci_low5=r(ci_low5) ci_high5=r(ci_high5), reps(100): regression, n(`N')

    gen N = `N'
    append using `results'
    save `results', replace
}


use `results', clear

collapse (mean) b* ci_*, by(N)

reshape long b ci_low ci_high, i(N) j(model)

sort N model

*beta
table N, statistic(mean b ci_high ci_low) nformat(%9.6f)

preserve
collapse (mean) b ci_high ci_low, by(N)

*encode N
gen str_N = string(N)
gen Ni = _n
ssc install labutil
labmask Ni, values(str_N)

#delimit ;
twoway 
	(rcap ci_low ci_high Ni, lcolor(gs10))
	(scatter b Ni, mcolor(black)),
	xlabel(1(1)6, valuelabel)
	xtitle("")
	legend(order(1 2) pos(1) label(1 "Confidence Interval") label(2 "Coefficient Estimate") size(small))

;
#delimit cr;
restore

graph export "convergence.jpg", replace

table model, statistic(mean b ci_high ci_low) nformat(%9.6f)

preserve
collapse (mean) b ci_high ci_low, by(model)

label define model_lbl 1 "T only" ///
                      2 "T + X1" ///
                      3 "T + X1 + X2" ///
                      4 "T + X1 + X2 + FE" ///
                      5 "ALL"

label values model model_lbl

#delimit ;
twoway 
	(rcap ci_low ci_high model, lcolor(gs10))
	(scatter b model, mcolor(black)),
	xlabel(1(1)5, valuelabel angle(0))
	xtitle("")
	legend(order(1 2) pos(1) label(1 "Confidence Interval") label(2 "Coefficient Estimate") size(small))

;
#delimit cr;
restore

graph export "biaseness.jpg", replace
