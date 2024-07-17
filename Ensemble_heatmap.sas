/*Process Tetrad bootstrap outputs*/
data file_list;
input name $ 1-25;
datalines;
PC_0tier_100boot
PC_3tier_100boot
PC_4tier_100boot
FCI_0tier_100boot
FCI_3tier_100boot
FCI_4tier_100boot
FGES_0tier_100boot
FGES_3tier_100boot
FGES_4tier_100boot
GRasp_bic_0tier_100boot
GRasp_bdeu_0tier_100boot
GRasp_3tier_100boot
GRasp_4tier_100boot
;
run;

/*Data cleaning for cpDAG ensemble heatmaps*/
/*create blank grid with all variable-variable pairs from correlation heatmap file*/
data grid_blank;
set corrlist2;
node_1 = var;
node_2 = withvar;
ensemble = .;
keep node_1 node_2 ensemble;
run;
proc sort data = grid_blank;
by node_1 node_2;
format node_1 $namelabels. node_2 $namelabels.;
run;


/*for each cpDAG dataset, sort by node_1 node_2*/
/*then merge with blank grid*/
/*then where cpDAG has no arrow, set ensemble to 0*/
%macro all(length = 13);
proc sql noprint;
select distinct name 
	into :dat1 - :dat13 
	from file_list;
quit;
run; 
%do i = 1 %to &length;
	data &&dat&i;
	set &&dat&i;
		if node_1 = "Adhx15bin" then node_1 = "Adhx15Bin";
		if node_2 = "Adhx15bin" then node_2 = "Adhx15Bin";
	run;
	
	proc sort data = &&dat&i;
		by node_1 node_2;
	format node_1 $namelabels. node_2 $namelabels.;
	run;

	proc printto print = "<path>\output.rtf";
	run;
	proc print data = &&dat&i;
		where node_1 = "dth5" or node_1 = "Adhx15Bin" ;
	var node_1 node_2 ensemble;
	title1 &&dat&i;
	title2 "arrows out";
	proc print data = &&dat&i;
		where node_2  = "dth5" or node_2  = "Adhx15Bin" ;
	var node_1 node_2 ensemble;
	title1 &&dat&i;
	title2 "arrows in";
	run;
	proc printto;
	run;

	data new_&&dat&i;
	merge grid_blank &&dat&i;
	by node_1 node_2;
	run;

	data new_&&dat&i;
	set new_&&dat&i;
	if ensemble = . then ensemble = 0;
	keep node_1 node_2 ensemble;
	run;

	proc template;
		define statgraph ensemblemap;
		begingraph;
		entrytitle "Ensemble edge probabilities";
		entrytitle "&&dat&i";

	/*Define attribute map and assign name range*/
   	rangeattrmap name="range1";
		range MIN-0 / rangeColor = WHITE;
		range 0-<0.5 / rangeColormodel=(VPAV VLIV);
        range 0.5 - MAX   / rangeColormodel=(VLIV VIV);  
  	 endrangeattrmap;
 	/*Associate attribute map with pvalue column and assign name pvalue_range*/  
   	rangeattrvar attrvar=ensemble_range 
				var= ensemble
				attrmap="range1";              

	layout overlay /yaxisopts=(discreteopts=(tickvaluefitpolicy=none tickvalueformat = $namelabels.) display=(tickvalues) reverse=true tickvalueattrs =(family="Arial"  size = 7))
				xaxisopts=(discreteopts=(tickvaluefitpolicy=rotate TICKVALUEROTATION=vertical tickvalueformat = $namelabels.) display=(tickvalues) tickvalueattrs =(family="Arial"  size = 7))
				 ;

	/* Heat map provides the color for each cell;*/
	heatmapparm y=Node_1 x=Node_2 colorresponse=ensemble_range / name = "corrmapparm" ;
	continuouslegend "corrmapparm" / title = "Ensemble proportion" location = outside valign=bottom titleattrs=(family = "Arial Rounded MT Bold");
	endlayout;
	endgraph;
	end;
	quit;

	proc sgrender data = new_&&dat&i template = ensemblemap;
	run;

%end;
%mend;


ods graphics on / height=8in width=8in imagename = "Ensemble_Plot" outputfmt=jpg reset=Index;
ods listing gpath = "<path>\Figures" image_dpi=300;
%all(length = 13);

