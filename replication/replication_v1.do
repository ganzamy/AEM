
*******
* project: AEM replication
* paper: Bedard & Deschenes, 2004. "Sex Preferences, Marital Dissolution, and the Economic Status of Women"
* Part 1 create samples
* Author: A. Ganz
*******

*global raw "C:\Users\alg638\Documents"
global raw "/Users/amy/Dropbox/1. NYU Wagner/Fall 2016/AEM/replication"
*global raw "/Users/AmyGanz/Dropbox/1. NYU Wagner/Fall 2016/AEM"
cd "$raw"
clear all
set more off 
u ipums

drop year

************
* work with moms 
************

*get number of adults per household
gen adults=1
replace adults=. if age<18
gen minors=1
replace minors=. if age>=18


bys serial: egen hhadults=sum(adults) 
bys serial: egen hhminors=sum(minors) 
save ipums1, replace

/* Our sample includes U.S.-born white women aged 21–40 who have been married at least once and who have had at least one child.
Throughout the analysis we focus on women whose first marriage began when they were 17–26 years of age. 
This includes more than 90 percent of all first marriages. 
*/
clear all 
u ipums1

keep if bpl <=120 & race==1 & sex==2 & age>=21 & age<=40 
keep if (agemarr>=17 & agemarr<=26) & marst<5
*After removing the "not applicable" category (coded 00), to get the actual number of children ever born, users must subtract 1 from the value of CHBORN. 
gen cheverborn=chborn-1 
replace cheverborn=0 if chborn==0    
keep if cheverborn>0 

/*
Observations with allocated age, number of marriages, current marital status, age at first marriage,
number of children ever-born, relationship to the household head, and sex were excluded. Families are also
excluded if the oldest child has allocated values for age, sex, relationship to the household head, or month
of birth. Widows are also excluded. None of the results are significantly altered by these exclusions.
*/
keep if (qage==0 & qagemarr==0 & qchborn==0 & qmarrno==0  & qmarst==0 & qrelate==0  & qsex==0)
drop qage-qbirthmo

gen mergeid=pernum
save potential_moms, replace


************
*work with children
************

clear all 
u ipums1

keep if momloc ~=0 

bys serial momloc: egen oldest=max(age)
bys serial momloc: egen child_hh=count(age)
keep if age==oldest

rename (age sex birthqtr qage qsex qrelate qbirthmo)  (fb_age fb_sex fb_birthqtr fb_qage fb_qsex fb_qrelate fb_qbirthmo) // rename vars for merging back in with moms

*ID families with more than one child who is oldest and same age. 
*bysort serial momloc: gen age_diff = oldest - oldest[_n-1] // identifies oldest children born in same year to same mother
gsort serial momloc fb_birthqtr
by serial momloc: gen famnum =_N
gsort serial momloc fb_birthqtr
by serial momloc: gen famid=_n

*calculate how many quarters apart to tell if they are twins
*by serial momloc: gen age_qtr_diff = fb_birthqtr-fb_birthqtr[_n+1] // identifies oldest children born in same quarter to same mother
by serial momloc: egen bqtr1=min(fb_birthqtr)
by serial momloc: egen bqtr2=max(fb_birthqtr)
gen twin=1 if (famnum>1 & (bqtr1==bqtr2))

/*
preserve
keep if twin==1
save twins, replace
restore
*/

keep if (famid==1 | (famid>1 & twin==1)) // this way gives 1,997,853

keep serial momloc child_hh fb_age fb_sex fb_birthqtr fb_qage fb_qsex fb_qrelate fb_qbirthmo twin famnum

gen mergeid=momloc


save kids, replace

***********


clear all 
u potential_moms
merge 1:m serial mergeid using kids
drop if _merge==2
drop _merge 

save mom_kids, replace


***********
* Create different samples
*********** 

clear all 
u mom_kids

rename *, lower

*Families are also excluded if the oldest child has allocated values for age, sex, relationship to the household head, or month of birth. 
keep if fb_qage==0 | fb_qage==.
keep if fb_qsex==0 | fb_qsex==.
keep if fb_qrelate==0 | fb_qrelate==.
keep if fb_qbirthmo==0 | fb_qbirthmo==.

replace hhincome=. if hhincome==9999999
drop if hhincome==.
*replace hhincome=0 if hhincome<0
gen adj=(hhadults+.7*hhminors)^(.7)
gen adj_hhinc=hhincome/adj

keep if raced==100

drop fb_qage fb_qsex fb_qrelate fb_qbirthmo


gen marr_end=0
replace marr_end= 1 if (marst==3 | marst==4) // if first marriage ended
replace marr_end=1 if marrno>=2

gen fb_girl=0 // firstborn sex
replace fb_girl=1 if fb_sex==2

gen age_at_fb= age-fb_age //age at first birth

gen marr2bir= age_at_fb-agemarr //create var for filtering by age at first birth-age first marriage

gen educ=higrade-3 // recode years of education
replace educ=0 if higrade<4

gen urban=0 // urban variable
replace urban=1 if metarea ~=0

*use chborn and nchild for sample 2 


