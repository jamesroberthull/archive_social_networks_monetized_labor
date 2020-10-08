*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_94_06.sas
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

%let f=94_6;  ** names file (allows portability) **;

**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/nangrong/data_sas/1994/current/sibs94.02';
libname in&f.2 xport '/nangrong/data_sas/1994/current/hh94.03';
libname in&f.3 xport '/nangrong/data_sas/1994/current/indiv94.04';

******************************
**  Create Working Dataset  **
******************************;

*******************************************************************************
**                                                                           **
** Coding for original location variables for siblings not in HH             **
**                                                                           **
** In this village                            1 + 0 + Ban Lek Ti + 0000      **
** In this split village                      1 + 0 + Ban Lek Ti + Village # **
** Temple in this village                     1 + 0 + 996        + 0000      **
** Temple in this split village               1 + 0 + 996        + Village # **
** In this village but ban lek ti unknown     1 + 0 + 999        + 0000      **
** In this split village but blt unknown      1 + 0 + 999        + Village # **
** Another village in Nang Rong               2 + Village #      + 0000      **
** Another village but village # is unknown   2 + 9999           + 0000      **
** Another district of Buriram                3 + District #     + 0000      **
** Another district but district # is unknown 3 + 9999           + 0000      **
** Another province                           4 + Province #     + 0000      **
** Another province but province # is unknown 4 + 9999           + 0000      **
** Another country                            5 + Country #      + 0000      **
** N/A                                        9 + 9999           + 9998      **
** Missing/Don?t know                         9 + 9999           + 9999      **
**                                                                           **
*******************************************************************************;


data work&f.01 (keep=HHID94 sex age place);
     set in&f.1.sibs94 (keep=HHID94 Q4_5P: Q4_5S: Q4_5A:);

     length place $9;

     array a(1:12) Q4_5A1-Q4_5A12;
     array s(1:12) Q4_5S1-Q4_5S12;
     array p(1:12) Q4_5P1-Q4_5P12;

     do i=1 to 12;
        SEX=s(i);
        AGE=a(i);
        PLACE=p(i);
        if PLACE ^in ( "999999999","999999998")  then output;
     end;
run;

data work&f.02 (drop=HHID94C VILLAGE BLT94 LOCATION SEX) work&f.03 (drop=HHID94C BLT94 VILLBLT);
     set work&f.01;

     HHID94C=put(HHID94,$8.);


     if AGE in (98,99) then AGE=.;
     if SEX in (8,9) then SEX=.;

     if SEX=2 then MALE=0;
        else if SEX=1 then MALE=1;
        else MALE=.;

     if substr(PLACE,1,1)="1" then LOCATION=1;
     if substr(PLACE,1,1)="2" then LOCATION=2;
     if substr(PLACE,1,1)="3" then LOCATION=3;
     if substr(PLACE,1,1)="4" then LOCATION=4;
     if substr(PLACE,1,1)="5" then LOCATION=5;

     if LOCATION=1 then do;
                           if substr(PLACE,6,4)="0000" then VILLAGE=substr(HHID94C,1,4);
                              else VILLAGE=substr(PLACE,6,4);
                        end;

     if LOCATION=2 then do;
                           if substr(PLACE,2,4) ne "9999" then VILLAGE=substr(PLACE,2,4);
                        end;


     if LOCATION=1 and substr(PLACE,3,2) ne "99" then BLT94=substr(PLACE,3,3);


     if VILLAGE ne "    " and BLT94 ne "   " then VILLBLT=trim(VILLAGE)||BLT94;

     if LOCATION in (1,2) and VILLAGE ne "    " and BLT94 ne "   " then output work&f.02;
     if LOCATION in (1,2) and VILLAGE ne "    " then output work&f.03;

run;

******************************************************************************************
** Re-Sort by VILLAGE and BLT then merge to standard list to remove errors and mistakes **
******************************************************************************************;

* Add V84 so that data can be sorted by both V84 and HHID00 before merging *;

data vill_id&f.01;
     set in&f.3.indiv94 (keep=HHID94 V84);
run;

proc sort data=vill_id&f.01 out=vill_id&f.02 nodupkey;
     by HHID94;
run;

data work&f.02b;
     merge work&f.02 (in=a)
           vill_id&f.02 (in=b);
     by HHID94;
     if a=1 then output;
run;

data work&f.04 (drop=VILL94 LEKTI94);
     set in&f.2.hh94 (keep=HHID94 VILL94 LEKTI94);

     SIBHH94=HHID94;

     VILLBLT=VILL94||LEKTI94;
run;

data work&f.04b (drop=HHID94);
     merge work&f.04 (in=a)
           vill_id&f.02 (in=b);
     by HHID94;
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
     by HHID94;
run;

*****************************************************
** add in self-reflexive ties (siblings in ego HH) **
*****************************************************;

data addsib&f.01 (keep=HHID94);
     set in&f.1.sibs94 (keep=HHID94 Q4_4:);

     array a(1:8) Q4_4_1-Q4_4_8;

     do i=1 to 8;
        SIB=a(i);
        if SIB ^in ( "998","999")  then output;
     end;
