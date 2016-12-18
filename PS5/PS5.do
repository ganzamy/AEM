************
************
* Amy Ganz 
* PS 5!
* AEM
************
************


clear all 
global ps5 "/Users/amy/Dropbox/1. NYU Wagner/Fall 2016/AEM/PS5"

cd "$ps5"

u DinD_ex

*`1. Use mean differences to compute the difference in means estimate of the change in minimum wage.

gen njfte=nj*fte
replace njfte=. if nj==0

ttest njfte, by(after)



/* New Jersey:
Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
       0 |     284    17.30106    .5267727    8.877331    16.26417    18.33795
       1 |     284    17.58363    .4991043    8.411055     16.6012    18.56605
---------+--------------------------------------------------------------------
combined |     568    17.44234    .3625626    8.640865    16.73021    18.15447
---------+--------------------------------------------------------------------
    diff |           -.2825704    .7256684               -1.707902    1.142761
------------------------------------------------------------------------------
    diff = mean(0) - mean(1)                                      t =  -0.3894
Ho: diff = 0                                     degrees of freedom =      566

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.3486         Pr(|T| > |t|) = 0.6971          Pr(T > t) = 0.6514

*/

gen pa=0
replace pa=1 if nj==0
gen pafte=pa*fte
replace pafte=. if nj==1

ttest pafte, by(after) 

/*
For pennsylvania:
Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
       0 |      65        20.3     1.50888    12.16498    17.28567    23.31433
       1 |      65    18.25385    .9771041    7.877665    16.30186    20.20584
---------+--------------------------------------------------------------------
combined |     130    19.27692    .8998412    10.25977    17.49657    21.05728
---------+--------------------------------------------------------------------
    diff |            2.046154    1.797624               -1.510752     5.60306
------------------------------------------------------------------------------
    diff = mean(0) - mean(1)                                      t =   1.1383
Ho: diff = 0                                     degrees of freedom =      128

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.8714         Pr(|T| > |t|) = 0.2571          Pr(T > t) = 0.1286 

*/


/* 2. Estimate the differences-in-differences using a regression model in
differences, i.e., the left-hand-side variable is change in the outcome of interest. Do
two versions: one plain vanilla and one with the robust option. The difference in the
standard errors is sizeable – why is this? */


reg dfte nj
outreg2 using q2.docx, replace
reg dfte nj, robust
outreg2 using q2.docx, append


reg dfte njafter
reg dfte njafter, robust







*why is standard error sensitive? because you are interviewing the same restaurants twice, so you essentially have half the observations as regular OLS due to inter-class correlation. Also, heteroskedasticity? 


/*3. Now estimate the following model in levels, i.e., with the left-hand-side
variable in levels. Again estimate two versions of the model with different standard
errors: one plain vanilla and one with the robust option. What is the coefficient of
interest? Do the standard error options make a difference. */

reg fte nj njafter after // tstat: 1.34 
outreg2 using q3.docx, replace
reg fte nj njafter after, robust // t-stat in njafter  1.21 
outreg2 using q3.docx, append

/*4. Now estimate the levels model from question 3 but cluster on sheet. How do
the standard errors change? */

reg fte nj njafter after, cluster(sheet) // tstat 1.58
outreg2 using q3.docx, append

/* 5. Now estimate the levels model using fixed effects (i.e. xtreg). Which variables
get dropped and why? */

xtset sheet after

xtreg fte nj njafter after, fe
outreg2 using q3.docx, append


*New Jersey indicator gets dropped because it is time invariant. 

/*6. Why are all the estimated impact of the minimum wage the same in all these
models? */ 

* Because the point estimates are all the same. We are making different assumptions about the standard errors, not the coefficients. 
/*The first vertical line is the rise in the NJ minimum wage they studied, the second
vertical line a further rise and the final vertical line a rise in the federal minimum
wage which brought the NJ and PA minimum wages back in line. The lines represent
employment in fast-food restaurants in NJ and two selections of PA counties. Why do
you think this picture contains useful information?*/

*The fact that the lines cross is bad news. It violates the assumption of constant differences between time trends in states. You want to see them parallel to eachother over time. 
*The time period around 


* Q8

clear all 
global ps5 "/Users/amy/Dropbox/1. NYU Wagner/Fall 2016/AEM/PS5"
cd "$ps5"
clear all
u  safesave_slim_data
/*
Given this information, create a plot displaying the time trends in loan balances for
the treatment and comparison branches, pre and post interest rate change. Eyeballing
the figure, do they look parallel?
*/

rename *, lower

gen ltika=tika*loanbal
gen lge=ge*loanbal

bys monthyear: egen mean_ltika=mean(ltika)
bys monthyear: egen mean_lge=mean(lge)

line mean_ltika trend || line mean_lge trend, xline(13) ysc(r(0 1000)) ylabel(#5) xlabel(#11)

twoway scatter mean_ltika trend || twoway scater mean_lge trend, xline(13) ysc(r(0 1000)) ylabel(#5) xlabel(#11)
graph tw (scatter mean_ltika trend) || lfit mean_ltika trend

gen diff=mean_ltika-mean_lge

line diff trend, xline(13)

scatter ltika trend || scatter lge trend, xline(13)

* The post period is defined from February 2000 onward.
gen post=0
replace post=1 if trend>=13
sum post


ttest mean_ltika, by(post)
ttest mean_lge, by(post)

/*
Now run a regression to provide a test of the parallel trend assumption in the preperiod
(i.e., that the treatment and comparison branches have the same time trend
before the interest rate change). While you’re at it, check whether within the
comparison branches, either the intercept or slope changed when the interest changed.
What is needed for the strategy to be valid? What do you find?
*/

gen trendpost=trend*post
reg loanbal trend post trendpost if tika==1 // col1, table 2
outreg2 using "q8.docx", replace 

reg loanbal trend post trendpost if tika==0 // col2, table 2
outreg2 using "q8.docx", append 


*trendpost is significant for treated but not for control group. 
*test  

// add: Treatment × Post × Trend, Treatment × Post, Treatment × Trend
gen tpt=tika*post*trend
gen tp=tika*post 
gen tt=tika*trend

reg loanbal tika trend post trendpost tpt tp tt
outreg2 using "q8.docx", append 
 
reg loanbal tika trend post trendpost tpt tp tt nage tinpr
outreg2 using "q8.docx", append


/*
Something you will notice is that the comparison and treatment branches have a
different level of loan balances (i.e., intercept) pre-interest rate change. Is this
problematic for the strategy? Does this change persist when you control for the
variables tinpr and nage (time in program – the length of time the borrower has been
with the bank – and nage, the age of the borrower)?
*/



