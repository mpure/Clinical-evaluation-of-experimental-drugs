/*给药12周后hba1c相对基线变化（分组）*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas，绘图样式-%ggplot2.sas*/

/*定义分组格式*/
proc format;
value $group
'A' = '试验药10mg'
'C' = '试验药20mg'
'D' = '安慰剂'
;
run;

/*绘制分组误差限条形图*/
proc sgplot data=fas_hba1c_null;
title '三组12周后HbA1c相对基线变化';
format actarmcd $group.;
vbar actarmcd/
response=diff_12
stat=mean
limitstat=stddev
limits=lower
datalabel=diff_12
seglabel
seglabelattrs=(color=white size=15 style=italic)
legendlabel='12周后HbA1c相对基线变化(%)'
x2axis
;
xaxis label="分组" labelattrs=(size=10);
yaxis label="HbA1c相对基线变化(%)" labelattrs=(size=10 );
/*使用双x轴标注基线*/
x2axis display=(novalues) label="试验药10mg基线均值 8.4%    试验药20mg基线均值 8.4%    安慰剂基线均值 8.2%" labelattrs=(size=10) labelpos=center;
run;
