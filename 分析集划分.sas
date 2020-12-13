/*预处理-取出供分析用的fas、pps、ss集，保存受试者id和实际分组代码*/
/*运行本程序前请将CDISC数据命名为medical逻辑库*/

proc sql;
/*fas-全分析集*/
create table fas as
select usubjid,actarmcd from medical.dm
	where actarmcd ~= 'SCRNFAIL' /*剔除未过筛选期者*/
	and usubjid in /*剔除缺少给药后主要疗效指标的访视数据者*/
		(select usubjid from medical.lb
			where (lbtestcd = 'HBA1C' and visit = '给药后第4周' and lbstresn ~= .)
				or (lbtestcd = 'HBA1C' and visit = '给药后第8周' and lbstresn ~= .)
				or (lbtestcd = 'HBA1C' and visit = '给药后第12周' and lbstresn ~= .))
	order by usubjid; /*按id排序*/

/*pps-符合方案集*/
create table pps as
select * from fas
	where usubjid not in /*从fas中剔除所有提前退出者*/
		(select usubjid from medical.ds
			where dsscat = '提前退出')
	order by usubjid;

/*ss-安全性数据集*/
create table ss as
select usubjid,actarmcd from medical.dm
	where actarmcd ~= 'SCRNFAIL' /*剔除未过筛选期者*/
	and usubjid in /*剔除没有给药后访视记录者*/
		(select usubjid from medical.sv
			where visit ='给药后第4周')
	order by usubjid;

quit;
