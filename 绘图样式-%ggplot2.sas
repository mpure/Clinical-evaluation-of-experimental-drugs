/*�ڻ�ͼǰֻ�����б���ʽ���򼴿ɵõ����ġ�ppt�е�ͼƬ��ʽ*/
/*����ʽ���ԣ�SAS������壻���ߣ��Ⱥ���*/

/*����ģ��洢*/
libname mylib 'd:\template';
ods path(prepend)mylib.Forest_DataLabel_Indent_93(update);

/*��ͼ��ʽggplot2*/
proc template;                                                                
   define style Styles.ggplot2;                                              
      parent = styles.listing; 

	  style color_list from color_list
	     "Abstract colors used in graph styles" /
		 'bgA'   = cxffffff; 

      class GraphColors
         "Abstract colors used in graph styles" /
         'gwalls' =cxebebeb
		 'glegend'=cxebebeb
		 'ggrid'  =cxFFFFFF
		  'gcdata7' = cxfb61d7
	      'gdata7' = cxfb61d7
	      'gcdata6' = cxa58aff
	      'gdata6' = cxa58aff
	      'gcdata5' = cx00b6eb
	      'gdata5' = cx00b6eb
	      'gcdata4' = cx00c094
	      'gdata4' = cx00c094
	      'gcdata3' = cx53b400
	      'gdata3' = cx53b400
	      'gcdata2' = cxc49a00
	      'gdata2' = cxc49a00
	      'gcdata1' = cxf8766d
	      'gdata1' = cxf8766d 
           'gcdata'=cxf8766d
           'gdata'=cxf8766d;

      class GraphWalls /                                                      
         linethickness = 1px                                                  
         linestyle = 1                                                        
         frameborder = on   
         contrastcolor = GraphColors('gwalls')                                 
         backgroundcolor = GraphColors('gwalls')                              
         color = GraphColors('gwalls');   

      class GraphGridLines /                                                  
         displayopts = "on"                                                 
         linethickness = 1px                                                  
         linestyle = 1                                                        
         contrastcolor = GraphColors('ggrid')                                 
         color = GraphColors('ggrid');

      class GraphAxisLines /                                                  
         tickdisplay = "outside"                                              
         linethickness = 1px                                                  
         linestyle = 1                                                        
         contrastcolor = GraphColors('gaxis');  
 
      class GraphBox /                                                        
         capstyle = "serif"                                                   
         connect = "mean"                                                     
        displayopts = "fill median mean outliers";

		*==�޸�ͼ�δ�С;
		style Graph from Graph/
		OutputWidth=14cm
		OutputHeight=10cm 
		BorderWidth=0;
	   
		*==�޸�ͼ�����߿�;
		style  GraphBorderLines from GraphBorderLines /
		LineThickness=0px 
		LineStyle=1;

	    *==�޸�ͼ�α߿�;
		style GraphOutlines from GraphOutlines/
		LineStyle=1
		LineThickness=0px;
	    
	    *==�޸�Markersymbol;
	   class GraphData1 from GraphData1 /
       markersymbol = "CircleFilled" ;
	   class GraphData2 from GraphData2 /
       markersymbol = "CircleFilled" ;
	   class GraphData3 from GraphData3 /
       markersymbol = "CircleFilled" ;
	   class GraphData4 from GraphData4 /
       markersymbol = "CircleFilled" ;
	   class GraphData5 from GraphData5 /
       markersymbol = "CircleFilled" ;
	   class GraphData6 from GraphData6 /
       markersymbol = "CircleFilled" ;
	   class GraphData7 from GraphData7 /
       markersymbol = "CircleFilled" ;

	   *==�޸�������;
		class GraphAxisLines from GraphAxisLines/
		tickdisplay = "outside"
		linethickness = 0px
		linestyle = 1;
 end;
run;

*===ʹ����ʽ;

ods html style=ggplot2 gpath="D:\TEST" dpi=400;
ods graphics/ outputfmt=png;
