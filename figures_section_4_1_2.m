%-----FIGURES OF SECTION 4.1.2-----
user_defined_inputs;
%% 
preamble;
%% SELECT DATA TYPE
% PART A - LOAD
%{
ttData = GFA_15_min;
ttData.Properties.DimensionNames{1} = 'time';
Data   = GFA_15_min.P_GFA;
Mdl = Mdl_ld;
varName = '$P^{\ell}\;[MW]$';
varNameTitle = 'ld';
%}
% PART B - WIND POWER
%
newTimes      = (datetime(2018,1,1,00,00,00):minutes(15):datetime(2018,12,31,23,45,00))';
ttData        = retime(RES,newTimes,'linear');
WF1           = WindFarm();
WF1.WindValue = ttData.Wind_Speed;
WF1.DoWindPower;
Data          = WF1.WindPower;
Mdl = Mdl_wp;
varName = '$P^{w}\;[MW]$';
varNameTitle = 'wp';

%}
%% ------------------------------FIGURE -----------------------------------
%--------------------Scenarios and probabilistic plot----------------------
myProbFrcstFigTitle = [varNameTitle,'probFrcst_t_',num2str(t_current)];
myScenFrcstFigTitle = [varNameTitle,'scenFrcst_t_',num2str(t_current)];
funProbFrcstFig1step(ttData, par, Data, t_current, Mdl, varName, myProbFrcstFigTitle);
funScenFrcstFig1step(ttData, par, Data, t_current, Mdl, varName, myScenFrcstFigTitle);
%%
myFrcstFigTitle = [varNameTitle,'Frcst_t_',num2str(t_current)];
funFrcstFig1step(ttData, par, Data, t_current, Mdl, varName, myFrcstFigTitle);