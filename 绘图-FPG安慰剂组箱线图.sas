/*����fpg,2h ppg��Ի��߱仯�����飩*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas����ͼ��ʽ-%ggplot2.sas*/

proc format;
value weekdisplay
4='��ҩ���4��'
8='��ҩ���8��'
12='��ҩ���12��'
;
run;

data fpg_empty_d;
set fpg_empty_week;
where actarmcd='D';
run;

proc sgplot data=fpg_empty_d;
title '��ο�������FPG��Ի��߽�������ͼ';
format week weekdisplay.;
vbox diff/
group=week;
xaxis label="����" labelattrs=(size=10);
yaxis label="FPG��Ի��߱仯(%)" labelattrs=(size=10 );
run;
