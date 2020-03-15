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

Methodology: We sort the ranking of Meeting UC/CSU Grad requirement to see the 
trend of number of students met the requirement to enter colleges with respect 
to Charter School or not.

Followup Steps: Afterwards we can try to see if if the "Reporting Category"
also is a factor affecting the percentage of meeting UC/CSU Grad requirement.
*/


proc sort
    data=master
    out=CharterGradRate
    ;
    by
        descending HS_Grad_Co
        ;
    where
        not(missing(HS_Grad_Co))
        and
        not(missing(Seal_of_Biliteracy_Co))
        and
        CharterSchool in ('Yes', 'No')
		;
run;

proc report data=CharterGradRate
			out=CharterGradRateReport;
	column CharterSchool CohortStudents HS_Grad_Co Met_UC_CSU_Req_Co HS_Grad_Rate Met_UC_CSU_Req_Rate;
	define CharterSchool / group;
	define CohortStudents / sum noprint;
	define HS_Grad_Co / sum noprint;
	define Met_UC_CSU_Req_Co / sum noprint;
	define HS_Grad_Rate / computed format=percent8. 'High School Graduation Rate';
	define Met_UC_CSU_Req_Rate / computed format=percent8. 'Met UC/CSU Entry Requirement Rate';
	
	compute HS_Grad_Rate;
		HS_Grad_Rate=HS_Grad_Co.sum/CohortStudents.sum;
	endcomp;
	
	compute Met_UC_CSU_Req_Rate;
		Met_UC_CSU_Req_Rate=Met_UC_CSU_Req_Co.sum/CohortStudents.sum;
	endcomp;
run;

title "Charter School and non-Charter School student's performance on meeting UC/CSU Entry Requirement";
proc sgplot data=CharterGradRateReport;
	hbar CharterSchool / response=Met_UC_CSU_Req_Rate
	datalabel
	barwidth=0.3 
    baselineattrs=(thickness=0)
	discreteoffset=0;
	xaxis label='Rate';
	yaxis label='Types of School (Charter/Non-Charter)';
run;

/*
title "Charter School and non-Charter School student's performance on High School Graduation Rate";
proc sgplot data=CharterGradRateReport;
	hbar CharterSchool / response=HS_Grad_Rate
	datalabel
	barwidth=0.3
    baselineattrs=(thickness=0)
	discreteoffset=0;
	xaxis label='Rate';
	yaxis label='Types of School (Charter/Non-Charter)';
run;*/

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
rate. Then we use barchart to see the rate of Diploma Graduates across the three races with biliteracy, White, Hispanic and Asian.

Followup Steps: We should see the entries that without a numerical value as it 
doesn't contains a figure of the reporting category. We should filter it for 
more accurate result. Also, we can try to see if there are correlation between the number of high school graduates and the biliteracy rate.
*/


proc sort
    data=master
    out=Biliteracy_analysis 
    ;
    by
        descending Seal_of_Biliteracy_Co
        ;
    where
		not(missing(Seal_of_Biliteracy_Co))
        and
        not(missing(ReportingCategory))
        and
        ReportingCategory in ('RA','RH','RW')
    ;
run;

proc report data=Biliteracy_analysis 
			out=Biliteracy_out;
	column ReportingCategory CohortStudents Seal_of_Biliteracy_Co Seal_of_Biliteracy_Ra HS_Grad_Co HS_Grad_Ra;
	define ReportingCategory / group 'Ethicity';
	define CohortStudents / sum noprint;
	define Seal_of_Biliteracy_Co / sum noprint;
	define HS_Grad_Co / sum noprint;
	define Seal_of_Biliteracy_Ra / computed format=percent8. 'Biliteracy Rate';
	define HS_Grad_Ra / computed format=percent8. 'High School Graduation Rate';
	
	
	compute Seal_of_Biliteracy_Ra;
		Seal_of_Biliteracy_Ra=Seal_of_Biliteracy_Co.sum/CohortStudents.sum;
	endcomp;
	
	compute HS_Grad_Ra;
		HS_Grad_Ra=HS_Grad_Co.sum/CohortStudents.sum;
	endcomp;
run;

proc corr data=Biliteracy_analysis noprob nosimple PEARSON SPEARMAN;
	var 
	Seal_of_Biliteracy_Co
	HS_Grad_Co
	;
	title 'Pearson and Spearman Correlation between Biliteracy and High School Graduation Student Count';
run;

/*title "Student's Seal of Biliteracy Rate and Graduation Rate";
proc sgplot data=Biliteracy_out;
	hbar ReportingCategory / response=Seal_of_Biliteracy_Ra
	datalabel
	legendlabel='Seal of Biliteracy Rate'
	barwidth=0.3 
    baselineattrs=(thickness=0)
	discreteoffset=-0.15;
	hbar ReportingCategory / response=HS_Grad_Ra
	datalabel
	legendlabel='High School Graduation Rate'
	categoryorder=respasc
	barwidth=0.3 
    baselineattrs=(thickness=0)
	discreteoffset=0.15;
	xaxis label='Rate';
	yaxis label='Ethicity';
run;*/


