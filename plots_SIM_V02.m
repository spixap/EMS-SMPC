% -----DMPC/SMPC PLOTS-----
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

% preamble;
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\Period_7500_7800\rslts_gtONcst_5000.mat','RSLT');
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\day100.mat','RSLT');
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\days_100_110.mat','RSLT');

%%
t_start = t_current;
t_end = t_start + par.N_steps;
idx_start = t_start - t_current + 1;
idx_end = t_end - t_current +1;
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
%% \\\\\\\\\\\\\\\\\PLOT 2: total GT power (scn & mean)\\\\\\\\\\\\\\\\\\\

myFigs.gtPwrTot.figWidth = 7; myFigs.gtPwrTot.figHeight = 5;
myFigs.gtPwrTot.figBottomLeftX0 = 2; myFigs.gtPwrTot.figBottomLeftY0 =2;
myFigs.gtPwrTot.fig = figure('Name','gtPwrTot','NumberTitle','off','Units','inches',...
    'Position',[myFigs.gtPwrTot.figBottomLeftX0 myFigs.gtPwrTot.figBottomLeftY0 myFigs.gtPwrTot.figWidth myFigs.gtPwrTot.figHeight],...
    'PaperPositionMode','auto');


setup.ESS_mean.iVecDmpPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iVecGTAPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iVecGTBPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iVecGTCPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iVecGTDPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iVecDmpPwrTrue = zeros(idx_end - idx_start + 1,1);
setup.ESS_mean.iAllGTstates   = zeros(idx_end - idx_start + 1,1);

setup.ESS_scn.iVecDmpPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iVecGTAPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iVecGTBPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iVecGTCPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iVecGTDPwr     = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iVecDmpPwrTrue = zeros(idx_end - idx_start + 1,1);
setup.ESS_scn.iAllGTstates   = zeros(idx_end - idx_start + 1,1);


