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
    create table q1_gender as
    select 
        CharterSchool
       ,CohortStudents
       ,ReportingCategory
       ,HS_Grad_Co as MetReq 
       ,Total_EL
    from
        master     
    ;
quit; 

proc sql;
	create table q1gender
		like q1_gender;
	select * from q1gender;
	insert into q1gender
		select * from q1_gender;
	delete from q1gender
		where CharterSchool='All';
	delete from 
		q1gender
	where 
		ReportingCategory = 'RA'
		OR
		ReportingCategory = 'RH'
		OR
		ReportingCategory = 'RW'		
	;
quit;


proc report data = q1gender;
 column
 	CharterSchool
	ReportingCategory
	MetReq
	CohortStudents	
	MetReq = pctMetReq
 ;	
	define CharterSchool / group;
	define ReportingCategory / group;
	define MetReq / group sum  "MetReq";
	define CohortStudents / group sum "CohortStudents";	
	define pctMetReq / analysis across PCTSUM format =percent7.1;
run;

footnote1 justify=left
'This proc sql and proc report will generate a table that will only contain information about students who are classified as either Gender Male (GM) or Gender Female (GF) as well as the rate ate which they are able to meet high school graduation requirments.'
;

footnote2 justify=left
'In the both the table and plot it appears that female students are meeting high school graduation requirments at about the same or slightly higher rate than their male peers in both the charter school and public school learing environment. This also shows that neither groups perform as well in a charter school setting as they do in a public school.'
;

footnote3 justify=left
'From this output further analysis can be used to determine which other factors contribute to the drastic differences that affects both groups ability in meeting high school graduation equirements.'
;

proc sgplot data=q1gender;
	yaxis label="Odds of HS Graduation" ;
    vbar ReportingCategory / response=MetReq 
    	group=CharterSchool
    	groupdisplay=Cluster
    	barwidth=.5
    	transparency=0.2;
run;
title;

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
'From this histogram, we can see that the odds of a male or a female student meeting the UC/CSU requirements is roughly equivalent at either a Charter School or Public School, with male students having a slightly higher odds of meeting the requirements at a charter school and female students having a slightly higher odds of meeting the requirements at a public school'
;

footnote2 justify=left
'From this, we can say that the learning environment of a charter school vs a public school has minimal effect on a students ability to meet UC/CSU admissions requirements.'
;

proc sql;
    create table q2_gender as
    select 
        CharterSchool
       ,ReportingCategory
       ,Met_UC_CSU_Req_Co       
    from
        master 
    ;
quit;

proc sql;
	create table q2gender
		like q2_gender;
	select * from q2gender;
	insert into q2gender
		select * from q2_gender;
	delete from q2gender
		where CharterSchool='All';
	delete from 
		q2gender
	where 
		ReportingCategory = 'RA'
		OR
		ReportingCategory = 'RH'		
		OR
		ReportingCategory = 'RW'		
	;
quit;

footnote3 justify=left
'In the above plot it appears that female students are meeting the UC/CSU admissions requirements at a higher rate than their male peers in both the charter school and public school learing environment. This was an expected trend since it followed the odds for this same population meeting high school graduation requirements.'
;

/* Bar plot of MetReq for Gender Male vs Gender Female  */
proc sgplot data=q2gender;
	yaxis label="Met UC/CSU Req" ;
    vbar ReportingCategory / response=Met_UC_CSU_Req_Co
        group=CharterSchool
        groupdisplay=Cluster
    	barwidth=0.5
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


title2 justify=left
'Proc freq analysis to determine the odd that a Hispanic Student will meet admission requirements attending a charter school compared to a "White, not Hispanic" student.'
;

footnote1 justify=left
'Spanish ELs/LEP students make up the largest portion of this student population as they represent 15% of ELs/LEP students'
;

proc sql;
    create table q3_race as
    select 
        CharterSchool
       ,ReportingCategory
       ,CohortStudents
       ,Met_UC_CSU_Req_Co as MetReq       
    from
        master 
    ;
quit;

proc sql;
	create table q3race
		like q3_race;
	select * from q3race;
	insert into q3race
		select * from q3_race;
	delete from q3race
		where CharterSchool='All';	
	delete from 
		q3race
	where 
		ReportingCategory = 'RA'		
		OR
		ReportingCategory = 'GM'		
        OR		
		ReportingCategory = 'GF'		
	;
quit;

footnote2 justify=left
'In the above table and plot it appears that Hispanic students have at least a slightly higher odds of meeting the UC/CSU admissions requirements than their White peers in both the charter school and public school learing environment, with their greates odd of meeting the requirements in a charter school. We can also see that the odds of a White student meeting the admissions requirments is lower at a charter school vs a public school.'
;

proc sgplot data=q3race;
	yaxis label="Met UC/CSU Req" ;
    vbar ReportingCategory / response=MetReq
        group=CharterSchool
        groupdisplay=Cluster
    	barwidth=0.5
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
	create table q4_race as
		select 
        	CharterSchool 
       	   ,ReportingCategory
       	   ,CohortStudents
       	   ,HS_Grad_Co as MetReq 
           
		from
        	master 
    ;
quit;

proc sql;
	create table q4race
		like q4_race;
	select * from q4race;
	insert into q4race
		select * from q4_race;
	delete from q4race
		where CharterSchool='All';	
	delete from 
		q4race
	where 
		ReportingCategory = 'RA'
		OR
		ReportingCategory = 'GM'
		OR
		ReportingCategory = 'GF'		
	;
quit;

footnote2 justify=left
'In the above table and plot it appears that the odds of either student population meeting high school graduation requirments has shifted lower from the odds of them meeting admissions requirements for UC/CSU admissions, which was unexpected.'
;

proc freq data=q4race ;
    weight MetReq;
    tables CharterSchool*ReportingCategory /plots=freqplot ; *cmh chisq all measures riskdiff;
run;

/* clear titles/footnotes */
title;
footnote;
