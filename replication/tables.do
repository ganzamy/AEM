*******
* project: AEM replication
* paper: Bedard & Deschenes, 2004. "Sex Preferences, Marital Dissolution, and the Economic Status of Women"
* Part 2 create tables
* Author: A. Ganz
*******


global raw "/Users/amy/Dropbox/1. NYU Wagner/Fall 2016/AEM/replication"
*global raw "/Users/AmyGanz/Dropbox/1. NYU Wagner/Fall 2016/AEM"
cd "$raw"
clear all
set more off 

***
* Table 1
***

u sample1
set matsize 600
sum marr_end agemarr fb_girl cheverborn age_at_fb age educ urban adj_hhinc pov nonwominc inctot incwage

outreg2 using col1.docx, replace sum(log) keep (marr_end agemarr fb_girl cheverborn age_at_fb age educ urban adj_hhinc pov nonwominc inctot incwage) 


clear all 
u sample2
outreg2 using col1.docx, append sum(log) keep (marr_end agemarr fb_girl cheverborn age_at_fb age educ urban adj_hhinc pov nonwominc inctot incwage)


clear all 
u sample3
outreg2 using col1.docx, append sum(log) keep (marr_end agemarr fb_girl cheverborn age_at_fb age educ urban adj_hhinc pov nonwominc inctot incwage)

***
* Table 2
***
clear all 
u sample3

* unadjusted 
gen educlev=0
	replace educlev=1 if educ<12
	replace educlev=2 if educ==12
	replace educlev=3 if (educ>=13 & educ<=15)
	replace educlev=4 if educ>15

gen mar20=0
	replace mar20=1 if agemarr<20
	replace mar20=2 if agemarr>=20

gen agebirth=0
	replace agebirth=1 if age_at_fb<22
	replace agebirth=2 if age_at_fb>=22
save sample3a, replace

reg marr_end fb_sex, robust
	test fb_sex
	outreg2 using table2_unadjusted, stats(coef se) adds(F-test, r(F)) replace nocons   //keep(fb_sex) addstat(F test, e(p))

forvalues x = 1/4 {
	reg marr_end fb_sex if educlev==`x', robust
	test fb_sex
	outreg2 using table2_unadjusted, stats(coef se) adds(F-test, r(F)) append nocons 
}

forvalues x=1/2{
	reg marr_end fb_sex if mar20==`x', robust
	test fb_sex
	outreg2 using table2_unadjusted, stats(coef se) adds(F-test, r(F)) append nocons 
}

forvalues x=1/2 {
	reg marr_end fb_sex if agebirth==`x', robust
	test fb_sex
	outreg2 using table2_unadjusted, stats(coef se) adds(F-test, r(F)) append nocons 
}


* regression adjusted 
gen agesq=age*age
gen agefb_sq=age_at_fb*age_at_fb
gen agemarrsq=agemarr*agemarr
gen educsq=educ*educ
gen ageeduc=age*educ
gen mareduc=agemarr*educ
gen birtheduc=age_at_fb*educ
save sample3b, replace 

global adj "age educ agemarr educ age_at_fb educ agesq agefb_sq agemarrsq educsq urban ageeduc mareduc birtheduc"

reg marr_end fb_sex $adj, robust
	test fb_sex
	outreg2 using table2_adjusted, stats(coef se) adds(F-test, r(F)) replace nocons keep(fb_sex)


forvalues x = 1/4 {
	reg marr_end fb_sex $adj if educlev==`x', robust
	test fb_sex
	outreg2 using table2_adjusted, stats(coef se) adds(F-test, r(F)) append nocons keep(fb_sex)
}

forvalues x=1/2 {
	reg marr_end fb_sex $adj if mar20==`x', robust
	test fb_sex
	outreg2 using table2_adjusted, stats(coef se) adds(F-test, r(F)) append nocons keep(fb_sex)
}

forvalues x=1/2 {
reg marr_end fb_sex $adj if agebirth==`x', robust
test fb_sex
	outreg2 using table2_adjusted, stats(coef se) adds(F-test, r(F)) append nocons keep(fb_sex)
}



********
* Table 3
********
clear all 
u sample3b

*by divorce status

ttest agemarr, by(marr_end) 

