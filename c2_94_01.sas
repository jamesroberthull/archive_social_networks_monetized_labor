*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_01.sas
**     Programmer: james r. hull
**     Start Date: 2008 MARCH 14
**     Purpose:
**        1.) Create variables for first go at chapter 2
**     Input Data:
**        1.) /nangrong/data_sas/1994/current/hh94.02
**        2.) /nangrong/data_sas/1994/current/helprh94.01
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_94_01.xpt
**
**      NOTES:
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

title1 'Analysis of Social Distance and Rice Networks';

**********************
**  Data Libraries  **
**********************;

libname in94_1 xport '/nangrong/data_sas/1994/current/hh94.03';
libname in94_2 xport '/nangrong/data_sas/1994/current/helprh94.01';

libname out94_1 xport '/trainee/jrhull/diss/ch2/c2data/c2_94_01.xpt';


******************************
**  Create Working Dataset  **
******************************;

***********************************************************
**  Variables initially in Work1 dataset:
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


data work94_1;
     set in94_1.hh94;
     keep hhid94 hhtype94 lekti84 vill84 house84 hhid84 lekti94 vill94
          Q6_16 Q6_17 Q6_18 Q6_19 Q6_20 Q6_21 Q6_22 Q6_23
          Q6_23A: Q6_23B: Q6_23C: Q6_23D:;
     rename Q6_16=RICE Q6_23=HELP23B Q6_23A1=HELP23C1 Q6_23A2=HELP23C2
          Q6_23A3=HELP23C3 Q6_23A4=HELP23C4 Q6_23A5=HELP23C5
          Q6_23B1=HELP23D1 Q6_23B2=HELP23D2 Q6_23B3=HELP23D3
          Q6_23B4=HELP23D4 Q6_23B5=HELP23D5 Q6_23C1=HELP23F1
          Q6_23C2=HELP23F2 Q6_23C3=HELP23F3 Q6_23C4=HELP23F4
          Q6_23C5=HELP23F5 Q6_23D1=HELP23G1 Q6_23D2=HELP23G2
          Q6_23D3=HELP23G3 Q6_23D4=HELP23G4 Q6_23D5=HELP23G5;

run;

/* proc contents data=work94_1 varnum;
run; */


********************************************************************
**  Separate helping households into same and different villages  **
********************************************************************;

/*NEED TO DOUBLE CHECK THE GROUPING OF THE CASES IN THE NEXT STEP*/


 /*
 In this village Ban Lek Ti + 0000        0
 In this village but blt is unknown 997 + 0000   1
 In this split village Ban Lek Ti + Village #    2
 In this split village but blt is unknown 997 + Village #  3
 Another village in Nang Rong 000 + Village #   4
 Another district in Buriram 000 + District #   5
 Another province 000 + Province #              6
 Another country 000 + Country #                7
 Missing/Don't know 9999999                     8
 */


data work94_2;
     set in94_2.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E);

     if Q6_24A in ('9999997','0009999','9999999') then LOCATION=8; /*allmissing*/
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=5 then LOCATION=7; /*country*/
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=4 then LOCATION=6; /*province*/
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=3 then LOCATION=5; /*district*/
        else if substr(Q6_24A,1,3)='000' and substr(Q6_24A,4,1)=2 then LOCATION=4; /*othervill*/
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)=2 then LOCATION=3; /*splitmissing*/
        else if substr(Q6_24A,1,3)='997' and substr(Q6_24A,4,1)=0 then LOCATION=2; /*samemissing*/
        else if substr(Q6_24A,4,4)='9999' then LOCATION=2; /*samemissing*/
        else if substr(Q6_24A,4,4)='0000' then LOCATION=0; /*samevill*/
        else if substr(Q6_24A,4,1)='2' then LOCATION=1; /*splitvill*/
        else if substr(Q6_24A,4,1)='0' then LOCATION=1; /*splitvill*/
        else LOCATION=.;                                /* LOGIC PROBLEMS IF . > 0 */

        if Q6_24C=99 then Q6_24C=1;          /*RECODES*/ /*If number of days unknown, code as 1*/
        if Q6_24B=99 then Q6_24B=1;                      /*If number of workers unknown, code as 1*/
        if Q6_24E=996 then Q6_24E=.;                       /*If wages unknown, code as "."  */
           else if Q6_24E=998 then Q6_24E=.;
           else if Q6_24E=999 then Q6_24E=.;

