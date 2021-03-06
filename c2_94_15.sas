*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_14.sas
**     Programmer: james r. hull
**     Start Date: 2009 09 19
**     Purpose:
**        1.) Revised Analysis for Chapter 2 - corrects at risk population
**     Input Data:
**        1.) RAW DATA
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_94_14.xpt
**
**      NOTES: This dataset is a compilation of all previous datasets, w/ changes
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

%let f=14;   ** Allows for greater file portability **;
%let y=94;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/nangrong/data_sas/1994/current/hh94.03';
libname in&y.&f.02 xport '/nangrong/data_sas/1994/current/helprh94.01';
libname in&y.&f.03 xport '/nangrong/data_sas/1994/current/indiv94.05';

libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_9402B.xpt';
libname ot&y.&f.02 xport '/trainee/jrhull/diss/ch2/c2data/c2_9403B.xpt';
libname ot&y.&f.03 xport '/trainee/jrhull/diss/ch2/c2data/c2_94HHB.xpt';
libname ot&y.&f.04 xport '/trainee/jrhull/diss/ch2/c2data/c2_9407B.xpt';
libname ot&y.&f.05 xport '/trainee/jrhull/diss/ch2/c2data/c2_9408B.xpt';
libname ot&y.&f.06 xport '/trainee/jrhull/diss/ch2/c2data/c2_9409B.xpt';
libname ot&y.&f.07 xport '/trainee/jrhull/diss/ch2/c2data/c2_9410B.xpt';
libname ot&y.&f.08 xport '/trainee/jrhull/diss/ch2/c2data/c2_9412B.xpt';
libname ot&y.&f.09 xport '/trainee/jrhull/diss/ch2/c2data/c2_9413B.xpt';


****c2_94_02********VILL*************************************************************************;
*************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

* This code stacks the code 2&3 help into a child file *;
* It adds the location=9 variable and codes # helpers=1 for all *;

data work&y.&f.01;
     set in&y.&f.01.hh94 (keep=hhid94 Q6_23A: Q6_23B: Q6_23C: Q6_23D:);
     keep HHID94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E LOCATION;

          length Q6_24A $ 7;

          array a(1:5) Q6_23A1-Q6_23A5;
          array b(1:5) Q6_23B1-Q6_23B5;
          array c(1:5) Q6_23C1-Q6_23C5;
          array d(1:5) Q6_23D1-Q6_23D5;

          do i=1 to 5;
               Q6_24A=a(i);
               Q6_24B=1;
               Q6_24C=b(i);
               Q6_24D=c(i);
               Q6_24E=d(i);
               LOCATION=9;
               if Q6_24A ne '998' then output;  *Keep only those cases with data *;
          end;
run;

data work&y.&f.02;
     set in&y.&f.02.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E);

     if Q6_24A in ('9999997','0009999','9999999') then LOCATION=8;                  *allmissing*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=5 then LOCATION=7;  *country*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=4 then LOCATION=6;  *province*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=3 then LOCATION=5;  *district*;
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=2 then LOCATION=4;  *othervill*;
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)=2 then LOCATION=3;  *splitmissing*;
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)=0 then LOCATION=2;  *samemissing*;
        else if substr(Q6_24A,4,4)='9999' then LOCATION=2;   *samemissing*;
        else if substr(Q6_24A,4,4)='0000' then LOCATION=0;   *samevill*;
        else if substr(Q6_24A,4,1)='2' then LOCATION=1;      *splitvill*;
        else if substr(Q6_24A,4,1)='0' then LOCATION=1;      *splitvill*;
        else LOCATION=.;                                     * LOGIC PROBLEMS IF . > 0 *;

        if Q6_24C=99 then Q6_24C=1;        *RECODES*;    *If number of days unknown, code as 1 *;
        if Q6_24B=99 then Q6_24B=1;                      *If number of workers unknown, code as 1 *;
                                                         *No recodes needed for Q6_24D *;
        if Q6_24E=996 then Q6_24E=.;                     *If wages unknown, code as "."  *;
           else if Q6_24E=998 then Q6_24E=.;             *The above recodes to 1 impact 22 and 12 helping hhs respectively *;
           else if Q6_24E=999 then Q6_24E=.;             *The logic is that if the hh was named then at least*;
run;                                                     * one person worked for at least 1 day *;

data work&y.&f.03;
     set work&y.&f.01
         work&y.&f.02;
run;


***************************************************************************
** Add V84 identifiers to 1994 data file as per Rick's comments on web   **
***************************************************************************;

proc sort data=work&y.&f.03 out=work&y.&f.04;
     by hhid94 q6_24a LOCATION;
run;

data work&y.&f.01fix;
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=work&y.&f.01fix out=work&y.&f.02fix nodupkey;
     by HHID94 v84;
run;

