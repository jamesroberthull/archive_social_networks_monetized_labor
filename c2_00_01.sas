*********************************************************************
**     Program Name: /home/jrhull/diss/ch2/c2prog/c2_00_01.sas
**     Programmer: james r. hull
**     Start Date: 2007 September 7
**     Purpose:
**        1.) Create variables needed for first go at ch 2
**     Input Data:
**        1.) /nangrong/data_sas/2000/current/hh00.04
**        2.) /nangrong/data_sas/2000/current/plots00.02
**
**     Output Data:
**        1.) /trainee/jrhull/diss/ch2/c2data/c2_00_01.xpt
**
**     NOTES: THIS PROGRAM MOSTLY CRIBBED FROM c3_00_01.sas
**
*********************************************************************;

***************
**  Options  **
***************;

options nocenter linesize=80 pagesize=60;

title1 'Program to create HH-level rice harvest variables: 2000';

**********************
**  Data Libraries  **
**********************;

libname in00_1 xport '/nangrong/data_sas/2000/current/hh00.04';
libname in00_2 xport '/nangrong/data_sas/2000/current/plots00.02';

libname out00_1 xport '/trainee/jrhull/diss/ch2/c2data/c2_00_01.xpt';

libname extra_1 xport '/nangrong/data_sas/1994/current/hh94.03';

******************************
**  Create Working Dataset  **
******************************;

***********************************************************
**  Variables initially in Work1 dataset:
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

data work00_1;                                                 /*RECODES*/
     set in00_1.hh00;
     keep VILL00 HOUSE00 HHID00 VILL94 HHID94
        VILL84 HOUSE84 HHTYPE00 RICE X6_83
        X6_84 X6_84C: X6_84W: X6_85 X6_85H: X6_85N: X6_85W:
        X6_86 X6_86l: X6_86N: X6_86W:;
     rename X6_83=HELPHH X6_84=HELP23A X6_84C1=HELP23C1
        X6_84C2=HELP23C2 X6_84C3=HELP23C3 X6_84C4=HELP23C4
        X6_84C5=HELP23C5 X6_84C6=HELP23C6 X6_84C7=HELP23C7
        X6_84W1=HELP23F1 X6_84W2=HELP23F2 X6_84W3=HELP23F3
        X6_84W4=HELP23F4 X6_84W5=HELP23F5 X6_84W6=HELP23F6
        X6_84W7=HELP23F7 X6_85=HELPVA X6_85H1=HELPVC1
        X6_85H2=HELPVC2 X6_85H3=HELPVC3 X6_85H4=HELPVC4
        X6_85H5=HELPVC5 X6_85H6=HELPVC6 X6_85H7=HELPVC7
        X6_85H8=HELPVC8 X6_85H9=HELPVC9 X6_85H10=HELPVC10
        X6_85H11=HELPVC11 X6_85H12=HELPVC12 X6_85H13=HELPVC13
        X6_85N1=HELPVE1 X6_85N2=HELPVE2 X6_85N3=HELPVE3
        X6_85N4=HELPVE4 X6_85N5=HELPVE5 X6_85N6=HELPVE6
        X6_85N7=HELPVE7 X6_85N8=HELPVE8 X6_85N9=HELPVE9
        X6_85N10=HELPVE10 X6_85N11=HELPVE11 X6_85N12=HELPVE12
        X6_85N13=HELPVE13 X6_85W1=HELPVF1 X6_85W2=HELPVF2
        X6_85W3=HELPVF3 X6_85W4=HELPVF4 X6_85W5=HELPVF5
        X6_85W6=HELPVF6 X6_85W7=HELPVF7 X6_85W8=HELPVF8
        X6_85W9=HELPVF9 X6_85W10=HELPVF10 X6_85W11=HELPVF11
        X6_85W12=HELPVF12 X6_85W13=HELPVF13 X6_86=HELPOA
        X6_86L1=HELPOC1 X6_86L2=HELPOC2 X6_86L3=HELPOC3
        X6_86L4=HELPOC4 X6_86L5=HELPOC5 X6_86L6=HELPOC6
        X6_86L7=HELPOC7 X6_86L8=HELPOC8 X6_86L9=HELPOC9
        X6_86L10=HELPOC10 X6_86N1=HELPOE1 X6_86N2=HELPOE2
        X6_86N3=HELPOE3 X6_86N4=HELPOE4 X6_86N5=HELPOE5
        X6_86N6=HELPOE6 X6_86N7=HELPOE7 X6_86N8=HELPOE8
        X6_86N9=HELPOE9 X6_86N10=HELPOE10 X6_86W1=HELPOF1
        X6_86W2=HELPOF2 X6_86W3=HELPOF3 X6_86W4=HELPOF4
        X6_86W5=HELPOF5 X6_86W6=HELPOF6 X6_86W7=HELPOF7
        X6_86W8=HELPOF8 X6_86W9=HELPOF9 X6_86W10=HELPOF10;

