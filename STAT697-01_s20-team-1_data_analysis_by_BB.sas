*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* load external file that will generate final analytic file */
%include './STAT697-01_s20-team-1_data_preparation.sas';

*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 4: How does the type of school effect ELs and LEP student's in 
meeting UC/CSU entrance requirements? Also how does this varry between 
ethnicities?

Rationale: This could help schools better understand the type of learing 
environment that is best for students who are ELs and LEP students?

Note: This utilizes the Met UC/CSU Grad Req' as the response and uses with the 
ELs/LEP indicator along with the indicator for Charter school or non Charter
School.
*/


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
quit;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 4: What are the odds of a male student meeting the admissions
requirements for a UC/CSU compared to a female student.

Rationale: Having an understadnign of how the various factors effect ELs and
LEP Students could help schools and parents determine which type of learning
environment will best serve these students.

Note: This utilizes the Met UC/CSU Grad Req' as the response and uses with the 
ELs/LEP indicator along with the factors for Charter school or non Charter
School (district, county, etc).
*/


proc sql
    select 
        CharterSchool
       ,ReportingCategory
       ,Met_UC_CSU_Grad_Req       
    from
        cde_analytic_file_raw
    where
        CohortStudents > 30
        ReportingCategory = (GM,GF)
    order by
        Met_UC_CSU_Grad_Req
quit;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 4: What are the odds that a Hispanic Student will meet 
admission requirements attending a charter school compared to a 'White, not 
Hispanic' student?

Rationale: From the odds we can gain a better perspective on the success rates
of an underserved/ underrepresented student populations compared to their 
'White, not Hispanic' peers.

Note: This compares the odds ratio of Met UC/CSU Grad Req' (Rate) of 'White, not 
Hispanic' with the odds ratio of Hispanic students through categorical analysis 
methods.
*/


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
quit;


proc logistic data=cde_analytic_file_raw;
    class CharterSchool (ref='YES') / param=reference;
    freq count;
    model type(ref='RW')=ReportingCategory / link=glogit;
    output out=type_pred PREDPROBS=YES;
run;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;
/*
Question 4 of 4: What are the odds that a ELs/LEP student will meet admission 
requirements compared to non ELs/LEP student?

Rationale: From the odds we can gain a better perspective on the success rates
of ELs/LEP students compared to non ELs/LEP strudents to see just how much any
descrpencies in support impacts this student population.

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
quit;