data work&y.&f.05;
     merge work&y.&f.04 (in=a)
           work&y.&f.02fix (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=work&y.&f.05 out=work&y.&f.06;
     by V84 HHID94;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 11 cases (a case here is a helper group)        **
******************************************************************************;

data work&y.&f.07;
     set work&y.&f.06;

     if Q6_24D ^in (.,9) then output;

     if LOCATION ^=9;     ** Removes CODE 2 & 3 Labor from subsequent analysis **;
run;


***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** 2/15/09: I collapsed original categories 0 through 3 -> 1 **;
** Category 7 had no cases in either year **;

* Location=1 *;

data work&y.&f.08_01 (keep=V84 V_NUM_T1 V_NUM_P1 V_NUM_F1);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T1 V_NUM_P1 V_NUM_F1 0;

  if first.V84 then do;
                          V_NUM_T1=0;
                          V_NUM_P1=0;
                          V_NUM_F1=0;
                       end;

  if LOCATION in (0,1,2,3) then do;
                        V_NUM_T1=V_NUM_T1+Q6_24B;
                        if Q6_24D=1 then V_NUM_P1=V_NUM_P1+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F1=V_NUM_F1+Q6_24B;
                     end;

  if last.V84 then output;

run;

data work&y.&f.09_01;                                          * Create Proportion Variable *;
     set work&y.&f.08_01;

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

data work&y.&f.08_04 (keep=V84 V_NUM_T4 V_NUM_P4 V_NUM_F4);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T4 V_NUM_P4 V_NUM_F4 0;

  if first.V84 then do;
                          V_NUM_T4=0;
                          V_NUM_P4=0;
                          V_NUM_F4=0;
                       end;

  if LOCATION=4 then do;
                        V_NUM_T4=V_NUM_T4+Q6_24B;
                        if Q6_24D=1 then V_NUM_P4=V_NUM_P4+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F4=V_NUM_F4+Q6_24B;
                     end;

  if last.V84 then output;

run;

data work&y.&f.09_04;                                          * Create Proportion Variable *;
     set work&y.&f.08_04;

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

data work&y.&f.08_05 (keep=V84 V_NUM_T5 V_NUM_P5 V_NUM_F5);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T5 V_NUM_P5 V_NUM_F5 0;

  if first.V84 then do;
                          V_NUM_T5=0;
                          V_NUM_P5=0;
                          V_NUM_F5=0;
                       end;

  if LOCATION=5 then do;
                        V_NUM_T5=V_NUM_T5+Q6_24B;
                        if Q6_24D=1 then V_NUM_P5=V_NUM_P5+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F5=V_NUM_F5+Q6_24B;
                     end;

  if last.V84 then output;

run;

data work&y.&f.09_05;                                          * Create Proportion Variable *;
     set work&y.&f.08_05;

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

data work&y.&f.08_06 (keep=V84 V_NUM_T6 V_NUM_P6 V_NUM_F6);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T6 V_NUM_P6 V_NUM_F6 0;

  if first.V84 then do;
                          V_NUM_T6=0;
                          V_NUM_P6=0;
                          V_NUM_F6=0;
                       end;

  if LOCATION=6 then do;
                        V_NUM_T6=V_NUM_T6+Q6_24B;
                        if Q6_24D=1 then V_NUM_P6=V_NUM_P6+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F6=V_NUM_F6+Q6_24B;
                     end;

  if last.V84 then output;

  label V_NUM_T6='Total Number Persons Helping';
  label V_NUM_P6='Total Number Persons Helping for Pay';
  label V_NUM_F6='Total Number Persons Helping for Free';

run;

data work&y.&f.09_06;                                          * Create Proportion Variable *;
     set work&y.&f.08_06;

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

data work&y.&f.08_08 (keep=V84 V_NUM_T8 V_NUM_P8 V_NUM_F8);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T8 V_NUM_P8 V_NUM_F8 0;

  if first.V84 then do;
                          V_NUM_T8=0;
                          V_NUM_P8=0;
                          V_NUM_F8=0;
                       end;

  if LOCATION=8 then do;
                        V_NUM_T8=V_NUM_T8+Q6_24B;
                        if Q6_24D=1 then V_NUM_P8=V_NUM_P8+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F8=V_NUM_F8+Q6_24B;
                     end;

  if last.V84 then output;

run;

data work&y.&f.09_08;                                          * Create Proportion Variable *;
     set work&y.&f.08_08;

     V_PRO_P8=ROUND(V_NUM_P8/(V_NUM_T8+0.0000001),.0001);
     V_PRO_F8=ROUND(V_NUM_F8/(V_NUM_T8+0.0000001),.0001);

     if V_NUM_T8=0 then do;
                           V_NUM_T8=".";
                           V_NUM_P8=".";
                           V_NUM_F8=".";
                           V_PRO_P8=".";
                           V_PRO_F8=".";
                        end;

run;

* Location=9 *;

data work&y.&f.08_09 (keep=V84 V_NUM_T9 V_NUM_P9 V_NUM_F9);  * Collapse into Villages *;
     set work&y.&f.07 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T9 V_NUM_P9 V_NUM_F9 0;

  if first.V84 then do;
                          V_NUM_T9=0;
                          V_NUM_P9=0;
                          V_NUM_F9=0;
                       end;

  if LOCATION=9 then do;
                        V_NUM_T9=V_NUM_T9+Q6_24B;
                        if Q6_24D=1 then V_NUM_P9=V_NUM_P9+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F9=V_NUM_F9+Q6_24B;
                     end;

  if last.V84 then output;

run;

data work&y.&f.09_09;                                          * Create Proportion Variable *;
     set work&y.&f.08_09;

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

data work&y.&f.10;
     merge work&y.&f.09_01
           work&y.&f.09_04
           work&y.&f.09_05
           work&y.&f.09_06
           work&y.&f.09_08
           work&y.&f.09_09;
     by V84;
run;

data work&y.&f.11 (drop=ZIPPO);
     set work&y.&f.10;
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

data ot&y.&f.01.c2_9402B;
     set work&y.&f.11;
run;


******c2_94_03********************************************************************************************;
**********************************************************************************************************;

proc sort data=work&y.&f.07 out=work&y.&f.07B;
     by HHID94;
run;

** This code collapses the data just like before, but by household this time, not by village **;

* Location=1 *;

data work&y.&f.12_01 (keep=HHID94 H_NUM_T1 H_NUM_P1 H_NUM_F1);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94 Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T1 H_NUM_P1 H_NUM_F1 0;

  if first.HHID94 then do;
                          H_NUM_T1=0;
                          H_NUM_P1=0;
                          H_NUM_F1=0;
                       end;

  if LOCATION in (0,1,2,3) then do;
                        H_NUM_T1=H_NUM_T1+Q6_24B;
                        if Q6_24D=1 then H_NUM_P1=H_NUM_P1+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F1=H_NUM_F1+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T1='Total Number Persons Helping';
  label H_NUM_P1='Total Number Persons Helping for Pay';
  label H_NUM_F1='Total Number Persons Helping for Free';

run;

data work&y.&f.13_01;                                          * Create Proportion Variable *;
     set work&y.&f.12_01;

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

data work&y.&f.12_04 (keep=HHID94  H_NUM_T4 H_NUM_P4 H_NUM_F4);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T4 H_NUM_P4 H_NUM_F4 0;

  if first.HHID94 then do;
                          H_NUM_T4=0;
                          H_NUM_P4=0;
                          H_NUM_F4=0;
                       end;

  if LOCATION=4 then do;
                        H_NUM_T4=H_NUM_T4+Q6_24B;
                        if Q6_24D=1 then H_NUM_P4=H_NUM_P4+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F4=H_NUM_F4+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T4='Total Number Persons Helping';
  label H_NUM_P4='Total Number Persons Helping for Pay';
  label H_NUM_F4='Total Number Persons Helping for Free';

run;

data work&y.&f.13_04;                                          * Create Proportion Variable *;
     set work&y.&f.12_04;

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

data work&y.&f.12_05 (keep=HHID94  H_NUM_T5 H_NUM_P5 H_NUM_F5);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T5 H_NUM_P5 H_NUM_F5 0;

  if first.HHID94 then do;
                          H_NUM_T5=0;
                          H_NUM_P5=0;
                          H_NUM_F5=0;
                       end;

  if LOCATION=5 then do;
                        H_NUM_T5=H_NUM_T5+Q6_24B;
                        if Q6_24D=1 then H_NUM_P5=H_NUM_P5+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F5=H_NUM_F5+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T5='Total Number Persons Helping';
  label H_NUM_P5='Total Number Persons Helping for Pay';
  label H_NUM_F5='Total Number Persons Helping for Free';

run;

data work&y.&f.13_05;                                          * Create Proportion Variable *;
     set work&y.&f.12_05;

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

data work&y.&f.12_06 (keep=HHID94  H_NUM_T6 H_NUM_P6 H_NUM_F6);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T6 H_NUM_P6 H_NUM_F6 0;

  if first.HHID94 then do;
                          H_NUM_T6=0;
                          H_NUM_P6=0;
                          H_NUM_F6=0;
                       end;

  if LOCATION=6 then do;
                        H_NUM_T6=H_NUM_T6+Q6_24B;
                        if Q6_24D=1 then H_NUM_P6=H_NUM_P6+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F6=H_NUM_F6+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T6='Total Number Persons Helping';
  label H_NUM_P6='Total Number Persons Helping for Pay';
  label H_NUM_F6='Total Number Persons Helping for Free';

run;

data work&y.&f.13_06;                                          * Create Proportion Variable *;
     set work&y.&f.12_06;

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

data work&y.&f.12_08 (keep=HHID94  H_NUM_T8 H_NUM_P8 H_NUM_F8);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

  retain H_NUM_T8 H_NUM_P8 H_NUM_F8 0;

  if first.HHID94 then do;
                          H_NUM_T8=0;
                          H_NUM_P8=0;
                          H_NUM_F8=0;
                       end;

  if LOCATION=8 then do;
                        H_NUM_T8=H_NUM_T8+Q6_24B;
                        if Q6_24D=1 then H_NUM_P8=H_NUM_P8+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F8=H_NUM_F8+Q6_24B;
                     end;

  if last.HHID94 then output;

  label H_NUM_T8='Total Number Persons Helping';
  label H_NUM_P8='Total Number Persons Helping for Pay';
  label H_NUM_F8='Total Number Persons Helping for Free';

run;

data work&y.&f.13_08;                                          * Create Proportion Variable *;
     set work&y.&f.12_08;

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

data work&y.&f.12_09 (keep=HHID94  H_NUM_T9 H_NUM_P9 H_NUM_F9);  * Collapse into HHs *;
     set work&y.&f.07B (keep=HHID94  Q6_24B Q6_24D LOCATION);

     by HHID94;

     retain H_NUM_T9 H_NUM_P9 H_NUM_F9 0;

     if first.HHID94 then do;
                          H_NUM_T9=0;
                          H_NUM_P9=0;
                          H_NUM_F9=0;
                       end;

     if LOCATION=9 then do;
                        H_NUM_T9=H_NUM_T9+Q6_24B;
                        if Q6_24D=1 then H_NUM_P9=H_NUM_P9+Q6_24B;
                        if Q6_24D in (2,3) then H_NUM_F9=H_NUM_F9+Q6_24B;
                     end;

     if last.HHID94 then output;

     label H_NUM_T9='Total Number Persons Helping';
     label H_NUM_P9='Total Number Persons Helping for Pay';
     label H_NUM_F9='Total Number Persons Helping for Free';

run;

data work&y.&f.13_09;                                          * Create Proportion Variable *;
     set work&y.&f.12_09;

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

*****************************************************************
**  Merge all separate hh files together, number cases= 2548   **
*****************************************************************;

data work&y.&f.14;
     merge work&y.&f.13_01
           work&y.&f.13_04
           work&y.&f.13_05
           work&y.&f.13_06
           work&y.&f.13_08
           work&y.&f.13_09;
     by HHID94;
run;

proc sort data=work&y.&f.07B out=work&y.&f.15;
     by Q6_24D HHID94;
run;


data work&y.&f.16 (drop=ZIPPO);
     set work&y.&f.14;
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

      if H_TOT_T>0; ** DROPS ALL HHs BUT THOSE THAT USED NON-CODE 2&3 EXTRA LABOR **;
run;

**************************************************************
** Create Village Level Variables from Household Level Data **
**************************************************************;

proc sort data=work&y.&f.15 out=work&y.&f.17;
     by HHID94 V84;
run;

data work&y.&f.18 (keep=V84 HHID94 H_NUM_PD H_NUM_FR H_NUM_OT H_NUM_IN);
     set work&y.&f.17 (keep=V84 HHID94 LOCATION Q6_24D);

     by HHID94;

     retain H_NUM_PD H_NUM_OT H_NUM_FR H_NUM_IN 0;

     if first.HHID94 then do;
                          H_NUM_PD=0;
                          H_NUM_FR=0;
                          H_NUM_OT=0;
                          H_NUM_IN=0;
                       end;

     ** Below excludes missing location cases AND CODE 2 & 3 LABOR **;

     if LOCATION ^in (8,9) then do;
                                  if Q6_24D in (1) then H_NUM_PD=H_NUM_PD+1;
                                  if Q6_24D in (2,3) then H_NUM_FR=H_NUM_FR+1;
                                  if LOCATION=1 then H_NUM_IN=H_NUM_IN+1;
                                  if LOCATION ^in (1,8) then H_NUM_OT=H_NUM_OT+1;
                                end;

     if last.HHID94 then output;

run;

proc sort data=work&y.&f.18 out=work&y.&f.19;
     by V84;
run;

data work&y.&f.20 (keep=V84 V_ANY_PD V_ANY_FR V_ANY_OT V_ANY_IN);
     set work&y.&f.19;

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
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=work&y.&f.01hh out=work&y.&f.02hh nodupkey;
     by V84 HHID94;
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
     set in&y.&f.01.hh94 (keep=hhid94 Q6_16);
run;

proc sort data=work&y.&f.01rice out=work&y.&f.02rice;
     by hhid94;
run;

data work&y.&f.03rice;
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=work&y.&f.03rice out=work&y.&f.04rice nodupkey;
     by HHID94 v84;
run;

data work&y.&f.05rice;
     merge work&y.&f.02rice (in=a)
           work&y.&f.04rice (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=work&y.&f.05rice out=work&y.&f.06rice;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data work&y.&f.07rice (keep=V84 V_NUM_RI);
     set work&y.&f.06rice;

     by V84;

     retain V_NUM_RI 0;

     if first.V84 then V_NUM_RI=0;

     if Q6_16=1 then V_NUM_RI=V_NUM_RI+1;

    if last.V84 then output;

run;

** # Rice-Growing HHs using EXTRA LABOR in Village Variable **;

data work&y.&f.01extra;
     set work&y.&f.16 (keep=HHID94 H_TOT_T);
run;

data work&y.&f.02extra;
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=work&y.&f.02extra  out=work&y.&f.03extra nodupkey;
     by HHID94 v84;
run;

data work&y.&f.04extra;
     merge work&y.&f.01extra (in=a)
           work&y.&f.03extra (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;


proc sort data=work&y.&f.04extra out=work&y.&f.05extra;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data work&y.&f.06extra (drop=H_TOT_T HHID94);
     set work&y.&f.05extra;

     by V84;

     retain V_NUM_EX 0;

     if first.V84 then V_NUM_EX=0;

     if H_TOT_T>0 then V_NUM_EX=V_NUM_EX+1;

    if last.V84 then output;

run;

data work&y.&f.21;
     merge work&y.&f.20
           work&y.&f.03hh
           work&y.&f.07rice
           work&y.&f.06extra;
     by V84;
run;

data work&y.&f.22;
     set work&y.&f.21;

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

data work&y.&f.23;     ** Create traditional dichotomous measure for comparision **;
     set work&y.&f.22;

     if V_ANY_PD > 0 then V_PD_0_1=1;
     else V_PD_0_1=0;
run;

data ot&y.&f.02.c2_9403B;
     set work&y.&f.23;
run;

data ot&y.&f.03.c2_94HHB;
     set work&y.&f.16;
run;


****c2_94_07**********VILL*********************************************************************************;
***********************************************************************************************************;

****************************************
**  Bring in Network Data from UCINET **
****************************************;

proc import datafile='/afs/isis.unc.edu/home/j/r/jrhull/a_data/Village_Vars_94.txt' out=work&y.&f.24 dbms=tab replace;
     getnames=yes;
     datarow=2;
run;

*******************************************
**  Bring in village-level on rice labor **
*******************************************;

data work&y.&f.25 (drop=V84);
     set work&y.&f.11;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

data work&y.&f.26 (drop=V84);
     set work&y.&f.23;
     attrib _all_ label='';
     V84N=input(V84,2.);
run;

 data work&y.&f.27;
     merge work&y.&f.24
           work&y.&f.25 (rename=(V84N=V84))
           work&y.&f.26 (rename=(V84N=V84));
     by V84;
run;

data work&y.&f.28 (drop=V_NUM_T1 V_NUM_P1 V_NUM_F1 V_PRO_P1 V_PRO_F1
                     V_NUM_T4 V_NUM_P4 V_NUM_F4 V_PRO_P4 V_PRO_F4
                     V_NUM_T5 V_NUM_P5 V_NUM_F5 V_PRO_P5 V_PRO_F5
                     V_NUM_T6 V_NUM_P6 V_NUM_F6 V_PRO_P6 V_PRO_F6
                     V_NUM_T8 V_NUM_P8 V_NUM_F8 V_PRO_P8 V_PRO_F8
                     V_NUM_T9 V_NUM_P9 V_NUM_F9 V_PRO_P9 V_PRO_F9
                     );
     set work&y.&f.27;

     if V84 ne 44;   *** VILLAGE 44 IS A SERIOUS OUTLIER AND I HAVE DECIDED TO REMOVE IT FROM ANALYSIS ***;

run;

** Output dataset so that it can also be used in STATA **;

data ot&y.&f.04.c2_9407B;
     set work&y.&f.28;
run;


***c2_94_08***********HH*******************************************************************************;
*******************************************************************************************************;

*************************************************
** Data Preparation - Create HH Vars and Merge **
*************************************************;

**********************
** Degree Variables **
**********************;

** import household network data by villages: rice degree **;

%macro imp_hh_1 (numvill=);

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/hh/r94_p);
%let p2=%quote(_FreemanDegree_asym_nref.txt);

%do i=1 %to &numvill;

    data v94_r&i.01;
         infile "&p1.&i.&p2";
         input @2 HHID94 :$9. +5 HG_ROR +5 HG_RIR +5 HGNROR +5 HGNRIR;
         if substr(HHID94,9,1)='"' then HHID94=substr(HHID94,1,8);
    run;

%end;

%mend imp_hh_1;

%imp_hh_1 (numvill=51);


** import household network data by villages: sibling degree **;

%macro imp_hh_2 (numvill=);

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/hh/r94_s);
%let p2=%quote(_FreemanDegree_asym_nref.txt);

%do i=1 %to &numvill;

    data v94_s&i.01;
         infile "&p1.&i.&p2";
         input @2 HHID94 :$9. +5 HG_ROS +5 HG_RIS +5 HGNROS +5 HGNRIS;
         if substr(HHID94,9,1)='"' then HHID94=substr(HHID94,1,8);
    run;

%end;

%mend imp_hh_2;

%imp_hh_2 (numvill=51);


** Append all village files into a single file: rice degree **;

data allvillrg&f.01;
     input HHID94 HG_RSR94 HG_ROR94 HG_RIR94 HGNROR94 HGNRIR94;
     datalines;
;
run;

%macro compile1(numvill=);

%do i=1 %to &numvill;

    data v94_r&i.02 (drop=HHID94C HG_ROR HG_RIR HGNROR HGNRIR);
         set v94_r&i.01 (rename=(HHID94=HHID94C));

         HHID94=input(HHID94C,best12.);
         HG_ROR94=input(HG_ROR, best12.);
         HG_RIR94=input(HG_RIR, best12.);
         HGNROR94=input(HGNROR, best12.);
         HGNRIR94=input(HGNRIR, best12.);

         HG_RSR94=HG_ROR94+HG_RIR94;

    run;

    proc append base=allvillrg&f.01 data=v94_r&i.02;
    run;

%end;

%mend compile1;

%compile1(numvill=51);



** Append all village files into a single file: sibling degree **;


data allvillsg&f.01;
     input HHID94 HG_RSS94 HG_ROS94 HG_RIS94 HGNROS94 HGNRIS94;
     datalines;
;
run;

%macro compile2(numvill=);

%do i=1 %to &numvill;

    data v94_s&i.02 (drop=HHID94C HG_ROS HG_RIS HGNROS HGNRIS);
         set v94_s&i.01 (rename=(HHID94=HHID94C));

         HHID94=input(HHID94C, best12.);
         HG_ROS94=input(HG_ROS, best12.);
         HG_RIS94=input(HG_RIS, best12.);
         HGNROS94=input(HGNROS, best12.);
         HGNRIS94=input(HGNRIS, best12.);

         HG_RSS94=HG_ROS94+HG_RIS94;

    run;

    proc append base=allvillsg&f.01 data=v94_s&i.02;
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

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/hh/r94_p);
%let p2=%quote(-Geo.txt);