run;

data work00_2 (drop= i j k HELP23B1-HELP23B7 HELPVT1-HELPVT13 HELPOT1-HELPOT10);
     set work00_1;

     array b(1:7) HELP23B1-HELP23B7;
     array c(1:7) HELP23C1-HELP23C7;
     array f(1:7) HELP23F1-HELP23F7;

     array vc(1:13) HELPVC1-HELPVC13;
     array ve(1:13) HELPVE1-HELPVE13;
     array vt(1:13) HELPVT1-HELPVT13;
     array vf(1:13) HELPVF1-HELPVF13;

     array oc(1:10) HELPOC1-HELPOC10;
     array oe(1:10) HELPOE1-HELPOE10;
     array ot(1:10) HELPOT1-HELPOT10;
     array of(1:10) HELPOF1-HELPOF10;

     do i=1 to 7;
        if c(i) ne '  ' then b(i)=1;
           else b(i)=0;
       if c(i)='99' then c(i)='  ';
        if f(i)=9 then f(i)=.;
     end;

     do j=1 to 13;
        if ve(j)=99 then ve(j)=1;
        if vf(j)=9 then vf(j)=.;
        if ve(j)=. then vt(j)=0;
           else vt(j)=ve(j);
     end;

     do k=1 to 10;
        if oe(k)=99 then oe(k)=1;
        if of(k)=9 then of(k)=.;
        if oe(k)=. then ot(k)=0;
           else ot(k)=oe(k);
     end;

     if RICE=2 then RICE=0;
        else if RICE=. then RICE=0;
        else if RICE=9 then RICE=.;

     if HELPHH=99 then HELPHH=.;

     if HELP23A=2 then HELP23A=0;
        else if HELP23A=9 then HELP23A=0;
        else if HELP23A=. then HELP23A=0;

     if HELPVA=2 then HELPVA=0;
        else if HELPVA=9 then HELPVA=0;
        else if HELPVA=. then HELPVA=0;

     if HELPOA=2 then HELPOA=0;
        else if HELPOA=9 then HELPOA=0;
        else if HELPOA=. then HELPOA=0;

     HELP23B = HELP23B1+HELP23B2+HELP23B3+HELP23B4+HELP23B5+HELP23B6+HELP23B7;
     HELPVB = sum(of HELPVT1-HELPVT13);
     HELPOB = sum(of HELPOT1-HELPOT10);

     TOTHELP=HELP23B+HELPVB+HELPOB;

     if HELP23B = 0 then HELP23B = .;
     if HELPVB = 0 then HELPVB =.;
     if HELPOB = 0 then HELPOB = .;

     label HELP23B = 'Total # of code 2 and 3 helpers';
     label HELPVB = 'Total # of helpers from same village';
     label HELPOB = 'Total # of helpers from other villages';

run;


/* proc contents data=work00_2 varnum;
run; */

/* proc datasets library=work;
     delete work00_1;
run; */

*************************************************************
**  Freqs, means, and sd for all variables in the dataset  **
*************************************************************;

/* proc freq data=work00_2;
     tables RICE HELP23A HELPVA HELPOA /missprint;
run;

proc means data=work00_2 maxdec=2 mean std min max nmiss;
     var HELP23B HELPVB HELPOB;
run; */

******************************************************************
**  Concatenate variables A and F for groups 23, V, and O       **
**  asking about paid labor status into single strings in       **
**  order to examine a frequency distribution of all sequences  **
******************************************************************;

data work00_3 (drop=string1-string3 i); /* concatenate 'A' variables */
    set work00_2;

    length string1-string3  $ 1 CCATALLA $ 3;

    array a (3) HELP23A HELPVA HELPOA;
    array b (3) string1-string3;

    do i=1 to 3;
      if a{i}=1 then b{i}='1';
      else if a{i}=2 then b{i}='2';
      else if a{i}=3 then b{i}='3';
      else b{i}=' ';
    end;

    CCATALLA=string1||string2||string3;


    label CCATALLA="concatenation of all A variables";
