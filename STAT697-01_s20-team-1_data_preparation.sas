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
Diploma Graduates (Count), Met UC/CSU Grad Req's (Count) and Seal of 
Biliteracy (Count).

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp

[Unique ID Schema] The column "ReportingCategory" in this data set is unique as
it reflects the columns of ethnicities in data set "filesgradaf.xlsx" and 
column "Language" in data set "fileselsch.xlsx".
*/
%let inputDataset1DSN = cohort1819_edited;
%let inputDataset1URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/cohort1819_edited.xlsx
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
Diploma Graduates (Count), Met UC/CSU Grad Req's (Count) and Seal of 
Biliteracy (Count).

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp

[Unique ID Schema] The column "ReportingCategory" in this data set is unique as
it reflects the columns of ethnicities in data set "filesgradaf.xlsx" and 
column "Language" in data set "fileselsch.xlsx".
*/
%let inputDataset2DSN = cohort1718_edited;
%let inputDataset2URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/cohort1718_edited.xlsx
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
https://github.com/stat697/team-1_project_repo/raw/master/data/fileselsch.xlsx
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
https://github.com/stat697/team-1_project_repo/raw/master/data/filesgradaf.xlsx
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


/* check cohort1819_edited to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1819_edited_dup1 as
        select
            CharterSchool
           ,ReportingCategory
           ,input(CohortStudents, 8.) as CohortStudents
           ,input(Regular_HS_Diploma_Graduates__Co,8.) as Regular_HS_Graduates
           ,input(VAR8, 8.) as Met_UCCSUReq
           ,input(Seal_of_Biliteracy__Count_, 8.) as Seal_of_Biliteracy
           ,SchoolName
           ,DistrictName
           ,GED_Completer__Count_
           ,CountyName
        from
            cohort1819_edited
        where
            not(missing(CohortStudents))
        group by
            CharterSchool
    ;
    /* combining the reporting category together */
    create table cohort1819 as
        select
            CharterSchool
           ,ReportingCategory
           ,sum(CohortStudents) as CohortStudents
           ,sum(Regular_HS_Graduates) as Regular_HS_Graduates
           ,sum(Met_UCCSUReq) as Met_UCCSUReq
           ,sum(Seal_of_Biliteracy) as Seal_of_Biliteracy
           ,SchoolName
           ,DistrictName
           ,GED_Completer__Count_
           ,CountyName
        from
            cohort1819_edited_dup1
        group by 
            CharterSchool, ReportingCategory
        order by
            ReportingCategory    
    ;
quit;


/* check cohort1718_edited to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1718_edited_dup1 as
        select
            CharterSchool
           ,ReportingCategory
		   ,input(CohortStudents, 8.) as CohortStudents
           ,input(Regular_HS_Diploma_Graduates__Co,8.) as Regular_HS_Graduates
           ,input(VAR8, 8.) as Met_UCCSUReq
           ,input(Seal_of_Biliteracy__Count_, 8.) as Seal_of_Biliteracy
           ,SchoolName
           ,DistrictName
           ,GED_Completer__Count_
           ,CountyName
        from
            cohort1718_edited
        where
            not(missing(CohortStudents))
        group by
            CharterSchool         
    ;
    /* combining the reporting category together */
    create table cohort1718 as
        select
            CharterSchool
           ,ReportingCategory
           ,sum(CohortStudents) as CohortStudents
           ,sum(Regular_HS_Graduates) as Regular_HS_Graduates
           ,sum(Met_UCCSUReq) as Met_UCCSUReq
           ,sum(Seal_of_Biliteracy) as Seal_of_Biliteracy
           ,SchoolName
           ,DistrictName
           ,GED_Completer__Count_
           ,CountyName
        from
            cohort1718_edited_dup1
        group by 
            CharterSchool, ReportingCategory
        order by
            ReportingCategory    
    ;
quit;


