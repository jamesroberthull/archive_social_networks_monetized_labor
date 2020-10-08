*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_04.sas
**     Programmer: james r. hull
**     Start Date: 2009 April 20
**     Purpose:
**        1.) Create files for social network analysis
**     Input Data:
**        1.) '/nangrong/data_sas/2000/current/hh00.04'
**        2.) '/nangrong/data_sas/2000/current/indiv00.03'
**
**     Output Data:
**        1.) Output files are ucinet and pajek files written to:
**            /afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/vill/
**
**     NOTES:  FILE 02 COLLAPSES VILLAGES W/O HHs first
**             FILE 03 COLLAPSES BY HH FIRST then by VILLAGE
**             FILE 04 CREATES VILLAGE LEVEL SOCIAL NETWORK FILES
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

ods listing;

%let f=00_4;  ** names file (allows portability) **;

**********************
**  Data Libraries  **
**********************;

libname in&f.1 xport '/nangrong/data_sas/2000/current/hh00.04';
libname ext&f.1 xport '/nangrong/data_sas/2000/current/indiv00.03';

******************************
**  Create Working Dataset  **
******************************;

***************************************************************************
** Stack rice harvest labor data into a child file and label by location **
***************************************************************************;

data work&f.01a;
     set in&f.1.hh00 (keep=HHID00 X6_84C: X6_84W:);
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

data work&f.01b;
     set in&f.1.hh00 (keep=HHID00 X6_85H: X6_85N: X6_85W:);
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

data work&f.01c;
     set in&f.1.hh00 (keep=HHID00 X6_86L: X6_86N: X6_86W:);
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

data work&f.02a;
     set work&f.01a;

     if X6_86W=9 then X6_86W=.;
run;

****************************************************************************
** This code collapses multiple code 2 & 3 workers from a household to    **
** a single observation and sums the values for each into summary counts. **
** For the "type of labor" variable, I use an "any paid --> paid" rule    **
** because paying a code 2 or 3 laborer is a rare behavior and distinct   **
****************************************************************************;

 data work&f.02a2;
     set work&f.02a;

     by HHID00;

     retain SUM_N SUM_TYPE SUM_LOC i;


     if first.HHID00 then do;
                            SUM_N=0;
                            SUM_TYPE=2; * Default is unpaid labor*;
                            SUM_LOC=9;
                            i=1;
                         end;

     SUM_N=SUM_N+X6_86N;
     if X6_86W=1 then SUM_TYPE=1;  * Any paid --> all paid *;
     SUM_LOC=9;
     i=i+1;

     if last.HHID00 then output;

run;

data work&f.02a3 (drop=SUM_N SUM_TYPE SUM_LOC i);
     set work&f.02a2;

     X6_86L="   ";
     X6_86N=SUM_N;
     X6_86W=SUM_TYPE;
     LOCATION=SUM_LOC;

run;

*********************************************************
** Take Care of Missing Data Issues - Recodes at least **
*********************************************************;

data work&f.02b;
     set work&f.01b;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;

data work&f.02c;
     set work&f.01c;

     if X6_86W=9 then X6_86W=.;
     if X6_86N=99 then X6_86W=1; * Assume at least 1 person worked *;
run;

**************************
** Merge files together **
**************************;

data work&f.03;
     set work&f.02a3
         work&f.02b
         work&f.02c;
run;

***************************************************************************
** Add V84 identifiers to 2000 data file as per Rick's suggestion on web **
***************************************************************************;

proc sort data=work&f.03 out=work&f.04;
     by HHID00 X6_86L LOCATION;
run;

data vill_id_fix&f.01;
     set ext&f.1.indiv00;
     keep HHID00 V84;
run;

proc sort data=vill_id_fix&f.01 out=vill_id_fix&f.02 nodupkey;
     by HHID00 v84;
run;

data vill_id_fix&f.03;
     merge work&f.04 (in=a)
           vill_id_fix&f.02 (in=b);
           if a=1 and b=1 then output;
     by HHID00;
run;

proc sort data=vill_id_fix&f.03 out=work&f.05;
     by V84;
run;

******************************************************************************
** This step removes all cases about which there is no information about    **
** how their laborers were compensated. This is my fix for the time being.  **
** Note: in doing so, I lose 7 cases (a case here is a helper group)        **
******************************************************************************;

