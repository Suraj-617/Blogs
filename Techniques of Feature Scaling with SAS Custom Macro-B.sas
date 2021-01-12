/* ------------------------------1.Abs_MaxScaler-------------------------------- */

%macro Abs_MaxScaler(dataset, variable);

proc sql noprint;

select max(&variable) into: mx
from &dataset;
quit;

data new;
set &dataset;
AM_&variable= (&variable/ &mx);
run;

TITLE 'Comparison of Actual Variable V/s Scaled Variable';
PROC UNIVARIATE DATA = new NOPRINT;
HISTOGRAM &variable / NORMAL;
HISTOGRAM AM_&variable / NORMAL;
RUN;

%mend;

/* example  */
%Abs_MaxScaler(sashelp.cars, MSRP)

/*-----------------------------2.BoxCox Transformation--------------------------*/
%macro BoxCox(dataset, variable);

data _null_;
set &dataset;
%if &variable > 0 %then %do;
	title 'Univariate Box-Cox';

	data x;
	set sashelp.cars;
	Acul_&variable = &variable;
	z=0;
	run;

	proc transreg maxiter=0 nozeroconstant;
   	model BoxCox(Acul_&variable) = identity(z);
   	output;
	run;

	proc univariate noprint;
	histogram TAcul_&variable / normal;
	run;
%end;

%else %do;
	%Put Error: You data has negtive values, hence you can not apply BoxCox transformation;
%end; 
run; 
%mend;

/* Example of BoxCox */
option symbolgen;
%BoxCox(sashelp.cars, MSRP)

/*----------------------------3.Common Transformations-------------------------*/

%macro Transform(dataset, variable, type);

%let transforms=%lowcase(&type);


%if &transforms=%lowcase(log) % then %do;
		data new;
		set &dataset;
		Log_&variable =log(&variable);
		run;
		
		TITLE 'Summary of Log Variable';
		PROC UNIVARIATE DATA = new NOPRINT;
		HISTOGRAM Log_&variable / NORMAL;
		RUN;
	
%end;

%else %if &transforms=%lowcase(Square Root) % then %do;
		data new;
		set &dataset;
		SRT_&variable=sqrt(&variable);
		run;

		TITLE 'Summary of Square Root Variable';
		PROC UNIVARIATE DATA = new NOPRINT;
		HISTOGRAM SRT_&variable / NORMAL;
		RUN;
%end;

%else %if &transforms =%lowcase(Reciprocal) % then %do;
		data new;
		set &dataset;
		REC_&variable =1/&variable;
		run;

		TITLE 'Summary of Reciprocal Variable';
		PROC UNIVARIATE DATA = new NOPRINT;
		HISTOGRAM REC_&variable / NORMAL;
		RUN;
		
%end;

%else %if &transforms= %lowcase(Exponential) % then %do;
		data new;
		set &dataset;
		EXP_&variable = 1/&variable;
		run;
		
		TITLE 'Summary of Exponential Variable';
		PROC UNIVARIATE DATA = new NOPRINT;
		HISTOGRAM EXP_&variable / NORMAL;
		RUN;

%end;

%else %do;
		%put ERROR: The following transformation are availiable only log10, Square Root, Reciprocal, Exponential.;
		%put NOTE: Select one of the aforementioned transformations.;
%end;

%mend;


%Transform(sashelp.cars, MSRP, log)






