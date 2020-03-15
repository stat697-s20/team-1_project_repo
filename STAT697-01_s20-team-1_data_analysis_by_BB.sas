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
'Question 1 of 4: What are the odds of a male student graduating from high school compared to a female student.'
;

title2 justify=left
'Rationale: Having an understading of how the various factors effect each gender could help schools determine which type of learning environment best serves students in meeting the requirements to graduate from high school. This could also help understand any descrepencies in meeting admissions requirements for a UC or CSU.'
;

/*
Note: This utilizes the Regular_HS_Diploma_Graduates__Ra as the response and 
uses with the ReportingCategory indicator along with the indicator for 
Charter school or non Charter School.

Methodology: Use proc sql steps to create a new table from the master dataset
and deleting all inputs that are not useful for the focus of the analysis.
Finally, use a proc logistic and proc sgplot to generate a contingency table
displaying the odds of graduating from high school for each gender given that
they attend either a charter school or a public school as well as a 
visualizations to display the proportion of odds.

Followup Steps: More carefully clean data and or ensure that it isn't overly
filtered so that both genders are accounted for equally. Additionally, 
examining the data to determine a trend fluxuation among these populations
over a larger period of time.

Limitations: Columns with a Cohort value of less than 30 were eliminated from
the dataset so that only regular public high schools and charter schools would
be counted and non schools, continuation schools, and independent study schools
would not be included to improve the accuracy of the analysis.
*/

title3 justify=left
'Selecting variables of interest that may impact a student in meeting high school graduation requirements'
;

proc sql;
    create table q1gender as
    select 
        CharterSchool
       ,CohortStudents
       ,ReportingCategory
       ,HS_Grad_Co as MetReq 
       ,Total_EL
    from
        master
    where
        not(CharterSchool='All'
            )
        and
        not(
            ReportingCategory = 'RA'
            OR
            ReportingCategory = 'RH'
            OR
            ReportingCategory = 'RW'
            )
    ;
quit; 

footnote1 justify=left
'The above table focuses on students in the data set who are classified as either Gender Male (GM) or Gender Female (GF) as well as the rate at which they are able to meet high school graduation requirements. From the table, we can see that female and male students are fairly even in their ability to meet high school graduation requirements with female students performing slightly better than their male peers by less than 0.5% in public schools and 0.8% in charter schools. Of greater significance is that both genders are able to meet the requirements for high school graduation at a far better rate in the public school (Charter School = No) learning environment compared to the Charter School (Charter School = Yes) learning environment, as neither are meeting the requirement above a 5%. Further analysis can be used to determine what other factors are contributing to the drastic differences that affects both groups ability in meeting high school graduation equirements between public and charter school learning envirnonments.'
;

proc report data = q1gender;
 column
 	CharterSchool
	ReportingCategory
	MetReq
	CohortStudents	
	MetReq = pctMetReq
    ;	
	define CharterSchool / group "Charter School Indicator";
	define ReportingCategory / group "Student Reporting Category";
	define MetReq / group sum format=comma18.0 noprint  "Met Graduation Requirement" ;
	define CohortStudents / group sum format=comma18.0 noprint "Total Students in Cohort";	
	define pctMetReq / analysis across PCTSUM format =percent7.1 "% Met Requirement";
run;

 /* clear titles/footnotes */
title;
footnote;

footnote1 justify=left
'From the plot, we can see the significant difference for each group in meeting the high school graduation requirements in each learning environment.'
;

proc sgplot data=q1gender;	
	xaxis values=('GF' 'GM') valuesdisplay=('Female' 'Male');
	xaxis label= "Students Who Met High School Graduation Requirements";	
	yaxis label="School Type";	
	yaxis values = ('No' 'Yes') valuesdisplay=('Public School' 'Charter School');	
    hbar CharterSchool / response=MetReq datalabel      	
    	group=ReportingCategory
    	groupdisplay=Cluster
    	barwidth=.5
    	transparency=0.2;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 2 of 4: What are the odds of a male student meeting the admissions requirements for a UC/CSU compared to a female student.'
