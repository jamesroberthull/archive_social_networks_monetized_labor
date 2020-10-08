*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_13.sas
**     Programmer: james r. hull
**     Start Date: 2009 September 9
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

%let f=13;   ** Allows for greater file portability **;
%let y=00;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_10.xpt';
libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_13.xpt';

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01;
     set in&y.&f.01.c2_&y._10;
run;

proc corr data=work&y.&f.01;
     var  VH_PR_PD VH_PR_FR VH_PR_OT VH_PR_IN;
     with NUMHHV&y NUMHHR&y PROPRH&y
          MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.01;
     var VH_PR_PD VH_PR_FR VH_PR_OT VH_PR_IN
         NUMHHV&y NUMHHR&y PROPRH&y
         MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
         MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
         ;
run;


data ot&y.&f.01.c2_&y._&f;
     set work&y.&f.01 (keep=VH_PR_PD VH_PR_FR VH_PR_OT VH_PR_IN
                            NUMHHV&y NUMHHR&y PROPRH&y
                            MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
                            MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
                            );
run;
