*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* 
[Dataset 1 Name] acgr19

[Dataset Description] Adjusted Cohort Graduation Rate and Outcome Data,
AY2018-19

[Experimental Unit Description] California public K-12 schools in AY2018-19

[Number of Observations] 198,022

[Number of Features] 6

[Data Source] The file ftp://ftp.cde.ca.gov/demo/acgr/cohort1819.txt was
downloaded and edited to produce file cohort1819_edited.xlsx by opening in
Excel. Certain columns has been deleted to reduce file size. We only kept the
columns: CharterSchool, ReportingCategory, CohortStudents, Regular HS
Diploma Graduates (Rate), Met UC/CSU Grad Req's (Rate) and Seal of 
Biliteracy (Rate).

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp

[Unique ID Schema] The column "ReportingCategory" in this data set is unique as
it reflects the columns of ethnicities in data set "filesgradaf.xlsx" and 
column "Language" in data set "fileselsch.xlsx".
*/
%let inputDataset1DSN = cohort1819_edited;
%let inputDataset1URL =
https://github.com/stat697/team-1_project_repo/blob/master/data/cohort1819_edited.xlsx
;
%let inputDataset1Type = XLSX;


/*
[Dataset 2 Name] acgr18

[Dataset Description] Adjusted Cohort Graduation Rate and Outcome Data,
AY2017-18

[Experimental Unit Description] California public K-12 schools in AY2017-18

[Number of Observations] 202,115

[Number of Features] 6

[Data Source] The file ftp://ftp.cde.ca.gov/demo/acgr/cohort1718.txt was
downloaded and edited to produce file cohort1718_edited.xls by opening in Excel
and setting all cell values to "Text" format.
Certain columns has been deleted to reduce file size. We only kept the
columns: CharterSchool, ReportingCategory, CohortStudents, Regular HS
Diploma Graduates (Rate), Met UC/CSU Grad Req's (Rate) and Seal of 
Biliteracy (Rate).

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp

[Unique ID Schema] The column "ReportingCategory" in this data set is unique as
it reflects the columns of ethnicities in data set "filesgradaf.xlsx" and 
column "Language" in data set "fileselsch.xlsx".
*/
%let inputDataset2DSN = cohort1718_edited;
%let inputDataset2URL =
https://github.com/stat697/team-1_project_repo/blob/master/data/cohort1718_edited.xlsx
;
%let inputDataset2Type = XLSX;


/*
[Dataset 3 Name] elsch19

[Dataset Description] English Learners by Grade & Language, AY2018-19

[Experimental Unit Description] English Learns (Els), formerly
limited-English-proficient (LEP) students, by grade, language and school,
AY2018-19

[Number of Observations] 62,911

[Number of Features] 21

[Data Source] The file 
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=EL&cPage=fileselsch 
was downloaded and edited to produce file fileselsch.xlsx by opening in Excel, 
and setting all cell values to "Text" format.

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fselsch.asp

[Unique ID Schema] The column CDS is a unique id.
*/
%let inputDataset3DSN = fileselsch;
%let inputDataset3URL =
https://github.com/stat697/team-1_project_repo/blob/master/data/fileselsch.xlsx
;
%let inputDataset3Type = XLSX;


/*
[Dataset 4 Name] Graduates Meeting UC/CSU Entrance Requirements

[Dataset Description] filesgradaf (Graduates meeting University of California/California State
University (UC/CSU) entrance requirements)

[Experimental Unit Description] California K-12 School Data 2017

[Number of Observations] 2,535

[Number of Features] 15

[Data Source] The file https://www.cde.ca.gov/ds/sd/sd/filesgradaf.asp
was downloaded and edited to produce file filesgradaf.xlsx by opening in Excel
and setting all cell values to "Text" format.

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The CDS_CODE in this dataset can be used as the primary key
for this dataset as each entry has its own unique identification number.
*/
%let inputDataset4DSN = filesgradaf;
%let inputDataset4URL =
https://github.com/stat697/team-1_project_repo/blob/master/data/filesgradaf.xlsx
;
%let inputDataset4Type = XLSX;


/* load raw datasets over the wire, if they doesn't already exist */
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 4;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets

/* The original data set will be uploaded later during week 3 to compare with
the modified data. The filename will be xxxxxx-original.xlsx */


