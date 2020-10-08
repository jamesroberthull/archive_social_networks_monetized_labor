*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_11.sas
**     Programmer: james r. hull
**     Start Date: 2009 August 27
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

%let f=11;   ** Allows for greater file portability **;
%let y=00;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_09.xpt';

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01;
     set in&y.&f.01.c2_&y._09 (drop=H&y.R_P1 H&y.R_P2 H&y.R_P3 H&y.R_P4 H&y.R_P5
                                    H&y.R_P6 H&y.R_P7 H&y.R_P8 H&y.R_P9 H&y.R_P10
                                    H&y.R_P11
                                    H&y.S_P1 H&y.S_P2 H&y.S_P3 H&y.S_P4 H&y.S_P5
                                    H&y.S_P6 H&y.S_P7 H&y.S_P8 H&y.S_P9 H&y.S_P10
                                    H&y.S_P11 H&y.S_P12 H&y.S_P13 H&y.S_P14 H&y.S_P15
                                    H&y.S_P16 H_T:
                            );
run;

*********************************************
**  Descriptive Analysis - Household Level **
*********************************************;

** Macro - produces t-tests for all variables in dataset by a given grouping variable **;

%macro alltest(dsn=,primevar=);

  %* dsn = name of dataset to use **;
  %* primevar = name of variable that defines groups for all t-tests **;

  %let dsid = %sysfunc(open(&dsn, I));
  %let numvars=%sysfunc(attrn(&dsid,NVARS));
  %do i = 1 %to &numvars;
      %let varname=%sysfunc(varname(&dsid,&i));
      %let varnum=%sysfunc(varnum(&dsid,&varname));
      %let vartype=%sysfunc(vartype(&dsid,&varnum));

      %if &vartype=N %then %do;

                             proc univariate data=&dsn;
                                  var &varname;
                             run;

                             proc univariate data=&dsn;
                                  var &varname;
                                  class &primevar;
                             run;

                           /*  proc multtest data=&dsn bon hoc hom sid pvals;
                                  class &primevar;
                                  test mean(&varname);
                             run; */


                           %end;
  %end;
  %let rc = %sysfunc(close(&dsid));

%mend alltest;


** Household level univariate statistics and t-tests **;

proc multtest data=work&y.&f.01 bon hoc hom sid pvals;
     class H_ANY_PD;
     test mean(HG_RSR&y HG_RIR&y HG_ROR&y HG_RSS&y HG_RIS&y HG_ROS&y
               H&y.RPCNT H&y.RPAVG H&y.SPCNT H&y.SPAVG
               );

run;

%alltest(dsn=work&y.&f.01, primevar=H_ANY_PD);

