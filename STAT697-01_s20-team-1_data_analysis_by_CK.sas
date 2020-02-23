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
Question 1 of 3: Does Charter School and non-Charter School have an effect on 
meeting the UC/CSU admission requirement?

Rationale: According to the Education Commission of the States, "charter schools
are semi-autonomous public schools that receive public funds. They operate under 
a written contract with a state, district or other entity (referred to as an 
authorizer or sponsor). This contract – or charter – details how the school will 
be organized and managed, what students will be expected to achieve, and how 
success will be measured. Many charters are exempt from a variety of laws and 
regulations affecting other public schools if they continue to meet the terms 
of their charters.". Meaning that the course content Charter School may have 
differences compared to the non-Charter one's. Will it affect the fairness of 
entering State-Funded Universities after graduating from Charter School and 
non-Charter Schools?

Note: This compares the column CharterSchool with Met UC/CSU Grad Req' (Count). 
We can use paired test to compare the differences between Charter School 
and non-Charter School.

Limitations: For data rows with an asterisk (indicating the number of entry is 
less than 10 to protect the students) should be excluded since it doesn't show
any true values. Also, we should compare the number of count instead of rate 
since when we calculate the number of students from the rate, it will show 
decimals which is impossible for number of counts.
*/


proc sql
    select
        CharterSchool
        , Met_UC/CSU_Grad_Reqs_(Count)
        , CohortStudents
    from
        cde_analytic_file_raw
    where
        CharterSchool = YES
        CohortStudents > 30
    order by
        Met_UC/CSU_Grad_Reqs_(Count) desc
quit;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Will schools with more students with bilaterally helps the 
graduation rate in high school?

Rationale: More students speaking language in addition to English might raise 
the awareness of the teachers and school to provide better support in English 
learning, or on the other hand they can get more peer support in the learning 
environment?

Note: This compares the column ReportingCategory, Seal of Biliteracy (Count) 
with the Regular HS Diploma Graduates (Count). We can use categorical data
analysis methods to determine this.

Limitations: For data rows with an asterisk (indicating the number of entry is 
less than 10 to protect the students) should be excluded since it doesn't show
any true values. Also, we should compare the number of count instead of rate 
since when we calculate the number of students from the rate, it will show 
decimals which is impossible for number of counts. 
*/


proc sql
        select
            ReportingCategory
            , CohortStudents
            , Seal_of_Biliteracy_(Count)
            , Regular_HS_Diploma_Graduates_(Count)
        from
            cde_analytic_file_raw
        where
            CohortStudents > 30
            ReportingCategory ^= Not_Reported
        having
            Seal_of_Biliteracy_(Count) > 30

quit;
        

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Will students with first language other than English affect 
the graduation rate in high school?

Rationale: This would help identify if further need on English language 
preparation for younger students is required. As they may need extra resources 
to absorb knowledge that are taught by English.

Note: In data set 3, elsch19 there is a column "LANGUAGE" which can be relate 
to the column "ReportingCategory" where the "ReportingCategory" in dataset 
acgr19 & acgr18 are the reported race/ethnicity and gender. We can use 
categorical data analysis methods to determine this.

Limitations: For data with column "LANGUAGE" marked as Other non-English 
languages (Column LC = 99) should be excluded since it doesn't show which type
of languages they use and can not relate to the column "ReportingCategory". We
also exclude the data with "Not Reported" in the column "ReportingCategory" as 
it doesn't have any value for analysis.
*/


proc sql
    create table language_table as
        (
            select  
            LC
            , LANGUAGE
            , KDGN
            , GR_1
            , GR_2
            , GR_3
            , GR_4
            , GR_5
            , GR_6
            , GR_7
            , GR_8
            , GR_9
            , GR_10
            , GR_11
            , GR_12
            , UNGR
            , TOTAL_EL
            from
                cde_analytic_file_raw
            where
                LC ^= 99
                CohortStudets > 30
                ReportingCategory ^= Not_Reported
            having
                TOTAL_EL > 10
quit;