;

title2 justify=left
'Rationale: Having an understading of how the various factors effect each gender could help schools determine which type of learning environment best serves students.'
;

/*
Note: This utilizes the Met UC/CSU Grad Req' as the response and uses with the 
Reporting Category along with the factors for Charter school or non Charter
School (district, county, etc).

Methodology: Use proc sql steps to create a new table from the master dataset
and deleting all inputs that are not useful for the focus of the analysis.
Finally, use a proc logistic and proc sgplot to generate a contingency table
displaying the odds of meeting the admissions requirements for a UC/CSU for 
each gender given that they attend either a charter school or a public school
as well as a visualizations to display the proportion of odds.

Followup Steps: More carefully clean data and or ensure that it isn't overly
filtered so that both genders are accounted for equally. Additionally, 
examining the data to determine a trend fluxuation among these populations
over a larger period of time.

Limitations: This dataset does not include any information about the demographics
in the teacher populations that may effect the odds of a female student or male 
student meeting UC/CSU admissions requirements.
*/

title3 justify=left
'Plot showing the proportion of Reporting Categories meeting UC/CSU admissions requirements, with the primary focus being the differences between male and female students'
;

footnote1 justify=left
'The above table focuses on students in the data set who are classified as either Gender Male (GM) or Gender Female (GF) as well as the rate at which they are able to meet the UC/CSU admissions requirements. From the table, we can see that females are meeting the requirements at a higher rate than their male peers, with female students meeting the requirements at a rate of 51% compared to their male peers at 39.5%. Once again, both genders are able to meet the requirements for admission into a UC/CSU at a far better rate in the public school (Charter School = No) learning environment compared to the Charter School (Charter School = Yes) learning environment, with female students and male students meeting the requirements at a meer 5.3% and 4.2% rate respectively. Additionally, further analysis can be utilized to determine what other factors are contributing to the drastic differences that affects both groups ability in meeting UC/CSU admissions requirements between public and charter school learning environments.'
;

proc sql;
    create table q2gender as
    select 
        CharterSchool
       ,CohortStudents
       ,ReportingCategory
       ,Met_UC_CSU_Req_Co as MetReq      
    from
        master 
    where
        not(CharterSchool='All'
            )
        and
        not(
            ReportingCategory = 'RA'
            OR
            ReportingCategory = 'RH'
            OR
            ReportingCategory = 'RW'
            )
    ;
quit;

proc report data = q2gender;
 column
 	CharterSchool
	ReportingCategory
	MetReq
	CohortStudents	
	MetReq = pctMetReq
    ;	
    define CharterSchool / group "Charter School Indicator";
	define ReportingCategory / group "Student Reporting Category";
	define MetReq / group sum format=comma18.0 noprint  "Met UC/CSU Admissions Requirement" ;
	define CohortStudents / group sum format=comma18.0 noprint "Total Students in Cohort";	
	define pctMetReq / analysis across PCTSUM format =percent7.1 "% Met Requirement";
run;

 /* clear titles/footnotes */
title; 
footnote;

footnote3 justify=left
'In the above plot it appears that female students are meeting the UC/CSU admissions requirements at a higher rate than their male peers in both the charter school and public school learing environment.' 
;

/* Bar plot of MetReq for Gender Male vs Gender Female  */
proc sgplot data=q2gender;    
	xaxis values=('GF' 'GM') valuesdisplay=('Female' 'Male');
	xaxis label= "Students Who Met UC/CSU Admissions Requirements";	
	yaxis label="School Type" ;	
	yaxis values = ('No' 'Yes') valuesdisplay=('Public School' 'Charter School');	
    hbar CharterSchool / response=MetReq datalabel       	
    	group=ReportingCategory
    	groupdisplay=Cluster
    	barwidth=.5
    	transparency=0.2;    
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;

title1 justify=left
'Question 3 of 4: What are the odds that a Hispanic Student will meet admission requirements attending a charter school compared to a "White, not Hispanic" student?'
;