run;

proc freq data=work94_2;
     tables LOCATION;
run;


data allmissing country province district othervill splitmissing samemissing samevill splitvill;
     set work94_2;
     if LOCATION=0 then output samevill;
        else if LOCATION=1 then output splitvill;
        else if LOCATION=2 then output samemissing;
        else if LOCATION=3 then output splitmissing;
        else if LOCATION=4 then output othervill;
        else if LOCATION=5 then output district;
        else if LOCATION=6 then output province;
        else if LOCATION=7 then output country;
        else if LOCATION=8 then output allmissing;
run;

/*Used this code to check the max number of cases*/

/* proc freq data=allmissing; *2 max*;
     tables HHID94;
run;

proc freq data=country; *0 max*;
     tables HHID94;
run;

proc freq data=province; *1 max*;
     tables HHID94;
run;

proc freq data=district;  *1 max*;
     tables HHID94;
run;

proc freq data=othervill; *4 max*;
     tables HHID94;
run;

proc freq data=splitmissing;  *2 max*;
     tables HHID94;
run;

proc freq data=samemissing;   *2 max*;
     tables HHID94;
run;

proc freq data=splitvill; *50 max*;
     tables HHID94;
run;

proc freq data=samevill;  *30 max*;
     tables HHID94;
run;    */


********************************************************************************
**  Un-stack data in location split files to create single cases for each HH  **
********************************************************************************;

/*File 8 allmissing - max number of variables is 2*/

data allmissing_2 (keep=HELP8C1-HELP8C2 HELP8E1-HELP8E2 HELP8D1-HELP8D2
     HELP8F1-HELP8F2 HELP8G1-HELP8G2 HHID94);
     set allmissing (rename=(Q6_24A=HELP8C Q6_24B=HELP8E Q6_24C=HELP8D
      Q6_24D=HELP8F Q6_24E=HELP8G));

   by HHID94;

   length HELP8C1-HELP8C2 $ 7;

   retain HELP8C1-HELP8C2 HELP8E1-HELP8E2 HELP8D1-HELP8D2
          HELP8F1-HELP8F2 HELP8G1-HELP8G2 i;

   array c(1:2) HELP8C1-HELP8C2;
   array e(1:2) HELP8E1-HELP8E2;
   array d(1:2) HELP8D1-HELP8D2;
   array f(1:2) HELP8F1-HELP8F2;
   array g(1:2) HELP8G1-HELP8G2;

   if first.HHID94 then do;
                           do j=1 to 2;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP8C;
   e(i)=HELP8E;
   d(i)=HELP8D;
   f(i)=HELP8F;
   g(i)=HELP8G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 7 country - max number of variables is 0*/ /*SKIP*/


/*File 6 province - max number of variables is 1*/

data province_2 (keep=HELP6C1 HELP6E1 HELP6D1
     HELP6F1 HELP6G1 HHID94);
     set province (rename=(Q6_24A=HELP6C Q6_24B=HELP6E Q6_24C=HELP6D
      Q6_24D=HELP6F Q6_24E=HELP6G));

   by HHID94;

   length HELP6C1 $ 7;

   retain HELP6C1 HELP6E1 HELP6D1
          HELP6F1 HELP6G1 i;

   array c(1:1) HELP6C1;
   array e(1:1) HELP6E1;
   array d(1:1) HELP6D1;
   array f(1:1) HELP6F1;
   array g(1:1) HELP6G1;

   if first.HHID94 then do;
                           do j=1 to 1;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP6C;
   e(i)=HELP6E;
   d(i)=HELP6D;
   f(i)=HELP6F;
   g(i)=HELP6G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 5 district - max number of variables is 1*/

