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

clear all 
set more off

**2
set obs 10000
set seed 2025

gen x = rnormal(0,1)
gen y = 2*x + rnormal(0,1)

save "part1_2.dta", replace
