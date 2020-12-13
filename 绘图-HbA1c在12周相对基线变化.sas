/*��ҩ12�ܺ�hba1c��Ի��߱仯�����飩*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas����ͼ��ʽ-%ggplot2.sas*/

/*��������ʽ*/
proc format;
value $group
'A' = '����ҩ10mg'
'C' = '����ҩ20mg'
'D' = '��ο��'
;
run;

/*���Ʒ������������ͼ*/
proc sgplot data=fas_hba1c_null;
title '����12�ܺ�HbA1c��Ի��߱仯';
format actarmcd $group.;
vbar actarmcd/
response=diff_12
stat=mean
limitstat=stddev
limits=lower
datalabel=diff_12
seglabel
seglabelattrs=(color=white size=15 style=italic)
legendlabel='12�ܺ�HbA1c��Ի��߱仯(%)'
x2axis
;
xaxis label="����" labelattrs=(size=10);
yaxis label="HbA1c��Ի��߱仯(%)" labelattrs=(size=10 );
/*ʹ��˫x���ע����*/
x2axis display=(novalues) label="����ҩ10mg���߾�ֵ 8.4%    ����ҩ20mg���߾�ֵ 8.4%    ��ο�����߾�ֵ 8.2%" labelattrs=(size=10) labelpos=center;
run;