data district_2 (keep=HELP5C1 HELP5E1 HELP5D1
     HELP5F1 HELP5G1 HHID94);
     set district (rename=(Q6_24A=HELP5C Q6_24B=HELP5E Q6_24C=HELP5D
      Q6_24D=HELP5F Q6_24E=HELP5G));

   by HHID94;

   length HELP5C1 $ 7;

   retain HELP5C1 HELP5E1 HELP5D1
          HELP5F1 HELP5G1 i;

   array c(1:1) HELP5C1;
   array e(1:1) HELP5E1;
   array d(1:1) HELP5D1;
   array f(1:1) HELP5F1;
   array g(1:1) HELP5G1;

   if first.HHID94 then do;
                           do j=1 to 1;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP5C;
   e(i)=HELP5E;
   d(i)=HELP5D;
   f(i)=HELP5F;
   g(i)=HELP5G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 4 othervill - max number of variables is 4*/

data othervill_2 (keep=HELP4C1-HELP4C4 HELP4E1-HELP4E4 HELP4D1-HELP4D4
     HELP4F1-HELP4F4 HELP4G1-HELP4G4 HHID94);
     set othervill (rename=(Q6_24A=HELP4C Q6_24B=HELP4E Q6_24C=HELP4D
      Q6_24D=HELP4F Q6_24E=HELP4G));

   by HHID94;

   length HELP4C1-HELP4C4 $ 7;

   retain HELP4C1-HELP4C4 HELP4E1-HELP4E4 HELP4D1-HELP4D4
          HELP4F1-HELP4F4 HELP4G1-HELP4G4 i;

   array c(1:4) HELP4C1-HELP4C4;
   array e(1:4) HELP4E1-HELP4E4;
   array d(1:4) HELP4D1-HELP4D4;
   array f(1:4) HELP4F1-HELP4F4;
   array g(1:4) HELP4G1-HELP4G4;

   if first.HHID94 then do;
                           do j=1 to 4;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP4C;
   e(i)=HELP4E;
   d(i)=HELP4D;
   f(i)=HELP4F;
   g(i)=HELP4G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 3 splitmissing - max number of variables is 2*/

data splitmissing_2 (keep=HELP3C1-HELP3C2 HELP3E1-HELP3E2 HELP3D1-HELP3D2
     HELP3F1-HELP3F2 HELP3G1-HELP3G2 HHID94);
     set splitmissing (rename=(Q6_24A=HELP3C Q6_24B=HELP3E Q6_24C=HELP3D
      Q6_24D=HELP3F Q6_24E=HELP3G));

   by HHID94;

   length HELP3C1-HELP3C2 $ 7;

   retain HELP3C1-HELP3C2 HELP3E1-HELP3E2 HELP3D1-HELP3D2
          HELP3F1-HELP3F2 HELP3G1-HELP3G2 i;

   array c(1:2) HELP3C1-HELP3C2;
   array e(1:2) HELP3E1-HELP3E2;
   array d(1:2) HELP3D1-HELP3D2;
   array f(1:2) HELP3F1-HELP3F2;
   array g(1:2) HELP3G1-HELP3G2;

   if first.HHID94 then do;
                           do j=1 to 2;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP3C;
   e(i)=HELP3E;
   d(i)=HELP3D;
   f(i)=HELP3F;
   g(i)=HELP3G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 2 samemissing - max number of variables is 2*/

data samemissing_2 (keep=HELP2C1-HELP2C2 HELP2E1-HELP2E2 HELP2D1-HELP2D2
     HELP2F1-HELP2F2 HELP2G1-HELP2G2 HHID94);
     set samemissing (rename=(Q6_24A=HELP2C Q6_24B=HELP2E Q6_24C=HELP2D
      Q6_24D=HELP2F Q6_24E=HELP2G));

   by HHID94;

   length HELP2C1-HELP2C2 $ 7;

   retain HELP2C1-HELP2C2 HELP2E1-HELP2E2 HELP2D1-HELP2D2
          HELP2F1-HELP2F2 HELP2G1-HELP2G2 i;

   array c(1:2) HELP2C1-HELP2C2;
   array e(1:2) HELP2E1-HELP2E2;
   array d(1:2) HELP2D1-HELP2D2;
   array f(1:2) HELP2F1-HELP2F2;
   array g(1:2) HELP2G1-HELP2G2;

   if first.HHID94 then do;
                           do j=1 to 2;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP2C;
   e(i)=HELP2E;
   d(i)=HELP2D;
   f(i)=HELP2F;
   g(i)=HELP2G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 1 splitvill - max number of variables is 50*/