% setup = {ESS_mean, ESS_scn}
for i = 1 : idx_end - idx_start + 1
    
    setup.ESS_mean.iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(idx_start-1+i).L(1,1);
    setup.ESS_mean.iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(idx_start-1+i).W(1,1);
    setup.ESS_mean.iVecDmpPwr(i) = mean(RSLT.ESS_mean.rslt.sol(idx_start-1+i).Power_dump(1,:));
    setup.ESS_mean.iVecGTAPwr(i) = mean(RSLT.ESS_mean.rslt.sol(idx_start-1+i).Power_GT(1,:,1)) * (RSLT.ESS_mean.x(2,idx_start-1+i) + RSLT.ESS_mean.u_0(3,idx_start-1+i) - RSLT.ESS_mean.u_0(4,idx_start-1+i));
    setup.ESS_mean.iVecGTBPwr(i) = mean(RSLT.ESS_mean.rslt.sol(idx_start-1+i).Power_GT(1,:,2)) * (RSLT.ESS_mean.x(3,idx_start-1+i) + RSLT.ESS_mean.u_0(5,idx_start-1+i) - RSLT.ESS_mean.u_0(6,idx_start-1+i));
    setup.ESS_mean.iVecGTCPwr(i) = mean(RSLT.ESS_mean.rslt.sol(idx_start-1+i).Power_GT(1,:,3)) * (RSLT.ESS_mean.x(4,idx_start-1+i) + RSLT.ESS_mean.u_0(7,idx_start-1+i) - RSLT.ESS_mean.u_0(8,idx_start-1+i));
    setup.ESS_mean.iVecGTDPwr(i) = mean(RSLT.ESS_mean.rslt.sol(idx_start-1+i).Power_GT(1,:,4)) * (RSLT.ESS_mean.x(5,idx_start-1+i) + RSLT.ESS_mean.u_0(9,idx_start-1+i) - RSLT.ESS_mean.u_0(10,idx_start-1+i));
    
    setup.ESS_mean.iVecDmpPwrTrue(i) = setup.ESS_mean.iVecGTAPwr(i)+setup.ESS_mean.iVecGTBPwr(i)+setup.ESS_mean.iVecGTCPwr(i)+setup.ESS_mean.iVecGTDPwr(i) - ...
        (RSLT.ESS_mean.u_0(1,i) - RSLT.ESS_mean.u_0(2,i)) - (setup.ESS_mean.iVecLoad(i)-setup.ESS_mean.iVecWndPwr(i));
    
    setup.ESS_mean.iAllGTstates(i) = RSLT.ESS_mean.x(2,idx_start-1+i) + RSLT.ESS_mean.x(3,idx_start-1+i) + RSLT.ESS_mean.x(3,idx_start-1+i) +RSLT.ESS_mean.x(4,idx_start-1+i);
    
    setup.ESS_scn.iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(idx_start-1+i).L(1,1);
    setup.ESS_scn.iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(idx_start-1+i).W(1,1);
    setup.ESS_scn.iVecDmpPwr(i) = mean(RSLT.ESS_scn.rslt.sol(idx_start-1+i).Power_dump(1,:));
    setup.ESS_scn.iVecGTAPwr(i) = mean(RSLT.ESS_scn.rslt.sol(idx_start-1+i).Power_GT(1,:,1)) * (RSLT.ESS_scn.x(2,idx_start-1+i) + RSLT.ESS_scn.u_0(3,idx_start-1+i) - RSLT.ESS_scn.u_0(4,idx_start-1+i));
    setup.ESS_scn.iVecGTBPwr(i) = mean(RSLT.ESS_scn.rslt.sol(idx_start-1+i).Power_GT(1,:,2)) * (RSLT.ESS_scn.x(3,idx_start-1+i) + RSLT.ESS_scn.u_0(5,idx_start-1+i) - RSLT.ESS_scn.u_0(6,idx_start-1+i));
    setup.ESS_scn.iVecGTCPwr(i) = mean(RSLT.ESS_scn.rslt.sol(idx_start-1+i).Power_GT(1,:,3)) * (RSLT.ESS_scn.x(4,idx_start-1+i) + RSLT.ESS_scn.u_0(7,idx_start-1+i) - RSLT.ESS_scn.u_0(8,idx_start-1+i));
    setup.ESS_scn.iVecGTDPwr(i) = mean(RSLT.ESS_scn.rslt.sol(idx_start-1+i).Power_GT(1,:,4)) * (RSLT.ESS_scn.x(5,idx_start-1+i) + RSLT.ESS_scn.u_0(9,idx_start-1+i) - RSLT.ESS_scn.u_0(10,idx_start-1+i));
    
    setup.ESS_scn.iVecDmpPwrTrue(i) = setup.ESS_scn.iVecGTAPwr(i)+setup.ESS_scn.iVecGTBPwr(i)+setup.ESS_scn.iVecGTCPwr(i)+setup.ESS_scn.iVecGTDPwr(i) - ...
        (RSLT.ESS_scn.u_0(1,i) - RSLT.ESS_scn.u_0(2,i)) - (setup.ESS_scn.iVecLoad(i)-setup.ESS_scn.iVecWndPwr(i));
    
    setup.ESS_scn.iAllGTstates(i) = RSLT.ESS_scn.x(2,idx_start-1+i) + RSLT.ESS_scn.x(3,idx_start-1+i) + RSLT.ESS_scn.x(3,idx_start-1+i) +RSLT.ESS_scn.x(4,idx_start-1+i);
    
end

myFigs.gtPwrTot.ax = gca;
hold on;

GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

plot(ttData.time(t_start : t_end),GTpowESSmean,'-r','LineWidth',1.5);
plot(ttData.time(t_start : t_end),GTpowESSscn,'--b','LineWidth',1.5);
hold off;

myFigs.gtPwrTot.ax.XLabel.Interpreter = 'latex';
myFigs.gtPwrTot.ax.XLabel.String ='Date';
myFigs.gtPwrTot.ax.XLabel.Color = 'black';
myFigs.gtPwrTot.ax.XLabel.FontSize  = 12;
myFigs.gtPwrTot.ax.XLabel.FontName = 'Times New Roman';
myFigs.gtPwrTot.ax.XAxis.FontSize  = 12;
myFigs.gtPwrTot.ax.FontName = 'Times New Roman';
myFigs.gtPwrTot.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
%         myFigs.netLoadSoC.ax.XLim = [0,max(sim4Opt(1,1).tout)+dt];
%         myFigs.netLoadSoC.ax.XTick = (0:1:max(sim4Opt(1,1).tout)+dt);