%do i=1 %to &numvill;

    proc import datafile="&p1.&i.&p2" out=v94_r&i.03 dbms=dlm replace;
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

     %let dsid = %sysfunc(open(v94_r&i.03,i));
     %let numvars=%sysfunc(attrn(&dsid,NVARS));

     data v94_r&i.04 (drop= VAR1-VAR&numvars);
          set v94_r&i.03;

     HHID94=input(VAR1,best12.);

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

%let dsid = %sysfunc(open(v94_r&k.04,i));
%let numvars=%sysfunc(attrn(&dsid,NVARS));

data v94_r&k.05 (keep=HHID94 H94R_P1-H94R_P50 H94RPSUM H94RPCNT H94RPAVG);
     set v94_r&k.04;

     length H94R_P1-H94R_P50 8.;

     array rvars(2:&numvars) RVAR2-RVAR&numvars;
     array path(1:50) H94R_P1-H94R_P50;

     do j=1 to 50;
                  path(j)=0;
     end;

     H94RPSUM=0;
     H94RPCNT=0;
     H94RPAVG=0;

     do i=2 to &numvars;

        do l=1 to 49;
                    if rvars(i)=l then path(l)=path(l)+1;
        end;

        if rvars(i) >= 50 then H94R_P50=H94R_P50+1;

        if rvars(i) ^in (.,0) then H94RPCNT=H94RPCNT+1;

     end;

     H94RPSUM=SUM(of RVAR2-RVAR&numvars);

     if H94RPCNT^=0 then H94RPAVG=H94RPSUM/H94RPCNT;