/*data - integrity checks for fileselch - checking for unique id values that are 
repeated, missing, or correspond to non-schools to remove any conflicting or 
incomplete entries*/
proc sql;
create table fileselsch_bad_unique_ids as
    select
        A.*
    from 
        fileselsch as A
        left join
        (
            select
                CDS
               ,count(*) as row_count_for_unique_id_value
            from
                fileselsch
            group by
                CDS
            ) as B
            on A.CDS=B.CDS
        having
        /*Removing repeated, missing, or non-school cooresponing values*/
            row_count_for_unique_id_value > 1
            or
            missing(CDS)
            or
            substr(cat(CDS),8,7) in ("0000000","0000001")
    ;
    /* Removing rows corresponding to District Offices and non-public schools */
    create table fileselsch_new as
        select
            *
        from
            fileselsch
        where
            substr(cat(CDS),8,7) not in ("0000000","0000001")
    ;
quit;


/*data - integrity checks for filesgradaf - checking for unique id values that are 
repeated, missing, or correspond to non-schools and removing rows where TOTAL is 
less than 30 to increase accuracy*/
proc sql;
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
        /* Removing repeated, missing, or non-school cooresponing values */
            row_count_for_unique_id_value > 1
            or
            missing(CDS_CODE)
            or
            substr(cat(CDS_CODE),8,7) in ("0000000","0000001")
    ;
    /* Removing rows corresponding to District Offices and non-public schools */
    create table filesgradaf_new as
        select
            *
        from
            filesgradaf
        where
            substr(cat(CDS_CODE),8,7) not in ("0000000","0000001")
    ;
    /* Removing rows where the student count TOTAL is less than 30 */
    create table filesgradaf_new2 as
        select
            *
        from
            filesgradaf
        where
            TOTAL < 30
            order by CDS_CODE
    ;
quit;