data splitvill_2 (keep=HELP1C1-HELP1C50 HELP1E1-HELP1E50 HELP1D1-HELP1D50
     HELP1F1-HELP1F50 HELP1G1-HELP1G50 HHID94);
     set splitvill (rename=(Q6_24A=HELP1C Q6_24B=HELP1E Q6_24C=HELP1D
      Q6_24D=HELP1F Q6_24E=HELP1G));

   by HHID94;

   length HELP1C1-HELP1C50 $ 7;

   retain HELP1C1-HELP1C50 HELP1E1-HELP1E50 HELP1D1-HELP1D50
          HELP1F1-HELP1F50 HELP1G1-HELP1G50 i;

   array c(1:50) HELP1C1-HELP1C50;
   array e(1:50) HELP1E1-HELP1E50;
   array d(1:50) HELP1D1-HELP1D50;
   array f(1:50) HELP1F1-HELP1F50;
   array g(1:50) HELP1G1-HELP1G50;

   if first.HHID94 then do;
                           do j=1 to 50;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP1C;
   e(i)=HELP1E;
   d(i)=HELP1D;
   f(i)=HELP1F;
   g(i)=HELP1G;


   i=i+1;

   if last.HHID94 then output;

run;

/*File 0 samevill - max number of variables is 30*/

data samevill_2 (keep=HELP0C1-HELP0C30 HELP0E1-HELP0E30 HELP0D1-HELP0D30
     HELP0F1-HELP0F30 HELP0G1-HELP0G30 HHID94);
     set samevill (rename=(Q6_24A=HELP0C Q6_24B=HELP0E Q6_24C=HELP0D
      Q6_24D=HELP0F Q6_24E=HELP0G));

   by HHID94;

   length HELP0C1-HELP0C30 $ 7;

   retain HELP0C1-HELP0C30 HELP0E1-HELP0E30 HELP0D1-HELP0D30
          HELP0F1-HELP0F30 HELP0G1-HELP0G30 i;

   array c(1:30) HELP0C1-HELP0C30;
   array e(1:30) HELP0E1-HELP0E30;
   array d(1:30) HELP0D1-HELP0D30;
   array f(1:30) HELP0F1-HELP0F30;
   array g(1:30) HELP0G1-HELP0G30;

   if first.HHID94 then do;
                           do j=1 to 30;
                              c(j)='       ';
                              e(j)=0;
                              d(j)=0;
                              f(j)=.;
                              g(j)=.;
                           end;
                           i=1;
                        end;
   c(i)=HELP0C;
   e(i)=HELP0E;
   d(i)=HELP0D;
   f(i)=HELP0F;
   g(i)=HELP0G;


   i=i+1;

   if last.HHID94 then output;

run;



**************************************************************
** Merge all location split files together as a parent file **
**************************************************************;

data work94_3 nowork;
   merge
   work94_1 (in=a)
   allmissing_2
   province_2
   district_2
   othervill_2
   splitmissing_2
   samemissing_2
   splitvill_2
   samevill_2;
   by HHID94;
   if a=1 then output work94_3;
   if a=0 then output nowork;
run;


***************
*** Recodes ***
***************;

