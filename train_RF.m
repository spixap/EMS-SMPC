%%%%%%%%%%%%%%%%%%%%% FORECASTING MODEL BUILDING %%%%%%%%%%%%%%%%%%%%%%%%%%
%-----CREATE THE QUANTILE REGRESSION FOREST MODELS-----

%--- DESCRIPTION:{
% Create the QRF models for probabilistic 
% forecasting of load demand of the platform and wind power 
%..................................................................}
%% Train autoregressive Random Forest predictive models, 
% for specified look ahead horizon
close all;
clc;
clearvars -except DataTot GFA_15_min RES Mdl_wp Mdl_ld Data_ld Data_wp
%% SELECT DATA TYPE
% PART A - LOAD
%
ttData = GFA_15_min;
ttData.Properties.DimensionNames{1} = 'time';
Data   = GFA_15_min.P_GFA;
%}
% PART B - WIND POWER
%{
newTimes      = (datetime(2018,1,1,00,00,00):minutes(15):datetime(2018,12,31,23,45,00))';
ttData        = retime(RES,newTimes,'linear');
WF1           = WindFarm();
WF1.WindValue = ttData.Wind_Speed;
WF1.DoWindPower;
Data          = WF1.WindPower;
%}
%% REGRESSORS, PREDICTION HORIZON and PARAMETERS
tsData_len = length(Data);
lagsNum    = 6;   
predHorK   = 12; 
% Hyperparameters
minLeafSize     = [5 10 15 20 25]; % Minimum number of observations at a leaf of a tree
numWeakLearners = 20;              % number of Trees in a Forest
options = statset('UseParallel',true);
%% Create input features matrix X (regressors/predictors)
X = zeros(tsData_len,lagsNum);
Y = NaN(tsData_len,predHorK);
for n = 0 : lagsNum-1
    i = 1;
    while i < n+1
        X(i,n+1) = NaN;
        i = i + 1;
    end
    X(i:tsData_len,i) = Data(1:end-(i-1));
end

for k = 1 : predHorK
    Y(1:tsData_len-k,k) = Data(k+1:end);
end

varNames    = cell(1,lagsNum);
varNames{1} = ['t-',num2str(0)];
Xtab        = table(X(:,1),'VariableNames',varNames(1));

% Response variable (regression Y)
for k = 1 : predHorK
    Ytab.T{k} = table(Y(:,k),'VariableNames',{['t+',num2str(k)]});
end
% Predictors variables (regression X)
for n = 1 : lagsNum-1
    varNames{n+1} = ['t-',num2str(n)];
    Xtab          = addvars(Xtab,X(:,n+1),'After',['t-',num2str(n-1)]);
    Xtab.Properties.VariableNames = varNames(1:n+1);
end

head(Xtab)
%% Build prediction models for each ahead time (t+1, t+2,...,t+K)
rng(1945,'twister')

% Training
for k = 1 : predHorK
    for leaf_idx = 1 : length(minLeafSize)
        Mdl.M{k,leaf_idx} = TreeBagger(numWeakLearners,Xtab,Ytab.T{1,k},'Method','regression',...
                                       'OOBPrediction','On','MinLeafSize',minLeafSize(leaf_idx),'Options',options);
    end
end
view(Mdl.M{1,1}.Trees{1},'Mode','graph')
view(Mdl.M{1,1}.Trees{1})