matrix table1 = J(20, 6, .)
*matrix colnames table1 = `vars'
*matrix rownames table1 = "First marriage ended" "Age at First Marriage" "Firstborn girl" "Number of Children" "Age at first birth" "Age" "Years of Education" "Urban" 

local i =1
foreach var in agemarr fb_girl cheverborn age_at_fb age educ urban {

	ttest `var', by(marr_end) 
	
	matrix table1[`i', 1] = r(mu_1)
	matrix table1[`i', 2] = r(sd_1)
	matrix table1[`i', 3] = r(mu_2)
	matrix table1[`i', 4] = r(sd_2)
	matrix table1[`i', 5] = r(mu_1)-r(mu_2)
	matrix table1[`i', 6] = r(se)	
	
local i =`i'+1

}

matrix list table1

*by firstborn sex
local i = 9
foreach var in marr_end agemarr cheverborn age_at_fb age educ urban {

	ttest `var', by(fb_girl) 
	
	matrix table1[`i', 1] = r(mu_1)
	matrix table1[`i', 2] = r(sd_1)
	matrix table1[`i', 3] = r(mu_2)
	matrix table1[`i', 4] = r(sd_2)
	matrix table1[`i', 5] = r(mu_1)-r(mu_2)
	matrix table1[`i', 6] = r(se) 	
	
	local i=`i'+1
}

matrix list table1

*****
* Table 4
*****
clear all 
u sample3b
global controls "age agemarr educ age_at_fb agesq agefb_sq agemarrsq educsq ageeduc mareduc birtheduc urban i.bpl i.state_res"

reg wkpay marr_end $controls, robust 

*col1 (OLS)
local replace replace
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	reg `v' marr_end $controls, robust 
	outreg2 using "table4_ols.docx", keep(marr_end) nocons `replace' 
	local replace append
}
	
*col2 2SLS no controls

local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' (marr_end = fb_girl), robust
	outreg2 using "table4_wald.docx", keep(marr_end) nocons `replace'
	local replace append
}
	
*col3 2sls with controls

*test 
*ivregress 2sls adj_hhinc $controls (marr_end = fb_girl) , first robust	

local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' $controls (marr_end = fb_girl), robust	
	outreg2 using "table4_tsls2.docx", keep(marr_end) nocons `replace'
	local replace append
}

*col4: with fertility and current marital status (remarried) 

*test
*ivregress 2sls adj_hhinc $controls nchild remarried (marr_end = fb_girl) , first robust


local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' nchild remarried $controls (marr_end = fb_girl), robust	
	outreg2 using "table4_tsls1.docx", keep(marr_end) nocons `replace'
	local replace append
}


*******
*Table 5
*******

* OLS full sample
local replace replace
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork {
	reg `v' marr_end $controls, robust 
	outreg2 using "table5_ols1.docx", keep(marr_end) nocons `replace' 
	local replace append
}

* OLS for oldest <12
preserve
keep if fb_age<12
reg adj_hhinc marr_end $controls, robust 
restore 




preserve 
keep if fb_age<12
local replace replace
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork {
	reg `v' marr_end $controls, robust 
	outreg2 using "table5_ols2.docx", keep(marr_end) nocons `replace' 
	local replace append
}
restore 
	
* OLS for oldest>=12  
preserve 
keep if fb_age>=12
local replace replace
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork {
	reg `v' marr_end $controls, robust 
	outreg2 using "table5_ols3.docx", keep(marr_end) nocons `replace' 
	local replace append
}
restore 



* 2sls full samp
local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' $controls (marr_end = fb_girl), robust	
	outreg2 using "table5_tsls1.docx", keep(marr_end) nocons `replace'
	local replace append
}


* 2sls <12
preserve
keep if fb_age<12
local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' $controls (marr_end = fb_girl), robust	
	outreg2 using "table5_tsls2.docx", keep(marr_end) nocons `replace'
	local replace append
}
restore


* 2sls 12+

preserve
keep if fb_age>=12
local replace replace 
foreach v in adj_hhinc pov nonwominc inctot incwage wkpay wkswork1 uhrswork{
	ivregress 2sls `v' $controls (marr_end = fb_girl), robust	
	outreg2 using "table5_tsls3.docx", keep(marr_end) nocons `replace'
	local replace append
}
restore

*get sample sizes and f-statistics (the square of the t-stats)
ivregress 2sls adj_hhinc $controls (marr_end = fb_girl), first robust

keep if fb_age<12
ivregress 2sls adj_hhinc $controls (marr_end = fb_girl), first robust

clear all 
u sample3b
keep if fb_age>11
ivregress 2sls adj_hhinc $controls (marr_end = fb_girl), first robust












	