/* In PROC SQL, for dataset 1 - dataset 4, we remove the rows with number of
students less than 30 because it affects the result of analyzing the effect
of education. Also we will remove the rows with "*" as it indicates data less
then 10. According to the cde.ca.gov, Data are suppressed (*) on the data file
if the cell size within a selected student population (cohort students) is 10
or less. Additionally, the "Not Reported" race/ethnicity is suppressed, 
regardless of actual cell size, if the student population for one or more other
race/ethnicity groups is suppressed. */


/* check dataset1 */


/* check cohort1819_edited to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1819_edited_dup1 as
        select
             CharterSchool
             ,DASS
             ,ReportingCategory
             ,CohortStudents
             ,Regular_HS_Diploma_Graduates_(Count)
             ,Met_UC/CSU_Grad_Reqs_(Count)
             ,Seal_of_Biliteracy_(Count)
        from
            cohort1819_edited
        where
            not(missing(CohortStudents))
        group by
             CharterSchool
        having
            CohortStudents >= 30
    ;
    /* combining the reporting category together */
    create table cohort1819 as
        select
            CharterSchool
            ,ReportingCategory
            ,sum(CohortStudents)
            ,sum(Regular_HS_Diploma_Graduates_(Count))
            ,sum(Met_UC/CSU_Grad_Reqs_(Count))
            ,sum(Seal_of_Biliteracy_(Count))
        from
            cohort1819_edited_dup1
        group by 
            CharterSchool, ReportingCategory
        order by
            ReportingCategory    
    ;
quit;


/* check dataset2 */


/* check cohort1718_edited to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1718_edited_dup1 as
        select
             CharterSchool
             ,DASS
             ,ReportingCategory
             ,CohortStudents
             ,Regular_HS_Diploma_Graduates_(Count)
             ,Met_UC/CSU_Grad_Reqs_(Count)
             ,Seal_of_Biliteracy_(Count)
        from
            cohort1819_edited
        where
            not(missing(CohortStudents))
        group by
             CharterSchool
        having
            CohortStudents >= 30

    /* combining the reporting category together */
    create table cohort1718 as
        select
            CharterSchool
            ,ReportingCategory
            ,sum(CohortStudents)
            ,sum(Regular_HS_Diploma_Graduates_(Count))
            ,sum(Met_UC/CSU_Grad_Reqs_(Count))
            ,sum(Seal_of_Biliteracy_(Count))
        from
            cohort1819_edited_dup1
        group by 
            CharterSchool, ReportingCategory
        order by
            ReportingCategory    
    ;
quit;

/* check dataset 3 */

/*data - integrity checks for fileselch */
proc sql;
    /* check for unique id values that are repeated, missing, or correspond to
       non-schools */
create table fileselch_bad_unique_ids as
    select
        A.*
    from 
        fileselch as A
        left join
        (
            select
                CDS
                ,count(*) as row_count_for_unique_id_value
            from
                    fileselch
                group by
                    CDS
            ) as B
            on A.CDS=B.CDS
        having
            /* capture rows corresponding to repeated primary key values */
            row_count_for_unique_id_value > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(CDS)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(cat(CDS),8,7) in ("0000000","0000001")
    ;
    /* remove rows with primary keys that do not correspond to */
    create table fileselch_new as
        select
            *
        from
            fileselch
        where
            /* remove rows for District Offices and non-public schools */
            substr(cat(CDS),8,7) not in ("0000000","0000001")
    ;
quit;

proc sql;
create table fileselch_final as
    select
        A.*
    from 
        fileselch as A
        left join
        (
            select
                CDS
                ,count(*) as row_count_for_unique_id_value
            from
                    fileselch
                group by
                    CDS
            ) as B
            on A.CDS=B.CDS
        having
            /* capture rows corresponding to nonrepeated primary key values */
            row_count_for_unique_id_value = 1
            or
            /* capture rows corresponding to nonmissing primary key values */
            not missing(CDS)
            or
            /* capture rows tha don't correspond to non-school primary key values */
            substr(cat(CDS),8,7) not in ("0000000","0000001")
    ;
quit;


/* data - inspection of fileselch*/
title "Inspect LANGUAGE in fileselsch - Most frequently spoken by ELS/LEP students";
PROC FREQ data = fileselch_final order=freq;
tables LANGUAGE;
run;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - KDGN";
PROC SQL;
    select
        min(KDGN) as min
       ,max(KDGN) as max
       ,mean(KDGN) as mean
       ,median(KDGN) as median
       ,nmiss(KDGN) as miss
       ,sum(KDGN) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_1";