%     myFigs.netLoadSoC.ax.Title.String = 'Total GT power';
myFigs.gtPwrTot.ax.YAxis.Label.Interpreter = 'latex';
myFigs.gtPwrTot.ax.YAxis.Label.String ='$P^{gt}\;[MW]$';
myFigs.gtPwrTot.ax.YAxis.Color = 'black';
myFigs.gtPwrTot.ax.XGrid = 'on';
myFigs.gtPwrTot.ax.YGrid = 'on';
myFigs.gtPwrTot.ax.YAxis.FontSize  = 12;
myFigs.gtPwrTot.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
legend(myFigs.gtPwrTot.ax,{'mean', 'scn'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');
%% \\\\\\\\\\\\\\\\\PLOT 3: Dumped power (scn & mean)\\\\\\\\\\\\\\\\\\\
setup.ESS_mean.iVecDmpPwr     = zeros(par.N_steps + 1,1);
setup.ESS_mean.iVecGTAPwr     = zeros(par.N_steps + 1,1);
setup.ESS_mean.iVecGTBPwr     = zeros(par.N_steps + 1,1);
setup.ESS_mean.iVecGTCPwr     = zeros(par.N_steps + 1,1);
setup.ESS_mean.iVecGTDPwr     = zeros(par.N_steps + 1,1);
setup.ESS_mean.iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
setup.ESS_mean.iAllGTstates   = zeros(par.N_steps + 1,1);


setup.ESS_scn.iVecDmpPwr     = zeros(par.N_steps + 1,1);
setup.ESS_scn.iVecGTAPwr     = zeros(par.N_steps + 1,1);
setup.ESS_scn.iVecGTBPwr     = zeros(par.N_steps + 1,1);
setup.ESS_scn.iVecGTCPwr     = zeros(par.N_steps + 1,1);
setup.ESS_scn.iVecGTDPwr     = zeros(par.N_steps + 1,1);
setup.ESS_scn.iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
setup.ESS_scn.iAllGTstates   = zeros(par.N_steps + 1,1);

% setup = {ESS_mean, ESS_scn}
for i = 1 : par.N_steps + 1
    
    setup.ESS_mean.iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1);
    setup.ESS_mean.iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);
    setup.ESS_mean.iVecDmpPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_dump(1,:));
    setup.ESS_mean.iVecGTAPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.u_0(3,i) - RSLT.ESS_mean.u_0(4,i));
    setup.ESS_mean.iVecGTBPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.u_0(5,i) - RSLT.ESS_mean.u_0(6,i));
    setup.ESS_mean.iVecGTCPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_mean.x(4,i) + RSLT.ESS_mean.u_0(7,i) - RSLT.ESS_mean.u_0(8,i));
    setup.ESS_mean.iVecGTDPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_mean.x(5,i) + RSLT.ESS_mean.u_0(9,i) - RSLT.ESS_mean.u_0(10,i));
    
    setup.ESS_mean.iVecDmpPwrTrue(i) = setup.ESS_mean.iVecGTAPwr(i)+setup.ESS_mean.iVecGTBPwr(i)+setup.ESS_mean.iVecGTCPwr(i)+setup.ESS_mean.iVecGTDPwr(i) - ...
        (RSLT.ESS_mean.u_0(1,i) - RSLT.ESS_mean.u_0(2,i)) - (setup.ESS_mean.iVecLoad(i)-setup.ESS_mean.iVecWndPwr(i));
    
    setup.ESS_mean.iAllGTstates(i) = RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.x(4,i) +RSLT.ESS_mean.x(5,i);
    
    setup.ESS_scn.iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(i).L(1,1);
    setup.ESS_scn.iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(i).W(1,1);
    setup.ESS_scn.iVecDmpPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_dump(1,:));
    setup.ESS_scn.iVecGTAPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.u_0(3,i) - RSLT.ESS_scn.u_0(4,i));
    setup.ESS_scn.iVecGTBPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.u_0(5,i) - RSLT.ESS_scn.u_0(6,i));
    setup.ESS_scn.iVecGTCPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_scn.x(4,i) + RSLT.ESS_scn.u_0(7,i) - RSLT.ESS_scn.u_0(8,i));
    setup.ESS_scn.iVecGTDPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_scn.x(5,i) + RSLT.ESS_scn.u_0(9,i) - RSLT.ESS_scn.u_0(10,i));
    
    setup.ESS_scn.iVecDmpPwrTrue(i) = setup.ESS_scn.iVecGTAPwr(i)+setup.ESS_scn.iVecGTBPwr(i)+setup.ESS_scn.iVecGTCPwr(i)+setup.ESS_scn.iVecGTDPwr(i) - ...
        (RSLT.ESS_scn.u_0(1,i) - RSLT.ESS_scn.u_0(2,i)) - (setup.ESS_scn.iVecLoad(i)-setup.ESS_scn.iVecWndPwr(i));
    
    setup.ESS_scn.iAllGTstates(i) = RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.x(4,i) +RSLT.ESS_scn.x(5,i);
    
