/*各周fpg,2h ppg相对基线变化（分组）*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas，绘图样式-%ggplot2.sas*/

%macro baseline_change(tpt=,title=);
data fpg_&tpt._4;
set fas_fpg_&tpt(rename=(diff_4=diff));
week=4;
keep usubjid actarmcd week diff;
run;
data fpg_&tpt._8;
set fas_fpg_&tpt(rename=(diff_8=diff));
week=8;
keep usubjid actarmcd week diff;
run;
data fpg_&tpt._12;
set fas_fpg_&tpt(rename=(diff_12=diff));
week=12;
keep usubjid actarmcd week diff;
run;
data fpg_&tpt._week;
set fpg_&tpt._4 fpg_&tpt._8 fpg_&tpt._12;
run;

/*自定义格式*/
proc format;
value $group
'A' = '试验药10mg'
'C' = '试验药20mg'
'D' = '安慰剂'
;
value weekdisplay
4='给药后第4周'
8='给药后第8周'
12='给药后第12周'
;
run;

/*绘图*/
proc sgplot data=fpg_&tpt._week;
title '三组12周后'"&title"'相对基线变化';
format actarmcd $group. week weekdisplay.;
vbar week/
group=actarmcd
groupdisplay=cluster
response=diff
stat=mean
limitstat=stddev
limits=lower
datalabel=diff
seglabel
seglabelattrs=(color=white size=10)
seglabelfitpolicy=noclip
legendlabel="12周后&title.相对基线变化(%)"
;
xaxis label="分组" labelattrs=(size=10);
yaxis label="&title.相对基线变化(%)" labelattrs=(size=10 );
run;
%mend baseline_change;

/*主程序*/
%baseline_change(tpt=empty,title=FPG)
%baseline_change(tpt=meal2,title=2h PPG)
