*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include './STAT697-01_s20-team-1_data_preparation.sas';

*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 1 of 4: How does the type of school effect an ELs/LEP student in 
meeting UC/CSU entrance requirements? Also how does this varry between 
ethnicities?'
;

title2 justify=left
'Rationale: This could help schools better understand the type of learing 
environment that is best for students who are ELs and LEP students?'
;

footnote1 justify=left
''
;

/*
'Note: This utilizes the Met UC/CSU Grad Req as the response and uses with the 
ELs/LEP indicator along with the indicator for Charter school or non Charter
School.'
*/


title3 justify=left
'Selecting variables of interest that may impact an ELs/LEP student in meeting
UC/CSU entrance requirements'
;

proc sql
    select 
        CharterSchool
       ,Met_UC_CSU_Grad_Req
       ,Total_EL
    from
        cde_analytic_file_raw
    where
        CohortStudents > 30
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 2 of 4: What are the odds of a male student meeting the admissions
requirements for a UC/CSU compared to a female student.'
;

title2 justify=left
'Rationale: Having an understadnign of how the various factors effect ELs and
LEP Students could help schools and parents determine which type of learning
environment will best serve these students.'
;


/*
Note: This utilizes the Met UC/CSU Grad Req' as the response and uses with the 
ELs/LEP indicator along with the factors for Charter school or non Charter
School (district, county, etc).
*/

title3 justify=left
'Plot showing the proportion of Reporting Categories meeting UC/CSU admissions
requirements, with the primary focus being the differences between male and
female students'


proc sql
    create table q2_gender as
    select 
        CharterSchool
       ,ReportingCategory
       ,input(Met_UC_CSU_Grad_Req, best.) as Met_UC_CSU_Grad_Req       
    from
        cde_analytic_file_raw
    where
        CohortStudents >= 30
        and
        is not null(Met_UC_CSU_Grad_Req)
        and
        ReportingCategory = (GM,GF)
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;


proc sgplot data=q2_gender;
	yaxis label="MetReq" ;
    vbar ReportingCategory / response=MetReq;
    vbar ReportingCategory / response=MetReq
    	barwidth=0.5
    	transparency=0.2;
run;

footnote1 justify=left
'In the above plot it appears that female students are meeting the UC/CSU 
admissions requirements at a higher rate than their male peers'
;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 3 of 4: What are the odds that a Hispanic Student will meet 
admission requirements attending a charter school compared to a "White, not 
Hispanic" student?'
;

title2 justify=left
'Rationale: From the odds we can gain a better perspective on the success rates
of an underserved/ underrepresented student populations compared to their 
"White, not Hispanic" peers.'
;


/*
Note: This compares the odds ratio of Met UC/CSU Grad Req' (Rate) of 'White, not 
Hispanic' with the odds ratio of Hispanic students through categorical analysis 
methods.
*/


title2 justify=left
'Proc freq analysis to determine the odd that aHispanic Student will meet 
admission requirements attending a charter school compared to a "White, not 
Hispanic" student.'
;

footnote1 justify=left
'Spanish ELs/LEP students make up the largest portion of this student
population as they represent 15% of ELs/LEP students'
;

proc sql
    select 
        CharterSchool
       ,ReportingCategory
       ,CohortStudents
       ,Met_UC_CSU_Grad_Req       
    from
        cde_analytic_file_raw
    where
        CohortStudents > 30
        ReportingCategory = (RW,RH)
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;


proc logistic data=cde_analytic_file_raw;
    class CharterSchool (ref='YES') / param=reference;
    freq count;
    model type(ref='RW')=ReportingCategory / link=glogit;
    output out=type_pred PREDPROBS=YES;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
title1 justify=left
'Question 4 of 4: What are the odds that a ELs/LEP student will meet admission 
requirements compared to non ELs/LEP student?'
;

title2 justify=left
'Rationale: From the odds we can gain a better perspective on the success rates
of ELs/LEP students compared to non ELs/LEP strudents to see just how much any
descrpencies in support impacts this student population.'
;


/*
Note: This compares the odds ratio of ELs/LEP students with the odds ratio of 
students of who are not ELs/LEP students through categorical analysis methods.
*/


proc sql
    select 
        CharterSchool
       ,Met_UC_CSU_Grad_Req
       ,LC
       ,Total_EL
    from
        cde_analytic_file_raw
    where
        CohortStudents > 30
        LC > 0
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;

title;
