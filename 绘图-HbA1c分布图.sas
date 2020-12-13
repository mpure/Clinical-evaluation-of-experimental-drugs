/*给药12周后hba1c分布图（与正态分布比较）*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas，绘图样式-%ggplot2.sas*/

ods graphics on;
data normal_a;
set fas_hba1c_null(where=(actarmcd='A'));
run;
data normal_c;
set fas_hba1c_null(where=(actarmcd='C'));
run;
data normal_d;
set fas_hba1c_null(where=(actarmcd='D'));
run;

/*使用univariate绘制分布图并设置格式*/
%macro distrib(data=,label=);
proc univariate data = &data normal;
var lbstresn_12;
label lbstresn_12="&label";
histogram   lbstresn_12 / normal( w=1 l=1 color=yellow mu=est sigma=est)
		cframe=gray caxes=black waxis=1  cbarline=black cfill=blue pfill=solid frontref;
inset
		mean
		skewness
		kurtosis
		nobs
		pnormal
		 / position=ne
		ctext=blue
		cfill=cxd3d3d3
		cframe=blue
		cheader=blue
		height=2
	;
run;
%mend distrib;

/*主程序-绘制分布图*/
%distrib(data=normal_a,label=试验药10mg-12周后hba1c值)
%distrib(data=normal_c,label=试验药20mg-12周后hba1c值)
%distrib(data=normal_d,label=安慰剂-12周后hba1c值)