run;

%let dsc=%sysfunc(close(&dsid));

%end;

%mend count_3;

%count_3 (numvill=51);


** Append all village files into a single file: rice pathlength **;

data allvillrp&f.01;
     input HHID94 H94R_P1-H94R_P50 H94RPSUM H94RPCNT H94RPAVG;
     datalines;
;
run;

%macro compile3(numvill=);

%do i=1 %to &numvill;

    proc append base=allvillrp&f.01 data=v94_r&i.05;
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

%let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/hh/r94_s);
%let p2=%quote(-Geo.txt);

%do i=1 %to &numvill;

    proc import datafile="&p1.&i.&p2" out=v94_s&i.03 dbms=dlm replace;
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

     %let dsid = %sysfunc(open(v94_s&i.03,i));
     %let numvars=%sysfunc(attrn(&dsid,NVARS));

     data v94_s&i.04 (drop= VAR1-VAR&numvars);
          set v94_s&i.03;

     HHID94=input(VAR1,best12.);

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

%let dsid = %sysfunc(open(v94_s&k.04,i));
%let numvars=%sysfunc(attrn(&dsid,NVARS));

data v94_s&k.05 (keep=HHID94 H94S_P1-H94S_P50 H94SPSUM H94SPCNT H94SPAVG);
     set v94_s&k.04;

     length H94S_P1-H94S_P50 8.;

     array rvars(2:&numvars) RVAR2-RVAR&numvars;
     array path(1:50) H94S_P1-H94S_P50;

     do j=1 to 50;
                  path(j)=0;
     end;

     H94SPSUM=0;
     H94SPCNT=0;
     H94SPAVG=0;

     do i=2 to &numvars;

        do l=1 to 49;
                    if rvars(i)=l then path(l)=path(l)+1;
        end;

        if rvars(i) >= 50 then H94S_P50=H94S_P50+1;

        if rvars(i) ^in (.,0) then H94SPCNT=H94SPCNT+1;

     end;

     H94SPSUM=SUM(of RVAR2-RVAR&numvars);

     if H94SPCNT^=0 then H94SPAVG=H94SPSUM/H94SPCNT;