data work&f.06;
     set work&f.05;

     rename X6_86L=HELPHHID;

     if X6_86W ^in (.,9) then output;
run;

************************************************************************************
** The steps below convert the ban lek ti information on the helping household    **
** into the standard HHID##, as a preparatory step to creating network datafiles. **
************************************************************************************;

data work&f.07;
     set work&f.06;


     if LOCATION in (0,9);
run;


data work&f.08;
     set work&f.07;

     if LOCATION=9 then do;
                           HELPHHID=HHID00;
                        end;


     if LOCATION=0 then do;
                           HELPHHID=substr(HELPHHID,2,9);
                        end;

run;

data work&f.09a (keep=HHID00N HELPHH00 V84N);
     set work&f.08;
     HELPHH00=input(HELPHHID,9.0);
     V84N=input(V84,2.0);
     HHID00N=input(HHID00,9.0);
run;

data work&f.09b (drop=HHID00);
     set ext&f.1.indiv00 (keep=HHID00);
     HELPHH00=input(HHID00,9.0);
run;

proc sort data=work&f.09a out=work&f.10a;
     by HELPHH00;
run;

proc sort data=work&f.09b out=work&f.10b nodupkey;
     by HELPHH00;
run;

data work&f.11 (drop=HHID00N);
     merge work&f.10a (in=a)
           work&f.10b (in=b);
     by HELPHH00;
     HHID00=HHID00N;
     if a=1 and b=1 then output;
run;

proc sort data=work&f.11 out=work&f.12;
     by HHID00 HELPHH00;
run;

**********************************************************************************
** finishes formatting the data so it can be outputted into a PAJAK/UCINET file **
**********************************************************************************;


data vill_id_fix&f.02b (drop=HHID00);
     set vill_id_fix&f.02;
     HHID00N=input(HHID00,9.0);
run;


data vill_id_fix&f.04 (drop=V84 HHID00N);
     set vill_id_fix&f.02b;
     V84N=input(V84,2.0);
     HHID00=HHID00N;
run;

data work&f.13;
     merge work&f.12 (in=a)
           vill_id_fix&f.04 (in=b);
     by HHID00;
run;

data work&f.14 (drop=HELPHH00 i j);
     set work&f.13;
     by HHID00;

     length HHID_H01-HHID_H14 8;          * 13 max plus 1 for good measure *;

     retain HHID_H01-HHID_H14 i;

     array h(1:14) HHID_H01-HHID_H14;

     if first.HHID00 then do;
                             do j= 1 to 14;
                                h(j)=.;
                             end;
                             i=1;
                          end;

     h(i)=HELPHH00;
     i=i+1;

     if last.HHID00 then output;
run;

proc sort data=work&f.14 out=work&f.15;
     by V84N HHID00;
run;

************************************************
** Create separate village files EACH VILLAGE **
************************************************;

%macro v_split (numvill=);  %* macro splits villages *;

       %* NUMVILL=Number of Unique Villages in file *;

%do i=1 %to &numvill;

    data r00_v&i (drop=V84N);
         set work&f.15;
         if V84N=&i;
    run;

%end;

%mend v_split;


%v_split (numvill=51);

***************************************************************
** Create 51 adjacency matrices, one for each village - rice **
***************************************************************;

%macro v_adj (numvill=);

%do i=1 %to &numvill;

proc iml;
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/adj.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/pajwrite.mod';
     %include '/afs/isis.unc.edu/home/j/r/jrhull/public/span/uciwrite.mod';

     %let p1=%quote(/afs/isis.unc.edu/home/j/r/jrhull/a_data/network/rice/vill/r00_v);
     %let p2=%quote(.net);
     %let p3=%quote(.dl);

     use r00_v&i;
     read all var _num_ into rcv;
     read all var{HHID00} into snd;

     rcv=rcv[,2:ncol(rcv)];
     r00_v=adj(snd,rcv);
     id=r00_v[,1];
     r00_v=r00_v[,2:ncol(r00_v)];
     adj=r00_v;

     file "&p1.&i.&p2";
     call pajwrite(adjval,id,2);
     file "&p1.&i.&p3";
     call uciwrite(adjval,id,id`,2);

quit;

%end;

%mend v_adj;

%v_adj(numvill=51);