title2 justify=left
'Rationale: From the odds we can gain a better perspective on the success rates of an underserved/ underrepresented student populations compared to their "White, not Hispanic" peers.'
;

/*
Note: This compares the odds ratio of Met UC/CSU Grad Req' (Rate) of 'White, not 
Hispanic' with the odds ratio of Hispanic students through categorical analysis 
methods.

Methodology: Use proc sql steps to create a new table from the master dataset
and deleting all inputs that are not useful for the focus of the analysis.
Finally, use a proc logistic and proc sgplot to generate a contingency table
displaying the odds of meeting the admissions requirements for a UC/CSU for 
each ethnicity given that they attend either a charter school or a public school
as well as a visualizations to display the proportion of odds.

Followup Steps: More carefully clean data and or ensure that it isn't overly
filtered so that both ethnicities are accounted for equally. Additionally, 
examining the data to determine a trend fluxuation among these populations
over a larger period of time.

Limitations: This dataset does not include any information about the demographics
of this cities in which these schools are located as well or the differences in 
the teacher populations that may effect the odds of a Hispanic student or 'White,
non Hispanic' student meeting UC/CSU admissions requirements.
*/

proc sql;
    create table q3race as
    select 
        CharterSchool
       ,ReportingCategory
       ,CohortStudents
       ,Met_UC_CSU_Req_Co as MetReq       
    from
        master 
    where
        not(CharterSchool='All'
            )
        and
        not(
            ReportingCategory = 'RA'
            OR
            ReportingCategory = 'GM'
            OR
            ReportingCategory = 'GF'
            )
    ;
quit;

footnote2 justify=left
'Since English Learning Students (ELs/LEP) speaking Spanish make up the largest proportion of this student population as they represent 15% of ELs/LEP students, they were selected to investigate the rate at which this population was able to meet the UC/CSU admissions requirements. In the above table and plot it appears that Hispanic (RW) students have a higher odds of meeting the UC/CSU admissions requirements than their White (RW) peers in both the charter school and public school learing environment, with their greatest odds of meeting the requirements in a charter school. In the public school (Charter School = No) learning environment, we can see that Hispanic students are meeting the admissions requirements at about a 20% higher rate, and meeting those same requirements at about a 5% higher rate in the charter school (Charter School = Yes) learning environment. Once again we can also see that each student populations ability to meet the admissions requirments is significantly lower at a charter school vs a public school.'
;

proc report data = q3race;
 column
 	CharterSchool
	ReportingCategory
	MetReq
	CohortStudents	
	MetReq = pctMetReq
    ;	
	define CharterSchool / group "Charter School Indicator";
	define ReportingCategory / group "Student Reporting Category";
	define MetReq / group sum format=comma18.0 noprint "Met UC/CSU Admissions Requirements" ;
	define CohortStudents / group sum format=comma18.0 noprint "Total Students in Cohort";	
	define pctMetReq / analysis across PCTSUM format =percent7.1 "% Met Requirement";    
run;

 /* clear titles/footnotes */
title; 
footnote;

footnote3 justify=left
'In the above plot it appears that Hispanic (RH) students are meeting the UC/CSU admissions requirements at a higher rate than their White (RW) peers in both the charter school and public school learing environment.' 
;

proc sgplot data=q3race;	
	xaxis values=('RH' 'RW') valuesdisplay=('Hispanic' 'White');
	xaxis label= "Students Who Met UC/CSU Admissions Requirements";	
	yaxis label="School Type" ;	
	yaxis values = ('No' 'Yes') valuesdisplay=('Public School' 'Charter School');	
    hbar CharterSchool / response=MetReq datalabel       	
    	group=ReportingCategory
    	groupdisplay=Cluster
    	barwidth=.5
    	transparency=0.2;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 4 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
'Question 4 of 4: What are the odds that a Hispanic Student will meet high school graduation requirements attending a charter school compared to a "White, not Hispanic" student?'
;