run;

%let dsc=%sysfunc(close(&dsid));

%end;

%mend count_4;

%count_4 (numvill=51);



** Append all village files into a single file: sibling pathlength **;

data allvillsp&f.01;
     input HHID94 H94S_P1-H94S_P50 H94SPSUM H94SPCNT H94SPAVG;
     datalines;
;
run;

%macro compile4(numvill=);

%do i=1 %to &numvill;

    proc append base=allvillsp&f.01 data=v94_s&i.05;
    run;

%end;

%mend compile4;

%compile4(numvill=51);

*******************************************
** Merge Degree and Pathlength Variables **
*******************************************;

proc sort data=allvillrg&f.01 out=allvillrg&f.02;
     by HHID94;
run;

proc sort data=allvillsg&f.01 out=allvillsg&f.02;
     by HHID94;
run;

proc sort data=allvillrp&f.01 out=allvillrp&f.02;
     by HHID94;
run;

proc sort data=allvillsp&f.01 out=allvillsp&f.02;
     by HHID94;
run;

data all&f.01;
     merge allvillrg&f.02
           allvillsg&f.02
           allvillrp&f.02
           allvillsp&f.02;
     by HHID94;
run;

** add village 84 variable to file **;

data vill_id_fix&f.01;
     set in&y.&f.03.indiv94;
     keep HHID94 V84;
