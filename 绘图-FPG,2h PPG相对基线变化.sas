/*����fpg,2h ppg��Ի��߱仯�����飩*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas����ͼ��ʽ-%ggplot2.sas*/

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

/*�Զ����ʽ*/
proc format;
value $group
'A' = '����ҩ10mg'
'C' = '����ҩ20mg'
'D' = '��ο��'
;
value weekdisplay
4='��ҩ���4��'
8='��ҩ���8��'
12='��ҩ���12��'
;
run;

/*��ͼ*/
proc sgplot data=fpg_&tpt._week;
title '����12�ܺ�'"&title"'��Ի��߱仯';
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
legendlabel="12�ܺ�&title.��Ի��߱仯(%)"
;
xaxis label="����" labelattrs=(size=10);
yaxis label="&title.��Ի��߱仯(%)" labelattrs=(size=10 );
run;
%mend baseline_change;

/*������*/
%baseline_change(tpt=empty,title=FPG)
%baseline_change(tpt=meal2,title=2h PPG)
