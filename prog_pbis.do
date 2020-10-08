 /*--------------------------------------------------------------------------
|            Point Biserial Correlation and Test for Significance            |
|                                                                            |
|                  Written by:  John A. Anderson                             |
|                               Penn State University                        |
|                               PTI -- PenDOT LTAP Project                   |
|                               206 Reseasch Office Building                 |
|                               University Park, PA  16802-4710              |
|                                                                            |
|                               November 1993                                |
 ---------------------------------------------------------------------------*/
*! pbis -- calculate biserial point correlation
*! version 1.2.1     John A. Anderson     November 6, 1993     STB-17: sg20
program define pbis
   version 3.0
	if ("%_*" == "") {
		di in re "varlist required: bvar cvar [if exp] [in range] "
		exit 100
	}
   	local varlist "req ex min(2) max(2)"
   	local if "opt"
   	local in "opt"
	parse "`*'"
   	tempvar XpVar Touse
   quietly {
	gen `Touse'=1 `if' `in'
	replace `Touse'=0 if `Touse'==.|`1'==.|`2'==.
	sum `1' if `Touse'
	local Obs=_result(1)
	if (`Obs'<3) {
		di in re "not enough observations"
		exit 2001
	}
	if (_result(5)>0)|(_result(5)<0)|(_result(6)>1)|(_result(6)<1) {
		di in re "var1 must be a zero/one dichotomous variable"
		exit 111
	}

	sum `2' if `Touse'
	local Mc=_result(3)	           /* "c" = continuous variable */
	local SDc=sqrt(_result(4)) 
	gen `XpVar'=`2' if `1'==1 & `Touse'
	sum `XpVar'
	local Np=_result(1)
	local Pp=_result(1)/[`Obs']
	local Rpbi=((_result(3)-`Mc')/`SDc')*sqrt(`Pp'/(1-`Pp'))
	local tRpbi=`Rpbi'*sqrt(([`Obs']-2)/(1-`Rpbi'^2))
   }
   #delimit ;
	di _new in gr "(obs= " `Obs' ")";
	di in gr "Np= " in ye _result(1) in gr "  p= " in ye %3.2f 
	_result(1)/`Obs';
	di in gr "Nq= " in ye `Obs'-_result(1) in gr "  q= " in ye 
	%3.2f 1-(_result(1)/`Obs');
	di in gr _dup(4) "------------------+";
	di  in gr "Coef.= " in ye %6.4f `Rpbi'  
	"          " in gr "t= " in ye %6.4f `tRpbi'  "        " 
	in gr "P>|t| = " in ye %6.4f max(tprob([`Obs']-2,`tRpbi'),.0001)
	"        " in gr "df= " in ye %6.0f `Obs'-2;

   mac def S_1 `Rpbi'       	 /* Point Biserial Coefficient */;
   mac def S_2 `tRpbi'      	 /* t-ratio */;
   mac def S_3 `Obs'        	 /* Number of Observations */;
   mac def S_4 = _result(1)   	 /* Np or Number of Obs if var1==1 */;
   mac def S_5 = `Obs'-_result(1)  /* Nq or Number of Obs if var1==0 */;
   mac def S_6 `Mc'         	 /* Mean of var2 */;
   mac def S_7 = `SDc'^2      	 /* Varience of var2 */;
end ;