run;

proc sort data=vill_id_fix&f.01 out=vill_id_fix&f.02 nodupkey;
     by HHID94 v84;
run;

data vill_id_fix&f.03;
     merge all&f.01 (in=a)
           vill_id_fix&f.02 (in=b);

     by HHID94;

     if a=1 and b=1 then output;
run;

proc sort data=vill_id_fix&f.03 out=all&f.02;
     by HHID94;
run;

data ot&y.&f.05.c2_9408B;
     set all&f.02;
run;


**c2_94_09*********HH**********************************************************************************;
*******************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.29 (drop=HHID&y.C);
     set work&y.&f.16 (rename=(HHID&y=HHID&y.C) drop=H_NUM_T4 H_NUM_P4 H_NUM_F4 H_PRO_P4 H_PRO_F4
                                   H_NUM_T5 H_NUM_P5 H_NUM_F5 H_PRO_P5 H_PRO_F5
                                   H_NUM_T6 H_NUM_P6 H_NUM_F6 H_PRO_P6 H_PRO_F6
                                   H_NUM_T8 H_NUM_P8 H_NUM_F8 H_PRO_P8 H_PRO_F8
                                   H_NUM_T9 H_NUM_P9 H_NUM_F9 H_PRO_P9 H_PRO_F9
                                   H_NUM_T1 H_NUM_P1 H_NUM_F1 H_PRO_P1 H_PRO_F1);

     HHID&y=input(HHID&y.C, best12.);