/* build analytic dataset from raw datasets imported above, including only the
columns and minimal data-cleaning/transformation needed to address each
research questions/objectives in data-analysis files */
proc sql;
    create table cde_analytic_file_raw as
        select
            coalesce(C.CDS_Code,D.CDS_Code)
            AS CDS_Code
           ,coalesce(A.School,B.School,C.School,D.School)
            AS School
           ,coalesce(A.District,B.District,C.District,D.District)
            AS District
           ,coalesce(A.CharterSchool, B.CharterSchool) 
            AS
            CharterSchool
           ,coalesce(A.ReportingCategory, B.ReportingCategory)
            AS
            ReportingCategory
           ,coalesce(A.CohortStudents, B.CohortStudents)
            AS
            CohortStudents
           ,coalesce(A.HS_Graduates, B.HS_Graduates)
            AS
            HS_Graduates
           ,coalesce(A.CountyName, B.CountyName)
            AS
            CountyName 
           ,coalesce(A.Biliteracy_Rate, B.Biliteracy_Rate)
            AS
            Biliteracy_Rate 
           ,coalesce(A.GED_Count, B.GED_Count)
            AS
            GED_Count 
           ,coalesce(A.Met_UC_CSU_Grad_Req, B.Met_UC_CSU_Grad_Req)
            AS
            Met_UC_CSU_Grad_Req            
           ,C.LanguageCode
            AS
            LanguageCode
           ,LANGUAGE
            AS
            Language
           ,C.Kindergarten
            AS
            Kindergarten
           ,C.Grade_1
            AS 
            Grade_1
           ,C.Grade_2
            AS 
            Grade_2
           ,C.Grade_3
            AS 
            Grade_3
           ,C.Grade_4
            AS 
            Grade_4
           ,C.Grade_5
            AS 
            Grade_5
           ,C.Grade_6
            AS 
            Grade_6
           ,C.Grade_7
            AS 
            Grade_7
           ,C.Grade_8
            AS 
            Grade_8
           ,C.Grade_2
            AS 
            Grade_9
           ,C.Grade_10
            AS 
            Grade_10
           ,C.Grade_11
            AS 
            Grade_11
           ,C.Grade_12
            AS 
            Grade_12
           ,C.Undergrad
            AS 
            Undergrad 
           ,C.TOTAL_EL
            AS 
            Total_EL  
           ,D.Hispanic
            AS 
            Hispanic
           ,D.American_Indian
            AS 
            American_Indian
           ,D.Asian
            AS 
            Asian
           ,D.Pacific_Ilander
            AS 
            Pacific_Ilander
           ,D.Filipino
            AS 
            Filipino
           ,D.African_American
            AS 
            African_American
           ,D.White
            AS 
            White 
           ,D.Total
            AS 
            Total            
        from
            (
                select 
                    SchoolName
                    AS
                    School
                   ,DistrictName
                    AS
                    District
                   ,CharterSchool 
                    AS
                    CharterSchool
                   ,ReportingCategory
                    AS
                    ReportingCategory
                   ,CohortStudents
                    AS
                    CohortStudents
                   ,Regular_HS_Graduates
                    AS
                    HS_Graduates
                   ,CountyName
                    AS
                    CountyName 
                   ,Seal_of_Biliteracy
                    AS
                    Biliteracy_Rate 
                   ,GED_Completer__Count_
                    AS
                    GED_Count 
                   ,Met_UCCSUReq
                    AS
                    Met_UC_CSU_Grad_Req                                        
                from
                  cohort1819 
            ) as A
            full join
            (
                select
                    SchoolName
                    AS
                    School
                   ,DistrictName
                    AS
                    District
                   ,CharterSchool 
                    AS
                    CharterSchool
                   ,ReportingCategory
                    AS
                    ReportingCategory
                   ,CohortStudents
                    AS
                    CohortStudents
                   ,Regular_HS_Graduates
                    AS
                    HS_Graduates
                   ,CountyName
                    AS
                    CountyName
                   ,Seal_of_Biliteracy
                    AS
                    Biliteracy_Rate 
                   ,GED_Completer__Count_
                    AS
                    GED_Count 
                   ,Met_UCCSUReq
                    AS
                    Met_UC_CSU_Grad_Req                                        
                from
                    cohort1718
            ) as B
            on A.School = B.School
            full join
            (
                select
                    CDS
                    AS CDS_Code
                   ,SCHOOL
                    AS School
                   ,DISTRICT
                    AS
                    District
                   ,LC
                    AS
                    LanguageCode
                   ,LANGUAGE
                    AS
                    Language
                   ,KDGN
                    AS
                    Kindergarten
                   ,GR_1
                    AS 
                    Grade_1
                   ,GR_2
                    AS 
                    Grade_2
                   ,GR_3
                    AS 
                    Grade_3
                   ,GR_4
                    AS 
                    Grade_4
                   ,GR_5
                    AS 
                    Grade_5
                   ,GR_6
                    AS 
                    Grade_6
                   ,GR_7
                    AS 
                    Grade_7
                   ,GR_8
                    AS 
                    Grade_8
                   ,GR_9
                    AS 
                    Grade_9
                   ,GR_10
                    AS 
                    Grade_10
                   ,GR_11
                    AS 
                    Grade_11
                   ,GR_12
                    AS 
                    Grade_12
                   ,UNGR
                    AS 
                    Undergrad 
                   ,TOTAL_EL
                    AS 
                    Total_EL                                     
                from
                    fileselsch
            ) as C
            on A.School = C.School 
            full join
            (
                select
                    CDS_CODE
                    AS CDS_Code
                   ,SCHOOL
                    AS School
                   ,DISTRICT
                    AS
                    District
                   ,HISPANIC
                    AS 
                    Hispanic
                   ,AM_IND
                    AS 
                    American_Indian
                   ,ASIAN
                    AS 
                    Asian
                   ,PAC_ISLD
                    AS 
                    Pacific_Ilander
                   ,FILIPINO
                    AS 
                    Filipino
                   ,AFRICAN_AM
                    AS 
                    African_American
                   ,WHITE
                    AS 
                    White 
                   ,TOTAL
                    AS 
                    Total                     
                from
                    filesgradaf
            ) as D
            on C.CDS_Code = D.CDS_Code
        order by
            CDS_Code
    ;
quit;


/* Checking for rows with repeating, missing, or cooresponding to 
non-schools CDS_Codes values and removing rows where Total is less
than 30 students to increase accuracy*/
data cde_analytic_file_raw_bad_ids;
    set cde_analytic_file_raw;
    by CDS_Code Total;

    if
        first.CDS_Code*last.CDS_Code = 0
        or
        missing(CDS_Code)
        or
        substr(cat(CDS),8,7) not in ("0000000","0000001")
        or
        Total < 30
    then
        do;
            output;
        end;
run;


/* remove duplicates from cde_analytic_file_raw using CDS_Code as the 
reference variable */
proc sort
        nodupkey
        data=cde_analytic_file_raw
        out=cde_analytic_file
    ;
    by
        CDS_Code
    ;
