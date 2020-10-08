*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_04.sas
**     Programmer: james r. hull
**     Start Date: 2009 June 5
**     Purpose:
**        1.) Create files for social network analysis
**     Input Data:
**        1.) '/nangrong/data_sas/1994/current/hh94.03'
**        2.) '/nangrong/data_sas/1994/current/helprh94.01'
**        3.) '/nangrong/data_sas/masterids/constructed/personid.X01'
**     Output Data:
**        1.) Output data are ucinet and pajek files written to directory:
**            /afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/vill/
**
**      NOTES: FILE 02 COLLAPSES VILLAGES W/O HHs first
**             FILE 03 COLLAPSES BY HH FIRST then by VILLAGE
**             FILE 04 CREATES VILLAGE LEVEL SOCIAL NETWORK FILES
**             FILE 05 CREATES VILLAGE SOCIOMATRICES - VALUED
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

ods listing;

%let f=94_5;  ** names file (allows portability) **;

**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/nangrong/data_sas/1994/current/hh94.03';
libname in&f.2 xport '/nangrong/data_sas/1994/current/helprh94.01';
libname in&f.3 xport '/nangrong/data_sas/masterids/constructed/personid.X01';
libname ext&f.1 xport '/nangrong/data_sas/1994/current/indiv94.05';

******************************
**  Create Working Dataset  **
******************************;

* This code stacks the code 2&3 help into a child file *;
* It adds the location=9 variable and codes # helpers=1 for all *;


data work&f.01;
     set in&f.1.hh94(keep=hhid94 Q6_23A: Q6_23B: Q6_23C: Q6_23D:);
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

****************************************************************************
** This code collapses multiple code 2 & 3 workers from a household to    **
** a single observation and sums the values for each into summary counts. **
** For the "type of labor" variable, I use an "any paid --> paid" rule    **
** because paying a code 2 or 3 laborer is a rare behavior and distinct   **
****************************************************************************;

data work&f.01b;
     set work&f.01;
     if Q6_24E in(996,999) then Q6_24E=.;
run;

data work&f.01c;
     set work&f.01b;

     by HHID94;

     retain SUM_B SUM_C SUM_E SUM_TYPE SUM_LOC i;


     if first.HHID94 then do;
                            SUM_B=0;
                            SUM_C=0;
                            SUM_E=0;
                            SUM_TYPE=2; * Default is unpaid labor*;
                            SUM_LOC=9;
                            i=1;
                         end;

     SUM_B=SUM_B+Q6_24B;
     SUM_C=SUM_C+Q6_24C;
     SUM_E=SUM_E+Q6_24E;
     if Q6_24D=1 then SUM_TYPE=1;  * Any paid --> all paid *;
     SUM_LOC=9;
     i=i+1;

     if last.HHID94 then output;

run;

data work&f.01d (drop=SUM_B SUM_C SUM_E SUM_TYPE SUM_LOC i);
     set work&f.01c;

     Q6_24A="   ";
     Q6_24B=SUM_B;
     Q6_24C=(SUM_C/(i-1));
     Q6_24D=SUM_TYPE;
     Q6_24E=SUM_E;
     LOCATION=SUM_LOC;

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


data work&f.02;
     set in&f.2.helprh94 (keep=hhid94 Q6_24A Q6_24B Q6_24C Q6_24D Q6_24E);

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
        else LOCATION=.;                                     * LOGIC PROBLEMS EXIST IF . > 0 *;

        if Q6_24C=99 then Q6_24C=1;        *RECODES*;    *If number of days unknown, code as "."*;
        if Q6_24B=99 then Q6_24B=1;                      *If number of workers unknown, code as "."*;
                                                         *No recodes needed for Q6_24D *;
        if Q6_24E=996 then Q6_24E=.;                     *If wages unknown, code as "."  *;
           else if Q6_24E=998 then Q6_24E=.;             *The above recodes to 1 impact 22 and 12 helping hhs respectively *;
           else if Q6_24E=999 then Q6_24E=.;             *The logic is that if the hh was named then at least*;
run;                                                     * one person worked for at least 1 day *;

data work&f.03;
     set work&f.01d
         work&f.02;
run;

***************************************************************************
** Add V84 identifiers to 1994 data file as per Rick's comments on web   **
***************************************************************************;

proc sort data=work&f.03 out=work&f.04;
     by hhid94 q6_24a LOCATION;
run;

data vill_id_fix&f.01;
     set ext&f.1.indiv94;
     keep HHID94 V84;
run;

proc sort data=vill_id_fix&f.01 out=vill_id_fix&f.02 nodupkey;
     by HHID94 v84;
run;

data vill_id_fix&f.03;
     merge work&f.04 (in=a)
           vill_id_fix&f.02 (in=b);
           if a=1 and b=1 then output;
     by HHID94;
run;

proc sort data=vill_id_fix&f.03 out=work&f.05;
     by V84 HHID94;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 11 cases (a case here is a helper group)        **
