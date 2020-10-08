*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_07.sas
**     Programmer: james r. hull
**     Start Date: 2009 July 21
**     Purpose:
**        1.) Generate Tables for Chapter 2 - Village Network Vars
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

%let f=00_7;   ** Allows for greater file portability **;


**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_02.xpt';
libname in&f.2 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_03.xpt';

libname ot&f.1 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_07.xpt';


****************************************
**  Bring in Network Data from UCINET **
****************************************;

proc import datafile='/afs/isis.unc.edu/home/j/r/jrhull/a_data/Village_Vars_00.txt' out=work&f.01 dbms=tab replace;
     getnames=yes;
     datarow=2;
run;


*******************************************
**  Bring in village-level on rice labor **
*******************************************;

data work&f.02 (drop=V84);
     set in&f.1.c2_00_02;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

data work&f.03 (drop=V84);
     set in&f.2.c2_00_03;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

 data work&f.04;
     merge work&f.01
           work&f.02 (rename=(V84N=V84))
           work&f.03 (rename=(V84N=V84));
     by V84;
run;

data work&f.05 (drop=V_NUM_T1 V_NUM_P1 V_NUM_F1 V_PRO_P1 V_PRO_F1
                     V_NUM_T4 V_NUM_P4 V_NUM_F4 V_PRO_P4 V_PRO_F4
                     V_NUM_T5 V_NUM_P5 V_NUM_F5 V_PRO_P5 V_PRO_F5
                     V_NUM_T6 V_NUM_P6 V_NUM_F6 V_PRO_P6 V_PRO_F6
                     V_NUM_T8 V_NUM_P8 V_NUM_F8 V_PRO_P8 V_PRO_F8
                     V_NUM_T9 V_NUM_P9 V_NUM_F9 V_PRO_P9 V_PRO_F9
                     );
     set work&f.04;

     /* if V84 ne 29; */     ** This case is an outlier on some proportion var's, but not key var's used in ch2 **;

run;

** Output dataset so that it can also be used in STATA **;

data ot&f.1.c2_00_07;
     set work&f.05;
run;


*******************************************
**  Descriptive Analysis - Village Level **
*******************************************;

** Macro - produces pairwise correlations for all numeric variables against a single variable **;

%macro allcorr(dsn=,primevar=);

  %* dsn = name of dataset to use **;
  %* primevar = name of variable to pair with all other numeric vars **;

  %let dsid = %sysfunc(open(&dsn, I));
  %let numvars=%sysfunc(attrn(&dsid,NVARS));
  %do i = 1 %to &numvars;
      %let varname=%sysfunc(varname(&dsid,&i));
      %let varnum=%sysfunc(varnum(&dsid,&varname));
      %let vartype=%sysfunc(vartype(&dsid,&varnum));

      %if &vartype=N %then %do;
                               proc corr data=&dsn;
                                    var &primevar &varname;
                               run;
                           %end;
  %end;
  %let rc = %sysfunc(close(&dsid));

%mend allcorr;


** Descriptive Statistics for All Village Variables **;

proc means data=work&f.05;
run;


** correlations with central variables of interest - village level **;

   %allcorr(dsn=work&f.05, primevar=v_pro_pd);
   %allcorr(dsn=work&f.05, primevar=vh_pr_pd);

   %allcorr(dsn=work&f.05, primevar=v_pro_fr);
   %allcorr(dsn=work&f.05, primevar=vh_pr_fr);

   %allcorr(dsn=work&f.05, primevar=v_pro_ot);
   %allcorr(dsn=work&f.05, primevar=vh_pr_ot);

   %allcorr(dsn=work&f.05, primevar=v_pro_in);
   %allcorr(dsn=work&f.05, primevar=vh_pr_in);

run;
