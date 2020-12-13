/*各周fpg,2h ppg相对基线变化（分组）*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas，绘图样式-%ggplot2.sas*/

proc format;
value weekdisplay
4='给药后第4周'
8='给药后第8周'
12='给药后第12周'
;
run;

data fpg_empty_d;
set fpg_empty_week;
where actarmcd='D';
run;

proc sgplot data=fpg_empty_d;
title '安慰剂组各周FPG相对基线降幅箱线图';
format week weekdisplay.;
vbox diff/
group=week;
xaxis label="分组" labelattrs=(size=10);
yaxis label="FPG相对基线变化(%)" labelattrs=(size=10 );
run;