run;

data addsib&f.02;
     set addsib&f.01;

     MALE=.;
     AGE=.;
     SIBHH94=HHID94;
run;

data addsib&f.03;
     set addsib&f.02 work&f.08;
run;

proc sort data=addsib&f.03 out=addsib&f.04;
     by HHID94;
run;

*********************
** Add V84 to data **
*********************;

* Code removed from here and added earlier to solve sorting issues *;

data work&f.09;
     merge addsib&f.04 (in=a)
           vill_id&f.02 (in=b);
     by HHID94;
     if a=1 then output;
run;

*********************************************
** Reformat character variables to numeric **
*********************************************;

data work&f.10 (drop=SIBHH94 HHID94 V84);
     set work&f.09;

     SIBHH94N=input(strip(SIBHH94),9.);
     HHID94N=input(strip(HHID94),9.);
     V84N=input(V84,2.);
run;

data work&f.11 (drop=SIBHH94N HHID94N V84N);
     set work&f.10;

     SIBHH94=SIBHH94N;
     HHID94=HHID94N;
     V84=V84N;
run;

*******************************************************
** Collapse non-ego HHs containing multiple siblings **
*******************************************************;

proc sort data=work&f.11 out=work&f.12;
     by HHID94 SIBHH94;
run;

data work&f.13;
     set work&f.12;

     HHSIB94=trim(HHID94)||strip(SIBHH94);
run;

data work&f.14 (drop=MALE AGE HHSIB94 i);
     set work&f.13;

     by HHSIB94;

     retain SUM_SEX SUM_AGE SUM_SIB MIS_SIB i;


     if first.HHSIB94 then do;
                             SUM_SEX=0;
                             SUM_AGE=0;
                             SUM_SIB=0;
                             MIS_SIB=0;
                             i=1;
                           end;

     if MALE ne . then SUM_SEX=SUM_SEX+MALE;
     if AGE ne . then SUM_AGE=SUM_AGE+AGE;
     if AGE ne . then MIS_SIB=MIS_SIB+1;
     SUM_SIB=SUM_SIB+1;
     i=i+1;

    if last.HHSIB94 then output;

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

data work&f.16 (keep= HHID94 V84 SEX01-SEX16 AGE01-AGE16 NUM01-NUM16 SIBHH01-SIBHH16);
     set work&f.15;
     by HHID94;

     retain SEX01-SEX16 AGE01-AGE16 NUM01-NUM16 SIBHH01-SIBHH16 i;


     array s(1:16) SEX01-SEX16;
     array a(1:16) AGE01-AGE16;
     array t(1:16) NUM01-NUM16;
     array p(1:16) SIBHH01-SIBHH16;

     if first.HHID94 then do;
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
     p(i)=SIBHH94;

     i=i+1;

     if last.HHID94 then output;
run;

******************************************
** merge in households with no siblings **
******************************************;


data vill_id&f.03 (drop=V84 HHID94);
     set vill_id&f.02;
     V84N=input(V84,2.0);
     HHID94N=input(strip(HHID94),9.0);
run;

data vill_id&f.04 (drop=V84N HHID94N);
     set vill_id&f.03;
     V84=V84N;
     HHID94=HHID94N;
run;

data work&f.17;
     merge work&f.16 (in=a)
           vill_id&f.04 (in=b);
     by HHID94;
     if b=1 then output;
run;

****************************************************
** Create separate village files for EACH VILLAGE **
****************************************************;

proc sort data=work&f.17 out=work&f.18;
     by V84 HHID94;
run;

%macro v_split (numvill=);  %* macro splits villages *;

       %* NUMVILL=Number of Unique Villages in file *;

%do i=1 %to &numvill;

    data v94_s&i (drop=V84);
         set work&f.18;
         if V84=&i;
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

     %let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/sib/vill/r94_s);
     %let p2=%quote(.net);
     %let p3=%quote(.dl);

     use v94_s&i;
     read all var{SIBHH01 SIBHH02 SIBHH03 SIBHH04 SIBHH05
                  SIBHH06 SIBHH07 SIBHH08 SIBHH09 SIBHH10
                  SIBHH11 SIBHH12 SIBHH13 SIBHH14 SIBHH15
                  } into rcv;
     read all var{NUM01 NUM02 NUM03 NUM04 NUM05
                  NUM06 NUM07 NUM08 NUM09 NUM10
                  NUM11 NUM12 NUM13 NUM14 NUM15
                  } into val;

     read all var{HHID94} into snd;

     r94_s=adjval(snd,rcv,val);
     id=r94_s[,1];
     r94_s=r94_s[,2:ncol(r94_s)];
     adj=r94_s;

     file "&p1.&i.&p2";
     call pajwrite(adj,id,2);
     file "&p1.&i.&p3";
     call uciwrite(adj,id,id`,2);

quit;

%end;

%mend v_adj;

%v_adj(numvill=51);