data work94_4 (drop=i);

     set work94_3;

     if HELP23B=8 then HELP23B=0;            /* RECODES TO ORIGINAL CODE 2 & 3 STUFF */

     if HELP23B > 0 then HELP23A=1;
        else HELP23A=0;

     array c(1:5) HELP23C1-HELP23C5;
     array d(1:5) HELP23D1-HELP23D5;
     array f(1:5) HELP23F1-HELP23F5;
     array g(1:5) HELP23G1-HELP23G5;

     do i=1 to 5;
        if c(i)='998' then c(i)='   ';
           else if c(i)='999' then c(i)='   ';
        if d(i)=98 then d(i)=.;
           else if d(i)=99  then d(i)=1;
        if f(i)=8 then f(i)=.;
           else if f(i)=9 then f(i)=.;
        if g(i)=996 then g(i)=.;
           else if g(i)=998 then g(i)=.;
           else if g(i)=999 then g(i)=1;
     end;

     array e8(1:2) HELP8E1-HELP8E2;          /*RECODE Missing to 0 so they will sum below */
     array d8(1:2) HELP8D1-HELP8D2;
     array e6(1:1) HELP6E1;
     array d6(1:1) HELP6D1;
     array e5(1:1) HELP5E1;
     array d5(1:1) HELP5D1;
     array e4(1:4) HELP4E1-HELP4E4;
     array d4(1:4) HELP4D1-HELP4D4;
     array e3(1:2) HELP3E1-HELP3E2;
     array d3(1:2) HELP3D1-HELP3D2;
     array e2(1:2) HELP2E1-HELP2E2;
     array d2(1:2) HELP2D1-HELP2D2;
     array e1(1:50) HELP1E1-HELP1E50;
     array d1(1:50) HELP1D1-HELP1D50;
     array e0(01:30) HELP0E1-HELP0E30;
     array d0(1:30) HELP0D1-HELP0D30;

     do i=1 to 2;
        if e8(i)='.' then e8(i)=0;
        if d8(i)='.' then d8(i)=0;
     end;

     do i=1 to 1;
        if e6(i)='.' then e6(i)=0;
        if d6(i)='.' then d6(i)=0;
     end;

      do i=1 to 1;
        if e5(i)='.' then e5(i)=0;
        if d5(i)='.' then d5(i)=0;
     end;

      do i=1 to 4;
        if e4(i)='.' then e4(i)=0;
        if d4(i)='.' then d4(i)=0;
     end;

      do i=1 to 2;
        if e3(i)='.' then e3(i)=0;
        if d3(i)='.' then d3(i)=0;
     end;

      do i=1 to 2;
        if e2(i)='.' then e2(i)=0;
        if d2(i)='.' then d2(i)=0;
     end;

      do i=1 to 50;
        if e1(i)='.' then e1(i)=0;
        if d1(i)='.' then d1(i)=0;
     end;

     do i=1 to 30;
        if e0(i)='.' then e0(i)=0;
        if d0(i)='.' then d0(i)=0;
     end;

     HELP0B=sum(of HELP0E1-HELP0E30);
     HELP1B=sum(of HELP1E1-HELP1E50);
     HELP2B=sum(of HELP2E1-HELP2E2);
     HELP3B=sum(of HELP3E1-HELP3E2);
     HELP4B=sum(of HELP4E1-HELP4E4);
     HELP5B=HELP5E1;
     HELP6B=HELP6E1;
     HELP8B=sum(of HELP8E1-HELP8E2);

     TOTHELP=HELP0B+HELP1B+HELP2B+HELP3B+HELP4B+HELP5B+HELP6B+HELP8B;

     if HELP0B>0 then HELP0A= 1;
        else if HELP0B=0 then HELP0A=0;
        else HELP0A=.;                /*There should be no missing values*/

     if HELP1B>0 then HELP1A= 1;
        else if HELP1B=0 then HELP1A=0;
        else HELP1A=.;                /*There should be no missing values*/

     if HELP2B>0 then HELP2A= 1;
        else if HELP2B=0 then HELP2A=0;
        else HELP2A=.;                /*There should be no missing values*/

     if HELP3B>0 then HELP3A= 1;
        else if HELP3B=0 then HELP3A=0;
        else HELP3A=.;                /*There should be no missing values*/

      if HELP4B>0 then HELP4A= 1;
        else if HELP4B=0 then HELP4A=0;
        else HELP4A=.;                /*There should be no missing values*/

      if HELP5B>0 then HELP5A= 1;
        else if HELP5B=0 then HELP5A=0;
        else HELP5A=.;                /*There should be no missing values*/

      if HELP6B>0 then HELP6A= 1;
        else if HELP6B=0 then HELP6A=0;
        else HELP6A=.;                /*There should be no missing values*/

      if HELP8B>0 then HELP8A= 1;
        else if HELP8B=0 then HELP8A=0;
        else HELP8A=.;                /*There should be no missing values*/

     if RICE=2 then RICE=0;      /* End of Recodes*/

run;