run;

data work&y.&f.30;
     set all&f.02 (drop=H&y.S_P17-H&y.S_p50 H&y.R_P12-H&y.R_P50);
run;


data work&y.&f.31;
     merge work&y.&f.29 (in=a)
           work&y.&f.30 (in=b);
     by HHID&y;

     if a=1 then output;

     attrib _all_ label='';

run;

** output dataset  **;

data ot&y.&f.06.c2_9409B;
     set work&y.&f.31;
run;


***c2_94_10****VILL************************************************************************************;
*******************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.32 (drop=V84C);
     set work&y.&f.31 (drop=H&y.R_P1 H&y.R_P2 H&y.R_P3 H&y.R_P4 H&y.R_P5
                                  H&y.R_P6 H&y.R_P7 H&y.R_P8 H&y.R_P9 H&y.R_P10
                                  H&y.R_P11
                                  H&y.S_P1 H&y.S_P2 H&y.S_P3 H&y.S_P4 H&y.S_P5
                                  H&y.S_P6 H&y.S_P7 H&y.S_P8 H&y.S_P9 H&y.S_P10
                                  H&y.S_P11 H&y.S_P12 H&y.S_P13 H&y.S_P14 H&y.S_P15
                                  H&y.S_P16
                            rename=(V84=V84C));
     V84=input(V84C,2.0);
run;

proc sort data=work&y.&f.32 out=work&y.&f.33;
     by HHID&y;
run;

data work&y.&f.34 (drop=HHID&y.C V84C);
     set in&y.&f.03.indiv&y (keep=HHID&y V84 rename=(HHID&y=HHID&y.C V84=V84C));
     HHID&y=input(HHID&y.C,best12.);
     V84=input(V84C,2.0);
run;

proc sort data=work&y.&f.34 out=work&y.&f.35 nodupkey;
     by HHID&y;
run;

data work&y.&f.36;
     merge work&y.&f.33 (in=a)
           work&y.&f.35 (in=b);
     by HHID&y;
     if a=1 and b=1 then output;
run;

proc sort data=work&y.&f.36 out=work&y.&f.37;
     by V84;
run;

