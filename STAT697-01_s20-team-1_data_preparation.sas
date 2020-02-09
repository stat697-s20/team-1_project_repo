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
downloaded and edited to produce file cohort1819-edited.xlsx by opening in
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
downloaded and edited to produce file cohort1718-edited.xls by opening in Excel
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

[Dataset Description] Graduates meeting University of California/California State
University (UC/CSU) entrance requirements.

[Experimental Unit Description] California K-12 School Data 2017

[Number of Observations] 2,535

[Number of Features] 15

[Data Source]  The file https://www.cde.ca.gov/ds/sd/sd/filesgradaf.asp
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

proc sql;
    create table fileselsch_dups as
        select
             *
        from
            fileselsch
        group by
             LANGUAGE
        having
            TOTAL_EL >= 1
    ;
    create table fileselsch_2 as
        select
            *
        from
            fileselsch
        where
            /* remove rows with missing unique id value components */
            not(missing(County_Code))
            and
            not(missing(District_Code))
            and
            not(missing(School_Code))
            and
            /* remove rows for District Offices and non-public schools */
            School_Code not in ("0000000","0000001")
    ;
quit;

/* check dataset 4 */

proc sql;
    create table frpm1415_raw_dups as
        select
             County_Code
            ,District_Code
            ,School_Code
            ,count(*) as row_count_for_unique_id_value
        from
            frpm1415_raw
        group by
             County_Code
            ,District_Code
            ,School_Code
        having
            row_count_for_unique_id_value > 1
    ;
    create table frpm1415 as
        select
            *
        from
            frpm1415_raw
        where
            /* remove rows with missing unique id value components */
            not(missing(County_Code))
            and
            not(missing(District_Code))
            and
            not(missing(School_Code))
            and
            /* remove rows for District Offices and non-public schools */
            School_Code not in ("0000000","0000001")
    ;
quit;

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