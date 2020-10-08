*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_10.sas
**     Programmer: james r. hull
**     Start Date: 2009 August 15
**     Purpose:
**        1.) Generate Tables for Chapter 2 - Add'l Village Network Vars
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

%let f=10;   ** Allows for greater file portability **;
%let y=94;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_07.xpt';
libname in&y.&f.02 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_09.xpt';
libname in&y.&f.03 xport '/nangrong/data_sas/1994/current/indiv94.05';

libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_10.xpt';

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01;
    set in&y.&f.02.c2_&y._09 (drop=H&y.R_P1 H&y.R_P2 H&y.R_P3 H&y.R_P4 H&y.R_P5
                                  H&y.R_P6 H&y.R_P7 H&y.R_P8 H&y.R_P9 H&y.R_P10
                                  H&y.R_P11
                                  H&y.S_P1 H&y.S_P2 H&y.S_P3 H&y.S_P4 H&y.S_P5
                                  H&y.S_P6 H&y.S_P7 H&y.S_P8 H&y.S_P9 H&y.S_P10
                                  H&y.S_P11 H&y.S_P12 H&y.S_P13 H&y.S_P14 H&y.S_P15
                                  H&y.S_P16 H_T:
                            );
run;



proc sort data=work&y.&f.01 out=work&y.&f.02;
     by HHID&y;
run;

data work&y.&f.03 (keep=HHID&y V84);
     set in&y.&f.03.indiv&y;
run;

proc sort data=work&y.&f.03 out=work&y.&f.04 nodupkey;
     by HHID&y;
run;

data work&y.&f.05;
     merge work&y.&f.02 (in=a)
           work&y.&f.04 (in=b);
     by HHID&y;
     if a=1 and b=1 then output;
run;

proc sort data=work&y.&f.05 out=work&y.&f.06;
     by V84;
run;

data work&y.&f.07 (keep=V84 P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y NUMHHR&y
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.06(keep=V84 H&y.RPAVG H&y.RPCNT H&y.SPAVG H&y.SPCNT
                           H_ANY_PD H_ANY_FR H_ANY_IN H_ANY_OT
                           HG_RSR&y HG_RSS&y);
     by V84;

     retain P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y NUMHHR&y
            H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y;


     if first.V84 then do;
                         P_RSUM&y=0;
                         R_RSUM&y=0;
                         P_SSUM&y=0;
                         R_SSUM&y=0;
                         NUMHHR&y=0;
                         H_SUM_PD=0;
                         H_SUM_FR=0;
                         H_SUM_IN=0;
                         H_SUM_OT=0;
                         HGSUMR&y=0;
                         HGSUMS&y=0;
                       end;

     P_RSUM&y=P_RSUM&y+H&y.RPAVG;
     R_RSUM&y=R_RSUM&y+H&y.RPCNT;
     P_SSUM&y=P_SSUM&y+H&y.SPAVG;
     R_SSUM&y=R_SSUM&y+H&y.SPCNT;
     H_SUM_PD=H_SUM_PD+H_ANY_PD;
     H_SUM_FR=H_SUM_FR+H_ANY_FR;
     H_SUM_IN=H_SUM_IN+H_ANY_IN;
     H_SUM_OT=H_SUM_OT+H_ANY_OT;
     HGSUMR&y=HGSUMR&y+HG_RSR&y;
     HGSUMS&y=HGSUMS&y+HG_RSS&y;

     NUMHHR&y=NUMHHR&y+1;

if last.V84 then output;

run;


proc sort data=work&y.&f.03 out=work&y.&f.08 nodupkey;
     by HHID&y;
run;

proc sort data=work&y.&f.08 out=work&y.&f.09;
     by V84;
run;

data work&y.&f.10 (keep=V84 NUMHHV&y);
     set work&y.&f.09;

     by V84;

     retain NUMHHV&y;

     if first.V84 then do;
                         NUMHHV&y=0;
                       end;

     NUMHHV&y=NUMHHV&y+1;

     if last.V84 then output;
run;

data work&y.&f.11;
     merge work&y.&f.07 (in=a)
           work&y.&f.10 (in=b);
     by V84;
     if a=1 and b=1 then output;
run;

data work&y.&f.12 (drop=P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y V84C
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.11 (rename=(V84=V84C));

     MPRNSR&y=R_RSUM&y/NUMHHV&y;
     MRRNSR&y=P_RSUM&y/NUMHHV&y;
     MRSNSR&y=P_SSUM&y/NUMHHV&y;
     MPSNSR&y=R_SSUM&y/NUMHHV&y;
     MPDDIC&y=H_SUM_PD/NUMHHV&y;
     MFRDIC&y=H_SUM_FR/NUMHHV&y;
     MINDIC&y=H_SUM_IN/NUMHHV&y;
     MOTDIC&y=H_SUM_OT/NUMHHV&y;
     MGNNSR&y=HGSUMR&y/NUMHHV&y;
     MGNNSS&y=HGSUMS&y/NUMHHV&y;

     PROPRH&y=NUMHHR&y/NUMHHV&y;

     V84=input(V84C,2.0);
run;

data work&y.&f.13;
     merge work&y.&f.12 (in=a)
           in&y.&f.01.c2_&y._07 (in=b);
     by V84;
     if a=1 and b=1 then output;
run;


*********************************************
**  Descriptive Analysis - Village Level   **
*********************************************;


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


%allcorr(dsn=work&y.&f.13, primevar=PROPRH&y);
%allcorr(dsn=work&y.&f.13, primevar=NUMHHV&y);
%allcorr(dsn=work&y.&f.13, primevar=NUMHHR&y);


%allcorr(dsn=work&y.&f.13, primevar=MPRNSR&y);
%allcorr(dsn=work&y.&f.13, primevar=MRRNSR&y);
%allcorr(dsn=work&y.&f.13, primevar=MPSNSR&y);
%allcorr(dsn=work&y.&f.13, primevar=MRSNSR&y);


** output dataset  **;

data ot&y.&f.01.c2_&y._10;
     set work&y.&f.13;
run;