*************************************************************************
** Count up number of transactions of each type - paid, free, exchange **
*************************************************************************;
/*
data work94_10 (drop=HELPVH_1 HELPVH_2 HELPVH_3
                    HELPOH_1 HELPOH_2 HELPOH_3
                    HELP2H_1 HELP2H_2 HELP2H_3 i j k);
     set work94_9;

     array f(1:5) HELP23F1-HELP23F5;
     array vf(1:50) HELPVF1-HELPVF50;         /* I LEFT OFF HERE ON 12/20 IN RE-WRITING FOR ALL GROUPS */
/*   array of(1:4) HELPOF1-HELPOF4;

     HELPVH_1=0;
     HELPVH_2=0;
     HELPVH_3=0;
     HELPOH_1=0;
     HELPOH_2=0;
     HELPOH_3=0;
     HELP2H_1=0;
     HELP2H_2=0;
     HELP2H_3=0;

     do k=1 to 5;
        if f(k)=1 then HELP2H_1=HELP2H_1+1;
           else if f(k)=2 then HELP2H_2=HELP2H_2+1;
           else if f(k)=3 then HELP2H_3=HELP2H_3+1;
     end;

     do i=1 to 50;
        if vf(i)=1 then HELPVH_1=HELPVH_1+1;
           else if vf(i)=2 then HELPVH_2=HELPVH_2+1;
           else if vf(i)=3 then HELPVH_3=HELPVH_3+1;
     end;

     do j=1 to 4;
        if of(j)=1 then HELPOH_1=HELPOH_1+1;
           else if of(j)=2 then HELPOH_2=HELPOH_2+1;
           else if of(j)=3 then HELPOH_3=HELPOH_3+1;
     end;


     if HELPVH_1>0 then HELPVH=1;
        else if HELPVH_2>0 | HELPVH_3>0 then HELPVH=2;
                              else HELPVH=.;

     if HELPOH_1>0 then HELPOH=1;
        else if HELPOH_2>0 | HELPOH_3>0 then HELPOH=2;
                              else HELPOH=.;

     label HELPVH= 'Used village labor 1=paid 2=unpaid';
     label HELPOH= 'Used non-village labor 1=paid 2=unpaid';

     if RICE=0 then HELPDV=1;
        else if RICE=. then HELPDV=.;
        else if HELP23A=0 & HELPVA=0 & HELPOA=0 then HELPDV=2;
        else if HELP23A=1 & HELPVA=0 & HELPOA=0 then HELPDV=3;
        else if (HELPVH ne 1 & HELPOH ne 1) & (HELPVA=1 or HELPOA=1) then HELPDV=4;
        else if HELPVH=1 & HELPOH ne 1 then HELPDV=5;
        else if HELPOH=1 & HELPVH ne 1 then HELPDV=6;
        else if HELPVH=1 & HELPOH=1 then HELPDV=7;

     if RICE=0 then HELPDV2=1;
        else if RICE=. then HELPDV2=.;
        else if HELP23A=0 & HELPVA=0 & HELPOA=0 then HELPDV2=2;
        else if HELP23A=1 & HELPVA=0 & HELPOA=0 then HELPDV2=3;
        else if (HELPVH ne 1 & HELPOH ne 1) & (HELPVA=1 or HELPOA=1) then HELPDV2=3;
        else if HELPVH=1 & HELPOH ne 1 then HELPDV2=4;
        else if HELPOH=1 & HELPVH ne 1 then HELPDV2=4;
        else if HELPVH=1 & HELPOH=1 then HELPDV2=4;

     if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=1;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=2;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=3;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3=0 & HELPVH_3=0 & HELPOH_3=0) then HELPTYPE=4;
        else if (HELP2H_1=0 & HELPVH_1=0 & HELPOH_1=0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=5;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2=0 & HELPVH_2=0 & HELPOH_2=0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=6;
        else if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0)
              & (HELP2H_2>0 | HELPVH_2>0 | HELPOH_2>0)
              & (HELP2H_3>0 | HELPVH_3>0 | HELPOH_3>0) then HELPTYPE=7;
        else HELPTYPE=.;

    if (HELP2H_1>0 | HELPVH_1>0 | HELPOH_1>0) then HELPDV3=1;
       else if RICE=1 then HELPDV3=0;
       else HELPDV3=.;

run;

/* proc freq data=work94_1;
     tables HELPVH HELPOH HELPDV HELPDV2;
run;  */
/*
proc sort data=work94_10 out=sorted84;
     by VILL84;
run;
*/
/* proc freq data=sorted84;
     tables VILL84*HELPDV VILL84*HELPDV2/ NOPERCENT NOCOL NOFREQ;
run; */

