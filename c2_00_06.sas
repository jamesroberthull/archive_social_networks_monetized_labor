*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_06.sas
**     Programmer: james r. hull
**     Start Date: 2009 July 10
**     Purpose:
**        1.) Create sibling files for social network analysis
**     Input Data:
**        1.
**     Output Data:
**        1.) Output data are ucinet and pajek files written to directory:
**            /afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sibs/vill/
**
**      NOTES: FILE 02 COLLAPSES VILLAGES W/O HHs first
**             FILE 03 COLLAPSES BY HH FIRST then by VILLAGE
**             FILE 04 CREATES VILLAGE LEVEL SOCIAL NETWORK FILES
**             FILE 05 CREATES VILLAGE LEVEL SOCIOMATRICES - VALUED
**             FILE 06 CREATES VILLAGE LEVEL SIBLING SOCIAL NETWORK FILES
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

ods listing;

%let f=00_6;  ** names file (allows portability) **;

**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/nangrong/data_sas/2000/current/sibs00.03';
libname in&f.2 xport '/nangrong/data_sas/2000/current/hh00.04';
libname in&f.3 xport '/nangrong/data_sas/2000/current/indiv00.03';

******************************
**  Create Working Dataset  **
******************************;

**********************************************************************************
**                                                                              **
** In this (1984) village                     2 + Village #  + House #          **
** In this (1984) village, house # is unknown 2 + Village #  + 999              **
** Another village in Nang Rong               3 + 000            + Village #    **
** In Nang Rong, but village # is unknown     3 + 000            + 999999       **
** Outside Nang Rong, but within Buriram      4 + 0 + District # + 000000       **
** Another province                           5 + 0 + Province # + 000000       **
** Another country                            6 + 0 + Country #  + 000000       **
** N/A                                        [ ]                               **
** Missing/Don?t know                         9 + 999            + 999999       **
**                                                                              **
**********************************************************************************;


data work&f.01 (keep=HHID00 SEX AGE PLACE);
     set in&f.1.sibs00 (keep=HHID00 X4_5A: X4_5S: X4_5R:);

     length place $10.;

     array a(1:16) X4_5A1-X4_5A16;
     array s(1:16) X4_5S1-X4_5S16;
     array p(1:16) X4_5R1-X4_5R16;

     do i=1 to 16;
        SEX=s(i);
        AGE=a(i);
        PLACE=p(i);
        if PLACE ^in ( "9999999999","          ")  then output;
     end;
run;

data work&f.02 (drop=HHID00C VILLAGE BLT00 LOCATION SEX) work&f.03 (drop=HHID00C BLT00 VILLBLT);
     set work&f.01;

     HHID00C=put(HHID00,$9.);


     if AGE in (99,.) then AGE=.;
     if SEX in (9,.) then SEX=.;

     if SEX=2 then MALE=0;
        else if SEX=1 then MALE=1;
        else MALE=.;

     if substr(PLACE,1,1)="2" then LOCATION=1;
     if substr(PLACE,1,1)="3" then LOCATION=2;
     if substr(PLACE,1,1)="4" then LOCATION=3;
     if substr(PLACE,1,1)="5" then LOCATION=4;
     if substr(PLACE,1,1)="6" then LOCATION=5;

     if LOCATION=1 then VILLAGE=substr(PLACE,2,6);

     if LOCATION=2 then do;
                           if substr(PLACE,5,6) ne "999999" then VILLAGE=substr(PLACE,5,6);
                        end;


     if LOCATION=1 and substr(PLACE,8,3) ne "999" then BLT00=substr(PLACE,8,3);


     if VILLAGE ne "      " and BLT00 ne "   " then VILLBLT=trim(VILLAGE)||BLT00;

     if LOCATION in (1,2) and VILLAGE ne "      " and BLT00 ne "   " then output work&f.02;
     if LOCATION in (1,2) and VILLAGE ne "      " then output work&f.03;

run;

******************************************************************************************
** Re-Sort by VILLAGE and BLT then merge to standard list to remove errors and mistakes **
******************************************************************************************;

* Add V84 so that data can be sorted by both V84 and HHID00 before merging *;

data vill_id&f.01;
     set in&f.3.indiv00 (keep=HHID00 V84);
run;

proc sort data=vill_id&f.01 out=vill_id&f.02 nodupkey;
     by HHID00;
run;

data work&f.02b;
     merge work&f.02 (in=a)
           vill_id&f.02 (in=b);
     by HHID00;
     if a=1 then output;
run;


data work&f.04 (drop=VILL00 HOUSE00);
     set in&f.2.hh00 (keep=HHID00 VILL00 HOUSE00);

     SIBHH00=HHID00;

     VILLBLT=VILL00||HOUSE00;
run;

data work&f.04b (drop=HHID00);
     merge work&f.04 (in=a)
           vill_id&f.02 (in=b);
     by HHID00;
     if a=1 then output;
run;



proc sort data=work&f.02b out=work&f.05;
     by V84 VILLBLT;
run;

proc sort data=work&f.04b out=work&f.06;
     by V84 VILLBLT;
run;

data work&f.07 (drop=PLACE VILLBLT V84);
     merge work&f.05 (in=a)
           work&f.06 (in=b);
     by V84 VILLBLT;
     if a=1 and b=1 then output;
run;

proc sort data=work&f.07 out=work&f.08;
     by HHID00;
run;

*****************************************************
** add in self-reflexive ties (siblings in ego HH) **
*****************************************************;

data addsib&f.01 (keep=HHID00);
     set in&f.1.sibs00 (keep=HHID00 X4_4:);

     array a(1:10) X4_4_1-X4_4_10;

     do i=1 to 10;
        SIB=a(i);
        if SIB ^= "   " then output;
     end;
run;

