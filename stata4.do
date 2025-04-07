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