/* proc freq data=work94_1;
     tables VILL94*HELPDV VILL94*HELPDV2/ NOPERCENT NOCOL NOFREQ;
run; */

**************************************************************************
*** CREATE AGGREGATE MEASURES OF PERSONS, PERSON-DAYS, AND TOTAL WAGES ***
**************************************************************************;

*** At some point, I will label these newly created variables like a good boy ***;
*** For now, I'll just note that P=persons, PD=Person-Days, and T=Total Wages ***;
*** The rest should be self-explanatory, unless I hit my head really hard     ***;
*** PAID, FREE, and EXCH refer to Type of Labor, V, O, and 2 to Labor Source  ***;

/*
data work94_12 (drop= i j k);
     set sorted84;

     array d(1:5) HELP23D1-HELP23D5;
     array vd(1:50) HELPVD1-HELPVD50;
     array od(1:4) HELPOD1-HELPOD4;

     array ve(1:50) HELPVE1-HELPVE50;
     array oe(1:4) HELPOE1-HELPOE4;

     array f(1:5) HELP23F1-HELP23F5;
     array vf(1:50) HELPVF1-HELPVF50;
     array of(1:4) HELPOF1-HELPOF4;

     array g(1:5) HELP23G1-HELP23G5;
     array vg(1:50) HELPVG1-HELPVG50;
     array og(1:4) HELPOG1-HELPOG4;

     PAIDPD_2=0;
     FREEPD_2=0;
     EXCHPD_2=0;
     PAIDPD_V=0;
     FREEPD_V=0;
     EXCHPD_V=0;
     PAIDPD_O=0;
     FREEPD_O=0;
     EXCHPD_O=0;

     PAID_P_2=0;
     FREE_P_2=0;
     EXCH_P_2=0;
     PAID_P_V=0;
     FREE_P_V=0;
     EXCH_P_V=0;
     PAID_P_O=0;
     FREE_P_O=0;
     EXCH_P_O=0;

     PAID_T_2=0;
     PAID_T_V=0;
     PAID_T_O=0;


     do i=1 to 5;
        if f(i)=1 then PAIDPD_2=PAIDPD_2+(d(i));
           else if f(i)=2 then FREEPD_2=FREEPD_2+(d(i));
           else if f(i)=3 then EXCHPD_2=EXCHPD_2+(d(i));
     end;

     do j=1 to 50;
        if vf(j)=1 then PAIDPD_V=PAIDPD_V+(vd(j)*ve(j));
           else if vf(j)=2 then FREEPD_V=FREEPD_V+(vd(j)*ve(j));
           else if vf(j)=3 then EXCHPD_V=EXCHPD_V+(vd(j)*ve(j));
     end;

     do k=1 to 4;
        if of(k)=1 then PAIDPD_O=PAIDPD_O+(od(k)*oe(k));
           else if of(k)=2 then FREEPD_O=FREEPD_O+(od(k)*oe(k));
           else if of(k)=3 then EXCHPD_O=EXCHPD_O+(od(k)*oe(k));
     end;


     do i=1 to 5;
        if f(i)=1 then PAID_P_2=PAID_P_2+1;
           else if f(i)=2 then FREE_P_2=FREE_P_2+1;
           else if f(i)=3 then EXCH_P_2=EXCH_P_2+1;
     end;

     do j=1 to 50;
        if vf(j)=1 then PAID_P_V=PAID_P_V+ve(j);
           else if vf(j)=2 then FREE_P_V=FREE_P_V+ve(j);
           else if vf(j)=3 then EXCH_P_V=EXCH_P_V+ve(j);
     end;

     do k=1 to 4;
        if of(k)=1 then PAID_P_O=PAID_P_O+oe(k);
           else if of(k)=2 then FREE_P_O=FREE_P_O+oe(k);
           else if of(k)=3 then EXCH_P_O=EXCH_P_O+oe(k);
     end;


     do i=1 to 5;
        if f(i)=1 then PAID_T_2=PAID_T_2+(d(i)*g(i));
     end;

     do j=1 to 50;
        if vf(j)=1 then PAID_T_V=PAID_T_V+(vd(j)*ve(j)*vg(j));
     end;

     do k=1 to 4;
        if of(k)=1 then PAID_T_O=PAID_T_O+(od(k)*oe(k)*og(k));
     end;


     PAID_P=PAID_P_2+PAID_P_V+PAID_P_O;
     FREE_P=FREE_P_2+FREE_P_V+FREE_P_O;
     EXCH_P=EXCH_P_2+EXCH_P_V+EXCH_P_O;

     CODE23_P=PAID_P_2+FREE_P_2+EXCH_P_2;
     SMVILL_P=PAID_P_V+FREE_P_V+EXCH_P_V;
     OTVILL_P=PAID_P_O+FREE_P_O+EXCH_P_O;

     PAIDPD=PAIDPD_2+PAIDPD_V+PAIDPD_O;
     FREEPD=FREEPD_2+FREEPD_V+FREEPD_O;
     EXCHPD=EXCHPD_2+EXCHPD_V+EXCHPD_O;

     PAID_T=PAID_T_2+PAID_T_V+PAID_T_O;
     ALL_P=PAID_P+FREE_P+EXCH_P;
     ALL_PD=PAIDPD+FREEPD+EXCHPD;

     if RICE=1 then HELPDV4=ALL_P;
        else HELPDV4=.;

     if RICE=1 then HELPDV5=ALL_PD;
        else HELPDV5=.;

     if RICE=1 then HELPDV6=PAID_T;
        else HELPDV6=.;

run;


data work94_13;
     set work94_12 (keep=VILL84 HELPDV RICE CODE23_P PAID_P_2 SMVILL_P PAID_P_V OTVILL_P PAID_P_O);

     keep VILL84 VILL_PP2 VILL_PPV VILL_PPO TOTAL_HH RICEPROP;

     by VILL84;

     retain VILL_PP2 VILL_PPV VILL_PPO PAID_T_2 PAID_T_V PAID_T_O CODE23_T SMVILL_T OTVILL_T
            RICE HELPDV COUNTER RICECNTR RICEPROP TOTAL_HH;

     if first.VILL84 then do;
                            VILL_PP2=0;
                            VILL_PPV=0;
                            VILL_PPO=0;
                            PAID_T_2=0;
                            PAID_T_V=0;
                            PAID_T_O=0;
                            CODE23_T=0;
                            SMVILL_T=0;
                            OTVILL_T=0;
                            RICECNTR=0;
                            COUNTER=0;
                          end;

     COUNTER=COUNTER+1;

     if RICE=1 then do;
                      RICECNTR=RICECNTR+1;
                    end;

     if HELPDV>2 then do;
                        PAID_T_2=PAID_T_2+PAID_P_2;
                        PAID_T_V=PAID_T_V+PAID_P_V;
                        PAID_T_O=PAID_T_O+PAID_P_O;       /* Sum up paid workers by source by 84 village */

/*                      CODE23_T=CODE23_T+CODE23_P;
                        SMVILL_T=SMVILL_T+SMVILL_P;
                        OTVILL_T=OTVILL_T+OTVILL_P;       /* Sum up total workers by source by 84 village */
/*                    end;


     if last.VILL84 then do;
                           VILL_PP2=ROUND(PAID_T_2/(CODE23_T+0.0000001),.0001);
                           VILL_PPV=ROUND(PAID_T_V/(SMVILL_T+0.0000001),.0001);
                           VILL_PPO=ROUND(PAID_T_O/(OTVILL_T+0.0000001),.0001);   /* Percentages by source by 84 Vill */
/*                         TOTAL_HH=COUNTER;
                           RICEPROP=ROUND(RICECNTR/COUNTER,.0001);

                           OUTPUT;

                         end;
run;


proc corr data=work94_13;
run;

goptions reset = all;
proc boxplot data=work94_13;
  plot VILL_PP2 VILL_PPV VILL_PPO;
run;


data out94_1.c2_94_01;
     set work94_13;
run;


/* proc sort data=work94_2 out=work94_3;
     by RICE;
run;

proc freq data=work94_3;
     by RICE;
     tables HELPTYPE/MISSING;
run; */
