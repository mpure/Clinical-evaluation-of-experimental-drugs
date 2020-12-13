/*实验室检查值lb数据集分析/
/*本宏程序用于提取主要疗效指标hba1c，以及次要疗效指标fpg,2h ppg，清洗数据，并进行正态性、方差分析**/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas*/

/*方差分析*/
%macro anova(datatype= ,var= ); /*datatype为数据集名，var为因变量名*/
proc anova data = &datatype;
	title "&datatype";
	class actarmcd;
	model &var = actarmcd;
	means actarmcd / hovtest = bartlett snk;
run;
%mend anova;

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
title "&datatype";
class actarmcd;
var &var; 
run;
%mend nonparametric;


%macro lb_analysis(type= ,var= ,time= );/*type为数据集类型，var为分析变量，time为计划的研究时间点（空腹、餐后等）*/
proc sql;
/*根据数据集类型从lb选出受试者的id、分组、实验室检查值、访视日期、研究时间点*/
create table &var as
select a.usubjid,b.actarmcd,a.lbstresn,a.visit,a.lbtpt from medical.lb a,&type b
	where a.usubjid = b.usubjid
	and a.lbtestcd = "&var"
	and a.lbtpt = "&time"
	order by a.usubjid;

/*将基线处的数据保存为临时基线集temp_base*/
create table temp_base as
select * from &var
	where visit = '导入期（-4天）';
quit;

/*分别将给药后第4、8、12周时的信息保存为相应的数据集*/
%do week = 4 %to 12 %by 4;
data temp_&week;
set &var
	(rename = (lbstresn=lbstresn_&week visit=visit_&week) /*重命名防止变量重载*/
	where = (visit_&week ~= '导入期（-4天）' and visit_&week contains "&week"));
run;
%end;

/*将研究时间点转换为英文代号，方便命名后续使用的数据集，且可以被sas base读取*/
data _null_;
select;
when("&time" = ' ') call symput('timecd','null');
when("&time" = '空腹') call symput('timecd','empty');
otherwise call symput('timecd','meal2');
end;
run;

/*将给药后第8或12周时实验室检查值为缺失值的受试者挑出，并使用他们上一次受访时的实验室检查值填充缺失值*/
/*添加变量rate_12为实验室检查值在给药12周后相对基线的变化率*/
data &type&var&timecd;
merge temp_base temp_4 temp_8 temp_12;
	by usubjid;
/*缺失值填充*/
visit_12 = '给药后第12周';
visit_8 = '给药后第8周';
if lbstresn_4 = . then do;
	if lbstresn_8 ~= . then lbstresn_4 = lbstresn_8;
	else lbstresn_4 = lbstresn_12;
end;
if lbstresn_8 = . then lbstresn_8 = lbstresn_4;
if lbstresn_12 = . then lbstresn_12 = lbstresn_8;
format rate_4 percentn10.2 rate_8 percentn10.2 rate_12 percentn10.2; /*使用百分格式*/
diff_4 = lbstresn_4-lbstresn;/*计算相对基线差值，以便备用*/
diff_8 = lbstresn_8-lbstresn;
diff_12 = lbstresn_12-lbstresn;
rate_4 = (lbstresn_4-lbstresn) / lbstresn;/*计算相对基线比率，以便备用*/
rate_8 = (lbstresn_8-lbstresn) / lbstresn;
rate_12 = (lbstresn_12-lbstresn) / lbstresn;
run;

/*对个别在同一访视时期进行了多次测量的受试者进行清洗*/
/*对由于某次未查而进行复查的受试者，删去未查的观测*/
proc sql;
delete from &type&var&timecd
	where lbstresn_4 = . | lbstresn_8 = . | lbstresn_12 = .;
quit;
/*对其他个别在同一访视日期内有多次检查记录的受试者，取该访视日期内的首次检查数据*/
proc sort data=&type&var&timecd out=&type._&var._&timecd nodupkey;
	by usubjid;
run;

%normal(datatype=&type._&var._&timecd,var=lbstresn_12)/*正态性检验*/
%anova(datatype=&type._&var._&timecd,var=rate_12)/*方差分析*/
%nonparametric(datatype=&type._&var._&timecd,var=diff_12)/*非参数检验*/

proc delete data=&type&var&timecd temp_base temp_4 temp_8 temp_12 &var;/*删除临时数据集*/
run;

%mend lb_analysis;

/*主程序*/
%lb_analysis(type=fas,var=HBA1C,time= )/*fas集的hba1c*/
%lb_analysis(type=fas,var=FPG,time=空腹)/*fas集的fpg*/
%lb_analysis(type=fas,var=FPG,time=餐后2小时)/*fas集的2h ppg*/

%lb_analysis(type=pps,var=HBA1C,time= )/*pps集的hba1c*/
%lb_analysis(type=pps,var=FPG,time=空腹)/*pps集的fpg*/
%lb_analysis(type=pps,var=FPG,time=餐后2小时)/*pps集的2h ppg*/