/* clear titles and footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
'Question 3 of 3: Will students with first language other than English reduce as they spend more time in school?'
;

title2 justify=left
'Rationale: This would help identify if further need on English language preparation for younger students is required. As they will considered as English Learners and may need extra help on studies'
;

footnote1 justify=left
"In here we are just consider the top 10 languages that California School English Learner Speaks"
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

Methodology: Using proc sgplot to plot the distribution of total number of 
english learner according to their "reporting category". Then we use proc corr 
to see the correlation between Asian and Hispanic graduation counts. Here we 
exclude White because we assume the first language of students with ethicity 
White is English.

Followup Steps: There is a possible way to see if there are differences in
comparing difference language users, their graduation rate and those kids
with first language in English by setting up the ANOVA between average rate
of different first language students in different counties.
*/


proc sql noprint;
	create table noprintEnglish_Learner_Out as
	select 
		LANGUAGE,sum(KDGN) as KDGN, sum(GR_1) as GR_1, sum(GR_2) as GR_2, sum(GR_3) as GR_3, sum(GR_4) as GR_4, sum(GR_5) as GR_5, sum(GR_6) as GR_6, sum(GR_6) as GR_6, sum(GR_7) as GR_7, sum(GR_8) as GR_8, sum(GR_9) as GR_9, sum(GR_10) as GR_10, sum(GR_11) as GR_11, sum(GR_12) as GR_12, sum(UNGR) as UNGR, sum(TOTAL_EL) as TOTAL_EL 
	from 
		master
	where
		not(missing(TOTAL_EL))
	group by
		LANGUAGE
	order by
		TOTAL_EL desc
    ;
run;

title 'Top 10 Number of English Learner of students having first language other than English by School Grade';
proc report data=English_Learner_Out(obs=10);
	column LANGUAGE KDGN GR_1 GR_2 GR_3 GR_4 GR_5 GR_6 GR_7 GR_8 GR_9 GR_10 GR_11 GR_12 UNGR TOTAL_EL;
	define LANGUAGE / 'Language';
	define KDGN / 'Kindergarten';
	define GR_1 / 'Grade 1';
	define GR_2 / 'Grade 2';
	define GR_3 /'Grade 3';
	define GR_4 / 'Grade 4';
	define GR_5 / 'Grade 5';
	define GR_6 /'Grade 6';
	define GR_7 / 'Grade 7';
	define GR_8 / 'Grade 8';
	define GR_9 / 'Grade 9';
	define GR_10 / 'Grade 10';
	define GR_11 / 'Grade 11';
	define GR_12 / 'Grade 12';
	define UNGR / 'Undergraduate';
	define TOTAL_EL / 'Total Number';
run;

proc sql noprint outobs=10;
	create table English_Learner_Out1 as
	select 
		LANGUAGE,sum(KDGN) as KDGN, sum(GR_1) as GR_1, sum(GR_2) as GR_2, sum(GR_3) as GR_3, sum(GR_4) as GR_4, sum(GR_5) as GR_5, sum(GR_6) as GR_6, sum(GR_7) as GR_7, sum(GR_8) as GR_8, sum(GR_9) as GR_9, sum(GR_10) as GR_10, sum(GR_11) as GR_11, sum(GR_12) as GR_12, sum(UNGR) as UNGR, sum(TOTAL_EL) as TOTAL_EL 
	from 
		master
	where
		not(missing(TOTAL_EL))
	group by
		LANGUAGE
	order by
		TOTAL_EL desc
    ;
run;

proc sgplot data=English_Learner_Out1;
	hbar LANGUAGE/response=TOTAL_EL
	datalabel
	legendlabel='High School Graduation Rate'
	categoryorder=respasc
	barwidth=0.3 
    baselineattrs=(thickness=0)
	discreteoffset=0.15;
	xaxis label='Count';
	yaxis label='Language';
run;

proc sql outobs=3;
	create table English_Learner_Out2 as
	select 
		*
	from
		English_Learner_Out1
	order by
		TOTAL_EL desc
    ;
run;

title "Student Count in High School that are English Learners (Top 3 Number of Language User)";
proc sgplot data=English_Learner_Out2;
	vbar LANGUAGE / response=GR_6
	datalabel
	legendlabel='Grade 6'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=-0.3;
	vbar LANGUAGE / response=GR_7
	datalabel
	legendlabel='Grade 7'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=-0.2;
	vbar LANGUAGE / response=GR_8
	datalabel
	legendlabel='Grade 8'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=-0.1;
	vbar LANGUAGE / response=GR_9
	datalabel
	legendlabel='Grade 9'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=0;
	vbar LANGUAGE / response=GR_10
	datalabel
	legendlabel='Grade 10'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=0.1;
	vbar LANGUAGE / response=GR_11
	datalabel
	legendlabel='Grade 11'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=0.2;
	vbar LANGUAGE / response=GR_12
	datalabel
	legendlabel='Grade 12'
	barwidth=0.1 
    baselineattrs=(thickness=0)
	discreteoffset=0.3;
	yaxis label = 'Studnet Count';
	xaxis label = 'Language';
run;	
		

/* clear titles and footnotes */
title;
footnote;
