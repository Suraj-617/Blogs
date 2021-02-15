								/* Label Encoding  */
option mprint mlogic;
%macro Label_Encode(dataset,Var);
proc sql noprint;

select distinct(&Var)
into:Val1-
from &dataset;

select Count(distinct(&Var)) 
into: mx
from &dataset;
quit;
run;

data new;
set &dataset;
%do i=1 %to &mx;
if &Var="&&&val&i" then New=&i;
%end;
run;
%mend;

								/* Example Of Lable Encode */
%Label_Encode(SAShelp.cars,Origin) 
/* ----------------------------------------------------------------------------------------------------------------------------------------------------------- */

								/* Binary Encoding  */

%Macro Binary_Encoding(dataset,Var);

proc sql noprint;

select distinct(&Var)
into:Val1-
from &dataset;

select Count(distinct(&Var)) 
into: mx
from &dataset;
quit;
run;

data new;
set &dataset;
%do i=1 %to &mx;
if &Var="&&&val&i" then New=&i;
%end;
format New Binary.;
run;

%mend;

								/* Example of Binary Encoding */
%Binary_Encoding(SASHelp.cars, Make)
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------- */
								/* Spliting Columns  */
options mprint mlogic ;
%macro split_column(data,Var);

Data Try;
set &data;
Cha=put(&Var, Binary.);
run;

proc sql noprint;
select max(length(Cha)) into :Ln from Try ;
quit;

data &data;
set Try;
%do i=1 %to &Ln;

	C_&i=substr(Cha,&i,1);
%end;
run;

%mend;
options nomprint nomlogic ;
								/* Example of Column Split  */
options symbolgen;
%split_column(work.New,NEW)

/* --------------------------------------------------------------------------------------------------------------------------------------------------------------- */

								/* One Hot Encoding  */
option mprint mlogic;
%macro hot_encoding(data,var);
proc sql noprint;
select distinct &var 
	into:val1-
from &data;
select count(distinct(&var))
	into:len
from &data;
quit;
run;
data encoded_data;
set &data;
%do i=1 %to &len;
	if &var="&&&val&i" then %sysfunc(compress(&&&val&i,'$ - /'))=1 ;
	else  %sysfunc(compress(&&&val&i,'$ - /'))=0;
%end;
run;
%mend;

								/* Example of One Hot Encoding */
%hot_Encoding(SASHelp.cars, Origin)

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

								/* Frequency Encoding  */ 
%macro Frequency_Encoding(Dataset, Var);
proc sql;
create table Freq As 
select distinct(&Var) As Values, count(&Var) as Number
from &Dataset 
group by Values ;
run;

proc sql;
Create table New As 
select *, round(Freq.Number/count(&Var),00.01) As FREQ_Encode 
from &Dataset 
left join Freq 
on &Var=Freq.Values;
run;

Data New (Drop=Values Number);
set New;
run;

%mend;

								/* Example of Frequency Encoding  */
%Frequency_Encoding(Sashelp.cars,Origin)

/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */

								/* Macro Effect/Sum/ Deviation Encoding  */
option mprint mlogic;
%macro Sum_Encoding(data,var);
proc sql;
select distinct &var 
	into:val1-
from &data;
select count(distinct(&var))
	into:len
from &data;
quit;
run;
data encoded_data;
set &data;
%do i=1 %to &len;
	if &var="&&&val&i" then %sysfunc(compress(&&&val&i,'$ - /'))=1 ;
	else  %sysfunc(compress(&&&val&i,'$ - /'))=0;
%end;
run;

data Sum_Encode;
set encoded_data;
if %sysfunc(compress(&&&val&Len,'$ - /'))=1 then do;
	%do x=1 %to %eval(&len-1);
		%sysfunc(compress(&&&val&x,'$ - /'))=-1;
	%END;
END;
Drop %sysfunc(compress(&&&val&Len,'$ - /'));
run;

%mend;
								/* Examples of Sum_Encoding */
%Sum_encode(sashelp.cars,Origin)

