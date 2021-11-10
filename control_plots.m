% ----- CONTROL PLOTS -----
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
t_start = t_current;
t_end = t_start + par.N_steps;
% idx_start = t_start - t_current + 1;
% idx_end = t_end - t_current +1;
%% SELECT DATA TYPE
% PART A - LOAD
%
ttData = GFA_15_min;
ttData.Properties.DimensionNames{1} = 'time';
Data   = GFA_15_min.P_GFA;
Mdl = Mdl_ld;
varName = '$P_{\ell}\;[MW]$';
varNameTitle = 'ld';
%}
% PART B - WIND POWER
%{
newTimes      = (datetime(2018,1,1,00,00,00):minutes(15):datetime(2018,12,31,23,45,00))';
ttData        = retime(RES,newTimes,'linear');
WF1           = WindFarm();
WF1.WindValue = ttData.Wind_Speed;
WF1.DoWindPower;
Data          = WF1.WindPower;
Mdl = Mdl_wp;
varName = '$P_{w}\;[MW]$';
varNameTitle = 'wp';
%}
%%
funPltCtrlRsltPretty(par, ttData, t_start, t_end, RSLT.ESS_scn.x, RSLT.ESS_scn.u_0  , RSLT.ESS_scn.rslt, RSLT);