title2 justify=left
'Rationale: Rationale: From the odds we can gain a better perspective on the success rates of an underserved/ underrepresented student populations compared to their "White, not Hispanic" peers.'
;

footnote1 justify=left
'This assumes that communities with a higher proportion of ELs/LEP students have the same access to educational (financial) resources as communities with fewer.'
;

/*
Note: This compares the odds ratio of ELs/LEP students with the odds ratio of 
students of who are not ELs/LEP students through categorical analysis methods.

Methodology: Use proc sql steps to create a new table from the master dataset
and deleting all inputs that are not useful for the focus of the analysis.
Finally, use a proc logistic and proc sgplot to generate a contingency table
displaying the odds of high school graduation requirements for each ethnicity 
given that they attend either a charter school or a public school as well as 
a visualizations to display the proportion of odds.

Followup Steps: More carefully clean data and or ensure that it isn't overly
filtered so that both ethnicities are accounted for equally. Additionally, 
checking to see if proper sorting occured and try to further explain the
unexpected shift.

Limitations: Columns with a Cohort value of less than 30 were eliminated from
the dataset so that only regular public high schools and charter schools would
be counted and non schools, continuation schools, and independent study schools
would not be included to improve the accuracy of the analysis.
*/

proc sql;
	create table q4race as
		select 
        	CharterSchool 
       	   ,ReportingCategory
       	   ,CohortStudents
       	   ,HS_Grad_Co as MetReq           
		from
        	master 
        where
        not(CharterSchool='All'
            )
        and
        not(
            ReportingCategory = 'RA'
            OR
            ReportingCategory = 'GM'
            OR
            ReportingCategory = 'GF'
            )
    ;
quit;

footnote2 justify=left
'Since English Learning Students (ELs/LEP) speaking Spanish make up the largest proportion of this student population as they represent 15% of ELs/LEP students, they were selected to investigate the rate at which this population was able to meet high school graduation requirements. In the table it appears that Hispanic (RW) students have a higher odds of meeting high school graduation requirements than their White (RW) peers in both the charter school and public school learning environment, with their greatest odds of meeting the requirements in a charter school. In the public school (Charter School = No) learning environment, we can see that Hispanic students are meeting the admissions requirements at about a 30% higher rate, and meeting those same requirements at about a 3% higher rate in the charter school (Charter School = Yes) learning environment. The gap between each group in the public school learning environment is much greater than that seen for meeting UC/CSU admissions requirements. Once again we can also see that each student populations ability to meet the high school graduation requirements is significantly lower at a charter school vs a public school.'
;

proc report data = q4race;
 column
 	CharterSchool
	ReportingCategory
	MetReq
	CohortStudents	
	MetReq = pctMetReq
    ;	
	define CharterSchool / group "Charter School Indicator";
	define ReportingCategory / group "Student Reporting Category";
	define MetReq / group sum format=comma18.0 noprint "Met Graduation Requirement" ;
	define CohortStudents / group sum format=comma18.0 noprint "Total Students in Cohort";	
	define pctMetReq / analysis across PCTSUM format =percent7.1 "% Met Requirement";    
run;

 /* clear titles/footnotes */
title; 
footnote;

footnote3 justify=left
'In the graph it appears that Hispanic (RH) students are meeting the UC/CSU admissions requirements at a higher rate than their White (RW) peers in both the charter school and public school learing environment, with a more significant difference in public schools.' 
;

proc sgplot data=q4race;	
	xaxis values=('RH' 'RW') valuesdisplay=('Hispanic' 'White');
	xaxis label= "Students Who Met High School Graduation Requirements";	
	yaxis label="School Type" ;	
	yaxis values = ('No' 'Yes') valuesdisplay=('Public School' 'Charter School');	
    hbar CharterSchool / response=MetReq datalabel      	
    	group=ReportingCategory
    	groupdisplay=Cluster
    	barwidth=.5
    	transparency=0.2;
run;

/* clear titles/footnotes */
title;
footnote;


