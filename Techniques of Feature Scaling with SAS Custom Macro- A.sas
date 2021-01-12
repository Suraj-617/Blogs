/* ---------------------------1.Min_MaxScaler -------------------------------- */

%macro Min_MaxScaler(dataset, variable);

proc sql noprint;
select min(&variable) into: mn
from &dataset;

select max(&variable) into: mx
from &dataset;
quit;

data new;
set &dataset;
MM_&variable= (&variable - &mn)/(&mx - &mn);
run;

TITLE 'Comparison of Actual Variable V/s Scaled Variable';
PROC UNIVARIATE DATA = new NOPRINT;
HISTOGRAM &variable / NORMAL;
HISTOGRAM MM_&variable / NORMAL;
RUN;

%mend;

/* example  */
%Min_MaxScaler(sashelp.cars, MSRP)

/* ----------------------------2.Mean Normalization----------------------------*/

%macro Mean_Normalization(dataset, variable);

proc sql noprint;
select min(&variable) into: mn
from &dataset;

select max(&variable) into: mx
from &dataset;

select mean(&variable) into: avg
from &dataset;
quit;
run;

data new;
set &dataset;
MN_&variable= (&variable - &avg)/(&mx - &mn);
run;

TITLE 'Comparison of Actual Variable V/s Scaled Variable';
PROC UNIVARIATE DATA = new NOPRINT;
HISTOGRAM &variable / NORMAL;
HISTOGRAM MN_&variable / NORMAL;
RUN;

%mend;

%Mean_Normalization(sashelp.cars, MSRP)

/*--------------------------------3.Standard Scaling---------------------------*/

%macro Standard_Scaler(dataset, variable);

proc sql noprint;
select mean(&variable) into: m
from &dataset;

select std(&variable) into: s
from &dataset;
quit;

data new;
set &dataset;
SD_&variable= (&variable - &m)/&s;
run;

TITLE 'Comparison of Actual Variable V/s Scaled Variable';
PROC UNIVARIATE DATA = new NOPRINT;
HISTOGRAM &variable / NORMAL;
HISTOGRAM SD_&variable / NORMAL;
RUN;

%mend;

/* example  */
%Standard_Scaler(sashelp.cars, MSRP)

/*-------------------------------4. RobustScaler-------------------------------*/
%macro Robust_Scaler(dataset, Variable);

proc means data=&dataset Q1 Q3 median  noprint;
var &variable;
Output out = stat  Q1=Q1  Q3=Q3 median =M;
run;

proc sql;
select Q3-Q1 as iqr
into:iqr
from stat;
select M-0 as me
into:me
from stat;
quit;
run;

data new;
set &dataset;
RS_&variable = (&variable - &me) / &iqr ;
run;

TITLE 'Comparison of Actual Variable V/s Scaled Variable';
PROC UNIVARIATE DATA = new NOPRINT;
HISTOGRAM &variable / NORMAL;
HISTOGRAM RS_&variable / NORMAL;
RUN;
%mend;

/* example  */
option mlogic mprint symbolgen;
%Robust_Scaler(sashelp.cars, MSRP)












