*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_09.sas
**     Programmer: james r. hull
**     Start Date: 2009 July 26
**     Purpose:
**        1.) Generate Tables for Chapter 2 - Household Network Vars
**     Input Data:
**        1.)
**     Output Data:
**        1.)
**
**      NOTES:
**
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

ods listing;

%let f=09;   ** Allows for greater file portability **;
%let y=00;   ** Allows for greater file portability **;

**********************
**  Data Libraries  **
**********************;

libname in&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_HH.xpt';
libname in&y.&f.02 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_08.xpt';

libname ot&y.&f.01 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_09.xpt';

********************************************************
**  Bring in Datasets and Create Additional Variables **
********************************************************;

data work&y.&f.01 (drop=HHID&y.C);
     set in&y.&f.01.c2_&y._HH (rename=(HHID&y=HHID&y.C) drop=H_NUM_T4 H_NUM_P4 H_NUM_F4 H_PRO_P4 H_PRO_F4
                                   H_NUM_T5 H_NUM_P5 H_NUM_F5 H_PRO_P5 H_PRO_F5
                                   H_NUM_T6 H_NUM_P6 H_NUM_F6 H_PRO_P6 H_PRO_F6
                                   H_NUM_T8 H_NUM_P8 H_NUM_F8 H_PRO_P8 H_PRO_F8
                                   H_NUM_T9 H_NUM_P9 H_NUM_F9 H_PRO_P9 H_PRO_F9
                                   H_NUM_T1 H_NUM_P1 H_NUM_F1 H_PRO_P1 H_PRO_F1);

     HHID&y=input(HHID&y.C, best12.);
run;

data work&y.&f.02;
     set in&y.&f.02.c2_&y._08 (drop=H&y.S_P17-H&y.S_p50 H&y.R_P12-H&y.R_P50);
run;


data work&y.&f.03;
     merge work&y.&f.01 (in=a)
           work&y.&f.02 (in=b);
     by HHID&y;

     if a=1 then output;

     attrib _all_ label='';

run;

*********************************************
**  Descriptive Analysis - Household Level **
*********************************************;

** A macro that produces a simple histogram **;

%macro histogram (DATAIN=, HISTVAR=, MINVALUE=, MAXVALUE=, STEPVALUE=);

       %let NAMEVAR=&HISTVAR;

       ods trace on;

       data freq_001;
            set &DATAIN;
            do i = &MINVALUE to &MAXVALUE by &STEPVALUE;
               if  i-((&STEPVALUE)/2) <= &HISTVAR < i+((&STEPVALUE)/2) then &NAMEVAR=i;
            end;
       run;

       proc freq data=freq_001;
            tables &NAMEVAR;
            ods output OneWayFreqs=freq_002;
       run;

       proc means mean std min max data=freq_001;
            vars &NAMEVAR;
       run;

       data freq_annotate;
            set freq_002;

            length function color text $8;

            function = 'label';
            color    = 'black';
            size     =  1;
            style     =  'swiss';
            xsys     = '2';
            ysys     = '2';
            when     = 'a';
            x=&NAMEVAR;              ** The x-coordinate **;
            y=percent+3;            ** The y-coordinate **;
            text=left(put(percent, 4.2));
       run;

       proc univariate data=freq_001 noprint;
            histogram &HISTVAR /annotate=freq_annotate font=swiss cfill=green midpoints=&MINVALUE to &MAXVALUE by &STEPVALUE;

       run;

%mend histogram;


** Macro - produces pairwise correlations for all numeric variables against a single variable **;

%macro allcorr(dsn=,primevar=);

  %* dsn = name of dataset to use **;
  %* primevar = name of variable to pair with all other numeric vars **;

  %let dsid = %sysfunc(open(&dsn, I));
  %let numvars=%sysfunc(attrn(&dsid,NVARS));
  %do i = 1 %to &numvars;
      %let varname=%sysfunc(varname(&dsid,&i));
      %let varnum=%sysfunc(varnum(&dsid,&varname));
      %let vartype=%sysfunc(vartype(&dsid,&varnum));

      %if &vartype=N %then %do;
                               proc corr data=&dsn;
                                    var &primevar &varname;
                               run;
                           %end;
  %end;
  %let rc = %sysfunc(close(&dsid));

%mend allcorr;


** Basic Descriptive Statistics - Household Level Variables **;

proc means data=work&y.&f.03;
run;


** correlations with central variables of interest - household level **;

%allcorr(dsn=work&y.&f.03, primevar=H_PRO_PD);
%allcorr(dsn=work&y.&f.03, primevar=H_PRO_FR);
%allcorr(dsn=work&y.&f.03, primevar=H_PRO_IN);
%allcorr(dsn=work&y.&f.03, primevar=H_PRO_OT);

%allcorr(dsn=work&y.&f.03, primevar=H_ANY_PD);
%allcorr(dsn=work&y.&f.03, primevar=H_ANY_FR);
%allcorr(dsn=work&y.&f.03, primevar=H_ANY_IN);
%allcorr(dsn=work&y.&f.03, primevar=H_ANY_OT);

** output dataset  **;

data ot&y.&f.01.c2_00_09;
     set work&y.&f.03;
run;


/*
** histrograms of central variables of interest - household level **;

ods rtf file='/trainee/jrhull/diss/ch2/c2graph/c2_00_09_001.rtf' style=journal startpage=never;
ods graphics on;


%histogram (DATAIN=work&y.&f.03, HISTVAR=H_PRO_PD, MINVALUE=0, MAXVALUE=1, STEPVALUE=0.1);
ods rtf startpage=now;
%histogram (DATAIN=work&y.&f.03, HISTVAR=H_ANY_PD, MINVALUE=0, MAXVALUE=1, STEPVALUE=0.5);
ods rtf startpage=now;

%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_RSR&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;
%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_RIR&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;
%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_ROR&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;

%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_RSS&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;
%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_RIS&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;
%histogram (DATAIN=work&y.&f.03, HISTVAR=HG_ROS&y, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;

%histogram (DATAIN=work&y.&f.03, HISTVAR=H&y.RPAVG, MINVALUE=0, MAXVALUE=10, STEPVALUE=1);
ods rtf startpage=now;

%histogram (DATAIN=work&y.&f.03, HISTVAR=H&y.SPAVG, MINVALUE=0, MAXVALUE=20, STEPVALUE=1);
ods rtf startpage=now;

ods rtf close;
ods graphics off;
ods listing;      */