data addsib&f.02;
     set addsib&f.01;

     MALE=.;
     AGE=.;
     SIBHH00=HHID00;
run;

data addsib&f.03;
     set addsib&f.02 work&f.08;
run;

proc sort data=addsib&f.03 out=addsib&f.04;
     by HHID00;
run;

*********************
** Add V84 to data **
*********************;

* Code moved from here up in program in order to solve matching problem *;

data work&f.09;
     merge addsib&f.04 (in=a)
           vill_id&f.02 (in=b);
     by HHID00;
     if a=1 then output;
run;

*********************************************
** Reformat character variables to numeric **
*********************************************;

data work&f.10 (drop=SIBHH00 HHID00 V84);
     set work&f.09;

     SIBHH00N=input(strip(SIBHH00),9.);
     HHID00N=input(strip(HHID00),9.);
     V84N=input(V84,2.);
run;

data work&f.11 (drop=SIBHH00N HHID00N V84N);
     set work&f.10;

     SIBHH00=SIBHH00N;
     HHID00=HHID00N;
     V84=V84N;
run;

*******************************************************
** Collapse non-ego HHs containing multiple siblings **
*******************************************************;

proc sort data=work&f.11 out=work&f.12;
     by HHID00 SIBHH00;
run;

data work&f.13;
     set work&f.12;

     HHSIB00=trim(HHID00)||strip(SIBHH00);
run;

data work&f.14 (drop=MALE AGE HHSIB00 i);
     set work&f.13;

     by HHSIB00;

     retain SUM_SEX SUM_AGE SUM_SIB MIS_SIB i;


     if first.HHSIB00 then do;
                             SUM_SEX=0;
                             SUM_AGE=0;
                             SUM_SIB=0;
                             MIS_SIB=0;
                             i=1;
                           end;

     SUM_SEX=SUM_SEX+MALE;
     if AGE ne . then SUM_AGE=SUM_AGE+AGE;
     if AGE ne . then MIS_SIB=MIS_SIB+1;
     SUM_SIB=SUM_SIB+1;
     i=i+1;

    if last.HHSIB00 then output;

run;

data work&f.15(drop=SUM_SEX SUM_AGE MIS_SIB);
     set work&f.14;

     RAT_M=SUM_SEX/SUM_SIB;
     if MIS_SIB=0 then AVG_A=SUM_AGE/SUM_SIB;
        else AVG_A=SUM_AGE/MIS_SIB;
run;

***********************************
** Unstack back to a mother file **
***********************************;

data work&f.16 (keep= HHID00 V84 SEX01-SEX16 AGE01-AGE16 NUM01-NUM16 SIBHH01-SIBHH16);
     set work&f.15;
     by HHID00;

     retain SEX01-SEX16 AGE01-AGE16 NUM01-NUM16 SIBHH01-SIBHH16 i;


     array s(1:16) SEX01-SEX16;
     array a(1:16) AGE01-AGE16;
     array t(1:16) NUM01-NUM16;
     array p(1:16) SIBHH01-SIBHH16;

     if first.HHID00 then do;
                            do j=1 to 16;
                                        s(j)=.;
                                        a(j)=.;
                                        t(j)=.;
                                        p(j)=.;
                            end;
                            i=1;
                          end;

     s(i)=RAT_M;
     a(i)=AVG_A;
     t(i)=SUM_SIB;
     p(i)=SIBHH00;

     i=i+1;

     if last.HHID00 then output;
run;


data vill_id&f.03 (drop=V84 HHID00);
     set vill_id&f.02;
     V84N=input(V84,2.0);
     HHID00N=input(HHID00,9.0);
run;

data vill_id&f.04 (drop=V84N HHID00N);
     set vill_id&f.03;
     V84=V84N;
     HHID00=HHID00N;
run;

data work&f.17;
     merge work&f.16 (in=a)
           vill_id&f.04 (in=b);
     by HHID00;
     if b=1 then output;
run;

****************************************************
** Create separate village files for EACH VILLAGE **
****************************************************;

proc sort data=work&f.17 out=work&f.18;
     by V84 HHID00;
run;

%macro v_split (numvill=);  %* macro splits villages *;

       %* NUMVILL=Number of Unique Villages in file *;

%do i=1 %to &numvill;

    data v00_s&i (drop=V84);
         set work&f.18;
         if V84=&i;
    run;

%end;

%mend v_split;

%v_split (numvill=51);


************************************************************************
** Create 51 VALUED adjacency matrices, one for each village -sibling **
************************************************************************;

%macro v_adj (numvill=);

%do i=1 %to &numvill;

proc iml;
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/adjval.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/pajwrite.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/uciwrite.mod';

     %let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/vill/r00_s);
     %let p2=%quote(.net);
     %let p3=%quote(.dl);

     use v00_s&i;
     read all var{SIBHH01 SIBHH02 SIBHH03 SIBHH04 SIBHH05
                  SIBHH06 SIBHH07 SIBHH08 SIBHH09 SIBHH10
                  SIBHH11 SIBHH12 SIBHH13 SIBHH14 SIBHH15
                  } into rcv;
     read all var{NUM01 NUM02 NUM03 NUM04 NUM05
                  NUM06 NUM07 NUM08 NUM09 NUM10
                  NUM11 NUM12 NUM13 NUM14 NUM15
                  } into val;

     read all var{HHID00} into snd;

     r00_s=adjval(snd,rcv,val);
     id=r00_s[,1];
     r00_s=r00_s[,2:ncol(r00_s)];
     adj=r00_s;

     file "&p1.&i.&p2";
     call pajwrite(adj,id,2);
     file "&p1.&i.&p3";
     call uciwrite(adj,id,id`,2);

quit;

%end;

%mend v_adj;

%v_adj(numvill=51);