end

myFigs.dmpPwr.figWidth = 7; myFigs.dmpPwr.figHeight = 5;
myFigs.dmpPwr.figBottomLeftX0 = 2; myFigs.dmpPwr.figBottomLeftY0 =2;
myFigs.dmpPwr.fig = figure('Name','dumpPwr','NumberTitle','off','Units','inches',...
    'Position',[myFigs.dmpPwr.figBottomLeftX0 myFigs.dmpPwr.figBottomLeftY0 myFigs.dmpPwr.figWidth myFigs.dmpPwr.figHeight],...
    'PaperPositionMode','auto');

myFigs.dmpPwr.ax = gca;
hold on;

plot(ttData.time(t_start : t_end),setup.ESS_mean.iVecDmpPwrTrue ,'-r','LineWidth',1.5);
plot(ttData.time(t_start : t_end),setup.ESS_scn.iVecDmpPwrTrue ,'--b','LineWidth',1.5);

hold off;
myFigs.dmpPwr.ax.YAxis.Label.Interpreter = 'latex';
myFigs.dmpPwr.ax.YAxis.Label.String = '$P^{d}\;[MW]$';
myFigs.dmpPwr.ax.YAxis.Color = 'black';
myFigs.dmpPwr.ax.XLabel.FontSize  = 12;
myFigs.dmpPwr.ax.XLabel.Interpreter = 'latex';
myFigs.dmpPwr.ax.XLabel.String = 'Date';
myFigs.dmpPwr.ax.XLabel.FontName = 'Times New Roman';
myFigs.dmpPwr.ax.XAxis.FontName = 'Times New Roman';
myFigs.dmpPwr.ax.XAxis.FontSize  = 12;
myFigs.dmpPwr.ax.XGrid = 'on';
myFigs.dmpPwr.ax.YGrid = 'on';
% myFigs.dmpPwr.ax.YAxis.FontSize  = 18;
% myFigs.dmpPwr.ax.YAxis.FontName = 'Times New Roman';
myFigs.dmpPwr.ax.YAxis.FontSize  = 12;
myFigs.dmpPwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.dmpPwr.ax.YLim = [0,1];
legend(myFigs.dmpPwr.ax,{'mean', 'scn'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');
%% \\\\\\\\\\\\\\\\\PLOT 4: GT x power (scn & mean)\\\\\\\\\\\\\\\\\\\

myFigs.gtPwrA.figWidth = 7; myFigs.gtPwrA.figHeight = 5;
myFigs.gtPwrA.figBottomLeftX0 = 2; myFigs.gtPwrA.figBottomLeftY0 =2;
myFigs.gtPwrA.fig = figure('Name','gt_D_Pwr','NumberTitle','off','Units','inches',...
    'Position',[myFigs.gtPwrA.figBottomLeftX0 myFigs.gtPwrA.figBottomLeftY0 myFigs.gtPwrA.figWidth myFigs.gtPwrA.figHeight],...
    'PaperPositionMode','auto');
myFigs.gtPwrA.ax = gca;
hold on;

    GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
    GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

% GTpowESSmean = setup.ESS_mean.iVecGTAPwr;
% GTpowESSscn = setup.ESS_scn.iVecGTAPwr;
%
% GTpowESSmean = setup.ESS_mean.iVecGTBPwr;
% GTpowESSscn = setup.ESS_scn.iVecGTBPwr;
%
% GTpowESSmean = setup.ESS_mean.iVecGTCPwr;
% GTpowESSscn = setup.ESS_scn.iVecGTCPwr;
%
% GTpowESSmean = setup.ESS_mean.iVecGTDPwr;
% GTpowESSscn = setup.ESS_scn.iVecGTDPwr;

plot(ttData.time(t_start : t_end),GTpowESSmean,'-r','LineWidth',1.5);
plot(ttData.time(t_start : t_end),GTpowESSscn,'--b','LineWidth',1.5);
hold off;

%     myFigs.gtPwrA.ax.Title.String = 'Total GT power';
myFigs.gtPwrA.ax.YAxis.Label.Interpreter = 'latex';
myFigs.gtPwrA.ax.YAxis.Label.String ='$P^{gt,D}\;[MW]$';
myFigs.gtPwrA.ax.YAxis.Color = 'black';
myFigs.gtPwrA.ax.XGrid = 'on';
myFigs.gtPwrA.ax.YGrid = 'on';
% myFigs.pwr.ax.YAxis.FontSize  = 18;
myFigs.gtPwrA.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
legend(myFigs.gtPwrA.ax,{'mean', 'scn'},'FontSize',8,...
    'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');

%% \\\\\\\\\\\\\\\\\PLOT 5: GT On number (scn & mean)\\\\\\\\\\\\\\\\\\\

myFigs.gtNmr.figWidth = 7; myFigs.gtNmr.figHeight = 5;
myFigs.gtNmr.figBottomLeftX0 = 2; myFigs.gtNmr.figBottomLeftY0 =2;
myFigs.gtNmr.fig = figure('Name','gt_ON_nmr','NumberTitle','off','Units','inches',...
    'Position',[myFigs.gtNmr.figBottomLeftX0 myFigs.gtNmr.figBottomLeftY0 myFigs.gtNmr.figWidth myFigs.gtNmr.figHeight],...
    'PaperPositionMode','auto');
myFigs.gtNmr.ax = gca;
hold on;

% stem(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,'-r','LineWidth',1.5);
% stem(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,'--b','LineWidth',1.5);
bar(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,'r','FaceAlpha',0.8);
bar(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,'b','FaceAlpha',0.4);
hold off;

%     myFigs.gtNmr.ax.Title.String = 'GT states';
myFigs.gtNmr.ax.YAxis.Label.Interpreter = 'latex';
myFigs.gtNmr.ax.YAxis.Label.String ='No. of GT ON';
myFigs.gtNmr.ax.YAxis.Color = 'black';
myFigs.gtNmr.ax.XGrid = 'on';
myFigs.gtNmr.ax.YGrid = 'on';
myFigs.gtNmr.ax.XLabel.Interpreter = 'latex';
myFigs.gtNmr.ax.XLabel.String = 'Date';
myFigs.gtNmr.ax.XLabel.FontName = 'Times New Roman';
myFigs.gtNmr.ax.XAxis.FontName = 'Times New Roman';
myFigs.gtNmr.ax.YAxis.FontSize  = 12;
myFigs.gtNmr.ax.YAxis.FontName = 'Times New Roman';
myFigs.gtNmr.ax.XAxis.FontSize  = 12;
% myFigs.gtNmr.ax.YAxis.FontSize  = 18;
myFigs.gtNmr.ax.YAxis.FontName = 'Times New Roman';
myFigs.gtNmr.ax.YLim = [0,4];
yticks(0:1:4);

legend(myFigs.gtNmr.ax,{'mean', 'scn'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northwest');
%%
funPaperPlts(par, ttData, t_start, t_end, RSLT.ESS_scn.x, RSLT.ESS_scn.u_0  , RSLT.ESS_scn.rslt, RSLT);
%% SELECT SPECIFIC t TO PLOT SCENARIO FORECASTS
t_slct = find(ttData.time==datetime('21-Mar-2019 12:30:00'));
myFigtitle = [varNameTitle,'frcst_t_',num2str(t_slct)];
funFrcstFig1step(ttData, par, Data, t_slct, Mdl, varName, myFigtitle);
%     tempXI = RSLT.ESS_scn.rslt.xi(t_slct-t_current+1).L;
tempXI = RSLT.ESS_scn.rslt.xi(t_slct-t_current+1).W;
hold on;plot(ttData.time(t_slct : t_slct+5),tempXI)
%% Appendix-1: Save produced figures
%{
% mkdir FigOutTest
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Figs_Out\paper_01';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    %       FigName   = num2str(get(FigHandle, 'Number'));
    FigName   = get(FigHandle,'Name');
    %     set(0, 'CurrentFigure', FigHandle);
    %     savefig(fullfile(FolderName, [FigName '.fig']));
    print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')
end
%}