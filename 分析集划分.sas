/*Ԥ����-ȡ���������õ�fas��pps��ss��������������id��ʵ�ʷ������*/
/*���б�����ǰ�뽫CDISC��������Ϊmedical�߼���*/

proc sql;
/*fas-ȫ������*/
create table fas as
select usubjid,actarmcd from medical.dm
	where actarmcd ~= 'SCRNFAIL' /*�޳�δ��ɸѡ����*/
	and usubjid in /*�޳�ȱ�ٸ�ҩ����Ҫ��Чָ��ķ���������*/
		(select usubjid from medical.lb
			where (lbtestcd = 'HBA1C' and visit = '��ҩ���4��' and lbstresn ~= .)
				or (lbtestcd = 'HBA1C' and visit = '��ҩ���8��' and lbstresn ~= .)
				or (lbtestcd = 'HBA1C' and visit = '��ҩ���12��' and lbstresn ~= .))
	order by usubjid; /*��id����*/

/*pps-���Ϸ�����*/
create table pps as
select * from fas
	where usubjid not in /*��fas���޳�������ǰ�˳���*/
		(select usubjid from medical.ds
			where dsscat = '��ǰ�˳�')
	order by usubjid;

/*ss-��ȫ�����ݼ�*/
create table ss as
select usubjid,actarmcd from medical.dm
	where actarmcd ~= 'SCRNFAIL' /*�޳�δ��ɸѡ����*/
	and usubjid in /*�޳�û�и�ҩ����Ӽ�¼��*/
		(select usubjid from medical.sv
			where visit ='��ҩ���4��')
	order by usubjid;

quit;
