********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_15.sas
**     Programmer: james r. hull
**     Start Date: 2009 11 19
**     Purpose:
**        1.) Revised Analysis for Chapter 2 - corrects at risk population
**     Input Data:
**        1.) RAW DATA
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_00_15.xpt
**
**      NOTES: This dataset is a compilation of all previous datasets, w/ changes
**             THIS CODE RE-RUNS FINAL ANALYSIS USING ALL RICE-GROWING HOUSEHOLDS
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

%let f=15;   ** Allows for greater file portability **;
%let y=00;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/nangrong/data_sas/2000/current/hh00.04';
libname in&y.&f.02 xport '/nangrong/data_sas/2000/current/plots00.02';
libname in&y.&f.03 xport '/nangrong/data_sas/2000/current/indiv00.04';

libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_0002C.xpt';
libname ot&y.&f.02 xport '/trainee/jrhull/diss/ch2/c2data/c2_0003C.xpt';
libname ot&y.&f.03 xport '/trainee/jrhull/diss/ch2/c2data/c2_00HHC.xpt';
libname ot&y.&f.04 xport '/trainee/jrhull/diss/ch2/c2data/c2_0007C.xpt';
libname ot&y.&f.05 xport '/trainee/jrhull/diss/ch2/c2data/c2_0008C.xpt';
libname ot&y.&f.06 xport '/trainee/jrhull/diss/ch2/c2data/c2_0009C.xpt';
libname ot&y.&f.07 xport '/trainee/jrhull/diss/ch2/c2data/c2_0010C.xpt';
libname ot&y.&f.08 xport '/trainee/jrhull/diss/ch2/c2data/c2_0012C.xpt';
libname ot&y.&f.09 xport '/trainee/jrhull/diss/ch2/c2data/c2_0013C.xpt';


*c2_00_02*****VILL***************************************************************************************;
*********************************************************************************************************;

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01_1;
     set in&y.&f.01.hh00 (keep=HHID00 X6_84C: X6_84W:);
     keep HHID00 X6_86L X6_86N X6_86W LOCATION;

     length X6_86L $ 10;

     array a(1:7) X6_84C1-X6_84C7;
     array b(1:7) X6_84W1-X6_84W7;

     do i=1 to 7;
          X6_86L=a(i);
          X6_86N=1;
          X6_86W=b(i);
          LOCATION=9;
          if a(i) ne " " then output;  * Keep only those cases with data *;
     end;
run;

data work&y.&f.02_1;
     set in&y.&f.01.hh00 (keep=HHID00 X6_85H: X6_85N: X6_85W:);
     keep HHID00 X6_86L X6_86N X6_86W LOCATION;

     length X6_86L $ 10;

     array a(1:13) X6_85H1-X6_85H13;
     array b(1:13) X6_85N1-X6_85N13;
     array c(1:13) X6_85W1-X6_85W13;

     do i=1 to 13;
          X6_86L=a(i);
          X6_86N=b(i);
          X6_86W=c(i);
          if a(i)="9999999999" then LOCATION=8;
             else if substr(a(i),8,3)=999 then LOCATION=1;
             else LOCATION=0;
          if a(i) ne " " then output;  * Keep only those cases with data *;
     end;

run;

data work&y.&f.03_1;
     set in&y.&f.01.hh00 (keep=HHID00 X6_86L: X6_86N: X6_86W:);
     keep HHID00 X6_86L X6_86N X6_86W LOCATION;

     length X6_86L $ 10;

     array a(1:10) X6_86L1-X6_86L10;
     array b(1:10) X6_86N1-X6_86N10;
     array c(1:10) X6_86W1-X6_86W10;

     do i=1 to 10;
          X6_86L=a(i);
          X6_86N=b(i);
          X6_86W=c(i);
          if a(i)="9999999" then LOCATION=8;
             else if substr(a(i),1,1)=5 then LOCATION=6;
             else if substr(a(i),1,1)=4 then LOCATION=5;
             else if substr(a(i),1,2)=39 then LOCATION=3;
             else LOCATION=4;
          if a(i) ne " " then output;  * Keep only those cases with data *;
     end;
run;

 *********************************************************
 ** Take Care of Missing Data Issues - Recodes at least **
 *********************************************************;

data work&y.&f.01_2;
     set work&y.&f.01_1;

     if X6_86W=9 then X6_86W=.;
run;

data work&y.&f.02_2;
     set work&y.&f.02_1;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86N=1; * Assume at least 1 person worked *;
run;

data work&y.&f.03_2;
     set work&y.&f.03_1;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86N=1; * Assume at least 1 person worked *;
run;


**************************
** Merge files together **
**************************;

data work&y.&f.03;
     set work&y.&f.01_2
         work&y.&f.02_2
         work&y.&f.03_2;
run;

***************************************************************************
** Add V84 identifiers to 2000 data file as per Rick's suggestion on web **
***************************************************************************;

proc sort data=work&y.&f.03 out=work&y.&f.04;
     by HHID00 X6_86L LOCATION;
run;

data work&y.&f.01vill;
     set in&y.&f.03.indiv00;
     keep HHID00 V84;
run;

proc sort data=work&y.&f.01vill out=work&y.&f.02vill nodupkey;
     by HHID00 v84;
run;

