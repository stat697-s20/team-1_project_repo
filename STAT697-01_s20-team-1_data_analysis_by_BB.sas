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

/*
'Note: This utilizes the Met UC/CSU Grad Req as the response and uses with the 
ELs/LEP indicator along with the indicator for Charter school or non Charter
School.'

Limitations: Columns with a Cohort value of less than 30 were eliminated from
the dataset so that only regular public high schools and charter schools would
be counted and non schools, continuation schools, and independent study schools
would not be included to improve the accuracy of the analysis.
*/


title3 justify=left
'Selecting variables of interest that may impact an ELs/LEP student in meeting
UC/CSU entrance requirements'
;

proc sql;
    create table q2_gender as
    select 
        CharterSchool
       ,CohortStudents
       ,ReportingCategory
       ,input(Met_UC_CSU_Grad_Req, best.) as Met_UC_CSU_Grad_Req 
       ,Total_EL
    from
        cde_analytic_file_raw
    where
        CohortStudents >= 30
        and
        not missing(Met_UC_CSU_Grad_Req)       
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;

proc sql;
	create table q1El
		like q1_El
	;
quit;

proc sql;
	select * from q1El;
quit;

proc sql;
	insert into q1El
		select * from q1_El
	;
quit;

proc sql;
	delete from q1El
		where CharterSchool='All';
quit;

/* Removing all Reporting Categories except for 
except those associated with student race */
proc sql;
	delete from 
		q1El
	where 
		ReportingCategory = 'GM'
		OR
		ReportingCategory = 'GF'
		OR
		ReportingCategory = 'SD'
		OR
		ReportingCategory = 'SE'
		OR
		ReportingCategory = 'SF'
		OR
		ReportingCategory = 'SH'
		OR
		ReportingCategory = 'SM'
		OR
		ReportingCategory = 'SS'
		OR
		ReportingCategory = 'TA'
		OR
		ReportingCategory = 'GX'
	;
quit;

proc report data = q1El;
    columns
        Met_UC_CSU_Grad_Req
        ReportingCategory
        LC
        Total_EL
        ;
        define Met_UC_CSU_Grad_Req / group;
        define ReportingCategory / group;
        define LC / group;
        ;
run; 

footnote1 justify=left
'This proc sql will generate a table that will only contain information about
students who are classified as ELs/LEP as well as the rate ate which they are
able to meet UC/CSU admissions requirments.'
;

footnote2 justify=left
'From this output further analysis can be to determine which type of learning
envirnonment best serves ELs/LEP Students.'
;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 2 of 4: What are the odds of a male student meeting the admissions
requirements for a UC/CSU compared to a female student.'
;

title2 justify=left
'Rationale: Having an understading of how the various factors effect each gender
could help schools determine which type of learning environment best serves 
students.'
;

/*
Note: This utilizes the Met UC/CSU Grad Req' as the response and uses with the 
Reporting Category along with the factors for Charter school or non Charter
School (district, county, etc).

Limitations: This dataset does not include any information about the demographics
in the teacher populations that may effect the odds of a female student or male 
student meeting UC/CSU admissions requirements.
*/

title3 justify=left
'Plot showing the proportion of Reporting Categories meeting UC/CSU admissions
requirements, with the primary focus being the differences between male and
female students'
;

footnote1 justify=left
'From this histogram, we can see that the odds of a male or a female student 
meeting the UC/CSU requirements is roughly equivalent at either a Charter 
School or Public School, with male students having a slightly higher odds of
meeting the requirements at a charter school and female students having a 
slightly higher odds of meeting the requirements at a public school'
;

footnote2 justify=left
'From this, we can say that the learning environment of a charter school vs
a public school has minimal effect on a students ability to meet UC/CSU
admissions requirements.'
;

proc sql;
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
        not missing(Met_UC_CSU_Grad_Req)       
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;

proc sql;
	create table q2gender
		like q2_gender
	;
quit;

proc sql;
	select * from q2gender;
quit;

proc sql;
	insert into q2gender
		select * from q2_gender
	;
quit;

proc sql;
	delete from q2gender
		where CharterSchool='All';
quit;

/* Removing all Reporting Categories except for 
GM=Gender Male and GF=Gender Female */
proc sql;
	delete from 
		q2gender
	where 
		ReportingCategory = 'RA'
		OR
		ReportingCategory = 'RB'
		OR
		ReportingCategory = 'RD'
		OR
		ReportingCategory = 'RF'
		OR
		ReportingCategory = 'RH'
		OR
		ReportingCategory = 'RI'
		OR
		ReportingCategory = 'RP'
		OR
		ReportingCategory = 'RT'
		OR
		ReportingCategory = 'RW'
		OR
		ReportingCategory = 'SD'
		OR
		ReportingCategory = 'SE'
		OR
		ReportingCategory = 'SF'
		OR
		ReportingCategory = 'SH'
		OR
		ReportingCategory = 'SM'
		OR
		ReportingCategory = 'SS'
		OR
		ReportingCategory = 'TA'
		OR
		ReportingCategory = 'GX'
	;
