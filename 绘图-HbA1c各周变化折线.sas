/*各周hba1c折线图（ITT与PP下）*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas，绘图样式-%ggplot2.sas*/

%macro linechart(data=,title=);
proc transpose data=&data out=deal1;
 var lbstresn lbstresn_4 lbstresn_8 lbstresn_12;
 by usubjid actarmcd;
run;

data deal2;
 set deal1;
 if _name_='LBSTRESN' then time=0;
 if _name_='lbstresn_4' then time=4;
 if _name_='lbstresn_8' then time=8;
 if _name_='lbstresn_12' then time=12;
run;

/*自定义显示格式*/
proc format;
value $group
'A' = '试验药10mg'
'C' = '试验药20mg'
'D' = '安慰剂'
;
run;

/*折线图绘制*/
proc sgplot data=deal2(rename=(col1=hba1c)) noborder;
title '各组hba1c均值随时间变化('"&title"'分析下)';
format actarmcd $group.;
 vline time/response=hba1c stat=mean group=actarmcd
 limits=both limitstat=stddev markers lineattrs=(pattern=solid thickness=1.5);
xaxis values = ( 0 to 12 by 4) label="给药后周数(周)" labelattrs=( size=10);
yaxis values = (7 to 9 by 0.5) label="hba1c均值(%)" labelattrs=(weight=bold size=10 );
run;
%mend linechart;

/*主程序*/
%linechart(data=fas_hba1c_null,title=ITT)
%linechart(data=pps_hba1c_null,title=PP)