run;


/* concatenate labor ?s*/


data work00_4 (drop= stringa1-stringa7 strngb1-strngb13
       strngc1-strngc10 i j k);
    set work00_3;

    length stringa1-stringa7  $ 1 CCAT23F $ 7;
    length strngb1-strngb13  $ 1 CCATVF $ 13;
    length strngc1-strngc10  $ 1 CCATOF $ 10;

    array va (7) HELP23F1-HELP23F7;
    array a (7) stringa1-stringa7;
    array vb (13) HELPVF1-HELPVF13;
    array b (13) strngb1-strngb13;
    array vc (10) HELPOF1-HELPOF10;
    array c (10) strngc1-strngc10;

    do i=1 to 7;
      if va{i}=1 then a{i}='1';
      else if va{i}=2 then a{i}='2';
      else if va{i}=3 then a{i}='3';
      else a{i}=' ';
    end;

    do j=1 to 13;
      if vb{j}=1 then b{j}='1';
      else if vb{j}=2 then b{j}='2';
      else if vb{j}=3 then b{j}='3';
      else b{j}=' ';
    end;

    do k=1 to 10;
      if vc{k}=1 then c{k}='1';
      else if vc{k}=2 then c{k}='2';
      else if vc{k}=3 then c{k}='3';
      else c{k}=' ';
    end;

    CCAT23F=stringa1||stringa2||stringa3||stringa4||stringa5||
            stringa6||stringa7;
    CCATVF=strngb1||strngb2||strngb3||strngb4||strngb5||strngb6||
        strngb7||strngb8||strngb9||strngb10||strngb11||strngb12||
        strngb13;
    CCATOF=strngc1||strngc2||strngc3||strngc4||strngc5||strngc6||
        strngc7||strngc8||strngc9||strngc10;

    CCATALLF=CCAT23F||CCATVF||CCATOF;

   label CCAT23F="concatenation of code 23 labor ?s";
   label CCATVF="concatenation of village labor ?s";
   label CCATOF="concatenation of oth vil labor ?s";
   label CCATALLF="concatenation of ALL labor ?s";

run;


/* proc freq data=work00_4;
     tables CCATALLA CCAT23F CCATVF CCATOF/ missprint;
run; */


proc datasets library=work;
     delete work00_3;
run;


data work00_5 (drop=HELPVH_1 HELPVH_2 HELPVH_3
                    HELPOH_1 HELPOH_2 HELPOH_3
                    HELP2H_1 HELP2H_2 HELP2H_3 i j k);

     set work00_4;

     array f(1:7) HELP23F1-HELP23F7;
     array vf(1:13) HELPVF1-HELPVF13;
     array of(1:10) HELPOF1-HELPOF10;

     HELPVH_1=0;
     HELPVH_2=0;
     HELPVH_3=0;
     HELPOH_1=0;
     HELPOH_2=0;
     HELPOH_3=0;
     HELP2H_1=0;
     HELP2H_2=0;
     HELP2H_3=0;

     do k=1 to 7;
          if f(k)=1 then HELP2H_1=HELP2H_1+1;
           else if f(k)=2 then HELP2H_2=HELP2H_2+1;
           else if f(k)=3 then HELP2H_3=HELP2H_3+1;
     end;

     do i=1 to 13;
        if vf(i)=1 then HELPVH_1=HELPVH_1+1;
           else if vf(i)=2 then HELPVH_2=HELPVH_2+1;
           else if vf(i)=3 then HELPVH_3=HELPVH_3+1;
     end;

     do j=1 to 10;
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

/* proc freq data=work00_5;
     tables HELPVH HELPOH HELPDV HELPDV2;
run; */

proc sort data=work00_5 out=sorted94;
     by VILL94;
run;

data vill_id_fix;
     set extra_1.hh94;
     keep VILL94 VILL84;
run;

proc sort data=vill_id_fix out=vill_id_fix2 nodupkey;
     by VILL94;
run;

data vill_id_fix3;
     merge sorted94 (in=a drop=VILL84)
           vill_id_fix2 (in=b);
     by VILL94;
run;

proc sort data=vill_id_fix3 out=sorted84;
     by VILL84;
run;

