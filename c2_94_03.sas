*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_03.sas
**     Programmer: james r. hull
**     Start Date: 2009 February 15
**     Purpose:
**        1.) Generate Tables for Chapter 2 - HH LEVEL AGGREGATION
**     Input Data:
**        1.) /nangrong/data_sas/1994/current/hh94.02
**        2.) /nangrong/data_sas/1994/current/helprh94.01
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_94_03.xpt
**
**      NOTES: FILE 02 COLLAPSES VILLAGES W/O HHs first
**             FILE 03 COLLAPSES BY HH FIRST then by VILLAGE
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

title1 'Analysis of LABORERS for Chapter 2';

**********************
**  Data Libraries  **
**********************;

libname in94_31 xport '/nangrong/data_sas/1994/current/hh94.03';
libname in94_32 xport '/nangrong/data_sas/1994/current/helprh94.01';
libname ext94_31 xport '/nangrong/data_sas/1994/current/indiv94.05';

libname out94_31 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_03.xpt';
libname out94_32 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_HH.xpt';


******************************
**  Create Working Dataset  **
******************************;

***********************************************************
**  Variables initially in dataset:
**
**  hhid94 = 1994 identifiers
**  hhtype94
**  lekti94
**  vill94
**  lekti84 = 1984 identifiers
**  vill84
**  house84
**  hhid84
**  Q6_16 = In the last year, did this household grow rice?
**  Q6_17 = In the last year, how many rai did this
**          household plant in rice?
**  Q6_18 = In the last year, during what months did
**          this household plant rice?
**  Q6_19 = In the last year, how long did it take to
**          plant rice?
**  Q6_20 = In the last year, this household used how
**          many people to plant rice?
**  Q6_21 = In the last year, this household harvested
**          rice during which months?
**  Q6_22 = In the last year, how much rice was harvested?
**  Q6_23 = Number of people coded 2 or 3 on Q1.1 who
**          helped with harvesting rice last year.
**  Q23A1-5 = CEP94 # from form 1
**  Q23B1-5 = Number of days
**  Q23C1-5 = Type of labor (Hired, Helped without pay,
**            N/A, missing)
**  Q23D1-5 = Wage per day
**  f6fFL = Does this household have form 6 data?
**
**  These variables come from the social network file:
**
**  Q6_24A = Did anyone from this village (or another village)
**           help to harvest rice in the last year?
**  Q6_24B = Number of people
**  Q6_24C = Number of days
**  Q6_24D = Type of labor (hired, helped without pay,
**           worked together)
**  Q6_24E = Wage per day
************************************************************;
* This code stacks the code 2&3 help into a child file *;
* It adds the location=9 variable and codes # helpers=1 for all *;


data work94_301;
     set in94_31.hh94 (keep=hhid94 Q6_23A: Q6_23B: Q6_23C: Q6_23D:);
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


********************************************************************
**  Label helping households according to source of labor         **
********************************************************************;

********************************************************************
**  0 In this village Ban Lek Ti + 0000
**  2 In this village but blt is unknown 997 + 0000
**  1 In this split village Ban Lek Ti + Village #
**  3 In this split village but blt is unknown 997 + Village #
**  4 Another village in Nang Rong 000 + Village #
**  5 Another district in Buriram 000 + District #
**  6 Another province 000 + Province #
**  7 Another country 000 + Country #
**  8 Missing/Don't know 9999999
**  9 Code 2 or 3 Returning HH member
*******************************************************************;


data work94_302;
     set in94_32.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E);

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

        if Q6_24C=99 then Q6_24C=1;        *RECODES*;    *If number of days unknown, code as "."*;
        if Q6_24B=99 then Q6_24B=1;                      *If number of workers unknown, code as "."*;
                                                         *No recodes needed for Q6_24D *;
        if Q6_24E=996 then Q6_24E=.;                     *If wages unknown, code as "."  *;
           else if Q6_24E=998 then Q6_24E=.;             *The above recodes to 1 impact 22 and 12 helping hhs respectively *;
           else if Q6_24E=999 then Q6_24E=.;             *The logic is that if the hh was named then at least*;
run;                                                     * one person worked for at least 1 day *;

/* proc freq data=work94_2;
     tables LOCATION;
run;

proc freq data=work94_2;
     tables Q6_24C Q6_24B Q6_24D Q6_24E;
run; */

data work94_303;
     set work94_301
         work94_302;
run;


***************************************************************************
** Add V84 identifiers to 1994 data file as per Rick's comments on web   **
***************************************************************************;

