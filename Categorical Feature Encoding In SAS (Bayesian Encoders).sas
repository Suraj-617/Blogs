	/* Mean Encoding */

%macro Mean_Encoding(Dataset,Var,Target);

proc sql;
create table Mean_Table As
select distinct(&Var) As GR, round(Mean(&Target),00.1) As Mean_Encode
from &Dataset
Group by GR;
quit;
run;

proc sql;
Create table New As 
select D.* , M.Mean_Encode
from &Dataset As D
left join Mean_Table As M
on &Var=M.GR;
quit;
run;

%mend;

					/* Example of Mean Encoding */

%Mean_Encoding(sashelp.cars,Origin,MSRP)

/* -------------------------------------------------------------------------------------------------------------------- */

					/* Weight Of Evidence Encoding  */

%Macro WOE_Encoding(Dataset,Var,Target);

proc sql;
create table Stats As
select distinct(&Var) As GR, round(Mean(&Target),00.1) As Mean_Encode 
from &Dataset
Group by GR;
quit;
run;

Data Stats;
set Stats;
Bad_Prob=1-Mean_Encode;
if Bad_Prob=0 then Bad_Prob=0.0001;
ME_by_BP=Mean_Encode/Bad_Prob;
WOE_Encode=log(ME_by_BP);
run;

proc sql;
Create table New As 
select D.* , S.WOE_Encode 
from &Dataset As D
left join Stats As S
on &Var=S.GR;
quit;
run;

%mend;

					/* example of Weight Of Evidence Encoding */

%WOE_Encoding(Try, DriveTrain ,Bin)

/* -------------------------------------------------------------------------------------------------------------------- */
					/* Probability Ratio Encoding  */

%Macro Probability_Encoding(Dataset,Var,Target);

proc sql;
create table Stats As
select distinct(&Var) As GR, round(Mean(&Target),00.1) As Mean_Encode 
from &Dataset
Group by GR;
quit;
run;

Data Stats;
set Stats;
Bad_Prob=1-Mean_Encode;
if Bad_Prob=0 then Bad_Prob=0.0001;
Prob_Encode=Mean_Encode/Bad_Prob;
run;

proc sql;
Create table New As 
select D.* , S.Prob_Encode 
from &Dataset As D
left join Stats As S
on &Var=S.GR;
quit;
run;

%mend;

					/* example of Probability Ratio Encoding */

%Probability_Encoding(SASHelp.cars, DriveTrain ,MSRP)
