*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_08.sas
**     Programmer: james r. hull
**     Start Date: 2009 July 26
**     Purpose:
**        1.) Generate Tables for Chapter 2 - Household Network Vars
**     Input Data:
**        1.)
**     Output Data:
**        1.)
**
**      NOTES:
**
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

ods listing;

%let f=00_8;   ** Allows for greater file portability **;


**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/nangrong/data_sas/2000/current/indiv00.04';

libname out&f.1 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_08.xpt';


*************************************************
** Data Preparation - Create HH Vars and Merge **
*************************************************;

**********************
** Degree Variables **
**********************;

** import household network data by villages: rice degree **;

%macro imp_hh_1 (numvill=);

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/hh/r00_p);
%let p2=%quote(_FreemanDegree_asym_nref.txt);

%do i=1 %to &numvill;

    data v00_r&i.01;
         infile "&p1.&i.&p2";
         input @2 HHID00 :$9. +5 HG_ROR +5 HG_RIR +5 HGNROR +5 HGNRIR;
         if substr(HHID00,9,1)='"' then HHID00=substr(HHID00,1,8);
    run;

%end;

%mend imp_hh_1;

%imp_hh_1 (numvill=51);


** import household network data by villages: sibling degree **;

%macro imp_hh_2 (numvill=);

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/hh/r00_s);
%let p2=%quote(_FreemanDegree_asym_nref.txt);

%do i=1 %to &numvill;

    data v00_s&i.01;
         infile "&p1.&i.&p2";
         input @2 HHID00 :$9. +5 HG_ROS +5 HG_RIS +5 HGNROS +5 HGNRIS;
         if substr(HHID00,9,1)='"' then HHID00=substr(HHID00,1,8);
    run;

%end;

%mend imp_hh_2;

%imp_hh_2 (numvill=51);


** Append all village files into a single file: rice degree **;

data allvillrg&f.01;
     input HHID00 HG_RSR00 HG_ROR00 HG_RIR00 HGNROR00 HGNRIR00;
     datalines;
;
run;

%macro compile1(numvill=);

%do i=1 %to &numvill;

    data v00_r&i.02 (drop=HHID00C HG_ROR HG_RIR HGNROR HGNRIR);
         set v00_r&i.01 (rename=(HHID00=HHID00C));

         HHID00=input(HHID00C,best12.);
         HG_ROR00=input(HG_ROR, best12.);
         HG_RIR00=input(HG_RIR, best12.);
         HGNROR00=input(HGNROR, best12.);
         HGNRIR00=input(HGNRIR, best12.);

         HG_RSR00=HG_ROR00+HG_RIR00;

    run;

    proc append base=allvillrg&f.01 data=v00_r&i.02;
    run;

%end;

%mend compile1;

%compile1(numvill=51);



** Append all village files into a single file: sibling degree **;


data allvillsg&f.01;
     input HHID00 HG_RSS00 HG_ROS00 HG_RIS00 HGNROS00 HGNRIS00;
     datalines;
;
run;

%macro compile2(numvill=);

%do i=1 %to &numvill;

    data v00_s&i.02 (drop=HHID00C HG_ROS HG_RIS HGNROS HGNRIS);
         set v00_s&i.01 (rename=(HHID00=HHID00C));

         HHID00=input(HHID00C, best12.);
         HG_ROS00=input(HG_ROS, best12.);
         HG_RIS00=input(HG_RIS, best12.);
         HGNROS00=input(HGNROS, best12.);
         HGNRIS00=input(HGNRIS, best12.);

         HG_RSS00=HG_ROS00+HG_RIS00;

    run;

    proc append base=allvillsg&f.01 data=v00_s&i.02;
    run;

%end;

%mend compile2;

%compile2(numvill=51);



**************************
** Pathlength Variables **
**************************;

** import household network data by villages: rice pathlength **;

%macro imp_hh_3 (numvill=);

%local mprint mlogic symbolgen notes source source2;
%let mprint=%sysfunc(getoption(mprint)) ;
%let mlogic=%sysfunc(getoption(mlogic)) ;
%let symbolgen=%sysfunc(getoption(symbolgen)) ;
%let notes=%sysfunc(getoption(notes)) ;
%let source=%sysfunc(getoption(source)) ;
%let source2=%sysfunc(getoption(source2)) ;
option nonotes nomprint nomlogic nosymbolgen nosource nosource2;

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/hh/r00_p);
%let p2=%quote(-Geo.txt);

