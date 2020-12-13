/*��ҩ12�ܺ�hba1c�ֲ�ͼ������̬�ֲ��Ƚϣ�*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼��⣬�����з���������.sas��lb������ȡ�봦��.sas����ͼ��ʽ-%ggplot2.sas*/

ods graphics on;
data normal_a;
set fas_hba1c_null(where=(actarmcd='A'));
run;
data normal_c;
set fas_hba1c_null(where=(actarmcd='C'));
run;
data normal_d;
set fas_hba1c_null(where=(actarmcd='D'));
run;

/*ʹ��univariate���Ʒֲ�ͼ�����ø�ʽ*/
%macro distrib(data=,label=);
proc univariate data = &data normal;
var lbstresn_12;
label lbstresn_12="&label";
histogram   lbstresn_12 / normal( w=1 l=1 color=yellow mu=est sigma=est)
		cframe=gray caxes=black waxis=1  cbarline=black cfill=blue pfill=solid frontref;
inset
		mean
		skewness
		kurtosis
		nobs
		pnormal
		 / position=ne
		ctext=blue
		cfill=cxd3d3d3
		cframe=blue
		cheader=blue
		height=2
	;
run;
%mend distrib;

/*������-���Ʒֲ�ͼ*/
%distrib(data=normal_a,label=����ҩ10mg-12�ܺ�hba1cֵ)
%distrib(data=normal_c,label=����ҩ20mg-12�ܺ�hba1cֵ)
%distrib(data=normal_d,label=��ο��-12�ܺ�hba1cֵ)
