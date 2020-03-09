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
%let inputDataset1DSN = cohort1819_final;
%let inputDataset1URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/cohort1819_Final.xlsx
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
%let inputDataset2DSN = cohort1718_final;
%let inputDataset2URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/cohort1718_Final.xlsx
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
%let inputDataset3DSN = fileselsch_final;
%let inputDataset3URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/fileselsch_final.xlsx
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
%let inputDataset4DSN = filesgradaf_final;
%let inputDataset4URL =
https://github.com/stat697/team-1_project_repo/raw/master/data/filesgradaf_final.xlsx
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


/* check cohort1819_final to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1819 as
        select
           *
        from
            cohort1819_final
        where
            not(missing(CohortStudents))
            and
            CohortStudents > 30
        group by
            CharterSchool
    ;
quit;


/* check cohort1718_final to first remove any non-numeric value and rows of 
Cohort Students less than 30 to improve accuracy*/
proc sql;
    create table cohort1718 as
        select
			*
        from
            cohort1718_final
        where
            not(missing(CohortStudents))
            and
            CohortStudents > 30
        group by
            CharterSchool         
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

proc sql;
	create table cohort as
		select
			*
		from
			cohort1718
		union all
		select
			*
		from
			cohort1819;
	alter table cohort
		drop
			AggregateLevel
		   ,DASS
		;
quit;

proc sql;
	create table files as
		select
			A.*
		   ,B.*
		from
			fileselsch_final as A
		left join
			filesgradaf_final as B
		on
			A.CDS_Code = B.CDS_Code
		where
			Total > 0
		order by
			CDS_Code
		;
quit;

proc sql;
	create table master as
		select
			*
		from cohort
		outer union
		select
			*
		from
			files
		;
quit;




/* build analytic dataset from raw datasets imported above, including only the
columns and minimal data-cleaning/transformation needed to address each
research questions/objectives in data-analysis files */

/*First Creating smaller table*/
/*
proc sql;
    create table A as
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
;
quit;          

proc sql;
    create table B as
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
                    ;
quit;

proc sql;
    create table C as
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
                    fileselsch_new;
quit;

proc sql;
    create table D as
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
            filesgradaf_new2
            ;
quit;



proc sql;
	create table cde_part1 as
		select
			coalesce(C.CDS_Code,D.CDS_Code)
            AS CDS_Code
           ,coalesce(C.School,D.School)
            AS School
           ,coalesce(C.District,D.District)
            AS District
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
            C
            full join
            D
            on C.CDS_Code = D.CDS_Code
        	order by
            	CDS_Code
    ;
quit;

proc sql;
    create table cde_analytic_file_raw as
        select
        	cde_part1.CDS_Code
           ,coalesce(A.School,cde_part1.School)
            AS School
           ,coalesce(A.District,cde_part1.District)
            AS District
           ,CharterSchool
           ,ReportingCategory
           ,CohortStudents
           ,HS_Graduates
           ,CountyName 
           ,Biliteracy_Rate 
           ,GED_Count 
           ,Met_UC_CSU_Grad_Req
           ,cde_part1.LanguageCode
           ,cde_part1.Language
           ,cde_part1.Kindergarten
           ,cde_part1.Grade_1
           ,cde_part1.Grade_2
           ,cde_part1.Grade_3
           ,cde_part1.Grade_4
           ,cde_part1.Grade_5
           ,cde_part1.Grade_6
           ,cde_part1.Grade_7
           ,cde_part1.Grade_8
           ,cde_part1.Grade_9
           ,cde_part1.Grade_10
           ,cde_part1.Grade_11
           ,cde_part1.Grade_12
           ,cde_part1.Undergrad 
           ,cde_part1.Total_EL  
           ,cde_part1.Hispanic
           ,cde_part1.American_Indian
           ,cde_part1.Asian
           ,cde_part1.Pacific_Ilander
           ,cde_part1.Filipino
           ,cde_part1.African_American
           ,cde_part1.White 
           ,cde_part1.Total
        from
            A
           	full join
            cde_part1
            on A.School = cde_part1.School
        	/*order by
            	CDS_Code*/
    ;
quit;*/


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
        substr(cat(CDS_Code),8,7) not in ("0000000","0000001")
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


/* Test combining data with unions */
proc sql; /* Union all will stack these two tables */
	create table cohort1 as
		select * from cohort1718
		union all
		select * from cohort1819;
alter table cohort1
	drop AggregateLevel 
		,DASS		 
		,Seal_of_Biliteracy_Co  
		,Seal_of_Biliteracy_Ra 	
	;
quit;

/*creates CDS_Code in cohort file */
proc sql;
	create table cohort as
		select
			cats(CountyCode,DistrictCode,SchoolCode)
			AS
			CDS_Code
		   ,CharterSchool		    
		   ,ReportingCategory
		   ,CohortStudents
		   ,HS_Grad_Co
		   ,HS_Grad_Ra
		   ,Met_UC_CSU_Req_Co
		   ,Met_UC_CSU_Req_Ra
		   
	 from
	 	cohort1
	 ;
quit;

proc sql; /* left join will match these on the CDS_Code and where Total > 0 removes row with missing values*/
	create table files as 
		select A.*, B.*
		from fileselch_final A
		left join filesgradaf_final B 
		on A.CDS_Code=B.CDS_Code
		where Total >0
		order by CDS_Code	    
		;
quit;

/* may want to try a left union here instead */
proc sql; /* Master file and CohortStudents has values */
	create table master as 
		select * from cohort
		outer union
		select * from files
		;
quit;
