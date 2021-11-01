%-----GENERATE FIGURE WITH MEAN, PROBABILISTIC AND SCENARIO FORECASTS------
%-----for time instant t_current------
%%
preamble;
%% SELECT DATA TYPE
% PART A - LOAD
%
ttData = GFA_15_min;
ttData.Properties.DimensionNames{1} = 'time';
Data   = GFA_15_min.P_GFA;
Mdl = Mdl_ld;
varName = '$P^{\ell}\;[MW]$';
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
varName = '$P^{w}\;[MW]$';
varNameTitle = 'wp';

%}

tsData_len = length(Data);
lagsNum    = 6;   
predHorK   = 12; 
% Hyperparameters
minLeafSize     = [5 10 15 20 25]; % Minimum number of observations at a leaf of a tree
numWeakLearners = 20;              % number of Trees in a Forest
options = statset('UseParallel',true);
% par.N_steps = 300;                  % number of timesteps to simulate 576 (nice period)
%% -----------------------------FIGURE 1-----------------------------------
% -------------MSE plots for different minimum Leaf Sizes------------------

s1=0;
yData = zeros(predHorK*length(minLeafSize),numWeakLearners);
for k = 1 : predHorK
    for leaf_idx=1:length(minLeafSize)
        s1=s1+1;
        yData(s1,:) = oobError(Mdl.M{k,leaf_idx});
    end
end

myFigs.mse.figWidth = 7; myFigs.mse.figHeight = 5;
myFigs.mse.figBottomLeftX0 = 2; myFigs.mse.figBottomLeftY0 =2;
myFigs.mse.fig = figure('Name','MSE','NumberTitle','off','Units','inches',...
    'Position',[myFigs.mse.figBottomLeftX0 myFigs.mse.figBottomLeftY0 myFigs.mse.figWidth myFigs.mse.figHeight],...
    'PaperPositionMode','auto');

hold on;

myFigs.mse.p1 = boxplot(yData);
myFigs.mse.p2 = plot(median(yData),'--k','LineWidth',1.2);
hold off;

myFigs.mse.ax = gca;
myFigs.mse.h = [myFigs.mse.p1(1);myFigs.mse.p2(1)];

% legend(myFigs.figName.h,{'$Label^{1}$', '$Label^{2}$'},'FontSize',12,...
%     'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');

myFigs.mse.ax.YAxis.Label.Interpreter = 'latex';
myFigs.mse.ax.YAxis.Label.String = 'MSE';
myFigs.mse.ax.YAxis.Color = 'black';
myFigs.mse.ax.YLabel.Color = 'black';
myFigs.mse.ax.YAxis.FontSize  = 12;
% myFigs.mse.ax.YLabel.FontSize  = 12;
myFigs.mse.ax.YAxis.FontName = 'Times New Roman';
% myFigs.mse.ax.YLim = [-1,1];

myFigs.mse.ax.XAxis.Label.Interpreter = 'latex';
myFigs.mse.ax.XAxis.FontName = 'Times New Roman';
myFigs.mse.ax.XAxis.FontSize  = 12;
myFigs.mse.ax.XAxis.Color = 'black';
myFigs.mse.ax.XAxis.Label.String ='$\vert \mathcal{T} \vert$';


myFigs.mse.ax.XLabel.Color = 'black';
myFigs.mse.ax.XLabel.FontSize  = 12;
myFigs.mse.ax.XLabel.FontName = 'Times New Roman';
% myFigs.mse.ax.XLim = [0,10];

myFigs.mse.ax.XGrid = 'on';
%% ------------------------------FIGURE 2----------------------------------
% ---------Calculate out-of-bag NRMSE as a function of lead time k-------

leafSizeIdx = 1;
tsDataRange = (max(Data)-min(Data));
dr = 1/numWeakLearners;
dg = 1/numWeakLearners;
db = 1/numWeakLearners;
r=1;
g=1; 
b=1;
mse = zeros(numWeakLearners,predHorK);
for k = 1 : predHorK
    mse(:,k) = oobError(Mdl.M{k,leafSizeIdx});
    rmse = sqrt(mse);
    nrmse = rmse./tsDataRange*100;
%     nrmse = rmse./max(Data)*100;
end

myFigs.nrmse.figWidth = 7; myFigs.nrmse.figHeight = 5;
myFigs.nrmse.figBottomLeftX0 = 2; myFigs.nrmse.figBottomLeftY0 =2;
myFigs.nrmse.fig = figure('Name','NRMSE','NumberTitle','off','Units','inches',...
    'Position',[myFigs.nrmse.figBottomLeftX0 myFigs.nrmse.figBottomLeftY0 myFigs.nrmse.figWidth myFigs.nrmse.figHeight],...
    'PaperPositionMode','auto');

