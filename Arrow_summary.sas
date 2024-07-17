/*Process Tetrad bootstrap outputs*/
data file_list2;
input name $ 1-25;
datalines;
PC_0tier
PC_3tier
PC_4tier
FCI_0tier
FCI_3tier
FCI_4tier
FGES_0tier
FGES_3tier
FGES_4tier
GRasp_bic_0tier
GRasp_bdeu_0tier
GRasp_3tier
GRasp_4tier
;
run;


%macro noboot(length = 13);
proc sql noprint;
select distinct name 
	into :dat1 - :dat13 
	from file_list2;
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

	proc printto print = "<path>\output_noboot.rtf";
	run;
	proc print data = &&dat&i;
	where node_1 = "dth5" or node_1 = "Adhx15Bin" ;
	var node_1 node_2;
	title1 &&dat&i;
	title2 "arrows out";
	format node_1 $namelabels. node_2 $namelabels.;
	run;

	proc print data = &&dat&i;
	where node_2  = "dth5" or node_2  = "Adhx15Bin" ;
	var node_1 node_2;
	title1 &&dat&i;
	title2 "arrows in";
	format node_1 $namelabels. node_2 $namelabels.;
	run;

	proc printto;
	run;

	
%end;
%mend;

%noboot(length = 13);

