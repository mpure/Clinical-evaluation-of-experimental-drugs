/*在绘图前只需运行本样式程序即可得到论文、ppt中的图片样式*/
/*本样式来自：SAS编程演义；作者：谷鸿秋*/

/*定义模板存储*/
libname mylib 'd:\template';
ods path(prepend)mylib.Forest_DataLabel_Indent_93(update);

/*绘图样式ggplot2*/
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

		*==修改图形大小;
		style Graph from Graph/
		OutputWidth=14cm
		OutputHeight=10cm 
		BorderWidth=0;
	   
		*==修改图形填充边框;
		style  GraphBorderLines from GraphBorderLines /
		LineThickness=0px 
		LineStyle=1;

	    *==修改图形边框;
		style GraphOutlines from GraphOutlines/
		LineStyle=1
		LineThickness=0px;
	    
	    *==修改Markersymbol;
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

	   *==修改坐标轴;
		class GraphAxisLines from GraphAxisLines/
		tickdisplay = "outside"
		linethickness = 0px
		linestyle = 1;
 end;
run;

*===使用样式;

ods html style=ggplot2 gpath="D:\TEST" dpi=400;
ods graphics/ outputfmt=png;
