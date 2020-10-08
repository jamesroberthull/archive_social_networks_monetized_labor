*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_12.sas
**     Programmer: james r. hull
**     Start Date: 2009 September 9
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

%let f=12;   ** Allows for greater file portability **;
%let y=94;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_09.xpt';
libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_12.xpt';



********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01;
     set in&y.&f.01.c2_&y._09;

     if H_TOT_P >= 1 and H_TOT_F >= 1 then H_PF_11=1;
        else H_PF_11=0;
     if H_TOT_P >= 1 and H_TOT_F = 0 then H_PF_10=1;
        else H_PF_10=0;
     if H_TOT_P = 0 and H_TOT_F >= 1 then H_PF_01=1;
        else H_PF_01=0;
     if H_TOT_P =0 and H_TOT_F = 0 then H_PF_00=1;
        else H_PF_00=0;

     if H_TOT_OT >= 1 and H_TOT_IN >= 1 then H_OI_11=1;
        else H_OI_11=0;
     if H_TOT_OT >= 1 and H_TOT_IN = 0 then H_OI_10=1;
        else H_OI_10=0;
     if H_TOT_OT = 0 and H_TOT_IN >= 1 then H_OI_01=1;
        else H_OI_01=0;
     if H_TOT_OT =0 and H_TOT_IN = 0 then H_OI_00=1;
        else H_OI_00=0;

run;

proc freq data=work&y.&f.01;
     tables H_PF_11 H_PF_10 H_PF_01 H_PF_00;
     tables H_OI_11 H_OI_10 H_OI_01 H_OI_00;
run;

proc corr data=work&y.&f.01;
     var  H_PF_00 H_PF_01 H_PF_11 H_PF_10;
     with H_OI_00 H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;

proc corr data=work&y.&f.01;
     var  H_PF_00 H_PF_01 H_PF_11 H_PF_10
          H_OI_00 H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;


data ot&y.&f.01.c2_&y._&f;
     set work&y.&f.01 (keep=H_PF_00 H_PF_01 H_PF_11 H_PF_10
                       H_OI_00 H_OI_01 H_OI_11 H_OI_10
                       HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
                       HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG);
run;