proc sort data=work94_303 out=work94_304;
     by hhid94 q6_24a LOCATION;
run;

data vill_id_fix301;
     set ext94_31.indiv94;
     keep HHID94 V84;
run;

proc sort data=vill_id_fix301 out=vill_id_fix302 nodupkey;
     by HHID94 v84;
run;

data vill_id_fix303;
     merge work94_304 (in=a)
           vill_id_fix302 (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=vill_id_fix303 out=work94_305;
     by HHID94;                            ** AT THIS STEP, SORT IS NOW BY HHID94 **;
run;

proc freq data=work94_305;
     tables Q6_24D;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 11 cases (a case here is a helper group)        **
******************************************************************************;

data work94_306;
     set work94_305;

     if Q6_24D ^in (.,9) then output;
run;

proc freq data=work94_306;
     tables Q6_24D;
run;

proc freq data=work94_306;
     tables LOCATION;
run;


***************************************************************
** The Following code is executed for each possible location **
***************************************************************;

** 2/15/09: I collapsed original categories 0 through 3 -> 1 **;
** Category 7 had no cases in either year **;

* Location=0 *;

/* data work94_7_0 (keep=V84 V_NUM_T0 V_NUM_P0 V_NUM_F0);  * Collapse into Villages *;
     set work94_6 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T0 V_NUM_P0 V_NUM_F0 0;

  if first.V84 then do;
                          V_NUM_T0=0;
                          V_NUM_P0=0;
                          V_NUM_F0=0;
                       end;

  if LOCATION in (0,2) then do;
                        V_NUM_T0=V_NUM_T0+Q6_24B;
                        if Q6_24D=1 then V_NUM_P0=V_NUM_P0+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F0=V_NUM_F0+Q6_24B;
                     end;

  if last.V84 then output;

  label V_NUM_T0='Total Number Persons Helping';
  label V_NUM_P0='Total Number Persons Helping for Pay';
  label V_NUM_F0='Total Number Persons Helping for Free';

run;

data work94_8_0;                                          * Create Proportion Variable *;
     set work94_7_0;

     V_PRO_P0=ROUND(V_NUM_P0/(V_NUM_T0+0.0000001),.0001);

     if V_NUM_T0=0 then do;
                           V_NUM_T0=".";
                           V_NUM_P0=".";
                           V_NUM_F0=".";
                           V_PRO_P0=".";
                        end;

     label V_PRO_P0='Proportion Same Village Paid';
run;  */


* Location=1 *;

data work94_307_1 (keep=HHID94 H_NUM_T1 H_NUM_P1 H_NUM_F1);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_1;                                          * Create Proportion Variable *;
     set work94_307_1;

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

data work94_7_2 (keep=V84 V_NUM_T2 V_NUM_P2 V_NUM_F2);  * Collapse into Villages *;
     set work94_6 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T2 V_NUM_P2 V_NUM_F2 0;

  if first.V84 then do;
                          V_NUM_T2=0;
                          V_NUM_P2=0;
                          V_NUM_F2=0;
                       end;

  if LOCATION=2 then do;
                        V_NUM_T2=V_NUM_T2+Q6_24B;
                        if Q6_24D=1 then V_NUM_P2=V_NUM_P2+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F2=V_NUM_F2+Q6_24B;
                     end;

  if last.V84 then output;

  label V_NUM_T2='Total Number Persons Helping';
  label V_NUM_P2='Total Number Persons Helping for Pay';
  label V_NUM_F2='Total Number Persons Helping for Free';

run;

data work94_8_2;                                          * Create Proportion Variable *;
     set work94_7_2;

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

data work94_7_3 (keep=V84 V_NUM_T3 V_NUM_P3 V_NUM_F3);  * Collapse into Villages *;
     set work94_6 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T3 V_NUM_P3 V_NUM_F3 0;

  if first.V84 then do;
                          V_NUM_T3=0;
                          V_NUM_P3=0;
                          V_NUM_F3=0;
                       end;

  if LOCATION=3 then do;
                        V_NUM_T3=V_NUM_T3+Q6_24B;
                        if Q6_24D=1 then V_NUM_P3=V_NUM_P3+Q6_24B;
                        if Q6_24D in (2,3) then V_NUM_F3=V_NUM_F3+Q6_24B;
                     end;

  if last.V84 then output;

  label V_NUM_T3='Total Number Persons Helping';
  label V_NUM_P3='Total Number Persons Helping for Pay';
  label V_NUM_F3='Total Number Persons Helping for Free';

run;

data work94_8_3;                                          * Create Proportion Variable *;
     set work94_7_3;

     V_PRO_P3=ROUND(V_NUM_P3/(V_NUM_T3+0.0000001),.0001);

     if V_NUM_T3=0 then do;
                           V_NUM_T3=".";
                           V_NUM_P3=".";
                           V_NUM_F3=".";
                           V_PRO_P3=".";
                        end;

     label V_PRO_P3='Proportion Split Missing Paid';
run;  */

* Location=4 *;

data work94_307_4 (keep=HHID94  H_NUM_T4 H_NUM_P4 H_NUM_F4);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_4;                                          * Create Proportion Variable *;
     set work94_307_4;

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

data work94_307_5 (keep=HHID94  H_NUM_T5 H_NUM_P5 H_NUM_F5);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_5;                                          * Create Proportion Variable *;
     set work94_307_5;

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

data work94_307_6 (keep=HHID94  H_NUM_T6 H_NUM_P6 H_NUM_F6);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_6;                                          * Create Proportion Variable *;
     set work94_307_6;

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

data work94_7_7 (keep=V84 V_NUM_T7 V_NUM_P7 V_NUM_F7);  * Collapse into Villages *;
     set work94_6 (keep=V84 Q6_24B Q6_24D LOCATION);

     by V84;

  retain V_NUM_T7 V_NUM_P7 V_NUM_F7 0;

  if first.V84 then do;
                          V_NUM_T7=0;
                          V_NUM_P7=0;
                          V_NUM_F7=0;
                       end;

  if LOCATION=7 then do;
                        V_NUM_T7=V_NUM_T7+Q6_24B;
                        if Q6_24D=1 then V_NUM_P7=V_NUM_P7+Q7_24B;
                        if Q6_24D in (2,3) then V_NUM_F7=V_NUM_F7+Q6_24B;
                     end;

  if last.V84 then output;

  label V_NUM_T7='Total Number Persons Helping';
  label V_NUM_P7='Total Number Persons Helping for Pay';
  label V_NUM_F7='Total Number Persons Helping for Free';

run;

data work94_8_7;                                          * Create Proportion Variable *;
     set work94_7_7;

     V_PRO_P7=ROUND(V_NUM_P7/(V_NUM_T7+0.0000001),.0001);

     if V_NUM_T7=0 then do;
                           V_NUM_T7=.;
                           V_NUM_P7=.;
                           V_NUM_F7=.;
                           V_PRO_P7=.;
                        end;

     label V_PRO_P7='Proportion Other Country Paid';
run;  */


* Location=8 *;

data work94_307_8 (keep=HHID94  H_NUM_T8 H_NUM_P8 H_NUM_F8);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_8;                                          * Create Proportion Variable *;
     set work94_307_8;

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

data work94_307_9 (keep=HHID94  H_NUM_T9 H_NUM_P9 H_NUM_F9);  * Collapse into HHs *;
     set work94_306 (keep=HHID94  Q6_24B Q6_24D LOCATION);

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

data work94_308_9;                                          * Create Proportion Variable *;
     set work94_307_9;

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



data work94_309;
     merge /* work94_8_0 */
           work94_308_1
           /*work94_8_2*/
           /*work94_8_3*/
           work94_308_4
           work94_308_5
           work94_308_6
           /* work94_8_7 */
           work94_308_8
           work94_308_9;
     by HHID94;
run;


*****************************************************
** Some Starter Descriptive Analysis that May Move **
*****************************************************;

proc means mean std sum min max data=work94_308_1;
run;

proc means mean std sum min max data=work94_308_4;
run;

proc means mean std sum min max data=work94_308_5;
run;

proc means mean std sum min max data=work94_308_6;
run;

proc means mean std sum min max data=work94_308_8;
run;

proc means mean std sum min max data=work94_308_9;
run;

proc means mean std sum min max data=work94_306;
    var Q6_24B;
run;

proc sort data=work94_306 out=work94_310;
     by Q6_24D HHID94;
run;

proc means mean std sum min max data=work94_310;
     var Q6_24B;
     by Q6_24D;
run;

*****************************************************
**  A Simple Household-level correlational analysis  **
*****************************************************;

** NOTE: The code that follows will be affected by any **
** changes to the grouping of cases above done on 2/15 **;

** Code 2 & 3 excluded from analysis, as well as unknown location **;

** After examining the data for 1994 and 2000, I found very few cases  **
** in which a household mixed payment strategies or labor sources, so  **
** the decision to recode these variables to dichotomous indicators    **
** 0,any seems a sensible way to simplify the data analysis. For the   **
** variable H_PRO_PD, roughly 3% in either year fell between 0 and 1,  **
** while for H_PRO_OT it was somewhere near 8% in either year. 3/10    **;

data work94_311 (drop=ZIPPO);
     set work94_309;
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

proc means data=work94_311 MEAN MEDIAN STD MIN MAX;
     var H_TOT_T H_TOT_P H_TOT_F H_TOT_IN H_TOT_OT
         H_PRO_PD H_PRO_IN H_PRO_OT H_ANY_PD H_ANY_OT;
run;

proc corr data=work94_311;
     var H_ANY_PD H_ANY_OT;
run;

proc freq data=work94_311;
     tables H_ANY_PD*H_ANY_OT / chisq;
run;



**************************************************************
** Create Village Level Variables from Household Level Data **
**************************************************************;

proc sort data=work94_310 out=work94_312;
     by HHID94 V84;
run;

data work94_313 (keep=V84 HHID94 H_NUM_PD H_NUM_FR H_NUM_OT H_NUM_IN);
     set work94_312 (keep=V84 HHID94 LOCATION Q6_24D);

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

     label H_NUM_PD='Num ties HH in Village Use PAID Labor';
     label H_NUM_FR='Num ties HH in Village Use FREE Labor';
     label H_NUM_OT='Num ties HH in Village Use OUTSIDE Labor';
     label H_NUM_IN='Num ties HH in Village Use INSIDE Labor';

run;

proc sort data=work94_313 out=work94_314;
     by V84;
run;

data work94_315 (keep=V84 V_ANY_PD V_ANY_FR V_ANY_OT V_ANY_IN);
     set work94_314;

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
     set ext94_31.indiv94;
     keep HHID94 V84;
run;

proc sort data=all_hh_301 out=all_hh_302 nodupkey;
     by V84 HHID94;
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
     set in94_31.hh94 (keep=hhid94 Q6_16);
run;

proc sort data=all_rice_301 out=all_rice_302;
     by hhid94;
run;

data all_rice_303;
     set ext94_31.indiv94;
     keep HHID94 V84;
run;

proc sort data=all_rice_303 out=all_rice_304 nodupkey;
     by HHID94 v84;
run;

data all_rice_305;
     merge all_rice_302 (in=a)
           all_rice_304 (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=all_rice_305 out=all_rice_306;
     by V84;                            ** AT THIS STEP, SORT IS NOW BY V84 **;
run;

data all_rice_307 (keep=V84 V_NUM_RI);
     set all_rice_306;

     by V84;

     retain V_NUM_RI 0;

     if first.V84 then V_NUM_RI=0;

     if Q6_16=1 then V_NUM_RI=V_NUM_RI+1;

    if last.V84 then output;

run;

data work94_316;
     merge work94_315
           all_hh_303
           all_rice_307;
     by V84;
run;

data work94_317;
     set work94_316;

     VH_PH_PD=V_ANY_PD/V_NUM_HH;
     VH_PH_FR=V_ANY_FR/V_NUM_HH;
     VH_PH_OT=V_ANY_OT/V_NUM_HH;
     VH_PH_IN=V_ANY_IN/V_NUM_HH;

     /* label VH_PH_PD='Prop HHs in Village Use PAID Labor';
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

proc means data=work94_317 MEAN MEDIAN STD MIN MAX;
     var VH_PR_PD VH_PR_FR VH_PR_OT VH_PR_IN
         VH_PH_PD VH_PH_FR VH_PH_OT VH_PH_IN;

run;


proc corr data=work94_317 outp=pearson94_301;
     var VH_PR_PD VH_PR_OT VH_PR_FR VH_PR_IN;
run;

proc corr data=work94_317 outp=pearson94_302;
     var VH_PH_PD VH_PH_OT VH_PH_FR VH_PH_IN;
run;


data work94_318;     ** Create traditional dichotomous measure for comparision **;
     set work94_317;

     if V_ANY_PD > 0 then V_PD_0_1=1;
     else V_PD_0_1=0;
run;

proc means data=work94_318 MEAN MEDIAN STD MIN MAX;
     var V_PD_0_1;
run;


data out94_31.c2_94_03;
     set work94_318;
run;

data out94_32.c2_94_HH;
     set work94_311;
run;
