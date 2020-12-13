/*Ԥ����-ͳ�Ʒ�����ͬ��������������˿�ѧ�����������������Ⱥ�Ʒ���Ƿ�����������*/
/*����������������*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas*/

/*�������*/
%macro anova(datatype= ,var= ); /*datatypeΪ���ݼ�����varΪ�������*/
proc anova data = &datatype;
	title "&datatype";
	class actarmcd;
	model &var = actarmcd;
	means actarmcd / hovtest = bartlett;
run;
%mend anova;

/*��������*/
%macro chisq(datatype= ,var= );
title "&datatype";
proc freq data = &datatype;
tables actarmcd*&var / chisq;
run;
%mend chisq;

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
title "&datatype.";
class actarmcd;
var &var; 
run;
%mend nonparametric;

/*�˿�ѧ���������䡢�Ա�Ĳ������*/
%macro dmdata(type= ); /*typeΪ���ݼ�����*/
%do i = 1 %to 2;
data _null_;
select; /*�ֱ�ȡ����Ϊ���䡢�Ա�*/
	when(&i = 1)call symput('var','AGE');
	otherwise call symput('var','SEX');
end;
run;
proc sql;
create table &var as
select usubjid,&var,actarmcd from medical.dm
	where usubjid in
		(select usubjid from &type);
quit;
data _null_;
if &i = 1 then do;
	call execute('%normal(datatype = &var,var = &var)'); /*������ʹ�÷������*/
	call execute('%anova(datatype = &var,var = &var)'); /*������ʹ�÷���*/
	call execute('%nonparametric(datatype = &var,var = &var)'); /*������ʹ�÷���*/
	end;
	else call execute ('%chisq(datatype = &var,var = &var)'); /*���Ա�ʹ�ÿ�������*/
run;
%end;
%mend dmdata;

/*�������������ء�bmi�����ʡ�����������ѹ������ѹ�Ĳ������*/
%macro vsdata(type= );
%do i = 1 %to 6; 
data _null_;
call symput('var','VSSTRESN'); /*��ֵ������Ϊvsstresn*/
select; /*�ֱ�ȡ�����ء�bmi�����ʡ�����������ѹ������ѹ*/
	when(&i = 1)call symput('datatype','WEIGHT');
	when(&i = 2)call symput('datatype','BMI');
	when(&i = 3)call symput('datatype','HR');
	when(&i = 4)call symput('datatype','RESP');
	when(&i = 5)call symput('datatype','DIABP');
	otherwise call symput('datatype','SYSBP');
end;
run;
proc sql;
create table &datatype as
select a.usubjid,actarmcd,&var from medical.dm a,medical.vs b 
	where a.usubjid in (select usubjid from &type)
	and b.vsblfl='��' /*ʹ�û��߱�־����*/
	and b.vstestcd = "&datatype"
	and a.usubjid = b.usubjid;
quit;
%normal(datatype = &datatype,var = &var) /*��̬�Լ���*/
%anova(datatype = &datatype,var = &var) /*�������Լ����뷽�����*/
%nonparametric(datatype = &datatype,var = &var)/*�ǲ�������*/
%end;
%mend vsdata;

/*�Ⱥ�Ʒʹ�õĲ������*/
%macro sudata(type= );
data _null_;
call symput('var','SUSITUA'); /*ȡ�Ⱥ�Ʒ�������susitua*/
run;
proc sql;
create table &var as
select a.usubjid,actarmcd,&var from medical.dm a,medical.su b
	where a.usubjid in (select usubjid from &type)
	and a.usubjid = b.usubjid
	and &var ^= ' ';
quit;
%chisq(datatype = &var,var = &var) /*ʹ�ÿ�������*/
%mend sudata;

/*������-��fas��������������������*/
%dmdata(type = fas)
%vsdata(type = fas)
%sudata(type = fas)