******************************************************************************;

data work&f.06;
     set work&f.05;

     rename Q6_24A=HELPHHID;
     HHID94_C=put(HHID94,$8.);

     if Q6_24D ^in (.,9) then output;
run;

************************************************************************************
** The steps below convert the ban lek ti information on the helping household    **
** into the standard HHID##, as a preparatory step to creating network datafiles. **
************************************************************************************;

data work&f.07;
     set work&f.06;

     length HELPVILL $ 4;
     length HELP_LEK $ 3;
     length VILL_LEK $ 7;

     if HELPHHID="0220162" then HELPHHID="0222016"; *Fix one data goof that I found*;

     if HELPHHID="   " then HELPHH94=HHID94;
        else HELPHH94=.;

     if HELPHH94=. then do;
                          HELPVILL=substr(HELPHHID,4,4);
                          if HELPVILL="0000" then HELPVILL=substr(HHID94_C,1,4);
                          HELP_LEK=substr(HELPHHID,1,3);
                          VILL_LEK=cats(HELPVILL,HELP_LEK);
                        end;

run;

data work&f.08;

     set ext&f.1.indiv94 (keep=HHID94 LEKTI94 VILL94 V84);

     length VILL_LEK $ 7;

     VILL_LEK=cat(VILL94,LEKTI94);

     rename HHID94=HHID94_2;
run;

proc sort data=work&f.07 out=work&f.09a;
     by V84 VILL_LEK;
run;

proc sort data=work&f.08 out=work&f.09b nodupkey;
     by V84 VILL_LEK;
run;

data work&f.10;
     merge work&f.09a (in=a)
           work&f.09b (in=b);
     by V84 VILL_LEK;
     if a=1 then output;
run;

data work&f.11 (drop=HHID94_2 HELPHHID HHID94_C HELPVILL HELP_LEK VILL94 LEKTI94 V84);
     set work&f.10;

     if HELPHH94=. then HELPHH94=HHID94_2;
     if Q6_24D=3 then PAIDHH94=2;
        else PAIDHH94=Q6_24D;
     V84N=input(V84,2.0);
run;

data work&f.12 (keep=HHID94 PAIDHH94 HELPHH94 V84N);
     set work&f.11;

     if HELPHH94 ne .;     ** Removes labor from outside village and unidentifiable households **;
run;

proc sort data=work&f.12 out=work&f.13;
     by HHID94 HELPHH94;
run;

**********************************************************************************
** finishes formatting the data so it can be outputted into a PAJAK/UCINET file **
**********************************************************************************;

data vill_id_fix&f.04 (drop=V84);
     set vill_id_fix&f.02;
     V84N=input(V84,2.0);
run;

data work&f.14;
     merge work&f.13 (in=a)
           vill_id_fix&f.04 (in=b);
     by HHID94;
run;

data work&f.15 (drop=HELPHH94 PAIDHH94 i j);
     set work&f.14;
     by HHID94;

     length HHID_H01-HHID_H50 8;             * 49 max plus 1 for good measure *;
     length PAID_H01-PAID_H50 8;             * 49 max plus 1 for good measure *;

     retain HHID_H01-HHID_H50 PAID_H01-PAID_H50 i;

     array h(1:50) HHID_H01-HHID_H50;
     array p(1:50) PAID_H01-PAID_H50;

     if first.HHID94 then do;
                             do j= 1 to 50;
                                h(j)=.;
                                p(j)=.;
                             end;
                             i=1;
                          end;

     h(i)=HELPHH94;
     p(i)=PAIDHH94;
     i=i+1;

     if last.HHID94 then output;
run;

****************************************************
** Create separate village files for EACH VILLAGE **
****************************************************;

%macro v_split (numvill=);  %* macro splits villages *;

       %* NUMVILL=Number of Unique Villages in file *;

%do i=1 %to &numvill;

    data r94_p&i (drop=V84N);
         set work&f.15;
         if V84N=&i;
    run;

%end;

%mend v_split;


%v_split (numvill=51);


**********************************************************************
** Create 51 VALUED adjacency matrices, one for each village - rice **
**********************************************************************;

%macro v_adj (numvill=);

%do i=1 %to &numvill;