data work&y.&f.38 (keep=V84 P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y NUMHHR&y
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.37 (keep=V84 H&y.RPAVG H&y.RPCNT H&y.SPAVG H&y.SPCNT
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

data work&y.&f.43;
     merge work&y.&f.38 (in=a)
           work&y.&f.28 (in=b);
     by V84;
     if a=1 and b=1 then output;
run;

data work&y.&f.44 (drop=P_RSUM&y R_RSUM&y P_SSUM&y R_SSUM&y
                        H_SUM_PD H_SUM_FR H_SUM_IN H_SUM_OT HGSUMR&y HGSUMS&y);
     set work&y.&f.43;

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
     PROPXR&y=V_NUM_EX/V_NUM_RI;
     PROPXH&y=V_NUM_EX/V_NUM_HH;

run;

** output dataset  **;

data ot&y.&f.07.c2_&y.10B;
     set work&y.&f.44;
run;


***c2_94_12***********************************************************************************************;
**********************************************************************************************************;


********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.45;
     set work&y.&f.31;

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

data ot&y.&f.08.c2_&y.12B;
     set work&y.&f.45; ** (keep=HHID94 H_PF_00 H_PF_01 H_PF_11 H_PF_10
                       H_OI_00 H_OI_01 H_OI_11 H_OI_10
                       HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
                       HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG);

run;


**c2_94_13**********************************************************************************************;
********************************************************************************************************;

** Village Level **;

proc corr data=work&y.&f.44;
     var  VH_PX_PD VH_PX_FR VH_PX_OT VH_PX_IN;
     with PROPRH&y PROPXH&y PROPXR&y
          MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.44;
     var VH_PX_PD VH_PX_FR VH_PX_OT VH_PX_IN
         PROPRH&y PROPXH&y PROPXR&y
         MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
         MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
         ;
run;

** Household Level **;

proc corr data=work&y.&f.45;
     var  H_PF_01 H_PF_11 H_PF_10;
     with H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;

proc corr data=work&y.&f.45;
     var  H_PF_01 H_PF_11 H_PF_10
          H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
run;


  ** Village Level Proportion Labor Variable **;

proc corr data=work&y.&f.44;
     var  V_PRO_PD V_PRO_FR;
     with MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
          MG_NSS&y MRSNSR&y MPSNSR&y MDNNS&y MC_NSS&y
          ;
run;

proc corr data=work&y.&f.44;
     var  V_PRO_PD V_PRO_FR
          MG_NSR&y MRRNSR&y MPRNSR&y MDNNR&y MC_NSR&y
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


************************************************************
** Partial Correlation Analysis - NEWLY ADDED TO C2_94_14 **
************************************************************;

** Bring in land data from Chapter 3 rather than starting from scratch **;

data work&y.&f.50 (drop=Q6_22);
     set in&y.&f.01.hh94 (keep=HHID94 Q6_22);

     if Q6_22=9998 then RICE_YLD=0;
             else if Q6_22=9999 then RICE_YLD=.;
             else RICE_YLD=Q6_22;
run;

data work&y.&f.51;
     set ot&y.&f.08.c2_&y.12B;  *** A shortcut, when running entire script, should be work&y.&f.45 **;
run;

data work&y.&f.52;
     merge work&y.&f.50 (in=a)
           work&y.&f.51 (in=b);
     by HHID94;
     if b=1 then output;
run;

*** Determine the tertiles for land and labor ***;

proc univariate data=work&y.&f.52;
     var RICE_YLD;
     output out=junk pctlpts=33.333 66.666 pctlpre=p;
run;

proc print;
     format p33_33 p66_66 8.2;
run;                   ** 33% = 240, 67% = 544 **;

proc univariate data=work&y.&f.52;
     var H_TOT_T;
     output out=junk pctlpts=33.333 66.666 pctlpre=p;
run;

proc print;
     format p33_33 p66_66 8.2;
run;                   ** 33% = 3, 67% = 7 **;


data work&y.&f.53;
     set work&y.&f.52;

     if RICE_YLD=. then YLD_TERT=4;
        else if RICE_YLD=<240 then YLD_TERT=1;
        else if RICE_YLD>240 and RICE_YLD=<544 then YLD_TERT=2;
        else if RICE_YLD>544 then YLD_TERT=3;

     if H_TOT_T=. then LAB_TERT=4;
        else if H_TOT_T=<3 then LAB_TERT=1;
        else if H_TOT_T>3 and H_TOT_T=<7 then LAB_TERT=2;
        else if H_TOT_T>7 then LAB_TERT=3;

run;

** Create Variable indicating case groupings by tertiles **;

data work&y.&f.54;
     set work&y.&f.53;

     if YLD_TERT=1 and LAB_TERT=1 then CORR_BOX=1;
     if YLD_TERT=1 and LAB_TERT=2 then CORR_BOX=2;
     if YLD_TERT=1 and LAB_TERT=3 then CORR_BOX=3;
     if YLD_TERT=2 and LAB_TERT=1 then CORR_BOX=4;
     if YLD_TERT=2 and LAB_TERT=2 then CORR_BOX=5;
     if YLD_TERT=2 and LAB_TERT=3 then CORR_BOX=6;
     if YLD_TERT=3 and LAB_TERT=1 then CORR_BOX=7;
     if YLD_TERT=3 and LAB_TERT=2 then CORR_BOX=8;
     if YLD_TERT=3 and LAB_TERT=3 then CORR_BOX=9;               ** I need corr_box = 1, 3, 7, and 9 **;
run;

proc freq;
     tables corr_box;
run;

** Re-Run Correlations on top and bottom thirds of each variable separately **;

proc sort data=work&y.&f.54 out=work&y.&f.55;
     by CORR_BOX HHID94;
run;

proc corr data=work&y.&f.55;
     var  H_PF_01 H_PF_11 H_PF_10;
     with H_OI_01 H_OI_11 H_OI_10
          HG_RSR&y HG_ROR&y HG_RIR&y H&y.RPCNT H&y.RPAVG
          HG_RSS&y HG_ROS&y HG_RIS&y H&y.SPCNT H&y.SPAVG;
     by CORR_BOX;
run;