hold on;
for tree = 1 : numWeakLearners
    myFigs.nrmse.s1(tree) = scatter((1:predHorK)',nrmse(tree,:),[],[r g b],'filled');
    r=r-dr;    
    g=g-dg;
    b=b-db;
%     myFigs.nrmse.p1(tree) = plot((1:predHorK)',nrmse(tree,:),'DisplayName',['$\vert \mathcal{T} \vert$ = ',num2str(tree)]);
%     myFigs.nrmse.p1(tree) = plot((1:predHorK)',nrmse(tree,:));
    myFigs.nrmse.p1(tree) = plot((1:predHorK)',nrmse(tree,:),'-k');
end
xa = [0.48,0.52];
ya = [0.85,0.22];
ta = annotation('textarrow',xa,ya);
ta.String = '$\vert \mathcal{T} \vert \uparrow$  ';
ta.FontSize = 12;
ta.Interpreter = 'latex';

hold off;

myFigs.nrmse.ax = gca;
myFigs.nrmse.h = [myFigs.nrmse.p1];

% legend(myFigs.nrmse.h,'FontSize',6,...
%     'Fontname','Times New Roman','NumColumns',5,'interpreter','latex','Location','northeast');

myFigs.nrmse.ax.YAxis.Label.Interpreter = 'latex';
myFigs.nrmse.ax.YAxis.Label.String = 'Out-of-Bag Nomralized RMSE [\%]';
myFigs.nrmse.ax.YAxis.Color = 'black';
myFigs.nrmse.ax.YLabel.Color = 'black';
myFigs.nrmse.ax.YAxis.FontSize  = 12;
myFigs.nrmse.ax.YLabel.FontSize  = 12;
myFigs.nrmse.ax.YAxis.FontName = 'Times New Roman';
% myFigs.nrmse.ax.YLim = [-1,1];

myFigs.nrmse.ax.XAxis.Label.Interpreter = 'latex';
myFigs.nrmse.ax.XAxis.FontName = 'Times New Roman';
myFigs.nrmse.ax.XAxis.FontSize  = 12;
myFigs.nrmse.ax.XAxis.Color = 'black';
myFigs.nrmse.ax.XAxis.Label.String = 'lead time $k$';


myFigs.nrmse.ax.XLabel.Color = 'black';
myFigs.nrmse.ax.XLabel.FontSize  = 12;
myFigs.nrmse.ax.XLabel.FontName = 'Times New Roman';
myFigs.nrmse.ax.XLim = [1,12];

myFigs.nrmse.ax.XGrid = 'on';
%% Whole timeseries forecasting for k model
%{
leafSizeIdx  = 1;
t_current = lagsNum;
k = 12;
str_k = ['{t+',num2str(k),'|t}'];
t_idx = 1;
predX = zeros(tsData_len - predHorK - t_current +1, lagsNum);
trueY = zeros(tsData_len - predHorK - t_current +1,1);
for t = t_current : tsData_len - predHorK
    
    for n = 0 : lagsNum-1
        predX(t_idx,n+1) = Data(t-n);
    end
    
    trueY(t_idx) = Data(t+k);
    t_idx = t_idx +1;
end
predY = predict(Mdl.M{k,leafSizeIdx},predX);

% Plot the whole series vs time
plotTimes(tsData_len - predHorK - t_current +1,1) = datetime;
for t_idx = 1 : tsData_len - predHorK - t_current + 1 
    plotTimes(t_idx)    = ttData.time(t_idx + (lagsNum-1) + k);
end

ttCompare = timetable(plotTimes,trueY,predY);
ttCompare.Properties.VariableNames = {'True_Val', 'Forecast_Val'};

myFigs.meanFrcstk1.figWidth = 7; myFigs.meanFrcstk1.figHeight = 5;
myFigs.meanFrcstk1.figBottomLeftX0 = 2; myFigs.meanFrcstk1.figBottomLeftY0 =2;
myFigsmeanFrcstk1mse.fig = figure('Name','MeanFrcstk1','NumberTitle','off','Units','inches',...
    'Position',[myFigs.meanFrcstk1.figBottomLeftX0 myFigs.meanFrcstk1.figBottomLeftY0 myFigs.meanFrcstk1.figWidth myFigs.meanFrcstk1.figHeight],...
    'PaperPositionMode','auto');

hold on;
myFigs.meanFrcstk1.p1 = plot(ttCompare.plotTimes,ttCompare.True_Val,'-k','LineWidth',1.5);
myFigs.meanFrcstk1.p2 = plot(ttCompare.plotTimes,ttCompare.Forecast_Val,'--r','LineWidth',2);
hold off;

myFigs.meanFrcstk1.ax = gca;
% myFigs.meanFrcstk1.h = [myFigs.mse.p1(1);myFigs.mse.p2(1)];

legend(myFigs.meanFrcstk1.ax,{['$y_',str_k,'$'],['$\hat{y}_',str_k,'$']},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

myFigs.meanFrcstk1.ax.YAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.YAxis.Label.String = '$P_{\ell}\;[MW]$';
myFigs.meanFrcstk1.ax.YAxis.Color = 'black';
myFigs.meanFrcstk1.ax.YAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.YAxis.FontName = 'Times New Roman';
% myFigs.meanFrcstk1.ax.YLim = [-1,1];
myFigs.meanFrcstk1.ax.YLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.YLabel.Color = 'black';



myFigs.meanFrcstk1.ax.XAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.XAxis.FontName = 'Times New Roman';
myFigs.meanFrcstk1.ax.XAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.XAxis.Color = 'black';
myFigs.meanFrcstk1.ax.XAxis.Label.String = 'Date';


myFigs.meanFrcstk1.ax.XLabel.Color = 'black';
myFigs.meanFrcstk1.ax.XLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.XLabel.FontName = 'Times New Roman';
% myFigs.meanFrcstk1.ax.XLim = [0,10];

myFigs.meanFrcstk1.ax.XGrid = 'on';
myFigs.meanFrcstk1.ax.YGrid = 'on';
%}
%% ------------------------------FIGURE 3----------------------------------
%--------------Zoomed timeseries forecasting for k=1 model-----------------

k = 1;
str_k = ['{t+',num2str(k),'|t}'];
t_idx = 1;
predX = zeros(par.N_steps, lagsNum);
trueY = zeros(par.N_steps,1);
plotTimes(par.N_steps,1) = datetime;
for t = t_current : t_current + par.N_steps
    
    for n = 0 : lagsNum-1
        predX(t_idx,n+1) = Data(t-n);
    end
    
    trueY(t_idx)     = Data(t+k);
    plotTimes(t_idx) = ttData.time(t + k);
    
    t_idx = t_idx +1;
end
predY = predict(Mdl.M{k,par.leafSizeIdx},predX);

ttCompare = timetable(plotTimes,trueY,predY);
ttCompare.Properties.VariableNames = {'True_Val', 'Forecast_Val'};

myFigs.meanFrcstk1.figWidth = 7; myFigs.meanFrcstk1.figHeight = 5;
myFigs.meanFrcstk1.figBottomLeftX0 = 2; myFigs.meanFrcstk1.figBottomLeftY0 =2;
myFigsmeanFrcstk1mse.fig = figure('Name',[varNameTitle,'MeanFrcstk1'],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.meanFrcstk1.figBottomLeftX0 myFigs.meanFrcstk1.figBottomLeftY0 myFigs.meanFrcstk1.figWidth myFigs.meanFrcstk1.figHeight],...
    'PaperPositionMode','auto');

hold on;
myFigs.meanFrcstk1.p1 = plot(ttCompare.plotTimes,ttCompare.True_Val,'-k','LineWidth',1.5);
myFigs.meanFrcstk1.p2 = plot(ttCompare.plotTimes,ttCompare.Forecast_Val,'--r','LineWidth',2);
hold off;

myFigs.meanFrcstk1.ax = gca;
% myFigs.meanFrcstk1.h = [myFigs.mse.p1(1);myFigs.mse.p2(1)];

legend(myFigs.meanFrcstk1.ax,{['$y_',str_k,'$'],['$\hat{y}_',str_k,'$']},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

myFigs.meanFrcstk1.ax.YAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.YAxis.Label.String = varName;
myFigs.meanFrcstk1.ax.YAxis.Color = 'black';
myFigs.meanFrcstk1.ax.YAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.YAxis.FontName = 'Times New Roman';
% myFigs.meanFrcstk1.ax.YLim = [-1,1];
myFigs.meanFrcstk1.ax.YLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.YLabel.Color = 'black';


myFigs.meanFrcstk1.ax.XAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.XAxis.FontName = 'Times New Roman';
myFigs.meanFrcstk1.ax.XAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.XAxis.Color = 'black';
myFigs.meanFrcstk1.ax.XAxis.Label.String = 'Date';
% myFigs.meanFrcstk1.ax.XTick = ttCompare.plotTimes;
myFigs.meanFrcstk1.ax.XTick = (ttCompare.plotTimes(1):hours(6):ttCompare.plotTimes(end));
myFigs.meanFrcstk1.ax.XLabel.Color = 'black';
myFigs.meanFrcstk1.ax.XLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.XLabel.FontName = 'Times New Roman';
myFigs.meanFrcstk1.ax.XLim = [ttCompare.plotTimes(1),ttCompare.plotTimes(end)];
myFigs.meanFrcstk1.ax.XTickLabelRotation = 45;


myFigs.meanFrcstk1.ax.XGrid = 'on';
myFigs.meanFrcstk1.ax.YGrid = 'on';

%% -----------------------------FIGURE 4-----------------------------------
%--------------Zoomed timeseries forecasting for k=6 model-----------------
%
k = 12;
str_k = ['{t+',num2str(k),'|t}'];
t_idx = 1;
predX = zeros(par.N_steps, lagsNum);
trueY = zeros(par.N_steps,1);
plotTimes(par.N_steps,1) = datetime;
for t = t_current : t_current + par.N_steps
    
    for n = 0 : lagsNum-1
        predX(t_idx,n+1) = Data(t-n);
    end
    
    trueY(t_idx)     = Data(t+k);
    plotTimes(t_idx) = ttData.time(t + k);
    
    t_idx = t_idx +1;
end
predY = predict(Mdl.M{k,par.leafSizeIdx},predX);

ttCompare = timetable(plotTimes,trueY,predY);
ttCompare.Properties.VariableNames = {'True_Val', 'Forecast_Val'};

myFigs.meanFrcstk1.figWidth = 7; myFigs.meanFrcstk1.figHeight = 5;
myFigs.meanFrcstk1.figBottomLeftX0 = 2; myFigs.meanFrcstk1.figBottomLeftY0 =2;
myFigsmeanFrcstk1mse.fig = figure('Name',[varNameTitle,'MeanFrcstk6'],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.meanFrcstk1.figBottomLeftX0 myFigs.meanFrcstk1.figBottomLeftY0 myFigs.meanFrcstk1.figWidth myFigs.meanFrcstk1.figHeight],...
    'PaperPositionMode','auto');

hold on;
myFigs.meanFrcstk1.p1 = plot(ttCompare.plotTimes,ttCompare.True_Val,'-k','LineWidth',1.5);
myFigs.meanFrcstk1.p2 = plot(ttCompare.plotTimes,ttCompare.Forecast_Val,'--r','LineWidth',2);
hold off;

myFigs.meanFrcstk1.ax = gca;
% myFigs.meanFrcstk1.h = [myFigs.mse.p1(1);myFigs.mse.p2(1)];

legend(myFigs.meanFrcstk1.ax,{['$y_',str_k,'$'],['$\hat{y}_',str_k,'$']},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

myFigs.meanFrcstk1.ax.YAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.YAxis.Label.String = '$P^{\ell}\;[MW]$';
myFigs.meanFrcstk1.ax.YAxis.Color = 'black';
myFigs.meanFrcstk1.ax.YAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.YAxis.FontName = 'Times New Roman';
% myFigs.meanFrcstk1.ax.YLim = [-1,1];
myFigs.meanFrcstk1.ax.YLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.YLabel.Color = 'black';



myFigs.meanFrcstk1.ax.XAxis.Label.Interpreter = 'latex';
myFigs.meanFrcstk1.ax.XAxis.FontName = 'Times New Roman';
myFigs.meanFrcstk1.ax.XAxis.FontSize  = 12;
myFigs.meanFrcstk1.ax.XAxis.Color = 'black';
myFigs.meanFrcstk1.ax.XAxis.Label.String = 'Date';
% myFigs.meanFrcstk1.ax.XTick = ttCompare.plotTimes;
myFigs.meanFrcstk1.ax.XTick = (ttCompare.plotTimes(1):hours(6):ttCompare.plotTimes(end));
myFigs.meanFrcstk1.ax.XTickLabelRotation = 45;



myFigs.meanFrcstk1.ax.XLabel.Color = 'black';
myFigs.meanFrcstk1.ax.XLabel.FontSize  = 12;
myFigs.meanFrcstk1.ax.XLabel.FontName = 'Times New Roman';
% myFigs.meanFrcstk1.ax.XLim = [0,10];

myFigs.meanFrcstk1.ax.XGrid = 'on';
myFigs.meanFrcstk1.ax.YGrid = 'on';
%}
%% -----------------------------FIGURE 5-----------------------------------
%--------------------Scenarios and probabilistic plot----------------------
myProbFrcstFigTitle = [varNameTitle,'probFrcst_t_',num2str(t_current)];
myScenFrcstFigTitle = [varNameTitle,'scenFrcst_t_',num2str(t_current)];
funProbFrcstFig1step(ttData, par, Data, t_current, Mdl, varName, myProbFrcstFigTitle);
funScenFrcstFig1step(ttData, par, Data, t_current, Mdl, varName, myScenFrcstFigTitle);
%% ------------------------\\\ SAVING FIGURES \\\---------------------------
%
% mkdir Figs_Out
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Figs_Out';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle,'Name');
    print(FigHandle, fullfile(FolderName, ['ld_crps_simulation_period .png']), '-r300', '-dpng')
%     print(FigHandle, fullfile(FolderName, [FigName '.eps']), '-r300', '-depsc2')

end
%}