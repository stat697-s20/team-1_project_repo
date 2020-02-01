*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* 
[Dataset 1 Name] acgr19
[Dataset Description] Adjusted Cohort Graduation Rate and Outcome Data, AY2018-19
[Experimental Unit Description] California public K-12 schools in AY2018-19
[Number of Observations] 198,022
[Number of Features] 34
[Data Source] ftp://ftp.cde.ca.gov/demo/acgr/cohort1819.txt
[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp
[Unique ID Schema] The columns "County Code", "District Code", and "School Code" form a composite key, which together are equivalent to the unique id column "County Code", "District Code", and "School Code" in dataset acgr18, and which together are also equivalent to the unique id column CDS in dataset elsch19.
*/
%let inputDataset1DSN = frpm1415_raw;
%let inputDataset1URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/frpm1415-edited.xls?raw=true
;
%let inputDataset1Type = XLSX;


/*
[Dataset 2 Name] acgr18
[Dataset Description] Adjusted Cohort Graduation Rate and Outcome Data, AY2017-18
[Experimental Unit Description] California public K-12 schools in AY2017-18
[Number of Observations] 202,115
[Number of Features] 34
[Data Source] ftp://ftp.cde.ca.gov/demo/acgr/cohort1718.txt
[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsacgr.asp
[Unique ID Schema] The columns "County Code", "District Code", and "School Code" form a composite key, which together are equivalent to the unique id column "County Code", "District Code", and "School Code" in dataset acgr19, and which together are also equivalent to the unique id column CDS in dataset elsch19.
*/
%let inputDataset2DSN = frpm1516_raw;
%let inputDataset2URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/frpm1516-edited.xls?raw=true
;
%let inputDataset2Type = XLSX;


/*
[Dataset 3 Name] elsch19
[Dataset Description] English Learners by Grade & Language, AY2018-19
[Experimental Unit Description] English Learns (Els), formerly limited-English-proficient (LEP) students, by grade, language and school, AY2018-19
[Number of Observations] 62,911
[Number of Features] 21
[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=EL&cPage=fileselsch
[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fselsch.asp
[Unique ID Schema] The column CDS is a unique id.
*/
%let inputDataset3DSN = gradaf15_raw;
%let inputDataset3URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/gradaf15.xls?raw=true
;
%let inputDataset3Type = XLSX;


/*
[Dataset 4 Name] sat15
[Dataset Description] SAT Test Results, AY2014-15
[Experimental Unit Description] California public K-12 schools in AY2014-15
[Number of Observations] 2,331
[Number of Features] 12
[Data Source]  The file http://www3.cde.ca.gov/researchfiles/satactap/sat15.xls
was downloaded and edited to produce file sat15-edited.xls by opening in Excel
and setting all cell values to "Text" format
[Data Dictionary] http://www.cde.ca.gov/ds/sp/ai/reclayoutsat.asp
[Unique ID Schema] The column CDS is a unique id.
*/
%let inputDataset4DSN = sat15_raw;
%let inputDataset4URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/sat15-edited.xls?raw=true
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


/* print the names of all datasets/tables created above by querying the
"dictionary tables" the SAS kernel maintains for the default "Work" library */
/* Note to learners: The example below illustrates how much work SAS does behind
the scenes when a new dataset is created. By default, SAS datasets are stored on
disk as physical files, which you could view by locating in folders called
"libraries," with the default "Work" library located in a temporary location
typically not accessible to the end user. In addition, SAS dataset files can be
optimized in numerous ways, including encryption, compression, and indexing.
This reflects SAS having been created in the 1960s, when computer resources were
extremely limited, and so it made sense to store even small datasets on disk and
load them into memory one record/row at a time, as needed.
By contract, most modern languages, like R and Python, store datasets in memory
by default. This has several trade-offs: Since DataFrames in R and Python are in
memory, any of their elements can be accessed simultaneously, making data
transformations fast and flexible, but DataFrames cannot be larger than available
system memory. On the other hand, SAS datasets can be arbitrarily large, but
large datasets often take longer to process since they must be streamed to
memory from disk and then operated on one record at a time.
*/
proc sql;
    select *
    from dictionary.tables
    where libname = 'WORK'
    order by memname;
quit;