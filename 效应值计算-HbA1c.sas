/*12周hba1c效应值计算*/
/*效应值计算的宏程序修改自参考文献[24]*/
/*运行本程序前请将CDISC数据命名为medical逻辑库，并运行分析集划分.sas，lb数据提取与处理.sas*/

%macro	effect_size( data,idvar,design,groupvar, timevar,
timeval1, timeval2,respvars,cl=0.95);
************************************************:
** case I: independent group post test design***;
** In this case timevar will be blank***********;
************************************************; 
data _null_;
call symput("conf","&cl"*100); run;
%if &timevar= %then %do; proc sql noprint;
select distinct(&groupvar) into :grp1-:grp2 from &data; quit;
proc sort data=&data out=data1(keep=&idvar &groupvar &respvars); by &groupvar;
run;
**** mean ****; ods trace on;
proc means data=data1 mean; by	&groupvar;
var	&respvars;
ods output Summary=Summary_mean; run;
ods trace off;
**** sd ****;
proc means data=data1 std; by	&groupvar;
var &respvars ;
ods output Summary=Summary_std; run;
**** N ****;
proc means data=data1 n; by	&groupvar;
var &respvars;
 
ods output Summary=Summary_n; run;
** transpose data***;
proc transpose data=summary_mean out=mean_long(rename=(_LABEL_=static)) name=Measure prefix=&groupvar;
id &groupvar; run;
proc transpose data=summary_std out=std_long(rename=(_LABEL_=static)) name=Measure prefix=&groupvar;
id &groupvar; run;
proc transpose data=Summary_n out=n_long(rename=(_LABEL_=static)) name=Measure prefix=&groupvar;
id &groupvar; run;
** merge data***;
data combined_withingroup_IG;
merge mean_long(keep=measure &&groupvar.&grp1 &&groupvar.&grp2 rename=(&&groupvar.&grp1=mean&grp1 &&groupvar.&grp2=mean&grp2))
std_long(keep=&&groupvar.&grp1 &&groupvar.&grp2 rename=(&&groupvar.&grp1=sd&grp1 &&groupvar.&grp2=sd&grp2))
n_long(keep=&&groupvar.&grp1 &&groupvar.&grp2 rename=(&&groupvar.&grp1=n&grp1 &&groupvar.&grp2=n&grp2)) ;
run;
*** Calculate effect size and CI***;
*** S.E. of effect size calculate using eqn 16 of Nakagawa & Cuthill (2007)*; data effectsize_table_IG;
retain measure n&grp1 mean&grp1 sd&grp1 n&grp2 mean&grp2 sd&grp2 eff_size ci_low ci_up;
set combined_withingroup_IG; M_Change=(mean&grp2-mean&grp1); SD_pool=sqrt((((n&grp1-1)*sd&grp1**2)+
((n&grp2-1)*sd&grp2**2))/(n&grp1+n&grp2-2)); eff_size=M_Change/SD_pool;
** Standard error of d**; se_d1=((n&grp1+n&grp2-1)/(n&grp1+n&grp2-3)); se_d2= 4/(n&grp1+n&grp2); se_d3=1+eff_size**2/8;
se_d= sqrt(se_d1*se_d2*se_d3); z=PROBIT(.50+&cl/2);
ci_low=eff_size-z*se_d; ci_up=eff_size+z*se_d; format _NUMERIC_ 8.3;
format n&grp1 n&grp2 8.0 mean&grp1 sd&grp1 mean&grp2 sd&grp2 8.2; drop se_d1 se_d2 se_d3 z se_d M_Change SD_pool;
run;
%goto printresult;
%end;
%printresult:

%mend effect_size;

/*提取A,D组数据*/
data hba1c_ad;
set fas_hba1c_null;
where actarmcd in ('A','D');
run;


/*提取C,D组数据*/
data hba1c_cd;
set fas_hba1c_null;
where actarmcd in ('C','D');
run;

/*效应值见生成的名为Effectsize_table_ig的数据集*/
%effect_size(data=hba1c_ad,
idvar=usubjid, groupvar=actarmcd,
respvars=diff_12,
cl=0.95)
/*%effect_size(data=hba1c_cd,
idvar=usubjid, groupvar=actarmcd,
respvars=diff_12,
cl=0.95)*/