quit;

/* Bar plot of MetReq for Gender Male vs Gender Female  */
proc sgplot data=q2gender;
	yaxis label="MetReqRate" ;
    vbar ReportingCategory / response=Met_UC_CSU_Grad_Req
        group=CharterSchool
        groupdisplay=Cluster
    	barwidth=0.5
    	transparency=0.2;
run;

footnote3 justify=left
'In the above plot it appears that female students are meeting the UC/CSU 
admissions requirements at a higher rate than their male peers in both 
the charter school and public school learing environment.'
;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
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

Limitations: This dataset does not include any information about the demographics
of this cities in which these schools are located as well or the differences in 
the teacher populations that may effect the odds of a Hispanic student or 'White,
non Hispanic' student meeting UC/CSU admissions requirements.
*/


title2 justify=left
'Proc freq analysis to determine the odd that a Hispanic Student will meet 
admission requirements attending a charter school compared to a "White, not 
Hispanic" student.'
;

footnote1 justify=left
'Spanish ELs/LEP students make up the largest portion of this student
population as they represent 15% of ELs/LEP students'
;

proc sql;
    create table q3_race as
    select 
        CharterSchool
       ,ReportingCategory
       ,CohortStudents
       ,Met_UC_CSU_Grad_Req       
    from
        cde_analytic_file_raw
    where
        CohortStudents >= 30        
    order by
        Met_UC_CSU_Grad_Req
    ;
quit;

proc sql;
	create table q3race
		like q3_race
	;
quit;

proc sql;
	select * from q3race;
quit;

proc sql;
	insert into q3race
		select * from q3_race
	;
quit;

proc sql;
	delete from q3race
		where CharterSchool='All';
quit;

proc sql;
	delete from q3race
		where 
			missing(School);
quit;

/* Removing all Reporting Categories except for 
RH=Race Hispanic and RW=Race White */
proc sql;
	delete from 
		q3race
	where 
		ReportingCategory = 'RA'
		OR
		ReportingCategory = 'RB'
		OR
		ReportingCategory = 'RD'
		OR
		ReportingCategory = 'RF'
		OR
		ReportingCategory = 'GM'
		OR
		ReportingCategory = 'RI'
		OR
		ReportingCategory = 'RP'
		OR
		ReportingCategory = 'RT'
		OR
		ReportingCategory = 'GF'
		OR
		ReportingCategory = 'SD'
		OR
		ReportingCategory = 'SE'
		OR
		ReportingCategory = 'SF'
		OR
		ReportingCategory = 'SH'
		OR
		ReportingCategory = 'SM'
		OR
		ReportingCategory = 'SS'
		OR
		ReportingCategory = 'TA'
		OR
		ReportingCategory = 'GX'
		
	;
quit;

proc logistic data=q3race;
    class CharterSchool (ref='YES') / param=reference;
    freq MetReq;
    model type(ref='RW')=ReportingCategory / link=glogit;
    output out=type_pred PREDPROBS=YES;
run;

footnote2 justify=left
'In the above table and plot it appears that Hispanic students are meeting the UC/CSU 
admissions requirements at a higher rate than their White peers in both the charter 
school and public school learing environment. We can also see that the odds of a White
student meeting the admissions requirments is lower at a charter school vs a public
school.'
;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 4 Analysis Starting Point;
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

footnote1 justify;
'This assumes that communities with a higher proportion of ELs/LEP students have 
the same access to educational (financial) resources as communities with fewer.' 
;

/*
Note: This compares the odds ratio of ELs/LEP students with the odds ratio of 
students of who are not ELs/LEP students through categorical analysis methods.

Limitations: Columns with a Cohort value of less than 30 were eliminated from
the dataset so that only regular public high schools and charter schools would
be counted and non schools, continuation schools, and independent study schools
would not be included to improve the accuracy of the analysis.
*/


proc report data = cde_analytic_file_raw;
    columns
        Met_UC_CSU_Grad_Req
        LC
        Total_EL
        ;
        define Met_UC_CSU_Grad_Req / group;
        define LC / group;
        ;
run;        

footnote1 justify;
'From this output further analysis can be to determine which student population
has the not only higher odds of meeting UC/CSU admission requirements, but also
by what magnitude does it deffer.' 
;

/* clear titles/footnotes */
title;
footnote;