PROC SQL;
    select
        min(GR_1) as min
       ,max(GR_1) as max
       ,mean(GR_1) as mean
       ,median(GR_1) as median
       ,nmiss(GR_1) as miss
       ,sum(GR_1) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_2";
PROC SQL;
    select
        min(GR_2) as min
       ,max(GR_2) as max
       ,mean(GR_2) as mean
       ,median(GR_2) as median
       ,nmiss(GR_2) as miss
       ,sum(GR_2) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_3";
PROC SQL;
    select
        min(GR_3) as min
       ,max(GR_3) as max
       ,mean(GR_3) as mean
       ,median(GR_3) as median
       ,nmiss(GR_3) as miss
       ,sum(GR_3) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_4";
PROC SQL;
    select
        min(GR_4) as min
       ,max(GR_4) as max
       ,mean(GR_4) as mean
       ,median(GR_4) as median
       ,nmiss(GR_4) as miss
       ,sum(GR_4) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_5";
PROC SQL;
    select
        min(GR_5) as min
       ,max(GR_5) as max
       ,mean(GR_5) as mean
       ,median(GR_5) as median
       ,nmiss(GR_5) as miss
       ,sum(GR_5) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_6";
PROC SQL;
    select
        min(GR_6) as min
       ,max(GR_6) as max
       ,mean(GR_6) as mean
       ,median(GR_6) as median
       ,nmiss(GR_6) as miss
       ,sum(GR_6) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_7";
PROC SQL;
    select
        min(GR_7) as min
       ,max(GR_7) as max
       ,mean(GR_7) as mean
       ,median(GR_7) as median
       ,nmiss(GR_7) as miss
       ,sum(GR_7) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_8";
PROC SQL;
    select
        min(GR_8) as min
       ,max(GR_8) as max
       ,mean(GR_8) as mean
       ,median(GR_8) as median
       ,nmiss(GR_8) as miss
       ,sum(GR_8) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_9";
PROC SQL;
    select
        min(GR_9) as min
       ,max(GR_9) as max
       ,mean(GR_9) as mean
       ,median(GR_9) as median
       ,nmiss(GR_9) as miss
       ,sum(GR_9) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_10";
PROC SQL;
    select
        min(GR_10) as min
       ,max(GR_10) as max
       ,mean(GR_10) as mean
       ,median(GR_10) as median
       ,nmiss(GR_10) as miss
       ,sum(GR_10) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_11";
PROC SQL;
    select
        min(GR_11) as min
       ,max(GR_11) as max
       ,mean(GR_11) as mean
       ,median(GR_11) as median
       ,nmiss(GR_11) as miss
       ,sum(GR_11) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - GR_12";
PROC SQL;
    select
        min(GR_12) as min
       ,max(GR_12) as max
       ,mean(GR_12) as mean
       ,median(GR_12) as median
       ,nmiss(GR_12) as miss
       ,sum(GR_12) as total
    from
        fileselch_final
    ;
quit;
title;


title "Inspect number of ELS/LEP students at each grade level in fileselsch - UNGR";
PROC SQL;
    select
        min(UNGR) as min
       ,max(UNGR) as max
       ,mean(UNGR) as mean
       ,median(UNGR) as median
       ,nmiss(UNGR) as miss
       ,sum(UNGR) as total
    from
        fileselch_final
    ;
quit;
title;

/* check dataset 4 */

/*data - integrity checks for filesgradaf */
proc sql;
    /* checking for unique id values that are repeated, missing, or correspond to
       non-schools */
create table filesgradaf_bad_unique_ids as
    select
        A.*
    from 
        filesgradaf as A
        left join
        (
            select
                CDS_CODE
                ,count(*) as row_count_for_unique_id_value
            from
                    filesgradaf
                group by
                    CDS_CODE
            ) as B
            on A.CDS_CODE=B.CDS_CODE
        having
            /* capture rows corresponding to repeated primary key values */
            row_count_for_unique_id_value > 1
            or
            /* capture rows corresponding to missing primary key values */
            missing(CDS_CODE)
            or
            /* capture rows corresponding to non-school primary key values */
            substr(cat(CDS_CODE),8,7) in ("0000000","0000001")
    ;
    /* removing rows with primary keys that do not correspond to schools*/
    create table filesgradaf_new as
        select
            *
        from
            filesgradaf
        where
            /* remove rows for District Offices and non-public schools */
            substr(cat(CDS_CODE),8,7) not in ("0000000","0000001")
    ;
    create table filesgradaf_new2 as
        select
            *
        from
            filesgradaf
        where
            /* remove rows for with sum of students is less than 30 */
            TOTAL < 30
            order by CDS_CODE
    ;
