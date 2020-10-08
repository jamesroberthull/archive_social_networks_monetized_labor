*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_03.sas
**     Programmer: james r. hull
**     Start Date: 2009 February 15
**     Purpose:
**        1.) Generate Tables for Chapter 2  HH LEVEL AGGREGATION
**     Input Data:
**        1.) /nangrong/data_sas/2000/current/hh00.04
**        2.) /nangrong/data_sas/2000/current/plots00.02
**
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_00_03.xpt
**
**     NOTES: FILE 02 COLLAPSES VILLAGES W/O HHs first
**            FILE 03 COLLAPSES BY HH FIRST then by VILLAGE
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

title1 'Analysis of LABORERS for Chapter 2';

**********************
**  Data Libraries  **
**********************;

libname in00_31 xport '/nangrong/data_sas/2000/current/hh00.04';
libname in00_32 xport '/nangrong/data_sas/2000/current/plots00.02';

libname out00_31 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_03.xpt';
libname out00_32 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_HH.xpt';

libname ext00_31 xport '/nangrong/data_sas/2000/current/indiv00.04';

******************************
**  Create Working Dataset  **
******************************;

***********************************************************
**  Variables initially in dataset:
**
**
**   vill00   = 2000 identifiers
**   house00
**   cep00
**   hhid00
**
**   vill94   = 1994 identifiers
**   lekti94
**   cep94
**   hhid94
**
**   vill84 = 1984 identifiers
**   house84
**   cep84
**   hhid84
**
**   rice = Interviewer checks if HH planted rice (see 6.20)
**
**   x6_83 = Last year, how many people in your household
**          helped with the harvesting of rice?
**
**   x6_84 = About harvesting rice last year, were there
**          people in your household in 1984 ad/or 1994
**          that do not currently live in your house who
**          helped with the rice harvest?
**   x6_84c1-x6_84c7 = 2000 CEP Number
**   x6_84w1-x6_84w7 = Type of labor (Hired/Wage, Free,
**         Labor exchange, N/A, missing)
**
**   x6_85 = Did anyone from this village help to harvest
**         rice in the last year?
**   x6_85h1-x6_85h13 = 2000 Household ID
**   x6_85n1-x6_85n13 = Number of people who helped
**   x6_85w1-x6_85w13 = Type of labor?
**
**   x6_86 = Did anyone from another village come to
**         help harvest rice in the last year?
**   x6_86l1-x6_86l10 = Location information
**   x6_86n1-x6_86n10 = Number persons who helped
**   x6_86w1-x6_86w10 = Type of labor (hired, free,
**           labor exchange, N/A, Missing/Don't Know)
**
**   x6_87a1 = number grasops of Jasmine rice harvested
**   x6_87a2 = number of grasops of sticky rice harvested
**   x6_87a3 = number of grasops of other rice harvested
**
************************************************************;




***************************************************************************
** Stack rice harvest labor data into a child file and label by location **
***************************************************************************;


********************************************************************
**  0 In this village 2 + vill# + house#
**  1 In this village but blt is unknown 2 + vill# + 999
**    In this split village NOT AVAILABLE
**    In this split village but blt is unknown NOT AVAILABLE
**  4 Another village in Nang Rong  3 + Vill#
**  3 Another village in Nang Rong but Vill # is unknown  3 + 999999
**  5 Another district in Buriram 4 + District# + 0000
**  6 Another province 5 + Province# + 0000
**    Another country NOT AVAILABLE
**  8 Missing/Don't know 9999999 OR 9999999999
**  9 Code 2 or 3 Returning HH member
*******************************************************************;

data work00_301_1;
     set in00_31.hh00 (keep=HHID00 X6_84C: X6_84W:);
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

data work00_301_2;
     set in00_31.hh00 (keep=HHID00 X6_85H: X6_85N: X6_85W:);
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

data work00_301_3;
     set in00_31.hh00 (keep=HHID00 X6_86L: X6_86N: X6_86W:);
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

data work00_302_1;
     set work00_301_1;

     if X6_86W=9 then X6_86W=.;
run;

data work00_302_2;
     set work00_301_2;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;

data work00_302_3;
     set work00_301_3;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;


**************************
** Merge files together **
**************************;

data work00_303;
     set work00_302_1
         work00_302_2
         work00_302_3;
run;

***************************************************************************
** Add V84 identifiers to 2000 data file as per Rick's suggestion on web **
***************************************************************************;

proc sort data=work00_303 out=work00_304;
     by HHID00 X6_86L LOCATION;
run;

data vill_id_fix301;
     set ext00_31.indiv00;
     keep HHID00 V84;
run;

proc sort data=vill_id_fix301 out=vill_id_fix302 nodupkey;
     by HHID00 v84;
run;

data vill_id_fix303;
     merge work00_304 (in=a)
           vill_id_fix302 (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=vill_id_fix303 out=work00_305;
     by HHID00;                            ** NOTE THAT SORT IS NOW BY HHID00 **;
run;

proc freq data=work00_305;
     tables X6_86W;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 7 cases (a case here is a helper group)        **
******************************************************************************;

data work00_306;
     set work00_305;

     if X6_86W ne . then output;
run;

proc freq data=work00_306;
     tables X6_86W;
run;

proc freq data=work00_306;
     tables LOCATION;
run;


***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** 2/15/09: I collapsed categories in 2000 0/1 ->1 3/4 -> 4 **;
** Category 7 had no cases in either year **;

/* * Location=0 *;

data work00_7_0 (keep=V84 V_NUM_T0 V_NUM_P0 V_NUM_F0);  * Collapse into Villages *;
     set work00_6 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

  by V84;

  retain V_NUM_T0 V_NUM_P0 V_NUM_F0 0;

  if first.V84 then do;
                          V_NUM_T0=0;
                          V_NUM_P0=0;
                          V_NUM_F0=0;
                       end;

  if LOCATION=0 then do;
                        V_NUM_T0=V_NUM_T0+X6_86N;
                        if X6_86W=1 then V_NUM_P0=V_NUM_P0+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F0=V_NUM_F0+X6_86N;
                     end;

  if last.V84 then output;

  label V_NUM_T0='Total Number Persons Helping';
  label V_NUM_P0='Total Number Persons Helping for Pay';
  label V_NUM_F0='Total Number Persons Helping for Free';

run;

data work00_8_0;                                          * Create Proportion Variable *;
     set work00_7_0;

     V_PRO_P0=ROUND(V_NUM_P0/(V_NUM_T0+0.0000001),.0001);

     if V_NUM_T0=0 then do;
                           V_NUM_T0=".";
                           V_NUM_P0=".";
                           V_NUM_F0=".";
                           V_PRO_P0=".";
                        end;

     label V_PRO_P0='Proportion Same Village Paid';
run;   */


* Location=1 *;

data work00_307_1 (keep=HHID00 H_NUM_T1 H_NUM_P1 H_NUM_F1);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

  label H_NUM_T1='Total Number Persons Helping';
  label H_NUM_P1='Total Number Persons Helping for Pay';
  label H_NUM_F1='Total Number Persons Helping for Free';

run;

data work00_308_1;                                          * Create Proportion Variable *;
     set work00_307_1;

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


/* * Location=2 *;

data work00_7_2 (keep=V84 V_NUM_T2 V_NUM_P2 V_NUM_F2);  * Collapse into Villages *;
     set work00_6 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T2 V_NUM_P2 V_NUM_F2 0;

  if first.V84 then do;
                          V_NUM_T2=0;
                          V_NUM_P2=0;
                          V_NUM_F2=0;
                       end;

  if LOCATION=2 then do;
                        V_NUM_T2=V_NUM_T2+X6_86N;
                        if X6_86W=1 then V_NUM_P2=V_NUM_P2+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F2=V_NUM_F2+X6_86N;
                     end;

  if last.V84 then output;

  label V_NUM_T2='Total Number Persons Helping';
  label V_NUM_P2='Total Number Persons Helping for Pay';
  label V_NUM_F2='Total Number Persons Helping for Free';

run;

data work00_8_2;                                          * Create Proportion Variable *;
     set work00_7_2;

     V_PRO_P2=ROUND(V_NUM_P2/(V_NUM_T2+0.0000001),.0001);

     if V_NUM_T2=0 then do;
                           V_NUM_T2=".";
                           V_NUM_P2=".";
                           V_NUM_F2=".";
                           V_PRO_P2=".";
                        end;

     label V_PRO_P2='Proportion Same Missing Paid';
run; */


/* * Location=3 *;

data work00_7_3 (keep=V84 V_NUM_T3 V_NUM_P3 V_NUM_F3);  * Collapse into Villages *;
     set work00_6 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T3 V_NUM_P3 V_NUM_F3 0;

  if first.V84 then do;
                          V_NUM_T3=0;
                          V_NUM_P3=0;
                          V_NUM_F3=0;
                       end;

  if LOCATION=3 then do;
                        V_NUM_T3=V_NUM_T3+X6_86N;
                        if X6_86W=1 then V_NUM_P3=V_NUM_P3+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F3=V_NUM_F3+X6_86N;
                     end;

  if last.V84 then output;

  label V_NUM_T3='Total Number Persons Helping';
  label V_NUM_P3='Total Number Persons Helping for Pay';
  label V_NUM_F3='Total Number Persons Helping for Free';

run;

data work00_8_3;                                          * Create Proportion Variable *;
     set work00_7_3;

     V_PRO_P3=ROUND(V_NUM_P3/(V_NUM_T3+0.0000001),.0001);

     if V_NUM_T3=0 then do;
                           V_NUM_T3=".";
                           V_NUM_P3=".";
                           V_NUM_F3=".";
                           V_PRO_P3=".";
                        end;

     label V_PRO_P3='Proportion Split Missing Paid';
run;   */

* Location=4 *;

data work00_307_4 (keep=HHID00 H_NUM_T4 H_NUM_P4 H_NUM_F4);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

  label H_NUM_T4='Total Number Persons Helping';
  label H_NUM_P4='Total Number Persons Helping for Pay';
  label H_NUM_F4='Total Number Persons Helping for Free';

run;

data work00_308_4;                                          * Create Proportion Variable *;
     set work00_307_4;

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

data work00_307_5 (keep=HHID00 H_NUM_T5 H_NUM_P5 H_NUM_F5);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

  label H_NUM_T5='Total Number Persons Helping';
  label H_NUM_P5='Total Number Persons Helping for Pay';
  label H_NUM_F5='Total Number Persons Helping for Free';

run;

data work00_308_5;                                          * Create Proportion Variable *;
     set work00_307_5;

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

data work00_307_6 (keep=HHID00 H_NUM_T6 H_NUM_P6 H_NUM_F6);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

  label H_NUM_T6='Total Number Persons Helping';
  label H_NUM_P6='Total Number Persons Helping for Pay';
  label H_NUM_F6='Total Number Persons Helping for Free';

run;

data work00_308_6;                                          * Create Proportion Variable *;
     set work00_307_6;

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

/* * Location=7 *;

data work00_7_7 (keep=V84 V_NUM_T7 V_NUM_P7 V_NUM_F7);  * Collapse into Villages *;
     set work00_6 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

     by V84;

  retain V_NUM_T7 V_NUM_P7 V_NUM_F7 0;

  if first.V84 then do;
                          V_NUM_T7=0;
                          V_NUM_P7=0;
                          V_NUM_F7=0;
                       end;

  if LOCATION=7 then do;
                        V_NUM_T7=V_NUM_T7+X6_86N;
                        if X6_86W=1 then V_NUM_P7=V_NUM_P7+X6_86N;
                        if X6_86W in (2,3) then V_NUM_F7=V_NUM_F7+X6_86N;
                     end;

  if last.V84 then output;

  label V_NUM_T7='Total Number Persons Helping';
  label V_NUM_P7='Total Number Persons Helping for Pay';
  label V_NUM_F7='Total Number Persons Helping for Free';

run;

data work00_8_7;                                          * Create Proportion Variable *;
     set work00_7_7;

     V_PRO_P7=ROUND(V_NUM_P7/(V_NUM_T7+0.0000001),.0001);

     if V_NUM_T7=0 then do;
                           V_NUM_T7=".";
                           V_NUM_P7=".";
                           V_NUM_F7=".";
                           V_PRO_P7=".";
                        end;

     label V_PRO_P7='Proportion Other Country Paid';
run;  */


* Location=8 *;

data work00_307_8 (keep=HHID00 H_NUM_T8 H_NUM_P8 H_NUM_F8);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

  label H_NUM_T8='Total Number Persons Helping';
  label H_NUM_P8='Total Number Persons Helping for Pay';
  label H_NUM_F8='Total Number Persons Helping for Free';

run;

data work00_308_8;                                          * Create Proportion Variable *;
     set work00_307_8;

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

data work00_307_9 (keep=HHID00 H_NUM_T9 H_NUM_P9 H_NUM_F9);  * Collapse into HHs *;
     set work00_306 (keep=HHID00 X6_86L X6_86N X6_86W LOCATION);

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

data work00_308_9;                                          * Create Proportion Variable *;
     set work00_307_9;

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



data work00_309;
     merge /* work00_8_0 */
           work00_308_1
           /*work00_8_2*/
           /*work00_8_3*/
           work00_308_4
           work00_308_5
           work00_308_6
           /* work00_8_7 */
           work00_308_8
           work00_308_9;
     by HHID00;
run;

*****************************************************
** Some Starter Descriptive Analysis that May Move **
*****************************************************;

proc means mean std sum min max data=work00_308_1;
run;

proc means mean std sum min max data=work00_308_4;
run;

proc means mean std sum min max data=work00_308_5;
run;

proc means mean std sum min max data=work00_308_6;
run;

proc means mean std sum min max data=work00_308_8;
run;

proc means mean std sum min max data=work00_308_9;
run;

proc means mean std sum min max data=work00_306;
     var X6_86N;
run;

proc sort data=work00_306 out=work00_310;
     by X6_86W HHID00;
run;

proc means mean std sum min max data=work00_310;
     var X6_86N;
     by X6_86W;
run;

proc means mean std sum min max data=in00_31.hh00 (keep=hhid00 X6_83);
     var X6_83;
run;

*****************************************************
**  A Simple Village-level correlational analysis  **
*****************************************************;

** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

** After examining the data for 1994 and 2000, I found very few cases  **
** in which a household mixed payment strategies or labor sources, so  **
** the decision to recode these variables to dichotomous indicators    **
** 0,any seems a sensible way to simplify the data analysis. For the   **
** variable H_PRO_PD, roughly 4% in either year fell between 0 and 1,  **
** while for H_PRO_OT it was somewhere near 13% in either year. 3/10    **;

data work00_311 (drop=ZIPPO);
     set work00_309;
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

 run;

 proc means data=work00_311 MEAN MEDIAN STD MIN MAX;
      var H_TOT_T H_TOT_P H_TOT_F H_TOT_IN H_TOT_OT
          H_PRO_PD H_PRO_IN H_PRO_OT H_ANY_PD H_ANY_OT;
 run;

 proc corr data=work00_311;
      var H_ANY_PD H_ANY_OT;
 run;

 proc freq data=work00_311;
      tables H_ANY_PD*H_ANY_OT / chisq;
 run;



**************************************************************
** Create Village Level Variables from Household Level Data **
**************************************************************;

proc sort data=work00_310 out=work00_312;
     by HHID00 V84;
run;

data work00_313 (keep=V84 HHID00 H_NUM_PD H_NUM_FR H_NUM_OT H_NUM_IN);
     set work00_312 (keep=V84 HHID00 LOCATION X6_86W);

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

     label H_NUM_PD='Num ties HH in Village Use PAID Labor';
     label H_NUM_FR='Num ties HH in Village Use FREE Labor';
     label H_NUM_OT='Num ties HH in Village Use OUTSIDE Labor';
     label H_NUM_IN='Num ties HH in Village Use INSIDE Labor';

run;

proc sort data=work00_313 out=work00_314;
     by V84;
run;

data work00_315 (keep=V84 V_ANY_PD V_ANY_FR V_ANY_OT V_ANY_IN);
     set work00_314;

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

     label V_ANY_PD='Num HHs in Village Use PAID Labor';
     label V_ANY_FR='Num HHs in Village Use FREE Labor';
     label V_ANY_OT='Num HHs in Village Use OUTSIDE Labor';
     label V_ANY_IN='Num HHs in Village Use INSIDE Labor';

run;

*********************************************************************
** Create two variables to use as denominators: # HHs & # RICE HHs **
*********************************************************************;

** # HH in Village Variable **;

data all_hh_301;
     set ext00_31.indiv00;
     keep HHID00 V84;
run;

proc sort data=all_hh_301 out=all_hh_302 nodupkey;
     by V84 HHID00;
run;

data all_hh_303 (keep=V84 V_NUM_HH);
     set all_hh_302;

     by V84;

     retain V_NUM_HH 0;

     if first.V84 then V_NUM_HH=0;

     V_NUM_HH=V_NUM_HH+1;

    if last.V84 then output;

run;

** # Rice-Growing HHs in Village Variable **;

data all_rice_301;
     set in00_31.hh00 (keep=hhid00 RICE);
run;

proc sort data=all_rice_301 out=all_rice_302;
     by HHID00;
run;

data all_rice_303;
     set ext00_31.indiv00;
     keep HHID00 V84;
run;

proc sort data=all_rice_303 out=all_rice_304 nodupkey;
     by HHID00 v84;
run;

data all_rice_305;
     merge all_rice_302 (in=a)
           all_rice_304 (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=all_rice_305 out=all_rice_306;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data all_rice_307 (keep=V84 V_NUM_RI);
     set all_rice_306;

     by V84;

     retain V_NUM_RI 0;

     if first.V84 then V_NUM_RI=0;

     if RICE=1 then V_NUM_RI=V_NUM_RI+1;

    if last.V84 then output;

run;

data work00_316;
     merge work00_315
           all_hh_303
           all_rice_307;
     by V84;
run;

data work00_317;
     set work00_316;

     VH_PH_PD=V_ANY_PD/V_NUM_HH;
     VH_PH_FR=V_ANY_FR/V_NUM_HH;
     VH_PH_OT=V_ANY_OT/V_NUM_HH;
     VH_PH_IN=V_ANY_IN/V_NUM_HH;

   /*  label VH_PH_PD='Prop HHs in Village Use PAID Labor';
     label VH_PH_FR='Prop HHs in Village Use FREE Labor';
     label VH_PH_OT='Prop HHs in Village Use OUTSIDE Labor';
     label VH_PH_IN='Prop HHs in Village Use INSIDE Labor';
   */
     VH_PR_PD=V_ANY_PD/V_NUM_RI;
     VH_PR_FR=V_ANY_FR/V_NUM_RI;
     VH_PR_OT=V_ANY_OT/V_NUM_RI;
     VH_PR_IN=V_ANY_IN/V_NUM_RI;

    /* label VH_PR_PD='Prop Rice HHs in Village Use PAID Labor';
     label VH_PR_FR='Prop Rice HHs in Village Use FREE Labor';
     label VH_PR_OT='Prop Rice HHs in Village Use OUTSIDE Labor';
     label VH_PR_IN='Prop Rice HHs in Village Use INSIDE Labor';
    */
run;

proc means data=work00_317 MEAN MEDIAN STD MIN MAX;
     var VH_PR_PD VH_PR_FR VH_PR_OT VH_PR_IN
         VH_PH_PD VH_PH_FR VH_PH_OT VH_PH_IN;

run;


proc corr data=work00_317 outp=pearson00_301;
     var VH_PR_PD VH_PR_OT VH_PR_FR VH_PR_IN;
run;

proc corr data=work00_317 outp=pearson00_302;
     var VH_PH_PD VH_PH_OT VH_PH_FR VH_PH_IN;
run;

data work00_318;       ** Create traditional dichotomous measure for comparision **;
     set work00_317;

     if V_ANY_PD > 0 then V_PD_0_1=1;
     else V_PD_0_1=0;
run;

proc means data=work00_318 MEAN MEDIAN STD MIN MAX;
     var V_PD_0_1;
run;

data out00_31.c2_00_03;
     set work00_318;
run;

data out00_32.c2_00_HH;
     set work00_311;
run;