*create poverty indicator
gen poverty_hh=0
replace poverty_hh=172*hhincome/6451 if hhadults==1 & hhminors==0 
replace poverty_hh=172*hhincome/8547 if hhadults==1 & hhminors==1 
replace poverty_hh=172*hhincome/9990 if hhadults==1 & hhminors==2 
replace poverty_hh=172*hhincome/12619 if hhadults==1 & hhminors==3 
replace poverty_hh=172*hhincome/14572 if hhadults==1 & hhminors==4 
replace poverty_hh=172*hhincome/16259 if hhadults==1 & hhminors==5 
replace poverty_hh=172*hhincome/17828 if hhadults==1 & hhminors>=6 
replace poverty_hh=172*hhincome/8303 if hhadults==2 & hhminors==0 
replace poverty_hh=172*hhincome/9981 if hhadults==2 & hhminors==1 
replace poverty_hh=172*hhincome/12575 if hhadults==2 & hhminors==2 
replace poverty_hh=172*hhincome/14798 if hhadults==2 & hhminors==3 
replace poverty_hh=172*hhincome/16569 if hhadults==2 & hhminors==4 
replace poverty_hh=172*hhincome/18558 if hhadults==2 & hhminors==5 
replace poverty_hh=172*hhincome/20403 if hhadults==2 & hhminors>=6 
replace poverty_hh=172*hhincome/9699 if hhadults==3 & hhminors==0 
replace poverty_hh=172*hhincome/12999 if hhadults==3 & hhminors==1 
replace poverty_hh=172*hhincome/15169 if hhadults==3 & hhminors==2 
replace poverty_hh=172*hhincome/17092 if hhadults==3 & hhminors==3 
replace poverty_hh=172*hhincome/19224 if hhadults==3 & hhminors==4 
replace poverty_hh=172*hhincome/21084 if hhadults==3 & hhminors==5 
replace poverty_hh=172*hhincome/25089 if hhadults==3 & hhminors>=6 
replace poverty_hh=172*hhincome/12790 if hhadults==4 & hhminors==0 
replace poverty_hh=172*hhincome/15648 if hhadults==4 & hhminors==1 
replace poverty_hh=172*hhincome/17444 if hhadults==4 & hhminors==2 
replace poverty_hh=172*hhincome/19794 if hhadults==4 & hhminors==3 
replace poverty_hh=172*hhincome/21738 if hhadults==4 & hhminors==4 
replace poverty_hh=172*hhincome/25719 if hhadults==4 & hhminors>=5 
replace poverty_hh=172*hhincome/15424 if hhadults==5 & hhminors==0 
replace poverty_hh=172*hhincome/17811 if hhadults==5 & hhminors==1 
replace poverty_hh=172*hhincome/20101 if hhadults==5 & hhminors==2 
replace poverty_hh=172*hhincome/22253 if hhadults==5 & hhminors==3 
replace poverty_hh=172*hhincome/26415 if hhadults==5 & hhminors>=4 
replace poverty_hh=172*hhincome/17740 if hhadults==6 & hhminors==0 
replace poverty_hh=172*hhincome/20540 if hhadults==6 & hhminors==1 
replace poverty_hh=172*hhincome/22617 if hhadults==6 & hhminors==2 
replace poverty_hh=172*hhincome/26921 if hhadults==6 & hhminors>=3 
replace poverty_hh=172*hhincome/20412 if hhadults==7 & hhminors==0 
replace poverty_hh=172*hhincome/23031 if hhadults==7 & hhminors==1 
replace poverty_hh=172*hhincome/27229 if hhadults==7 & hhminors>=2 
replace poverty_hh=172*hhincome/22830 if hhadults==8 & hhminors==0 
replace poverty_hh=172*hhincome/27596 if hhadults==8 & hhminors>=1 
replace poverty_hh=172*hhincome/27463 if hhadults>=9 & hhminors>=0 

*create pov indicator
gen pov=0
replace pov=1 if poverty_hh<100

*create income measures
gen nonwominc=hhincome-inctot

gen personal_inc=inctot

gen womanearn=incwage


*employment measures
gen employed=0
replace employed=1 if empstat==1

gen wkpay=0
replace wkpay=1 if (employed==1 & incwage>0)
nmissing incwage // no missings
replace wkpay=1 if (employed==1 & incwage>0)

gen married=0
replace married=1 if (marst==1 | marst==2)

gen remarried=0
replace remarried=1 if (marrno==2 & (marst==1 | marst==2))

gen state_b=0
replace state_b=bpl if bpl<=56


gen state_res=statefip


keep if stepmom==0
drop if gq==3 | gq==4

save sample1, replace 
* current count 664k


* limit the sample to women whose children all reside in her household
clear all 
u sample1

keep if nchild==cheverborn
* For similar reasons we further exclude women whose oldest child is 18 or older.

drop if fb_age>=18

drop if twin==1
 
* 542,951

save sample2, replace


* In an attempt to isolate biological children born during the first marriage, we limit the sample to women whose first child is born 
* within the first five years of her first marriage.

sum marr2bir

keep if (marr2bir>=0 & marr2bir<=5)

save sample3, replace
*463k
*********














