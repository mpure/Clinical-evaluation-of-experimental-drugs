/*绘图-亚组分析森林图*/
/*本样式来自：SAS编程演义；作者：谷鸿秋*/
/*运行本程序需要附带文件：森林图.xlsx*/

libname mylib 'd:\template';
ods path(prepend)mylib.Forest_DataLabel_Indent_93(update);
*====GTL实现;

%macro  PltRatio(Dataset=, ObsID=obsid, Indent=indent, FactorVar=factor, FactorLbl=亚组,n1=n1,p1=p1,ctnpct1Lbl=试验药组, n2=n2, p2=p2, ctnpct2Lbl=安慰剂组, ratio=ratio, lcl=lcl, ucl=ucl, ratiocllbl=%str(Cohen%'s d(95% CI)), P=p,Plbl=P value, width=10, height=7);

 ods graphics / reset width=&width.cm height=&height.cm ; 
  data ForestRatioDS;
	  set &dataset;
    FactorLbl="&FactorLbl";
    ctnpct1Lbl="&ctnpct1Lbl";
    ctnpct2Lbl="&ctnpct2Lbl";
		RatioclLbl="&ratiocllbl";
    Plbl="&Plbl";

		%if &n1 NE %str() and &p1 NE %str() %then %str(
		ctnpct1=cats(&n1,'(',put(&p1,6.2),')');
		ctnpct2=cats(&n2,'(',put(&p2,6.2),')');
    );
		
		ratiocl=cats(put(&ratio,6.2),'(',put(&lcl,6.2),'-',put(&ucl,6.2),')');
	  pv=put(&p,6.4);

		%if &n1 NE %then %do;
      if missing(&n1) then call missing(ctnpct1,ctnpct2,ratiocl,ratiocl,pv);
		%end;
run;


proc template;
	define statgraph Forest_DataLabel_Indent_93;
		dynamic  _bandcolor;
		begingraph;
			layout lattice / columns=2 columnweights=(0.8 0.2);

				/*--First column for Subgroup and patient counts--*/
				layout overlay / walldisplay=none 
					x2axisopts=(display=(tickvalues) offsetmin=0.05 offsetmax=0.1 tickvalueattrs=(size=8)) 
					yaxisopts=(reverse=true display=none tickvalueattrs=(weight=bold) offsetmin=0);

					referenceline y=ref / lineattrs=(thickness=14 color=_bandcolor);

					scatterplot y=eval(ifn(&Indent=0, &ObsID, .)) x=FactorLbl / datalabel=&FactorVar markerattrs=(size=0) datalabelposition=right 
						xaxis=x2 discreteoffset=-0.25 datalabelattrs=(weight=bold size=7  color=black); /*subgroup title*/

			        scatterplot y=eval(ifn(&Indent=1, &ObsID, .)) x=FactorLbl / datalabel=&FactorVar markerattrs=(size=0) datalabelposition=right 
						xaxis=x2 discreteoffset=-0.15 datalabelattrs=(weight=normal size=7  color=black); /*subgoup value*/


					scatterplot y=&ObsID  x=ctnpct1Lbl / datalabel=ctnpct1 markerattrs=(size=0) datalabelposition=center 
						xaxis=x2 datalabelattrs=(weight=normal size=7);

					scatterplot y=&ObsID  x=ctnpct2Lbl / datalabel=ctnpct2 markerattrs=(size=0) datalabelposition=center 
						xaxis=x2 datalabelattrs=(weight=normal size=7);

					scatterplot y=&ObsID  x=ratioclLbl / datalabel=ratiocl markerattrs=(size=0) datalabelposition=center 
						xaxis=x2 datalabelattrs=(weight=normal size=7);

					scatterplot y=&ObsID  x=plbl / datalabel=Pv markerattrs=(size=0) datalabelposition=center 
						xaxis=x2 datalabelattrs=(weight=normal size=7);

				endlayout;

				/*--Second column showing odds ratio graph--*/
				layout overlay / yaxisopts=(reverse=true display=none offsetmin=0) walldisplay=none
					xaxisopts=(type=log label="Cohen's d" tickvalueattrs=(size=8) labelattrs=(size=9)  );
					referenceline y=ref / lineattrs=(thickness=14 color=_bandcolor);
					highlowplot y=&ObsID low=&lcl  high=&ucl;
					scatterplot y=&ObsID x=&ratio  / markerattrs=(symbol=squarefilled);
					referenceline x=0;
				endlayout;
			endlayout;
		endgraph;
	end;
run;

proc sgrender data=ForestRatioDS template=Forest_DataLabel_Indent_93;
	dynamic _bandcolor='cxf0f0f0';
run;
%mend;

/*修改文件：森林图.xlsx的路径*/
proc import out=plotds datafile="D:\森林图.xlsx"
			 dbms=xlsx replace;
run;
ods html dpi=300;

%PltRatio(Dataset=plotds, ObsID=id,FactorVar=endpoint,width=18, height=14)
