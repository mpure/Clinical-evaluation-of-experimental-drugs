/*Э���������ANCOVA��*/
/*��������������hba1c,fpg,2h ppg��Э�������*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas*/

%macro boxcox_ancova(data=,var=);
/*box-coxת����*/
data temp_x0;
set &data;
x=0;/*������x,ʹx=0,�������к���ת��*/
run;

/*����Box-Coxת��*/
proc transreg maxiter=0 nozeroconstant detail ss2 data=temp_x0;
   model boxcox(&var) = identity(x);
   output out=temp_bc;
run;

/*��ȡת����ı���*/
data trans_bc;
merge &data temp_bc;
keep actarmcd lbstresn t&var;
run;

/*��������*/
proc sort data=trans_bc;
	by actarmcd;
run;

/*������̬��*/
proc univariate normal data=trans_bc;
	var t&var;
by actarmcd;
run;

/*���鷽������*/
proc discrim pool=test data=trans_bc;
	class actarmcd;
	var t&var;
run;

/*�������������*/
proc reg data=trans_bc;
	model &var=lbstresn;
	by actarmcd;
run;

/*Э�������*/
proc glm data=trans_bc;
	class actarmcd;
	model t&var=lbstresn actarmcd;
	lsmeans actarmcd/ stderr pdiff;
run;

%mend boxcox_ancova;

/*������*/
%boxcox_ancova(data=fas_hba1c_null,var=lbstresn_12)
%boxcox_ancova(data=fas_fpg_empty,var=lbstresn_12)
%boxcox_ancova(data=fas_fpg_meal2,var=lbstresn_12)