%do i=1 %to &numvill;

    proc import datafile="&p1.&i.&p2" out=v00_r&i.03 dbms=dlm replace;
         getnames=no;
         guessingrows=300;
         datarow=1;
    run;

%end;

option &notes &mprint &mlogic &symbolgen &source &source2;

%mend imp_hh_3;

%imp_hh_3 (numvill=51);


** Format all village-level pathlength files before collapsing: rice pathlength **;

%macro format_3 (numvill=);

%do i=1 %to &numvill;

     %let dsid = %sysfunc(open(v00_r&i.03,i));
     %let numvars=%sysfunc(attrn(&dsid,NVARS));

     data v00_r&i.04 (drop= VAR1-VAR&numvars);
          set v00_r&i.03;

     HHID00=input(VAR1,10.);

     %do j=2 %to &numvars;

         %if (%sysfunc(vartype(&dsid,&j)) = N) %then %do;
                                                          RVAR&j=input(VAR&j, best12.);
                                                     %end;

         %else %if (%sysfunc(vartype(&dsid,&j)) = C) %then %do;
                                                           if VAR&j="?" then VAR&j=" ";
                                                           RVAR&j=input(VAR&j, best12.);
                                                           %end;

     %end;

     run;

     %let rc=%sysfunc(close(&dsid));

%end;

%mend format_3;

%format_3 (numvill=51);


** Collapses data into household-level path length measures by village: rice pathlength **;

%macro count_3 (numvill=);

%do k=1 %to &numvill;

%let dsid = %sysfunc(open(v00_r&k.04,i));
%let numvars=%sysfunc(attrn(&dsid,NVARS));

data v00_r&k.05 (keep=HHID00 H00R_P1-H00R_P50 H00RPSUM H00RPCNT H00RPAVG);
     set v00_r&k.04;

     length H00R_P1-H00R_P50 8.;

     array rvars(2:&numvars) RVAR2-RVAR&numvars;
     array path(1:50) H00R_P1-H00R_P50;

     do j=1 to 50;
                  path(j)=0;
     end;

     H00RPSUM=0;
     H00RPCNT=0;
     H00RPAVG=0;

     do i=2 to &numvars;

        do l=1 to 49;
                    if rvars(i)=l then path(l)=path(l)+1;
        end;

        if rvars(i) >= 50 then H00R_P50=H00R_P50+1;

        if rvars(i) ^in (.,0) then H00RPCNT=H00RPCNT+1;

     end;

     H00RPSUM=SUM(of RVAR2-RVAR&numvars);

     if H00RPCNT^=0 then H00RPAVG=H00RPSUM/H00RPCNT;

run;

%let dsc=%sysfunc(close(&dsid));

%end;

%mend count_3;

%count_3 (numvill=51);


** Append all village files into a single file: rice pathlength **;

data allvillrp&f.01;
     input HHID00 H00R_P1-H00R_P50 H00RPSUM H00RPCNT H00RPAVG;
     datalines;
;
run;

%macro compile3(numvill=);

%do i=1 %to &numvill;

    proc append base=allvillrp&f.01 data=v00_r&i.05;
    run;

%end;

%mend compile3;

%compile3(numvill=51);


** import household network data by villages: sibling pathlength  **;

%macro imp_hh_4 (numvill=);

%local mprint mlogic symbolgen notes source source2;
%let mprint=%sysfunc(getoption(mprint)) ;
%let mlogic=%sysfunc(getoption(mlogic)) ;
%let symbolgen=%sysfunc(getoption(symbolgen)) ;
%let notes=%sysfunc(getoption(notes)) ;
%let source=%sysfunc(getoption(source)) ;
%let source2=%sysfunc(getoption(source2)) ;
option nonotes nomprint nomlogic nosymbolgen nosource nosource2;

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/hh/r00_s);
%let p2=%quote(-Geo.txt);

%do i=1 %to &numvill;

    proc import datafile="&p1.&i.&p2" out=v00_s&i.03 dbms=dlm replace;
         getnames=no;
         guessingrows=300;
         datarow=1;
    run;

%end;

option &notes &mprint &mlogic &symbolgen &source &source2;

