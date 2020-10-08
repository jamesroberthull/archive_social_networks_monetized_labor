*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_02.sas
**     Programmer: james r. hull
**     Start Date: 2009 February 15
**     Purpose:
**        1.) Generate Tables for Chapter 2
**     Input Data:
**        1.) /nangrong/data_sas/2000/current/hh00.04
**        2.) /nangrong/data_sas/2000/current/plots00.02
**
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_00_02.xpt
**
**     NOTES:
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

libname in00_21 xport '/nangrong/data_sas/2000/current/hh00.04';
libname in00_22 xport '/nangrong/data_sas/2000/current/plots00.02';

libname out00_21 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_02.xpt';

libname extra_21 xport '/nangrong/data_sas/2000/current/indiv00.04';

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

data work00_201_1;
     set in00_21.hh00 (keep=HHID00 X6_84C: X6_84W:);
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

data work00_201_2;
     set in00_21.hh00 (keep=HHID00 X6_85H: X6_85N: X6_85W:);
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

data work00_201_3;
     set in00_21.hh00 (keep=HHID00 X6_86L: X6_86N: X6_86W:);
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

data work00_202_1;
     set work00_201_1;

     if X6_86W=9 then X6_86W=.;
run;

data work00_202_2;
     set work00_201_2;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;

data work00_202_3;
     set work00_201_3;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;


**************************
** Merge files together **
**************************;

data work00_203;
     set work00_202_1
         work00_202_2
         work00_202_3;
run;

***************************************************************************
** Add V84 identifiers to 2000 data file as per Rick's suggestion on web **
***************************************************************************;

proc sort data=work00_203 out=work00_204;
     by HHID00 X6_86L LOCATION;
run;

data vill_id_fix201;
     set extra_21.indiv00;
     keep HHID00 V84;
run;

proc sort data=vill_id_fix201 out=vill_id_fix202 nodupkey;
     by HHID00 v84;
run;

data vill_id_fix203;
     merge work00_204 (in=a)
           vill_id_fix202 (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=vill_id_fix203 out=work00_205;
     by V84;
run;

proc freq data=work00_205;
     tables X6_86W;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 7 cases (a case here is a helper group)        **
******************************************************************************;

data work00_206;
     set work00_205;

     if X6_86W ne . then output;
run;

proc freq data=work00_206;
     tables X6_86W;
run;

proc freq data=work00_206;
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

data work00_207_1 (keep=V84 V_NUM_T1 V_NUM_P1 V_NUM_F1);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T1='Total Number Persons Helping';
  label V_NUM_P1='Total Number Persons Helping for Pay';
  label V_NUM_F1='Total Number Persons Helping for Free';

run;

data work00_208_1;                                          * Create Proportion Variable *;
     set work00_207_1;

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

data work00_207_4 (keep=V84 V_NUM_T4 V_NUM_P4 V_NUM_F4);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T4='Total Number Persons Helping';
  label V_NUM_P4='Total Number Persons Helping for Pay';
  label V_NUM_F4='Total Number Persons Helping for Free';

run;

data work00_208_4;                                          * Create Proportion Variable *;
     set work00_207_4;

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

data work00_207_5 (keep=V84 V_NUM_T5 V_NUM_P5 V_NUM_F5);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T5='Total Number Persons Helping';
  label V_NUM_P5='Total Number Persons Helping for Pay';
  label V_NUM_F5='Total Number Persons Helping for Free';

run;

data work00_208_5;                                          * Create Proportion Variable *;
     set work00_207_5;

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

data work00_207_6 (keep=V84 V_NUM_T6 V_NUM_P6 V_NUM_F6);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T6='Total Number Persons Helping';
  label V_NUM_P6='Total Number Persons Helping for Pay';
  label V_NUM_F6='Total Number Persons Helping for Free';

run;

data work00_208_6;                                          * Create Proportion Variable *;
     set work00_207_6;

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

data work00_207_8 (keep=V84 V_NUM_T8 V_NUM_P8 V_NUM_F8);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T8='Total Number Persons Helping';
  label V_NUM_P8='Total Number Persons Helping for Pay';
  label V_NUM_F8='Total Number Persons Helping for Free';

run;

data work00_208_8;                                          * Create Proportion Variable *;
     set work00_207_8;

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

data work00_207_9 (keep=V84 V_NUM_T9 V_NUM_P9 V_NUM_F9);  * Collapse into Villages *;
     set work00_206 (keep=V84 X6_86L X6_86N X6_86W LOCATION);

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

  label V_NUM_T9='Total Number Persons Helping';
  label V_NUM_P9='Total Number Persons Helping for Pay';
  label V_NUM_F9='Total Number Persons Helping for Free';

run;

data work00_208_9;                                          * Create Proportion Variable *;
     set work00_207_9;

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



data work00_209;
     merge /* work00_8_0 */
           work00_208_1
           /*work00_8_2*/
           /*work00_8_3*/
           work00_208_4
           work00_208_5
           work00_208_6
           /* work00_8_7 */
           work00_208_8
           work00_208_9;
     by V84;
run;


*****************************************************
** Some Starter Descriptive Analysis that May Move **
*****************************************************;

proc means mean std sum min max data=work00_208_1;
run;

proc means mean std sum min max data=work00_208_4;
run;

proc means mean std sum min max data=work00_208_5;
run;

proc means mean std sum min max data=work00_208_6;
run;

proc means mean std sum min max data=work00_208_8;
run;

proc means mean std sum min max data=work00_208_9;
run;

proc means mean std sum min max data=work00_206;
     var X6_86N;
run;

proc sort data=work00_206 out=work00_210;
     by X6_86W HHID00;
run;

proc means mean std sum min max data=work00_210;
     var X6_86N;
     by X6_86W;
run;

proc means mean std sum min max data=in00_21.hh00 (keep=hhid00 X6_83);
     var X6_83;
run;

*****************************************************
**  A Simple Village-level correlational analysis  **
*****************************************************;

** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

data work00_211 (drop=ZIPPO);
     set work00_209;
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

proc corr data=work00_211;
     var V_PRO_PD V_PRO_OT;
run;

data out00_21.c2_00_02;
     set work00_211;
run;
