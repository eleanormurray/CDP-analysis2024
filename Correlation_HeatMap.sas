libname ra '<path>';

/*Load dataset*/
data cdp;
set ra.cdp_binary;
run;


/*Sort variables by name alphabetically*/
proc sql noprint;
select name into :vars separated by ' '
from dictionary.columns
where libname eq 'WORK' and memname eq 'CDP'
order by name
;
quit;
run;

data cdp;
retain &vars;
set cdp;
run;

/*set alpha value*/
%let alpha = 0.05;

/*Run all pair-wise correlations*/
proc corr data=cdp FISHER;  /* FISHER ==> list of Pearson correlations */
   var _numeric_;
   ods output FisherPearsonCorr = CorrList;   /*Put the correlations in a data set */
run;

proc freq data =CorrList nlevels;
where pvalue le 0.05;
tables var;
run;

proc freq data =CorrList nlevels;
tables var;
run;


proc freq data =CorrList nlevels;
where pvalue le 0.05/820;
tables var;
run;

/*Add diagonals with Corr = 1 and p=1*/
data self_corr;
do i = 1 to 41;
	string = "&vars";
	Var = scan(string, i);
	WithVar = scan(string, i);
	Corr = 1;
	pvalue = 0;
output;
end;
keep Var WithVar Corr pvalue;
run;

data corrlist2;
set self_corr CorrList;
AbsCorr = abs(Corr);
keep Var WithVar Corr pvalue AbsCorr;
run;



/*Graph template*/

ods graphics on / height=8in width=8in imagename = "Corr_p_plot" outputfmt=jpg reset=Index;
ods listing gpath = "<path>" image_dpi=300;

proc template;
define statgraph corrmap_p;
begingraph;
entrytitle "Pairwise correlations";

/*Define attribute map and assign name range*/
   rangeattrmap name="range1";
		range MIN - 0 /rangeColor = DEV;
		range 0-<0.05 / rangeColormodel=(STV LIV);
        range 0.05 - MAX   / rangeColormodel=(PAV PWH);  
   endrangeattrmap;
 /*Associate attribute map with pvalue column and assign name pvalue_range*/  
   rangeattrvar attrvar=pvalue_range 
				var= pvalue 
				attrmap="range1";              

layout overlay /yaxisopts=(discreteopts=(tickvaluefitpolicy=none tickvalueformat = $namelabels.) display=(tickvalues) reverse=true tickvalueattrs =(family="Arial"  size = 7))
				xaxisopts=(discreteopts=(tickvaluefitpolicy=rotate TICKVALUEROTATION=vertical tickvalueformat = $namelabels.) display=(tickvalues) tickvalueattrs =(family="Arial"  size = 7))
				 ;

* Heat map provides the color for each cell;
heatmapparm y=WithVar x=Var colorresponse=pvalue_range / name = "corrmapparm" ;
continuouslegend "corrmapparm" / title = "p-value" location = outside valign=bottom titleattrs=(family = "Arial Rounded MT Bold");
*textplot y=WithVar x=Var text=eval(put(pvalue,pvalue4.2)) / textattrs=(family="Arial Rounded MT Bold" size=2px);
endlayout;
endgraph;
end;
quit;

/*Draw graph*/
proc sgrender data = CorrList2 template = corrmap_p;
run;
 

ods graphics on / height=8in width=8in imagename = "Corr_plot" outputfmt=jpg reset=Index;
ods listing gpath = "<path>" image_dpi=300;

proc template;
define statgraph corrmap_p;
begingraph;
entrytitle "Pairwise correlations";

/*Define attribute map and assign name range*/
   rangeattrmap name="range2";
		range 0-<0.3 / rangeColormodel=(VPAV VLIV);
        range 0.3 - 0.5   / rangeColormodel=(LIV BIV); 
		range 0.5 - <1 /rangeColormodel=(VIV STV);
		range 1 -MAX /rangeColor = DEV;
   endrangeattrmap;
 /*Associate attribute map with pvalue column and assign name pvalue_range*/  
   rangeattrvar attrvar=Corr_range 
				var= AbsCorr
				attrmap="range2";              

layout overlay /yaxisopts=(discreteopts=(tickvaluefitpolicy=none tickvalueformat = $namelabels.) display=(tickvalues) reverse=true tickvalueattrs =(family="Arial" size = 7 ))
				xaxisopts=(discreteopts=(tickvaluefitpolicy=rotate TICKVALUEROTATION=vertical tickvalueformat = $namelabels.) display=(tickvalues) tickvalueattrs =(family="Arial" size = 7 ))
				 ;

* Heat map provides the color for each cell;
heatmapparm y=WithVar x=Var colorresponse=Corr_range / name = "corrmapparm" ;
continuouslegend "corrmapparm" / title = "Correlation, absolute value (|(*ESC*){unicode '03C1'x}|)" location = outside valign=bottom ;
*textplot y=WithVar x=Var text=eval(put(pvalue,pvalue4.2)) / textattrs=(family="Arial Rounded MT Bold" size=2px);
endlayout;
endgraph;
end;
quit;

/*Draw graph*/
proc sgrender data = CorrList2 template = corrmap_p;
run;

ods graphics on / height=8in width=8in imagename = "Corr_p_bonf_plot" outputfmt=jpg reset=Index;
ods listing gpath = "<path>" image_dpi=300;
proc template;
define statgraph corrmap_p2;
begingraph;
entrytitle "Pairwise correlations";

/*Define attribute map and assign name range*/
   rangeattrmap name="range1";
		range MIN - 0 /rangeColor = DEV;
		range 0-<0.00006 / rangeColormodel=(STV LIV);
        range 0.00006 - MAX   / rangeColormodel=(PAV PWH);  
   endrangeattrmap;
 /*Associate attribute map with pvalue column and assign name pvalue_range*/  
   rangeattrvar attrvar=pvalue_range 
				var= pvalue 
				attrmap="range1";              

layout overlay /yaxisopts=(discreteopts=(tickvaluefitpolicy=none tickvalueformat = $namelabels.) display=(tickvalues) reverse=true tickvalueattrs =(family="Arial"  size = 7))
				xaxisopts=(discreteopts=(tickvaluefitpolicy=rotate TICKVALUEROTATION=vertical tickvalueformat = $namelabels.) display=(tickvalues) tickvalueattrs =(family="Arial"  size = 7))
				 ;

* Heat map provides the color for each cell;
heatmapparm y=WithVar x=Var colorresponse=pvalue_range / name = "corrmapparm" ;
continuouslegend "corrmapparm" / title = "p-value" location = outside valign=bottom titleattrs=(family = "Arial Rounded MT Bold");
*textplot y=WithVar x=Var text=eval(put(pvalue,pvalue4.2)) / textattrs=(family="Arial Rounded MT Bold" size=2px);
endlayout;
endgraph;
end;
quit;

/*Draw graph*/
proc sgrender data = CorrList2 template = corrmap_p2;
run;
 
