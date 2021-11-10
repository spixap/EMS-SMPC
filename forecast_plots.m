% ----- FORECAST PLOTS (based on selected date) -----
%%
user_defined_inputs;
preamble;
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
%% SELECT SPECIFIC t TO PLOT SCENARIO FORECASTS
% example date: '21-Mar-2019 12:30:00'
t_slct = find(ttData.time==datetime('21-Mar-2019 11:15:00'));
myFigtitle = [varNameTitle,'frcst_t_',num2str(t_slct)];
funFrcstFig1step(ttData, par, Data, t_slct, Mdl, varName, myFigtitle);