/* proc freq data=sorted84;
     tables VILL84*HELPDV2/ NOPERCENT NOCOL NOFREQ;
run; */

/* proc freq data=work00_5;
   tables VILL94*HELPDV VILL94*HELPDV2/ NOPERCENT NOCOL NOFREQ;
run; */

/* proc contents data=work00_5 varnum;
run; */

********************************************************************************
*** CREATE AGGREGATE MEASURES OF PERSONS WORKING (NO P-D OR WAGES AVAILABLE) ***
********************************************************************************;

*** At some point, I will label these newly created variables like a good boy ***;
*** For now, I'll just note that P=persons, PD=Person-Days, and T=Total Wages ***;
*** The rest should be self-explanatory, unless I hit my head really hard     ***;
*** PAID, FREE, and EXCH refer to Type of Labor, V, O, and 2 to Labor Source  ***;


data work00_6 (drop= i j k);
      set sorted84;

      array ve(1:13) HELPVE1-HELPVE13;
      array oe(1:10) HELPOE1-HELPOE10;

      array f(1:7) HELP23F1-HELP23F7;
      array vf(1:13) HELPVF1-HELPVF13;
      array of(1:10) HELPOF1-HELPOF10;

      PAID_P_2=0;
      FREE_P_2=0;
      EXCH_P_2=0;
      PAID_P_V=0;
      FREE_P_V=0;
      EXCH_P_V=0;
      PAID_P_O=0;
      FREE_P_O=0;
      EXCH_P_O=0;

      do i=1 to 7;
         if f(i)=1 then PAID_P_2=PAID_P_2+1;
            else if f(i)=2 then FREE_P_2=FREE_P_2+1;
            else if f(i)=3 then EXCH_P_2=EXCH_P_2+1;
      end;

      do j=1 to 13;
         if vf(j)=1 then PAID_P_V=PAID_P_V+ve(j);
            else if vf(j)=2 then FREE_P_V=FREE_P_V+ve(j);
            else if vf(j)=3 then EXCH_P_V=EXCH_P_V+ve(j);
      end;

      do k=1 to 10;
         if of(k)=1 then PAID_P_O=PAID_P_O+oe(k);
            else if of(k)=2 then FREE_P_O=FREE_P_O+oe(k);
            else if of(k)=3 then EXCH_P_O=EXCH_P_O+oe(k);
      end;

      PAID_P=PAID_P_2+PAID_P_V+PAID_P_O;
      FREE_P=FREE_P_2+FREE_P_V+FREE_P_O;
      EXCH_P=EXCH_P_2+EXCH_P_V+EXCH_P_O;

      CODE23_P=PAID_P_2+FREE_P_2+EXCH_P_2;
      SMVILL_P=PAID_P_V+FREE_P_V+EXCH_P_V;
      OTVILL_P=PAID_P_O+FREE_P_O+EXCH_P_O;


      ALL_P=PAID_P+FREE_P+EXCH_P;

      if RICE=1 then HELPDV4=ALL_P;
         else HELPDV4=.;

 run;



data work00_7;
     set work00_6 (keep=VILL84 HELPDV RICE CODE23_P PAID_P_2 SMVILL_P PAID_P_V OTVILL_P PAID_P_O);

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

                        CODE23_T=CODE23_T+CODE23_P;
                        SMVILL_T=SMVILL_T+SMVILL_P;
                        OTVILL_T=OTVILL_T+OTVILL_P;       /* Sum up total workers by source by 84 village */
                      end;


     if last.VILL84 then do;
                           VILL_PP2=ROUND(PAID_T_2/(CODE23_T+0.0000001),.0001);
                           VILL_PPV=ROUND(PAID_T_V/(SMVILL_T+0.0000001),.0001);
                           VILL_PPO=ROUND(PAID_T_O/(OTVILL_T+0.0000001),.0001);   /* Percentages by source by 84 Vill */
                           TOTAL_HH=COUNTER;
                           RICEPROP=ROUND(RICECNTR/COUNTER,.0001);

                           OUTPUT;

                         end;
run;


proc corr data=work00_7;
run;

data out00_1.c2_00_01;
     set work00_7;
run;



/* proc datasets library=work;
     delete work00_4 work00_5;
run; */

/* proc sort data=work00_6 out=work00_7;
     by RICE;
run;

proc freq data=work00_7;
     by RICE;
     tables HELPTYPE;
run; */
