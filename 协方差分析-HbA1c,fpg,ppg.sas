/*协方差分析（ANCOVA）*/
/*本宏程序可以用于hba1c,fpg,2h ppg的协方差分析*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas*/

%macro boxcox_ancova(data=,var=);
/*box-cox转换：*/
data temp_x0;
set &data;
x=0;/*增加列x,使x=0,用来进行后续转换*/
run;

/*进行Box-Cox转化*/
proc transreg maxiter=0 nozeroconstant detail ss2 data=temp_x0;
   model boxcox(&var) = identity(x);
   output out=temp_bc;
run;

/*提取转化后的变量*/
data trans_bc;
merge &data temp_bc;
keep actarmcd lbstresn t&var;
run;

/*按组排序*/
proc sort data=trans_bc;
	by actarmcd;
run;

/*检验正态性*/
proc univariate normal data=trans_bc;
	var t&var;
by actarmcd;
run;

/*检验方差齐性*/
proc discrim pool=test data=trans_bc;
	class actarmcd;
	var t&var;
run;

/*检验线性相关性*/
proc reg data=trans_bc;
	model &var=lbstresn;
	by actarmcd;
run;

/*协方差分析*/
proc glm data=trans_bc;
	class actarmcd;
	model t&var=lbstresn actarmcd;
	lsmeans actarmcd/ stderr pdiff;
run;

%mend boxcox_ancova;

/*主程序*/
%boxcox_ancova(data=fas_hba1c_null,var=lbstresn_12)
%boxcox_ancova(data=fas_fpg_empty,var=lbstresn_12)
%boxcox_ancova(data=fas_fpg_meal2,var=lbstresn_12)