run;


/* Updated sql code */

/* only use proc import statements if need to pull from local file and be sure to chage file location */
/*Dataset 1 */
proc import datafile = '/folders/myfolders/Team_1_STAT_697_wk_4/team-1_project_repo/data/cohort1819_original.xlsx'
 out = cohort1819_orig
 dbms = xlsx
 ;
run;


/*Dataset 2 */ 
proc import datafile = '/folders/myfolders/Team_1_STAT_697_wk_4/team-1_project_repo/data/cohort1718_original.xlsx'
 out = cohort1718_orig
 dbms = xlsx
 ;
run;


/*Dataset 3 */
proc import datafile = '/folders/myfolders/Team_1_STAT_697_wk_3/team-1_project_repo/data/fileselsch.xlsx'
 out = fileselch
 dbms = xlsx
 ;
run;


/*Dataset 4 */
proc import datafile = '/folders/myfolders/Team_1_STAT_697_wk_3/team-1_project_repo/data/filesgradaf.xlsx'
 out = filesgradaf
 dbms = xlsx
 ;
run;


/*Wk 4 Step 3 - create a single sql query to combine datasets*/

proc sql;
    create table cde_analytic_file_raw as
        select
             coalesce(A.CDS_Code, B.CDS_Code,C.CDS_Code,D.CDS_Code)
             AS CDS_Code /*
            ,coalesce(A.CountyCode,B.CountyCode)
             AS 
             CountyCode */
            ,coalesce(A.School,B.School,C.School,D.School) 
             AS School
            ,coalesce(A.District,B.District,C.District,D.District) 
             AS District
            ,coalesce(A.CharterSchool, B.CharterSchool) 
             AS
             CharterSchool
            ,coalesce(A.ReportingCategory, B.ReportingCategory)
             AS
             ReportingCategory
            ,coalesce(A.CohortStudents, B.CohortStudents)
             AS
             CohortStudents
            ,coalesce(A.HS_Graduates, B.HS_Graduates)
             AS
             HS_Graduates /*
            ,coalesce(A.SchoolCode, B.SchoolCode)
             AS
             SchoolCode */
            ,coalesce(A.Biliteracy_Rate, B.Biliteracy_Rate)
             AS
             Biliteracy_Rate 
            ,coalesce(A.GED_Count, B.GED_Count)
             AS
             GED_Count 
            ,coalesce(A.Met_UC_CSU_Grad_Req, B.Met_UC_CSU_Grad_Req)
             AS
             Met_UC_CSU_Grad_Req            
            ,C.Kindergarten
             AS 
             Kindergarten
            ,C.Grade_1
             AS 
             Grade_1
            ,C.Grade_2
             AS 
             Grade_2
            ,C.Grade_3
             AS 
             Grade_3
            ,C.Grade_4
             AS 
             Grade_4
            ,C.Grade_5
             AS 
             Grade_5
            ,C.Grade_6
             AS 
             Grade_6
            ,C.Grade_7
             AS 
             Grade_7
            ,C.Grade_8
             AS 
             Grade_8
            ,C.Grade_9
             AS 
             Grade_9
            ,C.Grade_10
             AS 
             Grade_10
            ,C.Grade_11
             AS 
             Grade_11
            ,C.Grade_12
             AS 
             Grade_12
            ,C.Undergrad
             AS 
             Undergrad 
            ,C.TOTAL_EL
             AS 
             Total_EL            
            ,D.Hispanic
             AS 
             Hispanic
            ,D.American_Indian
             AS 
             American_Indian
            ,D.Asian
             AS 
             Asian
            ,D.Pacific_Islander
             AS 
             Pacific_Islander
            ,D.Filipino
             AS 
             Filipino
            ,D.African_American
             AS 
             African_American
            ,D.White
             AS 
             White 
            ,D.Total
             AS 
             Total 
                        
        from
            (
                  select 
                     input(cats(CountyCode, DistrictCode, SchoolCode), best.14)
                     AS CDS_Code
                     /*length 14 */
                    ,SchoolName 
                     AS School 
                    ,DistrictName
                     AS
                     District
                    ,CharterSchool 
                     AS
                     CharterSchool
                    ,ReportingCategory
                     AS
                     ReportingCategory
                    ,CohortStudents
                     AS
                     CohortStudents
                    ,Regular_HS_Diploma_Graduates__RA
                     AS
                     HS_Graduates /*
                    ,VAR5
                     AS
                     VAR5  You may want to rename this */ 
                    ,Seal_of_Biliteracy__Rate_
                     AS
                     Biliteracy_Rate 
                    ,GED_Completer__Count_
                     AS
                     GED_Count 
                    ,VAR14
                     AS
                     Met_UC_CSU_Grad_Req                    
                from
                   cohort1819_original /*Need to reference original dataset 1 here*/
            ) as A
            full join
            (
                select 
                     input(cats(CountyCode, DistrictCode, SchoolCode), best.14)
                     AS CDS_Code
                     /*length 14*/
                    ,SchoolName
                     AS
                     School
                    ,DistrictName
                     AS
                     District
                    ,CharterSchool 
                     AS
                     CharterSchool
                    ,ReportingCategory
                     AS
                     ReportingCategory
                    ,CohortStudents
                     AS
                     CohortStudents
                    ,Regular_HS_Diploma_Graduates__RA
                     AS
                     HS_Graduates /*
                    ,VAR5
                     AS
                     VAR5  You may want to rename this */ 
                    ,Seal_of_Biliteracy__Rate_
                     AS
                     Biliteracy_Rate 
                    ,GED_Completer__Count_
                     AS
                     GED_Count 
                    ,VAR14
                     AS
                     Met_UC_CSU_Grad_Req                                        
                from
                    cohort1718_original 
            ) as B
            on A.CDS_Code = B.CDS_Code /* A.School = B.School */
            full join
            (
                select
                     CDS
                     AS CDS_Code
                    ,SCHOOL
                     AS School
                    ,DISTRICT
                     AS
                     District
                    ,LANGUAGE
                     AS
                     Language
                    ,KDGN
                     AS
                     Kindergarten
                    ,GR_1
                     AS 
                     Grade_1
                    ,GR_2
                     AS 
                     Grade_2
                    ,GR_3
                     AS 
                     Grade_3
                    ,GR_4
                     AS 
                     Grade_4
                    ,GR_5
                     AS 
                     Grade_5
                    ,GR_6
                     AS 
                     Grade_6
                    ,GR_7
                     AS 
                     Grade_7
                    ,GR_8
                     AS 
                     Grade_8
                    ,GR_9
                     AS 
                     Grade_9
                    ,GR_10
                     AS 
                     Grade_10
                    ,GR_11
                     AS 
                     Grade_11
                    ,GR_12
                     AS 
                     Grade_12
                    ,UNGR
                     AS 
                     Undergrad 
                    ,TOTAL_EL
                     AS 
                     Total_EL
                    
                from
                     fileselch
            ) as C
            on A.CDS_Code = C.CDS_Code /*A.SchoolName = C.SCHOOL /*only school name in common for these data sets */
            full join
            (
                select
                     CDS_Code
                     AS CDS_Code
                    ,SCHOOL
                     AS School
                    ,DISTRICT
                     AS
                     District
                    ,HISPANIC
                     AS 
                     Hispanic
                    ,AM_IND
                     AS 
                     American_Indian
                    ,ASIAN
                     AS 
                     Asian
                    ,PAC_ISLD
                     AS 
                     Pacific_Islander
                    ,FILIPINO
                     AS 
                     Filipino
                    ,AFRICAN_AM
                     AS 
                     African_American
                    ,WHITE
                     AS 
                     White 
                   ,TOTAL
                    AS 
                    Total                     
                from
                     filesgradaf
            ) as D
            on C.CDS_Code = D.CDS_Code
        order by
            CDS_Code  
    ;
quit;


/* Checking for rows with repeating, missing, or cooresponding to 
non-schools CDS_Codes values and removing rows where Total is less
than 30 students to increase accuracy*/
data cde_analytic_file_raw_bad_ids;
    set cde_analytic_file_raw;
    by CDS_Code Total;

    if
        first.CDS_Code*last.CDS_Code = 0
        or
        missing(CDS_Code)
        or
        substr(cat(CDS),8,7) not in ("0000000","0000001")
        or
        Total < 30
    then
        do;
            output;
        end;
run;


