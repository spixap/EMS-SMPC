% -----KPIs COMPARISON (DMPC/SMPC)-----
%%
user_defined_inputs;

clearvars -except DataTot GFA_15_min RES Mdl_wp Mdl_ld Data_ld Data_wp spi w8bar crps input t_current
close all; clc;
if exist('w8bar')==1
    delete(w8bar);
end
rng(0,'twister');

preamble;

% LOAD RESULT FILE
FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Results\Revision';   % Your destination folder
outFileName     =  [input.simulPeriodName,'.mat'];
matFileName     = fullfile(FolderDestination,outFileName); 

if isfile(matFileName)
   load(matFileName,'RSLT')
end

%%
ctrl_rslt_mean = funGetCtrlRslt(par, RSLT.ESS_mean.x, RSLT.ESS_mean.u_0, RSLT.ESS_mean.rslt);
ctrl_rslt_scn  = funGetCtrlRslt(par, RSLT.ESS_scn.x,  RSLT.ESS_scn.u_0,  RSLT.ESS_scn.rslt);
%% CALCULATIONS

kpi_list.mean_cumCostAllGT = ctrl_rslt_mean.cumCostAllGT;
kpi_list.scn_cumCostAllGT  = ctrl_rslt_scn.cumCostAllGT;
kpi_list.cumCostAllGTDiff  = ctrl_rslt_mean.cumCostAllGT - ctrl_rslt_scn.cumCostAllGT;
kpi_list.cumCostAllGTPrcnt = (ctrl_rslt_mean.cumCostAllGT - ctrl_rslt_scn.cumCostAllGT)/(ctrl_rslt_mean.cumCostAllGT)*100;

kpi_list.mean_cumFuelAllGT_tn = ctrl_rslt_mean.cumFuelAllGT/1000; % [tonnes]
kpi_list.scn_cumFuelAllGT_tn  = ctrl_rslt_scn.cumFuelAllGT/1000;
kpi_list.cumFuelAllGTDiff_tn  = ctrl_rslt_mean.cumFuelAllGT/1000 - ctrl_rslt_scn.cumFuelAllGT/1000;
kpi_list.cumFuelAllGTPrcnt    = (ctrl_rslt_mean.cumFuelAllGT/1000 - ctrl_rslt_scn.cumFuelAllGT/1000)/(ctrl_rslt_mean.cumFuelAllGT/1000)*100;

kpi_list.mean_OnOffcmdTot = ctrl_rslt_mean.OnOffcmdTot;
kpi_list.scn_OnOffcmdTot  = ctrl_rslt_scn.OnOffcmdTot;

kpi_list.mean_cumDumpNrg = ctrl_rslt_mean.cumDumpNrg;
kpi_list.scn_cumDumpNrg  = ctrl_rslt_scn.cumDumpNrg;
kpi_list.cumDumpNrgDiff  = ctrl_rslt_mean.cumDumpNrg-ctrl_rslt_scn.cumDumpNrg;
kpi_list.cumDumpNrgPrcnt = (ctrl_rslt_mean.cumDumpNrg - ctrl_rslt_scn.cumDumpNrg)/(ctrl_rslt_mean.cumDumpNrg)*100;

kpi_list.mean_cumDegrad = ctrl_rslt_mean.cumDegrad;
kpi_list.scn_cumDegrad  = ctrl_rslt_scn.cumDegrad;
kpi_list.cumDegradDiff  = ctrl_rslt_mean.cumDegrad-ctrl_rslt_scn.cumDegrad;
kpi_list.cumDegradPrcnt = (ctrl_rslt_mean.cumDegrad - ctrl_rslt_scn.cumDegrad)/(ctrl_rslt_mean.cumDegrad)*100;

kpi_list.mean_varPgtTot = ctrl_rslt_mean.varPgtTot;
kpi_list.scn_varPgtTot  = ctrl_rslt_scn.varPgtTot;
kpi_list.varPgtTotDiff  = ctrl_rslt_mean.varPgtTot - ctrl_rslt_scn.varPgtTot;
kpi_list.varPgtTotPrcnt = (ctrl_rslt_mean.varPgtTot - ctrl_rslt_scn.varPgtTot)/(ctrl_rslt_mean.varPgtTot)*100;