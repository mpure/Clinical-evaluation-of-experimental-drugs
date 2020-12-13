/*预处理-统计分析不同分组的受试者在人口学特征、生命体征、嗜好品上是否有显著差异*/
/*用于描述基期数据*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas*/

/*方差分析*/
%macro anova(datatype= ,var= ); /*datatype为数据集名，var为因变量名*/
proc anova data = &datatype;
	title "&datatype";
	class actarmcd;
	model &var = actarmcd;
	means actarmcd / hovtest = bartlett;
run;
%mend anova;

/*卡方检验*/
%macro chisq(datatype= ,var= );
title "&datatype";
proc freq data = &datatype;
tables actarmcd*&var / chisq;
run;
%mend chisq;

/*正态性检验*/
%macro normal(datatype= ,var= );
proc univariate data = &datatype normal; 
title "&datatype";
class actarmcd;
var &var; 
run;
%mend normal;

/*非参数检验*/
%macro nonparametric(datatype= ,var= );
proc npar1way data=&datatype wilcoxon dscf;
title "&datatype.";
class actarmcd;
var &var; 
run;
%mend nonparametric;

/*人口学特征：年龄、性别的差异分析*/
%macro dmdata(type= ); /*type为数据集类型*/
%do i = 1 %to 2;
data _null_;
select; /*分别取变量为年龄、性别*/
	when(&i = 1)call symput('var','AGE');
	otherwise call symput('var','SEX');
end;
run;
proc sql;
create table &var as
select usubjid,&var,actarmcd from medical.dm
	where usubjid in
		(select usubjid from &type);
quit;
data _null_;
if &i = 1 then do;
	call execute('%normal(datatype = &var,var = &var)'); /*对年龄使用方差分析*/
	call execute('%anova(datatype = &var,var = &var)'); /*对年龄使用分析*/
	call execute('%nonparametric(datatype = &var,var = &var)'); /*对年龄使用分析*/
	end;
	else call execute ('%chisq(datatype = &var,var = &var)'); /*对性别使用卡方分析*/
run;
%end;
%mend dmdata;

/*生命体征：体重、bmi、心率、呼吸、舒张压、收缩压的差异分析*/
%macro vsdata(type= );
%do i = 1 %to 6; 
data _null_;
call symput('var','VSSTRESN'); /*数值变量名为vsstresn*/
select; /*分别取出体重、bmi、心率、呼吸、舒张压、收缩压*/
	when(&i = 1)call symput('datatype','WEIGHT');
	when(&i = 2)call symput('datatype','BMI');
	when(&i = 3)call symput('datatype','HR');
	when(&i = 4)call symput('datatype','RESP');
	when(&i = 5)call symput('datatype','DIABP');
	otherwise call symput('datatype','SYSBP');
end;
run;
proc sql;
create table &datatype as
select a.usubjid,actarmcd,&var from medical.dm a,medical.vs b 
	where a.usubjid in (select usubjid from &type)
	and b.vsblfl='是' /*使用基线标志数据*/
	and b.vstestcd = "&datatype"
	and a.usubjid = b.usubjid;
quit;
%normal(datatype = &datatype,var = &var) /*正态性检验*/
%anova(datatype = &datatype,var = &var) /*方差齐性检验与方差分析*/
%nonparametric(datatype = &datatype,var = &var)/*非参数检验*/
%end;
%mend vsdata;

/*嗜好品使用的差异分析*/
%macro sudata(type= );
data _null_;
call symput('var','SUSITUA'); /*取嗜好品情况变量susitua*/
run;
proc sql;
create table &var as
select a.usubjid,actarmcd,&var from medical.dm a,medical.su b
	where a.usubjid in (select usubjid from &type)
	and a.usubjid = b.usubjid
	and &var ^= ' ';
quit;
%chisq(datatype = &var,var = &var) /*使用卡方检验*/
%mend sudata;

/*主程序-对fas集进行以上三类差异分析*/
%dmdata(type = fas)
%vsdata(type = fas)
%sudata(type = fas)
