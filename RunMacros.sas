libname cdp "<path>";
libname autodag "<path>";

%include '<path>\Program_1_data_processing.sas';
%include '<path>\Program3.sas';
%include '<path>\Program4.sas';
%include '<path>\rcspline.sas';

/*Import dataset for all covariates*/
data baseline;
set cdp.binary;
run;
proc contents data = baseline;
run;

/*Original 1980 variable names*/
%let covs_all = age_bin nonwhite mi_bin niha_bin1 rbw_bin 
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  
			cardiom stelev hifastgluc cig inact anyqqs anystdep 
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell 
			hineut hihemat ; 


%drop_missing(&covs_all, data_in = baseline, data_out = baseline_wide);

%longdata(datain=baseline_wide, dataout = baseline_ag);
%delete_postDeath(data =baseline_ag);


proc printto log = "<path>\log.2.15.24.rtf";
run;

/***************************************/
/*Unadjusted:*/
/*Part B unadj ==new adherence definition */
%partB_unadjusted( outdest = "<path>\Unadjusted_2.20.24.rtf", 
		inset = baseline_wide, titlemain = "Unadjusted, Complete data, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = work);

proc contents data = baseline_wide;run;
proc contents data = baseline_ag;run;

/*****RUN MACROS***/
%let nboot = 500;

/*PC algorithm*/
%let covs_PC6 = age_bin INACT 
				mi_bin AP IC NIHA_bin1 cardioM
				oralhyp dig diur antihyp
				hiserchol hionegluc hiwhitecell hineut
				anyqqs anystdep anytwave vcd fveb hiheart;

%let covs_PC7 = age_bin cig INACT 
				mi_bin IC NIHA_bin1 cardioM
				oralhyp dig diur antihyp
				hiserchol hiwhitecell
				anyqqs anystdep stelev vcd fveb hiheart;

%let covs_PC8 = age_bin cig INACT 
				mi_bin IC NIHA_bin1 cardioM
				oralhyp dig diur antihyp
				hiserchol hiseruric hionegluc hiwhitecell hineut
				anyqqs anystdep stelev vcd fveb hiheart;

/*FCI*/
%let covs_fci1 =cig inact
				ap ic icia niha_bin1 cardioM
				oralhyp antihyp dig diur 
				hiwhitecell hineut
				anyqqs anystdep anytwave vcd fveb hiheart;

%let covs_fci2 =age_bin nonwhite cig inact
				mi_bin chf ap ic icia niha_bin1 cardioM hidiasbp
				oralhyp antihyp dig diur 
				hiseralk hifastgluc hiwhitecell hineut
				anyqqs anystdep stelev vcd fveb hiheart;

%let covs_fci3 =nonwhite cig inact
				mi_bin chf ap ic icia niha_bin1 cardioM
				oralhyp antihyp dig diur 
				hiseralk hiserchol hiwhitecell hineut
				anyqqs anystdep anytwave vcd fveb hiheart;

/*FGES*/
%let covs_fges1a = cig 
					mi_bin chf niha_bin1 cardioM
					diur antihyp dig
					hineut
				 	anystdep anytwave vcd;

%let covs_fges1b = cig
					mi_bin cardioM
					dig
					hineut
					anystdep anytwave vcd;

%let covs_fges2 = cig inact
					mi_bin chf hisysbp niha_bin1 ic cardioM
					diur dig
					hiwhitecell hineut
					anystdep anytwave vcd;

%let covs_fges3 = cig inact
					irk mi_bin chf aci niha_bin1 ic cardioM
					diur antihyp dig
					hiwhitecell hineut
					anystdep anytwave vcd hiheart;
/*GRaSP*/

%let covs_grasp1a = cig 
					chf ap aci mi_bin niha_bin1
					diur dig antihyp 
					hiwhitecell
					anystdep;

%let covs_grasp1b = cig
					chf ap aci mi_bin niha_bin1
					diur dig antihyp
					hiwhitecell;

%let covs_grasp2a = age_bin cig 
					chf ap aci icia hisysbp mi_bin niha_bin1
					diur antihyp dig
					hisertrigly hiseruric hiwhitecell hineut hihemat
					anystdep anytwave;

%let covs_grasp2b = cig  
					aci ap icia hisysbp niha_bin1
					hisertrigly hiseruric hiwhitecell hineut
					anystdep anytwave;

%let covs_grasp3 = 	cig inact
					chf icia hisysbp niha_bin1 ap ic cardioM
					diur antihyp dig
					hisertrigly hineut hiwhitecell
					anystdep anyqqs anytwave vcd hiheart;

%let covs_grasp4 = 	cig inact  
				   	chf niha_bin1 mi_bin ic  cardioM
					diur oralhyp dig
					hiwhitecell hineut 
					anystdep vcd hiheart;

/***************************************/
/*Part B adj == logistic regression*/

/*updated adherence definition: new covariates and AFTER deleting obs with missing values of the new vars*/
/*%partB_adjusted( outdest = "<path>\PartB.Adj.logistic.pcAlg500boot.rtf", 
	inset =  AutoDAG_wide_pc,  
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=rajesh, adhvar = adhx15bin, covs = &covs_pcAlg);
*/

%partB_adjusted( outdest = "<path>\Baseline_adj.PC6.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_pc6);

%partB_adjusted( outdest = "<path>\Baseline_adj.PC7.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_pc7);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.PC8.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_pc8);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FCI1.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fci1);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FCI2.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fci2);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FCI3.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fci3);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FGES1a.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fges1a);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FGES1b.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fges1b);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FGES2.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fges2);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.FGES3.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_fges3);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP1a.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp1a);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP1b.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp1b);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP2a.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp2a);
		
%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP2b.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp2b);

%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP3.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp3);

%partB_adjusted( outdest = "<path>\Baseline_adj.GRaSP4.2.15.24.rtf", 
		inset =  baseline_wide,  
		titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=work, adhvar = adhx15bin, covs = &covs_grasp4);


/***************************************/
/*Part C: IP Weighted*/

proc contents data = baseline_ag;run;
 %let nboot = 500;

/*PC algorithm*/
%let covs_PC6_0 = age_bin INACT0 
				mi_bin AP0 IC0 NIHA_bin0 cardioM0
				oralhyp0 dig0 diur0 antihyp0
				hiserchol0 hionegluc0 hiwhitecell0 hineut0
				anyqqs0 anystdep0 anytwave0 vcd0 fveb0 hiheart0;

%let covs_PC6_fv = INACTfv 
				 APfv ICfv NIHAfv cardioMfv
				oralhypfv digfv diurfv antihypfv
				hisercholfv hioneglucfv hiwhitecellfv hineutfv
				anyqqsfv anystdepfv anytwavefv vcdfv fvebfv hiheartfv;

%let covs_PC6_lag = INACTfv_t1
				APfv_t1 ICfv_t1 NIHAfv_t1 cardioMfv_t1
				oralhypfv_t1 digfv_t1 diurfv_t1 antihypfv_t1
				hisercholfv_t1 hioneglucfv_t1 hiwhitecellfv_t1 hineutfv_t1
				anyqqsfv_t1 anystdepfv_t1 anytwavefv_t1 vcdfv_t1 fvebfv_t1 hiheartfv_t1;

%partC( outdest = "<path>\IPW_PC6.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_PC6_0, covs_FV = &covs_PC6_FV , covs_lag = &covs_PC6_lag);


%let covs_PC7_0 = age_bin cig0 INACT0
				mi_bin IC0 NIHA_bin0 cardioM0
				oralhyp0 dig0 diur0 antihyp0
				hiserchol0 hiwhitecell0
				anyqqs0 anystdep0 stelev0 vcd0 fveb0 hiheart0;

%let covs_PC7_FV = cigfv INACTfv 
				 ICfv NIHAfv cardioMfv
				oralhypfv digfv diurfv antihypfv
				hisercholfv hiwhitecellfv
				anyqqsfv anystdepfv stelevfv vcdfv fvebfv hiheartfv;

%let covs_PC7_lag = cigfv_t1 INACTfv_t1 
				ICfv_t1 NIHAfv_t1 cardioMfv_t1
				oralhypfv_t1 digfv_t1 diurfv_t1 antihypfv_t1
				hisercholfv_t1 hiwhitecellfv_t1
				anyqqsfv_t1 anystdepfv_t1 stelevfv_t1 vcdfv_t1 fvebfv_t1 hiheartfv_t1;

%partC( outdest = "<path>\IPW_PC7.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_PC7_0, covs_FV = &covs_PC7_FV , covs_lag = &covs_PC7_lag);


%let covs_PC8_0 = age_bin cig0 INACT0 
				mi_bin IC0 NIHA_bin0 cardioM0
				oralhyp0 dig0 diur0 antihyp0
				hiserchol0 hiseruric0 hionegluc0 hiwhitecell0 hineut0
				anyqqs0 anystdep0 stelev0 vcd0 fveb0 hiheart0;

%let covs_PC8_FV = cigfv INACTfv
				ICfv NIHAfv cardioMfv
				oralhypfv digfv diurfv antihypfv
				hisercholfv hiseruricfv hioneglucfv hiwhitecellfv hineutfv
				anyqqsfv anystdepfv stelevfv vcdfv fvebfv hiheartfv;

%let covs_PC8_lag = cigfv_t1 INACTfv_t1
				ICfv_t1 NIHAfv_t1 cardioMfv_t1
				oralhypfv_t1 digfv_t1 diurfv_t1 antihypfv_t1
				hisercholfv_t1 hiseruricfv_t1 hioneglucfv_t1 hiwhitecellfv_t1 hineutfv_t1
				anyqqsfv_t1 anystdepfv_t1 stelevfv_t1 vcdfv_t1 fvebfv_t1 hiheartfv_t1;

%partC( outdest = "<path>\IPW_PC8.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_PC8_0, covs_FV = &covs_PC8_FV , covs_lag = &covs_PC8_lag);



/*FCI*/
%let covs_fci1_0 =cig0 inact0
				ap0 ic0 icia0 niha_bin0 cardioM0
				oralhyp0 antihyp0 dig0 diur0
				hiwhitecell0 hineut0
				anyqqs0 anystdep0 anytwave0 vcd0 fveb0 hiheart0;

%let covs_fci1_FV =cigFV inactFV
				apFV icFV iciaFV nihaFV cardioMFV
				oralhypFV antihypFV digFV diurFV
				hiwhitecellFV hineutFV
				anyqqsFV anystdepFV anytwaveFV vcdFV fvebFV hiheartFV;

%let covs_fci1_lag =cigFV_t1 inactFV_t1
				apFV_t1 icFV_t1 iciaFV_t1 nihaFV_t1 cardioMFV_t1
				oralhypFV_t1 antihypFV_t1 digFV_t1 diurFV_t1
				hiwhitecellFV_t1 hineutFV_t1
				anyqqsFV_t1 anystdepFV_t1 anytwaveFV_t1 vcdFV_t1 fvebFV_t1 hiheartFV_t1;


%partC( outdest = "<path>\IPW_FCI1.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_FCI1_0, covs_FV = &covs_FCI1_FV , covs_lag = &covs_FCI1_lag);



%let covs_fci2_0 =age_bin nonwhite cig0 inact0
				mi_bin chf0 ap0 ic0 icia0 niha_bin0 cardioM0 hidiasbp0
				oralhyp0 antihyp0 dig0 diur0
				hiseralk0 hifastgluc0 hiwhitecell0 hineut0
				anyqqs0 anystdep0 stelev0 vcd0 fveb0 hiheart0;

%let covs_fci2_fv =cigfv inactfv
				chffv apfv icfv iciafv nihafv cardioMfv hidiasbpfv
				oralhypfv antihypfv digfv diurfv
				hiseralkfv hifastglucfv hiwhitecellfv hineutfv
				anyqqsfv anystdepfv stelevfv vcdfv fvebfv hiheartfv;

%let covs_fci2_LAG =cigfv_t1 inactfv_t1
				chffv_t1 apfv_t1 icfv_t1 iciafv_t1 nihafv_t1 cardioMfv_t1 hidiasbpfv_t1
				oralhypfv_t1 antihypfv_t1 digfv_t1 diurfv_t1
				hiseralkfv_t1 hifastglucfv_t1 hiwhitecellfv_t1 hineutfv_t1
				anyqqsfv_t1 anystdepfv_t1 stelevfv_t1 vcdfv_t1 fvebfv_t1 hiheartfv_t1;


%partC( outdest = "<path>\IPW_FCI2.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_FCI2_0, covs_FV = &covs_FCI2_FV , covs_lag = &covs_FCI2_lag);


%let covs_fci3_0 =nonwhite cig0 inact0
				mi_bin chf0 ap0 ic0 icia0 niha_bin0 cardioM0
				oralhyp0 antihyp0 dig0 diur0 
				hiseralk0 hiserchol0 hiwhitecell0 hineut0
				anyqqs0 anystdep0 anytwave0 vcd0 fveb0 hiheart0;


%let covs_fci3_FV =cigFV inactFV 
				chfFV apFV icFV iciaFV nihaFV  cardioMFV 
				oralhypFV antihypFV digFV diurFV  
				hiseralkFV  hisercholFV  hiwhitecellFV hineutFV 
				anyqqsFV  anystdepFV anytwaveFV vcdFV fvebFV  hiheartFV ;

				
%let covs_fci3_lag =cigFV_t1 inactFV_t1
				chfFV_t1 apFV_t1 icFV_t1 iciaFV_t1 nihaFV_t1  cardioMFV_t1 
				oralhypFV_t1 antihypFV_t1 digFV_t1 diurFV_t1  
				hiseralkFV_t1  hisercholFV_t1  hiwhitecellFV_t1 hineutFV_t1 
				anyqqsFV_t1  anystdepFV_t1 anytwaveFV_t1 vcdFV_t1 fvebFV_t1  hiheartFV_t1 ;

%partC( outdest = "<path>\IPW_FCI3.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_FCI3_0, covs_FV = &covs_FCI3_FV , covs_lag = &covs_FCI3_lag);

/*FGES*/
%let covs_fges1a_0 = cig0 
					mi_bin chf0 niha_bin0 cardioM0
					diur0 antihyp0 dig0
					hineut0
				 	anystdep0 anytwave0 vcd0;

%let covs_fges1a_fv = cigfv 
					 chffv  nihafv  cardioMfv 
					diurfv  antihypfv  digfv 
					hineutfv 
				 	anystdepfv anytwavefv vcdfv ;

%let covs_fges1a_lag = cigfv_t1 
					 chffv_t1  nihafv_t1  cardioMfv_t1
					diurfv_t1  antihypfv_t1  digfv_t1 
					hineutfv_t1 
				 	anystdepfv_t1 anytwavefv_t1 vcdfv_t1 ;
%partC( outdest = "<path>\IPW_FGES1a.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_fges1a_0, covs_FV = &covs_fges1a_FV , covs_lag = &covs_fges1a_lag);


%let covs_fges1b_0 = cig0
					mi_bin cardioM0
					dig0
					hineut0
					anystdep0 anytwave0 vcd0;

%let covs_fges1b_fv = cigfv
					cardioMfv
					digfv
					hineutfv
					anystdepfv anytwavefv vcdfv;

%let covs_fges1b_lag = cigfv_t1
					cardioMfv_t1
					digfv_t1
					hineutfv_t1
					anystdepfv_t1 anytwavefv_t1 vcdfv_t1;
%partC( outdest = "<path>\IPW_FGES1b.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_fges1b_0, covs_FV = &covs_fges1b_FV , covs_lag = &covs_fges1b_lag);

%let covs_fges2_0 = cig0 inact0
					mi_bin chf0 hisysbp0 niha_bin0 ic0 cardioM0
					diur0 dig0
					hiwhitecell0 hineut0
					anystdep0 anytwave0 vcd0;
%let covs_fges2_fv = cigfv inactfv
					chffv hisysbpfv nihafv icfv cardioMfv
					diurfv digfv
					hiwhitecellfv hineutfv
					anystdepfv anytwavefv vcdfv;
%let covs_fges2_lag = cigfv_t1 inactfv_t1
					chffv_t1 hisysbpfv_t1 nihafv_t1 icfv_t1 cardioMfv_t1
					diurfv_t1 digfv_t1
					hiwhitecellfv_t1 hineutfv_t1
					anystdepfv_t1 anytwavefv_t1 vcdfv_t1;
%partC( outdest = "<path>\IPW_FGES2.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_fges2_0, covs_FV = &covs_fges2_FV , covs_lag = &covs_fges2_lag);



%let covs_fges3_0 = cig0 inact0
					irk mi_bin  chf0 aci0 niha_bin0 ic0 cardioM0
					diur0 antihyp0 dig0
					hiwhitecell0 hineut0
					anystdep0 anytwave0 vcd0 hiheart0;

%let covs_fges3_fv = cigfv inactfv
					 chffv acifv nihafv icfv cardioMfv
					diurfv antihypfv digfv
					hiwhitecellfv hineutfv
					anystdepfv anytwavefv vcdfv hiheartfv;

%let covs_fges3_lag = cigfv_t1 inactfv_t1
					 chffv_t1 acifv_t1 nihafv_t1 icfv_t1 cardioMfv_t1
					diurfv_t1 antihypfv_t1 digfv_t1
					hiwhitecellfv_t1 hineutfv_t1
					anystdepfv_t1 anytwavefv_t1 vcdfv_t1 hiheartfv_t1;

%partC( outdest = "<path>\IPW_FGES3.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_fges3_0, covs_FV = &covs_fges3_FV , covs_lag = &covs_fges3_lag);

/*GRaSP*/

%let covs_grasp1a_0 = cig0 
					chf0 ap0 aci0 mi_bin niha_bin0
					diur0 dig0 antihyp0
					hiwhitecell0
					anystdep0;
%let covs_grasp1a_fv = cigfv 
					chffv apfv acifv  nihafv
					diurfv digfv antihypfv
					hiwhitecellfv
					anystdepfv;

%let covs_grasp1a_lag = cigfv_t1 
					chffv_t1 apfv_t1 acifv_t1  nihafv_t1
					diurfv_t1 digfv_t1 antihypfv_t1
					hiwhitecellfv_t1
					anystdepfv_t1;

%partC( outdest = "<path>\IPW_GRaSP1a.2.20.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp1a_0, covs_FV = &covs_grasp1a_FV , covs_lag = &covs_grasp1a_lag);

%let covs_grasp1b_0 = cig0
					chf0 ap0 aci0 mi_bin niha_bin0
					diur0 dig0 antihyp0
					hiwhitecell0;

%let covs_grasp1b_fv = cigfv
					chffv apfv acifv nihafv
					diurfv digfv antihypfv
					hiwhitecellfv;

%let covs_grasp1b_lag = cigfv_t1
					chffv_t1 apfv_t1 acifv_t1 nihafv_t1
					diurfv_t1 digfv_t1 antihypfv_t1
					hiwhitecellfv_t1;

%partC( outdest = "<path>\IPW_GRaSP1b.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp1b_0, covs_FV = &covs_grasp1b_FV , covs_lag = &covs_grasp1b_lag);




%let covs_grasp2a_0 = age_bin cig0 
					chf0 ap0 aci0 icia0 hisysbp0 mi_bin niha_bin0
					diur0 antihyp0 dig0
					hisertrigly0 hiseruric0 hiwhitecell0 hineut0 hihemat0
					anystdep0 anytwave0;


%let covs_grasp2a_fv =cigfv 
					chffv apfv acifv iciafv hisysbpfv nihafv
					diurfv antihypfv digfv
					hisertriglyfv hiseruricfv hiwhitecellfv hineutfv hihematfv
					anystdepfv anytwavefv;

%let covs_grasp2a_lag =cigfv_t1 
					chffv_t1 apfv_t1 acifv_t1 iciafv_t1 hisysbpfv_t1 nihafv_t1
					diurfv_t1 antihypfv_t1 digfv_t1
					hisertriglyfv_t1 hiseruricfv_t1 hiwhitecellfv_t1 hineutfv_t1 hihematfv_t1
					anystdepfv_t1 anytwavefv_t1;
%partC( outdest = "<path>\IPW_GRaSP2a.2.20.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp2a_0, covs_FV = &covs_grasp2a_FV , covs_lag = &covs_grasp2a_lag);


%let covs_grasp2b_0 = cig0  
					aci0 ap0 icia0 hisysbp0 ap0 niha_bin0
					hisertrigly0 hiseruric0 hiwhitecell0 hineut0
					anystdep0 anytwave0;


%let covs_grasp2b_fv = cigfv 
					acifv apfv iciafv hisysbpfv apfv nihafv
					hisertriglyfv hiseruricfv hiwhitecellfv hineutfv
					anystdepfv anytwavefv;

%let covs_grasp2b_lag = cigfv_t1 
					acifv_t1 apfv_t1 iciafv_t1 hisysbpfv_t1 apfv_t1 nihafv_t1
					hisertriglyfv_t1 hiseruricfv_t1 hiwhitecellfv_t1 hineutfv_t1
					anystdepfv_t1 anytwavefv_t1;


%partC( outdest = "<path>\IPW_GRaSP2b.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp2b_0, covs_FV = &covs_grasp2b_FV , covs_lag = &covs_grasp2b_lag);


%let covs_grasp3_0 = 	cig0 inact0
					chf0 icia0 hisysbp0 niha_bin0 ap0 ic0 cardioM0
					diur0 antihyp0 dig0
					hisertrigly0 hineut0 hiwhitecell0
					anystdep0 anyqqs0 anytwave0 vcd0 hiheart0;


%let covs_grasp3_fv = 	cigfv inactfv
					chffv iciafv hisysbpfv nihafv apfv icfv cardioMfv
					diurfv antihypfv digfv
					hisertriglyfv hineutfv hiwhitecellfv
					anystdepfv anyqqsfv anytwavefv vcdfv hiheartfv;

%let covs_grasp3_lag = 	cigfv_t1 inactfv_t1
					chffv_t1 iciafv_t1 hisysbpfv_t1 nihafv_t1 apfv_t1 icfv_t1 cardioMfv_t1
					diurfv_t1 antihypfv_t1 digfv_t1
					hisertriglyfv_t1 hineutfv_t1 hiwhitecellfv_t1
					anystdepfv_t1 anyqqsfv_t1 anytwavefv_t1 vcdfv_t1 hiheartfv_t1;

%partC( outdest = "<path>\IPW_GRaSP3.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp3_0, covs_FV = &covs_grasp3_FV , covs_lag = &covs_grasp3_lag);


%let covs_grasp4_0 = 	cig0 inact0  
				   	chf0 niha_bin0 mi_bin ic0  cardioM0
					diur0 oralhyp0 dig0
					hiwhitecell0 hineut0 hiwhitecell0 
					anystdep0 vcd0 hiheart0;

%let covs_grasp4_fv = 	cigfv  inactfv   
				   	chffv  nihafv icfv  cardioMfv 
					diurfv oralhypfv digfv 
					hiwhitecellfv hineutfv  
					anystdepfv vcdfv hiheartfv ;

%let covs_grasp4_lag= 	cigfv_t1  inactfv_t1   
				   	chffv_t1  nihafv_t1 icfv_t1  cardioMfv_t1 
					diurfv_t1 oralhypfv_t1 digfv_t1 
					hiwhitecellfv_t1 hineutfv_t1 
					anystdepfv_t1 vcdfv_t1 hiheartfv_t1 ;

%partC( outdest = "<path>\IPW_GRaSP4.2.15.24.rtf", 
	inset = baseline_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=work, 
		covs_0 = &covs_grasp4_0, covs_FV = &covs_grasp4_FV , covs_lag = &covs_grasp4_lag);







proc printto; run;