proc iml;
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/adjval.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/pajwrite.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/uciwrite.mod';

     %let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/vill/r94_p);
     %let p2=%quote(.net);
     %let p3=%quote(.dl);

     use r94_p&i;
     read all var{HHID_H01 HHID_H02 HHID_H03 HHID_H04 HHID_H05
                  HHID_H06 HHID_H07 HHID_H08 HHID_H09 HHID_H10
                  HHID_H11 HHID_H12 HHID_H13 HHID_H14 HHID_H15
                  HHID_H16 HHID_H17 HHID_H18 HHID_H19 HHID_H20
                  HHID_H21 HHID_H22 HHID_H23 HHID_H24 HHID_H25
                  HHID_H26 HHID_H27 HHID_H28 HHID_H29 HHID_H30
                  HHID_H31 HHID_H32 HHID_H33 HHID_H34 HHID_H35
                  HHID_H36 HHID_H37 HHID_H38 HHID_H39 HHID_H40
                  HHID_H41 HHID_H42 HHID_H43 HHID_H44 HHID_H45
                  HHID_H46 HHID_H47 HHID_H48 HHID_H49 HHID_H50
                  } into rcv;
     read all var{PAID_H01 PAID_H02 PAID_H03 PAID_H04 PAID_H05
                  PAID_H06 PAID_H07 PAID_H08 PAID_H09 PAID_H10
                  PAID_H11 PAID_H12 PAID_H13 PAID_H14 PAID_H15
                  PAID_H16 PAID_H17 PAID_H18 PAID_H19 PAID_H20
                  PAID_H21 PAID_H22 PAID_H23 PAID_H24 PAID_H25
                  PAID_H26 PAID_H27 PAID_H28 PAID_H29 PAID_H30
                  PAID_H31 PAID_H32 PAID_H33 PAID_H34 PAID_H35
                  PAID_H36 PAID_H37 PAID_H38 PAID_H39 PAID_H40
                  PAID_H41 PAID_H42 PAID_H43 PAID_H44 PAID_H45
                  PAID_H46 PAID_H47 PAID_H48 PAID_H49 PAID_H50
                  } into val;

     read all var{HHID94} into snd;

     r94_p=adjval(snd,rcv,val);
     id=r94_p[,1];
     r94_p=r94_p[,2:ncol(r94_p)];
     adj=r94_p;

     file "&p1.&i.&p2";
     call pajwrite(adj,id,2);
     file "&p1.&i.&p3";
     call uciwrite(adj,id,id`,2);

quit;

%end;

%mend v_adj;

%v_adj(numvill=51);

***************************************************************************************
** Create 51 attribute files containing ratios of in/out and total number of workers **
***************************************************************************************;

proc sort data=work&f.06 out=work&f.20;
     by HHID94;
run;

data work&f.21 (keep=HHID94 TOT_NUM TOT_PAY TOT_IN V84);  * Collapse into HHs *;
     set work&f.20 (keep=HHID94 Q6_24B Q6_24D V84 LOCATION);

     by HHID94;

  retain TOT_NUM TOT_PAY TOT_IN 0;

  if first.HHID94 then do;
                          TOT_NUM=0;
                          TOT_PAY=0;
                          TOT_IN=0;
                       end;


  TOT_NUM=TOT_NUM+Q6_24B;
  if Q6_24D=1 then TOT_PAY=TOT_PAY+Q6_24B;
  if LOCATION in (0,1,9) then TOT_IN=TOT_IN+Q6_24B;

  if last.HHID94 then output;

  label TOT_NUM='Total Number Persons Helping';
  label TOT_PAY='Total Number Persons Helping for Pay';
  label TOT_IN='Total Number Persons Helping from Village';

run;

data work&f.22(drop=V84);                * Create Proportion Variables *;
     set work&f.21;

     PROP_PAY=ROUND(TOT_PAY/(TOT_NUM+0.0000001),.0001);
     PROP_IN=ROUND(TOT_IN/(TOT_NUM+0.0000001),.0001);
     V84N=input(V84,2.0);

     if TOT_NUM=0 then do;
                           TOT_NUM=.;
                           TOT_PAY=.;
                           TOT_IN=.;
                           PROP_PAY=.;
                           PROP_IN=.;
                        end;

     label PROP_PAY='Proportion of ALL Labor Paid';
     label PROP_IN='Proportion of ALL Labor from Village';

run;

data vill_id_fix&f.05 (drop=V84);
     set vill_id_fix&f.02;
     V84N=input(V84,2.0);
run;

data work&f.23;
     merge work&f.22 (in=a)
           vill_id_fix&f.05 (in=b);
     by HHID94;
     if TOT_NUM=. then do;
                           TOT_NUM=0;
                           TOT_PAY=0;
                           TOT_IN=0;
                           PROP_PAY=0;
                           PROP_IN=0;
                       end;
run;

proc sort data=work&f.23 out=work&f.24;
     by V84N HHID94;
run;

%macro v_split2 (numvill=);  %* macro splits villages *;

       %* NUMVILL=Number of Unique Villages in file *;

%do i=1 %to &numvill;

    data r94_a&i (drop=V84N);
         set work&f.24;
         if V84N=&i;
    run;

%end;

%mend v_split2;


%v_split2 (numvill=51);

* Macro creates comma delimited text attribute files *;

%macro attrib(numvill=);

%do i=1 %to &numvill;

    data _null_ ;

         %let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/vill/r94_a);
         %let p2=%quote(.txt);

         set r94_a&i;
         file "&p1.&i.&p2";
         put  TOT_NUM TOT_PAY TOT_IN PROP_PAY PROP_IN;
run;

%end;

%mend attrib;

%attrib(numvill=51);
