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
'Question 1 of 3: Does Charter School and non-Charter School have an effect on meeting the UC/CSU admission requirement?'
;

title2 justify=left
'Rationale: Many charters are exempt from variety of laws and regulations affecting other public schools if they continue to meet the terms of their charters.".'
;
title3 justify=left
'Meaning that the course content Charter School may have differences compared to the non-Charter ones. Will it affect the fairness of entering State-Funded Universities after graduating from Charter School and non-Charter Schools?'
;

footnote1 justify=left
"According to the Education Commission of the States, Charter schools are semi-autonomous public schools that receive public funds. They operate under a written contract with a state, district or other entity (referred to as an authorizer or sponsor)."
;

footnote2 justify=left
"This contract – or charter, details how the school will be organized and managed, what students will be expected to achieve, and how success will be measured."
;

/*
Note: This compares the column CharterSchool with Met UC/CSU Grad Req (Count). 
We can use paired test to compare the differences between Charter School and 
non-Charter School.

Limitations: For data rows with an asterisk (indicating the number of entry is 
less than 10 to protect the students) should be excluded since it doesn't 
showany true values. Also, we should compare the number of count instead of 
rate since when we calculate the number of students from the rate, it will show 
decimals which is impossible for number of counts.

Methodology: 

Followup Steps:

*/


proc sort
    data=cde_analytic_file
    out=cde_analytic_file_by_UC_CSU_grad
    ;
    by
        descending Met_UC_CSU_Grad_Req
    ;
    where
        CharterSchool = YES
        and
        CohortStudents > 30
    ;
run;

proc report data=cde_analytic_file_by_UC_CSU_grad
    columns
        CharterSchool
        CohortStudents
        Met_UC_CSU_Grad_Req
    ;
run;

/* clear titles and footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
'Question 2 of 3: Will schools with more students with bilaterally helps the graduation rate in high school?'
;

title2 justify=left
'Rationale: More students speaking language in addition to English might raise the awareness of the teachers and school to provide better support in English learning, or on the other hand they can get more peer support in the learning environment?'
;

footnote1 justify=left
"In here we are making a hypothesis if schools having more students that English is not their first language will be able to provide more support to student. But that is not necessary the case of some school in some counties."
;

/*
Note: This compares the column ReportingCategory, Seal of Biliteracy (Count) 
with the Regular HS Diploma Graduates (Count). We can use categorical data
analysis methods to determine this.

Limitations: For data rows with an asterisk (indicating the number of entry is 
less than 10 to protect the students) should be excluded since it doesn't show
any true values. Also, we should compare the number of count instead of rate 
since when we calculate the number of students from the rate, it will show 
decimals which is impossible for number of counts.

Methodology: We can use porc sort to find which ethnicity has the most number
of Biliteracy Rate to see how the ethnicity and language affects the graduate
rate.

Followup Steps: We should see the entries that without a numerical value as it 
doesn't contains a figure of the reporting category. We should filter it for 
more accurate result.

*/


proc sort
    data=cde_analytic_file
    out=cde_analytic_file_by_Biliteracy
    ;
    by
        descending Biliteracy_Rate
        ReportingCategory
    where
        Biliteracy_Rate > 10
        HS_Graduates > 10
    ;
run;

/* clear titles and footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
'Question 3 of 3: Will students with first language other than English affect the graduation rate in high school?'
;

title2 justify=left
'Rationale: This would help identify if further need on English language preparation for younger students is required. As they may need extra resources to absorb knowledge that are taught by English.'
;

footnote1 justify=left
"In here we are just consider the learning ability of the student based the use of language only"
;

/*
Note: In data set 3, elsch19 there is a column "LANGUAGE" which can be relate 
to the column "ReportingCategory" where the "ReportingCategory" in dataset 
acgr19 & acgr18 are the reported race/ethnicity and gender. We can use 
categorical data analysis methods to determine this.

Limitations: For data with column LANGUAGE marked as Other non-English 
languages (Column LC = 99) should be excluded since it doesn't show which type 
of languages they use and can not relate to the column ReportingCategory. We 
also exclude the data with Not Reported in the column ReportingCategory as it 
doesn't have any value for analysis.

Methodology: 

Followup Steps:

*/


proc sgplot data=cde_analytic_file
    histogram Total_EL Language
run;

/* clear titles and footnotes */
title;
footnote;