%mend imp_hh_4;

%imp_hh_4 (numvill=51);


** Format all village-level pathlength files before collapsing: sibling pathlength **;

%macro format_4 (numvill=);

%do i=1 %to &numvill;

     %let dsid = %sysfunc(open(v00_s&i.03,i));
     %let numvars=%sysfunc(attrn(&dsid,NVARS));

     data v00_s&i.04 (drop= VAR1-VAR&numvars);
          set v00_s&i.03;

     HHID00=input(VAR1,10.);

     %do j=2 %to &numvars;

         %if (%sysfunc(vartype(&dsid,&j)) = N) %then %do;
                                                          RVAR&j=input(VAR&j, best12.);
                                                     %end;

         %else %if (%sysfunc(vartype(&dsid,&j)) = C) %then %do;
                                                           if VAR&j="?" then VAR&j=" ";
                                                           RVAR&j=input(VAR&j, best12.);
                                                           %end;

     %end;

     run;

     %let rc=%sysfunc(close(&dsid));

%end;

%mend format_4;

%format_4 (numvill=51);


** Collapses data into household-level path length measures by village: sibling pathlength **;

%macro count_4 (numvill=);

%do k=1 %to &numvill;

%let dsid = %sysfunc(open(v00_s&k.04,i));
%let numvars=%sysfunc(attrn(&dsid,NVARS));

data v00_s&k.05 (keep=HHID00 H00S_P1-H00S_P50 H00SPSUM H00SPCNT H00SPAVG);
     set v00_s&k.04;

     length H00S_P1-H00S_P50 8.;

     array rvars(2:&numvars) RVAR2-RVAR&numvars;
     array path(1:50) H00S_P1-H00S_P50;

     do j=1 to 50;
                  path(j)=0;
     end;

     H00SPSUM=0;
     H00SPCNT=0;
     H00SPAVG=0;

     do i=2 to &numvars;

        do l=1 to 49;
                    if rvars(i)=l then path(l)=path(l)+1;
        end;

        if rvars(i) >= 50 then H00S_P50=H00S_P50+1;

        if rvars(i) ^in (.,0) then H00SPCNT=H00SPCNT+1;

     end;

     H00SPSUM=SUM(of RVAR2-RVAR&numvars);

     if H00SPCNT^=0 then H00SPAVG=H00SPSUM/H00SPCNT;

run;

%let dsc=%sysfunc(close(&dsid));

%end;

%mend count_4;

%count_4 (numvill=51);



** Append all village files into a single file: sibling pathlength **;

data allvillsp&f.01;
     input HHID00 H00S_P1-H00S_P50 H00SPSUM H00SPCNT H00SPAVG;
     datalines;
;
run;

%macro compile4(numvill=);

%do i=1 %to &numvill;

    proc append base=allvillsp&f.01 data=v00_s&i.05;
    run;

%end;

%mend compile4;

%compile4(numvill=51);

*******************************************
** Merge Degree and Pathlength Variables **
*******************************************;

proc sort data=allvillrg&f.01 out=allvillrg&f.02;
     by HHID00;
run;

proc sort data=allvillsg&f.01 out=allvillsg&f.02;
     by HHID00;
run;

proc sort data=allvillrp&f.01 out=allvillrp&f.02;
     by HHID00;
run;

proc sort data=allvillsp&f.01 out=allvillsp&f.02;
     by HHID00;
run;

data all&f.01;
     merge allvillrg&f.02
           allvillsg&f.02
           allvillrp&f.02
           allvillsp&f.02;
     by HHID00;
run;

** add village 84 variable to file **;

data vill_id_fix&f.01 (drop=HHID00C);
     set in&f.1.indiv00 (keep=V84 HHID00 rename=(HHID00=HHID00C));
     HHID00=input(HHID00C, best12.);
run;

proc sort data=vill_id_fix&f.01 out=vill_id_fix&f.02 nodupkey;
     by HHID00 v84;
run;

data vill_id_fix&f.03;
     merge all&f.01 (in=a)
           vill_id_fix&f.02 (in=b);
     by HHID00;

     if a=1 and b=1 then output;
run;

proc sort data=vill_id_fix&f.03 out=all&f.02;
     by V84 HHID00;
run;

data out&f.1.c2_00_08;
     set all&f.02;
run;
