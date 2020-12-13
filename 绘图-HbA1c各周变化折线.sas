/*����hba1c����ͼ��ITT��PP�£�*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas����ͼ��ʽ-%ggplot2.sas*/

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

/*�Զ�����ʾ��ʽ*/
proc format;
value $group
'A' = '����ҩ10mg'
'C' = '����ҩ20mg'
'D' = '��ο��'
;
run;

/*����ͼ����*/
proc sgplot data=deal2(rename=(col1=hba1c)) noborder;
title '����hba1c��ֵ��ʱ��仯('"&title"'������)';
format actarmcd $group.;
 vline time/response=hba1c stat=mean group=actarmcd
 limits=both limitstat=stddev markers lineattrs=(pattern=solid thickness=1.5);
xaxis values = ( 0 to 12 by 4) label="��ҩ������(��)" labelattrs=( size=10);
yaxis values = (7 to 9 by 0.5) label="hba1c��ֵ(%)" labelattrs=(weight=bold size=10 );
run;
%mend linechart;

/*������*/
%linechart(data=fas_hba1c_null,title=ITT)
%linechart(data=pps_hba1c_null,title=PP)