data work&y.&f.03vill;
     merge work&y.&f.04 (in=a)
           work&y.&f.02vill (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=work&y.&f.03vill out=work&y.&f.05;
     by V84;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 7 cases (a case here is a helper group)        **
******************************************************************************;

data work&y.&f.06;
     set work&y.&f.05;

     if X6_86W ne . then output;

     if LOCATION ^= 9; ** DROPS ALL HHs BUT THOSE THAT USED NON-CODE 2&3 EXTRA LABOR **;
run;

***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** 2/15/09: I collapsed categories in 2000 0/1 ->1 3/4 -> 4 **;
** Category 7 had no cases in either year **;

* Location=1 *;

data work&y.&f.07_1 (keep=V84 V_NUM_T1 V_NUM_P1 V_NUM_F1);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T1 V_NUM_P1 V_NUM_F1 0;

  if first.V84 then do;
                          V_NUM_T1=0;
                          V_NUM_P1=0;
                          V_NUM_F1=0;
                       end;

  if LOCATION in (0,1) then do;
                        V_NUM_T1=V_NUM_T1+X6_86N;
                        if X6_86W=1 then V_NUM_P1=V_NUM_P1+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F1=V_NUM_F1+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_1;                                          * Create Proportion Variable *;
     set work&y.&f.07_1;

     V_PRO_P1=ROUND(V_NUM_P1/(V_NUM_T1+0.0000001),.0001);
     V_PRO_F1=ROUND(V_NUM_F1/(V_NUM_T1+0.0000001),.0001);

     if V_NUM_T1=0 then do;
                           V_NUM_T1=".";
                           V_NUM_P1=".";
                           V_NUM_F1=".";
                           V_PRO_P1=".";
                           V_PRO_F1=".";
                        end;

run;


* Location=4 *;

data work&y.&f.07_4 (keep=V84 V_NUM_T4 V_NUM_P4 V_NUM_F4);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T4 V_NUM_P4 V_NUM_F4 0;

  if first.V84 then do;
                          V_NUM_T4=0;
                          V_NUM_P4=0;
                          V_NUM_F4=0;
                       end;

  if LOCATION in (3,4) then do;
                        V_NUM_T4=V_NUM_T4+X6_86N;
                        if X6_86W=1 then V_NUM_P4=V_NUM_P4+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F4=V_NUM_F4+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_4;                                          * Create Proportion Variable *;
     set work&y.&f.07_4;

     V_PRO_P4=ROUND(V_NUM_P4/(V_NUM_T4+0.0000001),.0001);
     V_PRO_F4=ROUND(V_NUM_F4/(V_NUM_T4+0.0000001),.0001);

     if V_NUM_T4=0 then do;
                           V_NUM_T4=".";
                           V_NUM_P4=".";
                           V_NUM_F4=".";
                           V_PRO_P4=".";
                           V_PRO_F4=".";
                        end;

run;


* Location=5 *;

data work&y.&f.07_5 (keep=V84 V_NUM_T5 V_NUM_P5 V_NUM_F5);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T5 V_NUM_P5 V_NUM_F5 0;

  if first.V84 then do;
                          V_NUM_T5=0;
                          V_NUM_P5=0;
                          V_NUM_F5=0;
                       end;

  if LOCATION=5 then do;
                        V_NUM_T5=V_NUM_T5+X6_86N;
                        if X6_86W=1 then V_NUM_P5=V_NUM_P5+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F5=V_NUM_F5+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_5;                                          * Create Proportion Variable *;
     set work&y.&f.07_5;

     V_PRO_P5=ROUND(V_NUM_P5/(V_NUM_T5+0.0000001),.0001);
     V_PRO_F5=ROUND(V_NUM_F5/(V_NUM_T5+0.0000001),.0001);

     if V_NUM_T5=0 then do;
                           V_NUM_T5=".";
                           V_NUM_P5=".";
                           V_NUM_F5=".";
                           V_PRO_P5=".";
                           V_PRO_F5=".";
                        end;

run;


* Location=6 *;

data work&y.&f.07_6 (keep=V84 V_NUM_T6 V_NUM_P6 V_NUM_F6);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T6 V_NUM_P6 V_NUM_F6 0;

  if first.V84 then do;
                          V_NUM_T6=0;
                          V_NUM_P6=0;
                          V_NUM_F6=0;
                       end;

  if LOCATION=6 then do;
                        V_NUM_T6=V_NUM_T6+X6_86N;
                        if X6_86W=1 then V_NUM_P6=V_NUM_P6+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F6=V_NUM_F6+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_6;                                          * Create Proportion Variable *;
     set work&y.&f.07_6;

     V_PRO_P6=ROUND(V_NUM_P6/(V_NUM_T6+0.0000001),.0001);
     V_PRO_F6=ROUND(V_NUM_F6/(V_NUM_T6+0.0000001),.0001);

     if V_NUM_T6=0 then do;
                           V_NUM_T6=".";
                           V_NUM_P6=".";
                           V_NUM_F6=".";
                           V_PRO_P6=".";
                           V_PRO_F6=".";
                        end;

run;

* Location=8 *;

data work&y.&f.07_8 (keep=V84 V_NUM_T8 V_NUM_P8 V_NUM_F8);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T8 V_NUM_P8 V_NUM_F8 0;

  if first.V84 then do;
                          V_NUM_T8=0;
                          V_NUM_P8=0;
                          V_NUM_F8=0;
                       end;

  if LOCATION=8 then do;
                        V_NUM_T8=V_NUM_T8+X6_86N;
                        if X6_86W=1 then V_NUM_P8=V_NUM_P8+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F8=V_NUM_F8+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_8;                                          * Create Proportion Variable *;
     set work&y.&f.07_8;

     V_PRO_P8=ROUND(V_NUM_P8/(V_NUM_T8+0.0000001),.0001);
     V_PRO_F8=ROUND(V_NUM_P8/(V_NUM_T8+0.0000001),.0001);

     if V_NUM_T8=0 then do;
                           V_NUM_T8=".";
                           V_NUM_P8=".";
                           V_NUM_F8=".";
                           V_PRO_P8=".";
                           V_PRO_F8=".";
                        end;

run;

* Location=9 *;

data work&y.&f.07_9 (keep=V84 V_NUM_T9 V_NUM_P9 V_NUM_F9);  * Collapse into Villages *;
     set work&y.&f.06 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T9 V_NUM_P9 V_NUM_F9 0;

  if first.V84 then do;
                          V_NUM_T9=0;
                          V_NUM_P9=0;
                          V_NUM_F9=0;
                       end;

  if LOCATION=9 then do;
                        V_NUM_T9=V_NUM_T9+X6_86N;
                        if X6_86W=1 then V_NUM_P9=V_NUM_P9+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F9=V_NUM_F9+X6_86N;
                     end;

  if last.V84 then output;

run;

data work&y.&f.08_9;                                          * Create Proportion Variable *;
     set work&y.&f.07_9;

     V_PRO_P9=ROUND(V_NUM_P9/(V_NUM_T9+0.0000001),.0001);
     V_PRO_F9=ROUND(V_NUM_F9/(V_NUM_T9+0.0000001),.0001);

     if V_NUM_T9=0 then do;
                           V_NUM_T9=".";
                           V_NUM_P9=".";
                           V_NUM_F9=".";
                           V_PRO_P9=".";
                           V_PRO_F9=".";
                        end;

run;

*****************************************************************
**  Merge all separate village files together, number cases=51 **
*****************************************************************;

data work&y.&f.09;
     merge work&y.&f.08_1
           work&y.&f.08_4
           work&y.&f.08_5
           work&y.&f.08_6
           work&y.&f.08_8
           work&y.&f.08_9;
     by V84;
run;

proc sort data=work&y.&f.06 out=work&y.&f.10;
     by X6_86W HHID00;
run;

** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

data work&y.&f.11 (drop=ZIPPO);
     set work&y.&f.09;
     ZIPPO=0;
     V_TOT_T=sum(of V_NUM_T1 V_NUM_T4 V_NUM_T5 V_NUM_T6 ZIPPO);
     V_TOT_P=sum(of V_NUM_P1 V_NUM_P4 V_NUM_P5 V_NUM_P6 ZIPPO);
     V_TOT_F=sum(of V_NUM_F1 V_NUM_F4 V_NUM_F5 V_NUM_F6 ZIPPO);
     V_TOT_IN=sum(of V_NUM_T1 ZIPPO);
     V_TOT_OT=sum(of V_NUM_T4 V_NUM_T5 V_NUM_T6 ZIPPO);

     V_PRO_PD=ROUND(V_TOT_P/(V_TOT_T+0.0000001),.0001);
     V_PRO_FR=ROUND(V_TOT_F/(V_TOT_T+0.0000001),.0001);
     V_PRO_IN=ROUND(V_TOT_IN/(V_TOT_T+0.0000001),.0001);
     V_PRO_OT=ROUND(V_TOT_OT/(V_TOT_T+0.0000001),.0001);

run;

data ot&y.&f.01.c2_&y.02C;
     set work&y.&f.11;
run;


***c2_00_03***VILL***HH*****************************************************************************;
****************************************************************************************************;


proc sort data=work&y.&f.03vill out=work&y.&f.12;
     by HHID00;                            ** NOTE THAT SORT IS NOW BY HHID00 **;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 7 cases (a case here is a helper group)        **
******************************************************************************;

data work&y.&f.13;
     set work&y.&f.12;

     if X6_86W ne . then output;
run;

***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** 2/15/09: I collapsed categories in 2000 0/1 ->1 3/4 -> 4 **;
** Category 7 had no cases in either year **;

* Location=1 *;

data work&y.&f.14_1 (keep=HHID00 H_NUM_T1 H_NUM_P1 H_NUM_F1);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T1 H_NUM_P1 H_NUM_F1 0;

  if first.HHID00 then do;
                          H_NUM_T1=0;
                          H_NUM_P1=0;
                          H_NUM_F1=0;
                       end;

  if LOCATION in (0,1) then do;
                        H_NUM_T1=H_NUM_T1+X6_86N;
                        if X6_86W=1 then H_NUM_P1=H_NUM_P1+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F1=H_NUM_F1+X6_86N;
                     end;

  if last.HHID00 then output;

run;

data work&y.&f.15_1;                                          * Create Proportion Variable *;
     set work&y.&f.14_1;

     H_PRO_P1=ROUND(H_NUM_P1/(H_NUM_T1+0.0000001),.0001);
     H_PRO_F1=ROUND(H_NUM_F1/(H_NUM_T1+0.0000001),.0001);

     if H_NUM_T1=0 then do;
                           H_NUM_T1=.;
                           H_NUM_P1=.;
                           H_NUM_F1=.;
                           H_PRO_P1=.;
                           H_PRO_F1=.;
                        end;

run;

* Location=4 *;

data work&y.&f.14_4 (keep=HHID00 H_NUM_T4 H_NUM_P4 H_NUM_F4);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T4 H_NUM_P4 H_NUM_F4 0;

  if first.HHID00 then do;
                          H_NUM_T4=0;
                          H_NUM_P4=0;
                          H_NUM_F4=0;
                       end;

  if LOCATION in (3,4) then do;
                        H_NUM_T4=H_NUM_T4+X6_86N;
                        if X6_86W=1 then H_NUM_P4=H_NUM_P4+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F4=H_NUM_F4+X6_86N;
                     end;

  if last.HHID00 then output;

run;

data work&y.&f.15_4;                                          * Create Proportion Variable *;
     set work&y.&f.14_4;

     H_PRO_P4=ROUND(H_NUM_P4/(H_NUM_T4+0.0000001),.0001);
     H_PRO_F4=ROUND(H_NUM_F4/(H_NUM_T4+0.0000001),.0001);

     if H_NUM_T4=0 then do;
                           H_NUM_T4=.;
                           H_NUM_P4=.;
                           H_NUM_F4=.;
                           H_PRO_P4=.;
                           H_PRO_F4=.;
                        end;

run;


* Location=5 *;

data work&y.&f.14_5 (keep=HHID00 H_NUM_T5 H_NUM_P5 H_NUM_F5);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T5 H_NUM_P5 H_NUM_F5 0;

  if first.HHID00 then do;
                          H_NUM_T5=0;
                          H_NUM_P5=0;
                          H_NUM_F5=0;
                       end;

  if LOCATION=5 then do;
                        H_NUM_T5=H_NUM_T5+X6_86N;
                        if X6_86W=1 then H_NUM_P5=H_NUM_P5+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F5=H_NUM_F5+X6_86N;
                     end;

  if last.HHID00 then output;

run;

data work&y.&f.15_5;                                          * Create Proportion Variable *;
     set work&y.&f.14_5;

     H_PRO_P5=ROUND(H_NUM_P5/(H_NUM_T5+0.0000001),.0001);
     H_PRO_F5=ROUND(H_NUM_F5/(H_NUM_T5+0.0000001),.0001);

     if H_NUM_T5=0 then do;
                           H_NUM_T5=.;
                           H_NUM_P5=.;
                           H_NUM_F5=.;
                           H_PRO_P5=.;
                           H_PRO_F5=.;
                        end;

run;


* Location=6 *;

data work&y.&f.14_6 (keep=HHID00 H_NUM_T6 H_NUM_P6 H_NUM_F6);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T6 H_NUM_P6 H_NUM_F6 0;

  if first.HHID00 then do;
                          H_NUM_T6=0;
                          H_NUM_P6=0;
                          H_NUM_F6=0;
                       end;

  if LOCATION=6 then do;
                        H_NUM_T6=H_NUM_T6+X6_86N;
                        if X6_86W=1 then H_NUM_P6=H_NUM_P6+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F6=H_NUM_F6+X6_86N;
                     end;

  if last.HHID00 then output;

run;

data work&y.&f.15_6;                                          * Create Proportion Variable *;
     set work&y.&f.14_6;

     H_PRO_P6=ROUND(H_NUM_P6/(H_NUM_T6+0.0000001),.0001);
     H_PRO_F6=ROUND(H_NUM_F6/(H_NUM_T6+0.0000001),.0001);

     if H_NUM_T6=0 then do;
                           H_NUM_T6=.;
                           H_NUM_P6=.;
                           H_NUM_F6=.;
                           H_PRO_P6=.;
                           H_PRO_F6=.;
                        end;

run;

* Location=8 *;

data work&y.&f.14_8 (keep=HHID00 H_NUM_T8 H_NUM_P8 H_NUM_F8);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T8 H_NUM_P8 H_NUM_F8 0;

  if first.HHID00 then do;
                          H_NUM_T8=0;
                          H_NUM_P8=0;
                          H_NUM_F8=0;
                       end;

  if LOCATION=8 then do;
                        H_NUM_T8=H_NUM_T8+X6_86N;
                        if X6_86W=1 then H_NUM_P8=H_NUM_P8+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F8=H_NUM_F8+X6_86N;
                     end;

  if last.HHID00 then output;

run;

data work&y.&f.15_8;                                          * Create Proportion Variable *;
     set work&y.&f.14_8;

     H_PRO_P8=ROUND(H_NUM_P8/(H_NUM_T8+0.0000001),.0001);
     H_PRO_F8=ROUND(H_NUM_F8/(H_NUM_T8+0.0000001),.0001);

     if H_NUM_T8=0 then do;
                           H_NUM_T8=.;
                           H_NUM_P8=.;
                           H_NUM_F8=.;
                           H_PRO_P8=.;
                           H_PRO_F8=.;
                        end;

run;

* Location=9 *;

data work&y.&f.14_9 (keep=HHID00 H_NUM_T9 H_NUM_P9 H_NUM_F9);  * Collapse into HHs *;
     set work&y.&f.13 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

     by HHID00;

  retain H_NUM_T9 H_NUM_P9 H_NUM_F9 0;

  if first.HHID00 then do;
                          H_NUM_T9=0;
                          H_NUM_P9=0;
                          H_NUM_F9=0;
                       end;

  if LOCATION=9 then do;
                        H_NUM_T9=H_NUM_T9+X6_86N;
                        if X6_86W=1 then H_NUM_P9=H_NUM_P9+X6_86N;
                        if X6_86W in (2,3) then H_NUM_F9=H_NUM_F9+X6_86N;
                     end;

  if last.HHID00 then output;

  label H_NUM_T9='Total Number Persons Helping';
  label H_NUM_P9='Total Number Persons Helping for Pay';
  label H_NUM_F9='Total Number Persons Helping for Free';

run;

data work&y.&f.15_9;                                          * Create Proportion Variable *;
     set work&y.&f.14_9;

     H_PRO_P9=ROUND(H_NUM_P9/(H_NUM_T9+0.0000001),.0001);
     H_PRO_F9=ROUND(H_NUM_F9/(H_NUM_T9+0.0000001),.0001);

     if H_NUM_T9=0 then do;
                           H_NUM_T9=.;
                           H_NUM_P9=.;
                           H_NUM_F9=.;
                           H_PRO_P9=.;
                           H_PRO_F9=.;
                        end;

run;

*******************************************************************
**  Merge all separate HH files together, number cases=4406      **
*******************************************************************;

data work&y.&f.16;
     merge work&y.&f.15_1
           work&y.&f.15_4
           work&y.&f.15_5
           work&y.&f.15_6
           work&y.&f.15_8
           work&y.&f.15_9;
     by HHID00;
run;

proc sort data=work&y.&f.13 out=work&y.&f.17;
     by X6_86W HHID00;
run;

** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

** After examining the data for 1994 and 2000, I found very few cases  **
** in which a household mixed payment strategies or labor sources, so  **
** the decision to recode these variables to dichotomous indicators    **
** 0,any seems a sensible way to simplify the data analysis. For the   **
** variable H_PRO_PD, roughly 4% in either year fell between 0 and 1,  **
** while for H_PRO_OT it was somewhere near 13% in either year. 3/10    **;

data work&y.&f.18 (drop=ZIPPO);
     set work&y.&f.16;
     ZIPPO=0;     ** SLICK TRICK TO TAKE CARE OF MISSING DATA **;
     H_TOT_T=sum(of H_NUM_T1 H_NUM_T4 H_NUM_T5 H_NUM_T6 ZIPPO);
     H_TOT_P=sum(of H_NUM_P1 H_NUM_P4 H_NUM_P5 H_NUM_P6 ZIPPO);
     H_TOT_F=sum(of H_NUM_F1 H_NUM_F4 H_NUM_F5 H_NUM_F6 ZIPPO);
     H_TOT_IN=sum(of H_NUM_T1 ZIPPO);
     H_TOT_OT=sum(of H_NUM_T4 H_NUM_T5 H_NUM_T6 ZIPPO);

     H_PRO_PD=ROUND(H_TOT_P/(H_TOT_T+0.0000001),.0001);
     H_PRO_IN=ROUND(H_TOT_IN/(H_TOT_T+0.0000001),.0001);
     H_PRO_OT=ROUND(H_TOT_OT/(H_TOT_T+0.0000001),.0001);
     H_PRO_FR=ROUND(H_TOT_F/(H_TOT_T+0.0000001),.0001);

      if H_TOT_P>0 then H_ANY_PD=1;
         else H_ANY_PD=0;
      if H_TOT_F>0 then H_ANY_FR=1;
         else H_ANY_FR=0;
      if H_TOT_IN>0 then H_ANY_IN=1;
         else H_ANY_IN=0;
      if H_TOT_OT>0 then H_ANY_OT=1;
         else H_ANY_OT=0;

      * if H_TOT_T>0; ** DROPS ALL HHs BUT THOSE THAT USED NON-CODE 2&3 EXTRA LABOR **;

 run;

**************************************************************
** Create Village Level Variables from Household Level Data **
**************************************************************;

proc sort data=work&y.&f.17 out=work&y.&f.19;
     by HHID00 V84;
run;

data work&y.&f.20 (keep=V84 HHID00 H_NUM_PD H_NUM_FR H_NUM_OT H_NUM_IN);
     set work&y.&f.19 (keep=V84 HHID00 LOCATION X6_86W);

     by HHID00;

     retain H_NUM_PD H_NUM_OT H_NUM_FR H_NUM_IN 0;

     if first.HHID00 then do;
                          H_NUM_PD=0;
                          H_NUM_FR=0;
                          H_NUM_OT=0;
                          H_NUM_IN=0;
                       end;

     ** Below excludes missing location cases AND CODE 2 & 3 LABOR **;

     if LOCATION ^in (8,9) then do;
                                  if X6_86W in (1) then H_NUM_PD=H_NUM_PD+1;
                                  if X6_86W in (2,3) then H_NUM_FR=H_NUM_FR+1;
                                  if LOCATION=1 then H_NUM_IN=H_NUM_IN+1;
                                  if LOCATION ^in (1,8) then H_NUM_OT=H_NUM_OT+1;
                                end;

     if last.HHID00 then output;

run;

proc sort data=work&y.&f.20 out=work&y.&f.21;
     by V84;
run;

data work&y.&f.22 (keep=V84 V_ANY_PD V_ANY_FR V_ANY_OT V_ANY_IN);
     set work&y.&f.21;

     by V84;

     retain V_ANY_PD V_ANY_OT V_ANY_FR V_ANY_IN 0;

     if first.V84 then do;
                          V_ANY_PD=0;
                          V_ANY_FR=0;
                          V_ANY_OT=0;
                          V_ANY_IN=0;
                       end;

     ** Below excludes missing location cases AND CODE 2 & 3 LABOR **;

     if H_NUM_PD > 0 then V_ANY_PD=V_ANY_PD+1;
     if H_NUM_FR > 0 then V_ANY_FR=V_ANY_FR+1;
     if H_NUM_OT > 0 then V_ANY_OT=V_ANY_OT+1;
     if H_NUM_IN > 0 then V_ANY_IN=V_ANY_IN+1;

     if last.V84 then output;

run;

***********************************************************************
** Create three variables to use as denominators: # HHs & # RICE HHs **
***********************************************************************;

** # HH in Village Variable **;

data work&y.&f.01hh;
     set in&y.&f.03.indiv00;
     keep HHID00 V84;
run;

proc sort data=work&y.&f.01hh out=work&y.&f.02hh nodupkey;
     by V84 HHID00;
run;

data work&y.&f.03hh (keep=V84 V_NUM_HH);
     set work&y.&f.02hh;

     by V84;

     retain V_NUM_HH 0;

     if first.V84 then V_NUM_HH=0;

     V_NUM_HH=V_NUM_HH+1;

    if last.V84 then output;

run;

** # Rice-Growing HHs in Village Variable **;

data work&y.&f.01rice;
     set in&y.&f.01.hh00 (keep=HHID00 RICE);
run;

proc sort data=work&y.&f.01rice out=work&y.&f.02rice;
     by HHID00;
run;

data work&y.&f.03rice;
     set in&y.&f.03.indiv00;
     keep HHID00 V84;
run;

proc sort data=work&y.&f.03rice  out=work&y.&f.04rice nodupkey;
     by HHID00 v84;
run;

data work&y.&f.05rice;
     merge work&y.&f.02rice (in=a)
           work&y.&f.04rice (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=work&y.&f.05rice out=work&y.&f.06rice;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data work&y.&f.07rice (keep=V84 V_NUM_RI);
     set work&y.&f.06rice;

     by V84;

     retain V_NUM_RI 0;

     if first.V84 then V_NUM_RI=0;

     if RICE=1 then V_NUM_RI=V_NUM_RI+1;

    if last.V84 then output;

run;

** # Rice-Growing HHs using EXTRA LABOR in Village Variable **;

data work&y.&f.01extra;
     set work&y.&f.18 (keep=HHID00 H_TOT_T);
run;

data work&y.&f.02extra;
     set in&y.&f.03.indiv00;
     keep HHID00 V84;
run;

proc sort data=work&y.&f.02extra  out=work&y.&f.03extra nodupkey;
     by HHID00 v84;
run;

data work&y.&f.04extra;
     merge work&y.&f.01extra (in=a)
           work&y.&f.03extra (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;


proc sort data=work&y.&f.04extra out=work&y.&f.05extra;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data work&y.&f.06extra (drop=H_TOT_T HHID00);
     set work&y.&f.05extra;

     by V84;

     retain V_NUM_EX 0;

     if first.V84 then V_NUM_EX=0;

     if H_TOT_T>0 then V_NUM_EX=V_NUM_EX+1;

    if last.V84 then output;

run;

data work&y.&f.23;
     merge work&y.&f.22
           work&y.&f.03hh
           work&y.&f.07rice
           work&y.&f.06extra;
     by V84;
run;

data work&y.&f.24;
     set work&y.&f.23;

     VH_PH_PD=V_ANY_PD/V_NUM_HH;
     VH_PH_FR=V_ANY_FR/V_NUM_HH;
     VH_PH_OT=V_ANY_OT/V_NUM_HH;
     VH_PH_IN=V_ANY_IN/V_NUM_HH;

     VH_PR_PD=V_ANY_PD/V_NUM_RI;
     VH_PR_FR=V_ANY_FR/V_NUM_RI;
     VH_PR_OT=V_ANY_OT/V_NUM_RI;
     VH_PR_IN=V_ANY_IN/V_NUM_RI;

     VH_PX_PD=V_ANY_PD/V_NUM_EX;
     VH_PX_FR=V_ANY_FR/V_NUM_EX;
     VH_PX_OT=V_ANY_OT/V_NUM_EX;
     VH_PX_IN=V_ANY_IN/V_NUM_EX;

run;

data work&y.&f.25;       ** Create traditional dichotomous measure for comparision **;
     set work&y.&f.24;

     if V_ANY_PD > 0 then V_PD_0_1=1;
     else V_PD_0_1=0;
run;

data ot&y.&f.02.c2_&y.03C;
     set work&y.&f.25;
run;

data ot&y&f.03.c2_&y.HHC;
     set work&y.&f.18;
run;


***c2_00_07*************************************************************************************************;
************************************************************************************************************;


****************************************
**  Bring in Network Data from UCINET **
****************************************;

proc import datafile='/afs/isis.unc.edu/home/j/r/jrhull/a_data/Village_Vars_00.txt' out=work&y.&f.26 dbms=tab replace;
     getnames=yes;
     datarow=2;
run;

*******************************************
**  Bring in village-level on rice labor **
*******************************************;

data work&y.&f.27 (drop=V84);
     set work&y.&f.11;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

data work&y.&f.28 (drop=V84);
     set work&y.&f.25;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

data work&y.&f.29;
     merge work&y.&f.26
           work&y.&f.27 (rename=(V84N=V84))
           work&y.&f.28 (rename=(V84N=V84));
     by V84;
run;

data work&y.&f.30 (drop=V_NUM_T1 V_NUM_P1 V_NUM_F1 V_PRO_P1 V_PRO_F1
                     V_NUM_T4 V_NUM_P4 V_NUM_F4 V_PRO_P4 V_PRO_F4
                     V_NUM_T5 V_NUM_P5 V_NUM_F5 V_PRO_P5 V_PRO_F5
                     V_NUM_T6 V_NUM_P6 V_NUM_F6 V_PRO_P6 V_PRO_F6
                     V_NUM_T8 V_NUM_P8 V_NUM_F8 V_PRO_P8 V_PRO_F8
                     V_NUM_T9 V_NUM_P9 V_NUM_F9 V_PRO_P9 V_PRO_F9
                     );
     set work&y.&f.29;

     /* if V84 ne 29; */     ** This case is an outlier on some proportion var's, but not key var's used in ch2 **;

run;

** Output dataset so that it can also be used in STATA **;

data ot&y.&f.04.c2_&y.07C;
     set work&y.&f.30;
run;


***c2_00_08*************************************************************************************************;
************************************************************************************************************;

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
     set in&y.&f.03.indiv00 (keep=V84 HHID00 rename=(HHID00=HHID00C));
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
     by HHID00;
run;

data ot&y.&f.05.c2_&y.08C;
     set all&f.02;
run;


**c2_00_09***********************************************************************************************;
*********************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.31 (drop=HHID&y.C);
     set work&y.&f.18 (rename=(HHID&y=HHID&y.C) drop=H_NUM_T4 H_NUM_P4 H_NUM_F4 H_PRO_P4 H_PRO_F4
                                   H_NUM_T5 H_NUM_P5 H_NUM_F5 H_PRO_P5 H_PRO_F5
                                   H_NUM_T6 H_NUM_P6 H_NUM_F6 H_PRO_P6 H_PRO_F6
                                   H_NUM_T8 H_NUM_P8 H_NUM_F8 H_PRO_P8 H_PRO_F8
                                   H_NUM_T9 H_NUM_P9 H_NUM_F9 H_PRO_P9 H_PRO_F9
                                   H_NUM_T1 H_NUM_P1 H_NUM_F1 H_PRO_P1 H_PRO_F1);

     HHID&y=input(HHID&y.C, best12.);
run;

*****************************************************************************************************
*** ADDED!!! THIS SECTION RE-ADDS IN HHs THAT DID NOT USE ANY EXTRA LABOR FOR REVISED HH ANALYSIS ***
*****************************************************************************************************;

data work&y.&f.add01 (drop=HHID&y.C);
     set in&y.&f.01.hh&y (keep=HHID&y RICE rename=(HHID&y=HHID&y.C));

     if RICE^=1 then RICE=0;  * NOTE ALSO RECODES CASES MISSING DATA TO DID NOT GROW RICE **;
     HHID&y=input(HHID&y.C,best12.);
run;

data work&y.&f.add02;
     merge work&y.&f.31 (in=a)
           work&y.&f.add01 (in=b);
     if a=0 and b=1 then do;
                           H_TOT_T=0;
                           H_TOT_P=0;
                           H_TOT_F=0;
                           H_TOT_IN=0;
                           H_TOT_OT=0;
                           H_PRO_PD=0;
                           H_PRO_FR=0;
                           H_PRO_IN=0;
                           H_PRO_OT=0;
                           H_ANY_PD=0;
                           H_ANY_FR=0;
                           H_ANY_OT=0;
                           H_ANY_IN=0;
                         end;
     if b=1 then output;
run;

data work&y.&f.add03;
     set work&y.&f.add02;
     if H_TOT_T>0 then RICE=1;

     if RICE=1; *** THIS LINE SELECTS ONLY THE RICE-GROWING HHs ***;
run;


*** END ADDITIONS ***;

data work&y.&f.32;
     set all&f.02 (drop=H&y.S_P17-H&y.S_p50 H&y.R_P12-H&y.R_P50);
run;


data work&y.&f.33;
     merge work&y.&f.add03 (in=a)
           work&y.&f.32 (in=b);             *** CHANGED ***;
     by HHID&y;

     if a=1 then output;

     attrib _all_ label='';

run;

data ot&y.&f.06.c2_&y.09C;
     set work&y.&f.33;
run;


**c2_00_10***VILL**************************************************************************************;
*******************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.34 (drop=V84C);
     set work&y.&f.33 (drop=H&y.R_P1 H&y.R_P2 H&y.R_P3 H&y.R_P4 H&y.R_P5
                                  H&y.R_P6 H&y.R_P7 H&y.R_P8 H&y.R_P9 H&y.R_P10
                                  H&y.R_P11
                                  H&y.S_P1 H&y.S_P2 H&y.S_P3 H&y.S_P4 H&y.S_P5
                                  H&y.S_P6 H&y.S_P7 H&y.S_P8 H&y.S_P9 H&y.S_P10
                                  H&y.S_P11 H&y.S_P12 H&y.S_P13 H&y.S_P14 H&y.S_P15
                                  H&y.S_P16
                      rename=(V84=V84C));
     V84=input(V84C,2.0);
run;



proc sort data=work&y.&f.34 out=work&y.&f.35;
     by HHID&y;
run;

data work&y.&f.36 (drop=HHID&y.C V84C);
     set in&y.&f.03.indiv&y (keep=HHID&y V84 rename=(HHID&y=HHID&y.C V84=V84C));
     HHID&y=input(HHID&y.C,best12.);
     V84=input(V84C,2.0);
run;

proc sort data=work&y.&f.36 out=work&y.&f.37 nodupkey;
     by HHID&y;
run;

data work&y.&f.38;
     merge work&y.&f.35 (in=a)
           work&y.&f.37 (in=b);
     by HHID&y;
     if a=1 and b=1 then output;
run;

proc sort data=work&y.&f.38 out=work&y.&f.39;
     by V84;
run;

data work&y.&f.40 (keep=V84 P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y NUMHHR&y
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.39 (keep=V84 H&y.RPAVG H&y.RPCNT H&y.SPAVG H&y.SPCNT
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

data work&y.&f.41;
     merge work&y.&f.40 (in=a)
           work&y.&f.30 (in=b);
     by V84;
     if a=1 and b=1 then output;
run;


data work&y.&f.46 (drop=P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.41;

     MPRNSR&y=R_RSUM&y/V_NUM_HH;
     MRRNSR&y=P_RSUM&y/V_NUM_HH;
     MRSNSR&y=P_SSUM&y/V_NUM_HH;
     MPSNSR&y=R_SSUM&y/V_NUM_HH;
     MPDDIC&y=H_SUM_PD/V_NUM_HH;
     MFRDIC&y=H_SUM_FR/V_NUM_HH;
     MINDIC&y=H_SUM_IN/V_NUM_HH;
     MOTDIC&y=H_SUM_OT/V_NUM_HH;
     MGNNSR&y=HGSUMR&y/V_NUM_HH;
     MGNNSS&y=HGSUMS&y/V_NUM_HH;

     PROPRH&y=V_NUM_RI/V_NUM_HH;
     PROPXH&y=V_NUM_EX/V_NUM_HH;
     PROPXR&y=V_NUM_EX/V_NUM_RI;

run;



data ot&y.&f.07.c2_&y.10C;
     set work&y.&f.46;
run;


***c2_00_12***HH*********************************************************************************************;
*************************************************************************************************************;

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.47;
     set work&y.&f.33;

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

data ot&y.&f.08.c2_&y.12C;
     set work&y.&f.47 (keep=HHID00 H_PF_00 H_PF_01 H_PF_11 H_PF_10
                       H_OI_00 H_OI_01 H_OI_11 H_OI_10
                       HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
                       HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG);
run;



***c2_00_13****VILL**HH************************************************************************************************;
***********************************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

** Village Level **;

proc corr data=work&y.&f.46;
     var  VH_PX_PD VH_PX_FR VH_PX_OT VH_PX_IN;
     with PROPRH&y PROPXH&y PROPXR&y
          MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.46;
     var VH_PX_PD VH_PX_FR VH_PX_OT VH_PX_IN
         PROPRH&y PROPXH&y PROPXR&y
         MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
         MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
         ;
run;

** Household Level **;

proc corr data=work&y.&f.47;
     var  H_PF_01 H_PF_11 H_PF_10;
     with H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;

proc corr data=work&y.&f.47;
     var  H_PF_01 H_PF_11 H_PF_10
          H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;

** Village Level Proportion Labor Variable **;

proc corr data=work&y.&f.46;
     var  V_PRO_PD V_PRO_FR;
     with MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.46;
     var  V_PRO_PD V_PRO_FR
          MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

data work&y.&f.44;
     set ot&y.&f.07.c2_&y.10B;
run;

proc corr data=work&y.&f.44;
     var  VH_PX_PD V_ANY_PD V_ANY_FR V_NUM_EX;
     with MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;



*** Sensitivity Tests: Village Level ***;

*** I am interested here in the sensitivity to the households used in the analysis ***;

proc corr data=work&y.&f.44;
     var  VH_PH_PD VH_PR_PD VH_PX_PD;
     with MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.44;
     var  VH_PH_FR VH_PR_FR VH_PX_FR;
     with MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.44;
     var  VH_PH_PD VH_PR_PD VH_PX_PD;
run;

proc corr data=work&y.&f.44;
     var  VH_PH_FR VH_PR_FR VH_PX_FR;
run;