quit;


proc sql;
create table filesgradaf_integ1 as
    select
        A.*
    from 
        filesgradaf as A
        left join
        (
            select
                CDS_CODE
                ,count(*) as row_count_for_unique_id_value
            from
                    filesgradaf
                group by
                    CDS_CODE
            ) as B
            on A.CDS_CODE=B.CDS_CODE
        having
            /* capture rows corresponding to nonrepeated primary key values */
            row_count_for_unique_id_value = 1
            or
            /* capture rows corresponding to nonmissing primary key values */
            not missing(CDS_CODE)
            or
            /* capture rows tha don't correspond to non-school primary key values */
            substr(cat(CDS_CODE),8,7) not in ("0000000","0000001")
    ;
    create table filesgradaf_final as
        select
            *
        from
            filesgradaf_integ1
        where
            /* remove rows for with sum of students is less than 30 */
            TOTAL >= 30
            order by CDS_CODE 
    ;
quit;


/* data - inspection step for filesgradaf*/ 
title "Inspect TOTAL students in filesgradaf - TOTAL Var";
PROC SQL;
    select
        min(TOTAL) as min
       ,max(TOTAL) as max
       ,mean(TOTAL) as mean
       ,median(TOTAL) as median
       ,nmiss(TOTAL) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - HISPANIC";
PROC SQL;
    select
        min(HISPANIC) as min
       ,max(HISPANIC) as max
       ,mean(HISPANIC) as mean
       ,median(HISPANIC) as median
       ,nmiss(HISPANIC) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - AM_IND";
PROC SQL;
    select
        min(AM_IND) as min
       ,max(AM_IND) as max
       ,mean(AM_IND) as mean
       ,median(AM_IND) as median
       ,nmiss(AM_IND) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - ASIAN";
PROC SQL;
    select
        min(ASIAN) as min
       ,max(ASIAN) as max
       ,mean(ASIAN) as mean
       ,median(ASIAN) as median
       ,nmiss(ASIAN) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - PAC_ISLD";
PROC SQL;
    select
        min(PAC_ISLD) as min
       ,max(PAC_ISLD) as max
       ,mean(PAC_ISLD) as mean
       ,median(PAC_ISLD) as median
       ,nmiss(PAC_ISLD) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - AFRICAN_AM";
PROC SQL;
    select
        min(AFRICAN_AM) as min
       ,max(AFRICAN_AM) as max
       ,mean(AFRICAN_AM) as mean
       ,median(AFRICAN_AM) as median
       ,nmiss(AFRICAN_AM) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - WHITE";
PROC SQL;
    select
        min(WHITE) as min
       ,max(WHITE) as max
       ,mean(WHITE) as mean
       ,median(WHITE) as median
       ,nmiss(WHITE) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - TWO_MORE_RACES";
PROC SQL;
    select
        min(TWO_MORE_RACES) as min
       ,max(TWO_MORE_RACES) as max
       ,mean(TWO_MORE_RACES) as mean
       ,median(TWO_MORE_RACES) as median
       ,nmiss(TWO_MORE_RACES) as miss
    from
        filesgradaf_final
    ;
quit;
title;

title "Inspect TOTAL students in filesgradaf - NOT_REPORTED";
PROC SQL;
    select
        min(NOT_REPORTED) as min
       ,max(NOT_REPORTED) as max
       ,mean(NOT_REPORTED) as mean
       ,median(NOT_REPORTED) as median
       ,nmiss(NOT_REPORTED) as miss
    from
        filesgradaf_final
    ;
quit;
title;

/* end to be edited */


/* The original data set will be uploaded later during week 3 to compare with
the modified data. The filename will be xxxxxx-original.xlsx */


/* Print the names of all datasets/tables created above by querying the
"dictionary tables" the SAS kernel maintains for the default "Work" library */


proc sql;
    select *
    from dictionary.tables
    where libname = 'WORK'
    order by memname;
quit;
