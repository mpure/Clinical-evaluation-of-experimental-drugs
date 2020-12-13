/*ʵ���Ҽ��ֵlb���ݼ�����/
/*�������������ȡ��Ҫ��Чָ��hba1c���Լ���Ҫ��Чָ��fpg,2h ppg����ϴ���ݣ���������̬�ԡ��������**/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas*/

/*�������*/
%macro anova(datatype= ,var= ); /*datatypeΪ���ݼ�����varΪ�������*/
proc anova data = &datatype;
	title "&datatype";
	class actarmcd;
	model &var = actarmcd;
	means actarmcd / hovtest = bartlett snk;
run;
%mend anova;

/*��̬�Լ���*/
%macro normal(datatype= ,var= );
proc univariate data = &datatype normal; 
title "&datatype";
class actarmcd;
var &var; 
run;
%mend normal;

/*�ǲ�������*/
%macro nonparametric(datatype= ,var= );
proc npar1way data=&datatype wilcoxon dscf;
title "&datatype";
class actarmcd;
var &var; 
run;
%mend nonparametric;


%macro lb_analysis(type= ,var= ,time= );/*typeΪ���ݼ����ͣ�varΪ����������timeΪ�ƻ����о�ʱ��㣨�ո����ͺ�ȣ�*/
proc sql;
/*�������ݼ����ʹ�lbѡ�������ߵ�id�����顢ʵ���Ҽ��ֵ���������ڡ��о�ʱ���*/
create table &var as
select a.usubjid,b.actarmcd,a.lbstresn,a.visit,a.lbtpt from medical.lb a,&type b
	where a.usubjid = b.usubjid
	and a.lbtestcd = "&var"
	and a.lbtpt = "&time"
	order by a.usubjid;

/*�����ߴ������ݱ���Ϊ��ʱ���߼�temp_base*/
create table temp_base as
select * from &var
	where visit = '�����ڣ�-4�죩';
quit;

/*�ֱ𽫸�ҩ���4��8��12��ʱ����Ϣ����Ϊ��Ӧ�����ݼ�*/
%do week = 4 %to 12 %by 4;
data temp_&week;
set &var
	(rename = (lbstresn=lbstresn_&week visit=visit_&week) /*��������ֹ��������*/
	where = (visit_&week ~= '�����ڣ�-4�죩' and visit_&week contains "&week"));
run;
%end;

/*���о�ʱ���ת��ΪӢ�Ĵ��ţ�������������ʹ�õ����ݼ����ҿ��Ա�sas base��ȡ*/
data _null_;
select;
when("&time" = ' ') call symput('timecd','null');
when("&time" = '�ո�') call symput('timecd','empty');
otherwise call symput('timecd','meal2');
end;
run;

/*����ҩ���8��12��ʱʵ���Ҽ��ֵΪȱʧֵ����������������ʹ��������һ���ܷ�ʱ��ʵ���Ҽ��ֵ���ȱʧֵ*/
/*��ӱ���rate_12Ϊʵ���Ҽ��ֵ�ڸ�ҩ12�ܺ���Ի��ߵı仯��*/
data &type&var&timecd;
merge temp_base temp_4 temp_8 temp_12;
	by usubjid;
/*ȱʧֵ���*/
visit_12 = '��ҩ���12��';
visit_8 = '��ҩ���8��';
if lbstresn_4 = . then do;
	if lbstresn_8 ~= . then lbstresn_4 = lbstresn_8;
	else lbstresn_4 = lbstresn_12;
end;
if lbstresn_8 = . then lbstresn_8 = lbstresn_4;
if lbstresn_12 = . then lbstresn_12 = lbstresn_8;
format rate_4 percentn10.2 rate_8 percentn10.2 rate_12 percentn10.2; /*ʹ�ðٷָ�ʽ*/
diff_4 = lbstresn_4-lbstresn;/*������Ի��߲�ֵ���Ա㱸��*/
diff_8 = lbstresn_8-lbstresn;
diff_12 = lbstresn_12-lbstresn;
rate_4 = (lbstresn_4-lbstresn) / lbstresn;/*������Ի��߱��ʣ��Ա㱸��*/
rate_8 = (lbstresn_8-lbstresn) / lbstresn;
rate_12 = (lbstresn_12-lbstresn) / lbstresn;
run;

/*�Ը�����ͬһ����ʱ�ڽ����˶�β����������߽�����ϴ*/
/*������ĳ��δ������и���������ߣ�ɾȥδ��Ĺ۲�*/
proc sql;
delete from &type&var&timecd
	where lbstresn_4 = . | lbstresn_8 = . | lbstresn_12 = .;
quit;
/*������������ͬһ�����������ж�μ���¼�������ߣ�ȡ�÷��������ڵ��״μ������*/
proc sort data=&type&var&timecd out=&type._&var._&timecd nodupkey;
	by usubjid;
run;

%normal(datatype=&type._&var._&timecd,var=lbstresn_12)/*��̬�Լ���*/
%anova(datatype=&type._&var._&timecd,var=rate_12)/*�������*/
%nonparametric(datatype=&type._&var._&timecd,var=diff_12)/*�ǲ�������*/

proc delete data=&type&var&timecd temp_base temp_4 temp_8 temp_12 &var;/*ɾ����ʱ���ݼ�*/
run;

%mend lb_analysis;

/*������*/
%lb_analysis(type=fas,var=HBA1C,time= )/*fas����hba1c*/
%lb_analysis(type=fas,var=FPG,time=�ո�)/*fas����fpg*/
%lb_analysis(type=fas,var=FPG,time=�ͺ�2Сʱ)/*fas����2h ppg*/

%lb_analysis(type=pps,var=HBA1C,time= )/*pps����hba1c*/
%lb_analysis(type=pps,var=FPG,time=�ո�)/*pps����fpg*/
%lb_analysis(type=pps,var=FPG,time=�ͺ�2Сʱ)/*pps����2h ppg*/
