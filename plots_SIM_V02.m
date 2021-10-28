%----------------------GENERATE MEAN VS SCN PLOTS--------------------------
%%
preamble;
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\Period_7500_7800\rslts_gtONcst_5000.mat','RSLT');
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\day100.mat','RSLT');
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\days_100_110.mat','RSLT');

%%
t_start = t_current;
t_end = t_start + par.N_steps;
% t_start = 7681;
% t_end = 7753;
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
%% \\\\\\\\\\\\\\\\\PLOT 1: soc vs net load (scn & mean)\\\\\\\\\\\\\\\\\\\

iVecLoad       = zeros(idx_end - idx_start + 1,1);
iVecWndPwr     = zeros(idx_end - idx_start + 1,1);

for i = 1 : idx_end - idx_start + 1
    iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1);
    iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);
end

myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
myFigs.netLoadSoC.fig = figure('Name','SoC_Pgt_rslt','NumberTitle','off','Units','inches',...
    'Position',[myFigs.netLoadSoC.figBottomLeftX0 myFigs.netLoadSoC.figBottomLeftY0 myFigs.netLoadSoC.figWidth myFigs.netLoadSoC.figHeight],...
    'PaperPositionMode','auto');

%     subplot(2,1,1);
myFigs.states.ax = gca;
hold on;

p1=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,idx_start:idx_end),'-r','LineWidth',1.5);
p2=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,idx_start:idx_end),'--b','LineWidth',1.2);

yl1=yline(par.socDOWNlim,'--','LineWidth',3);
yl1.Color = [0.8500, 0.3250, 0.0980];
yl1.Interpreter = 'latex';
yl1.Label = '$SoC_{min}$';
yl1.LabelVerticalAlignment = 'top';
yl1.LabelHorizontalAlignment = 'left';
yl1.FontSize = 12;

yl2=yline(par.socUPlim,'--','LineWidth',3);
yl2.Color = [0.8500, 0.3250, 0.0980];
yl2.Interpreter = 'latex';
yl2.Label = '$SoC_{max}$';
yl2.LabelVerticalAlignment = 'bottom';
yl2.LabelHorizontalAlignment = 'left';
yl2.FontSize = 12;


yyaxis right;
p3=plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);
%     p3=plot(ttData.time(t_start : t_end),iVecLoad,'-k','LineWidth',1);
%     p4=plot(ttData.time(t_start : t_end),iVecWndPwr,'--k','LineWidth',1);
hold off;

myFigs.netLoadSoC.ax = gca;
myFigs.netLoadSoC.h = [p1;p2;p3];

myFigs.netLoadSoC.ax.XLabel.Interpreter = 'latex';
myFigs.netLoadSoC.ax.XLabel.String ='Date';
myFigs.netLoadSoC.ax.XLabel.Color = 'black';
myFigs.netLoadSoC.ax.XLabel.FontSize  = 12;
myFigs.netLoadSoC.ax.XLabel.FontName = 'Times New Roman';
%         myFigs.netLoadSoC.ax.FontSize  = 12;
myFigs.netLoadSoC.ax.FontName = 'Times New Roman';
%         myFigs.netLoadSoC.ax.XLim = [0,max(sim4Opt(1,1).tout)+dt];
%         myFigs.netLoadSoC.ax.XTick = (0:1:max(sim4Opt(1,1).tout)+dt);

myFigs.netLoadSoC.ax.XAxis.Label.Interpreter = 'latex';
myFigs.netLoadSoC.ax.XAxis.FontName = 'Times New Roman';
myFigs.netLoadSoC.ax.XAxis.FontSize  = 12;
myFigs.netLoadSoC.ax.XAxis.Color = 'black';
myFigs.netLoadSoC.ax.XAxis.Label.String = 'Date';
% myFigs.netLoadSoC.ax.XTick = ttCompare.plotTimes;
%     myFigs.netLoadSoC.ax.XTick = (ttCompare.plotTimes(1):hours(6):ttCompare.plotTimes(end));
myFigs.netLoadSoC.ax.XLabel.Color = 'black';
myFigs.netLoadSoC.ax.XLabel.FontSize  = 12;
myFigs.netLoadSoC.ax.XLabel.FontName = 'Times New Roman';
myFigs.netLoadSoC.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];

myFigs.netLoadSoC.ax.YAxis(1).Label.Interpreter = 'latex';
myFigs.netLoadSoC.ax.YAxis(1).Label.String ='SoC';
myFigs.netLoadSoC.ax.YAxis(1).Color = 'black';
myFigs.netLoadSoC.ax.YAxis(1).FontSize  = 12;
myFigs.netLoadSoC.ax.YAxis(1).FontName = 'Times New Roman';
%         myFigs.netLoadSoC.ax.YAxis(1).TickValues  = (-param.Usat*0.5:0.1:param.Usat*0.5);

myFigs.netLoadSoC.ax.YAxis(2).Label.Interpreter = 'latex';
myFigs.netLoadSoC.ax.YAxis(2).Label.String ='Net Load [MW]';
myFigs.netLoadSoC.ax.YAxis(2).Color = 'black';
myFigs.netLoadSoC.ax.YAxis(2).FontSize  = 12;
myFigs.netLoadSoC.ax.YAxis(2).FontName = 'Times New Roman';

myFigs.netLoadSoC.ax.XGrid = 'on';
myFigs.netLoadSoC.ax.YGrid = 'on';

%     myFigs.netLoadSoC.ax.Title.String = 'GT power';
%     myFigs.netLoadSoC.ax.YAxis.Label.Interpreter = 'latex';
%     myFigs.netLoadSoC.ax.YAxis.Label.String ='[MW]';
%     myFigs.netLoadSoC.ax.YAxis.Color = 'black';
%     myFigs.netLoadSoC.ax.XGrid = 'on';
%     myFigs.netLoadSoC.ax.YGrid = 'on';
%     % myFigs.pwr.ax.YAxis.FontSize  = 18;
%     myFigs.netLoadSoC.ax.YAxis.FontName = 'Times New Roman';
% %     myFigs.pwr.ax.YLim = [0,1];

legend(myFigs.netLoadSoC.h,{'mean','scn', 'net load'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',3,'interpreter','latex','Location','northwest');
%% \\\\\\\\\\\\\\\\\PLOT 2: total GT power (scn & mean)\\\\\\\\\\\\\\\\\\\

myFigs.gtPwrTot.figWidth = 7; myFigs.gtPwrTot.figHeight = 5;
myFigs.gtPwrTot.figBottomLeftX0 = 2; myFigs.gtPwrTot.figBottomLeftY0 =2;
myFigs.gtPwrTot.fig = figure('Name','gtPwrTot','NumberTitle','off','Units','inches',...
    'Position',[myFigs.gtPwrTot.figBottomLeftX0 myFigs.gtPwrTot.figBottomLeftY0 myFigs.gtPwrTot.figWidth myFigs.gtPwrTot.figHeight],...
    'PaperPositionMode','auto');
%      setup.NO_ESS.iVecDmpPwr     = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iVecGTAPwr     = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iVecGTBPwr     = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iVecGTCPwr     = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iVecGTDPwr     = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iVecDmpPwrTrue = zeros(idx_end - idx_start + 1,1);
%     setup.NO_ESS.iAllGTstates   = zeros(idx_end - idx_start + 1,1);


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
    %         setup.NO_ESS.iVecLoad(i)   = RSLT.NO_ESS.rslt.xi(i).L(1,1);
    %         setup.NO_ESS.iVecWndPwr(i) = RSLT.NO_ESS.rslt.xi(i).W(1,1);
    %         setup.NO_ESS.iVecDmpPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_dump(1,:));
    %         setup.NO_ESS.iVecGTAPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.NO_ESS.x(2,i) + RSLT.NO_ESS.u_0(3,i) - RSLT.NO_ESS.u_0(4,i));
    %         setup.NO_ESS.iVecGTBPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.NO_ESS.x(3,i) + RSLT.NO_ESS.u_0(5,i) - RSLT.NO_ESS.u_0(6,i));
    %         setup.NO_ESS.iVecGTCPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.NO_ESS.x(4,i) + RSLT.NO_ESS.u_0(7,i) - RSLT.NO_ESS.u_0(8,i));
    %         setup.NO_ESS.iVecGTDPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.NO_ESS.x(5,i) + RSLT.NO_ESS.u_0(9,i) - RSLT.NO_ESS.u_0(10,i));
    %
    %         setup.NO_ESS.iVecDmpPwrTrue(i) = setup.NO_ESS.iVecGTAPwr(i)+setup.NO_ESS.iVecGTBPwr(i)+setup.NO_ESS.iVecGTCPwr(i)+setup.NO_ESS.iVecGTDPwr(i) - ...
    %                             (RSLT.NO_ESS.u_0(1,i) - RSLT.NO_ESS.u_0(2,i)) - (setup.NO_ESS.iVecLoad(i)-setup.NO_ESS.iVecWndPwr(i));
    %
    %         setup.NO_ESS.iAllGTstates(i) = RSLT.NO_ESS.x(2,i) + RSLT.NO_ESS.x(3,i) + RSLT.NO_ESS.x(3,i) +RSLT.NO_ESS.x(4,i);
    
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

%     GTpowNoESS = setup.NO_ESS.iVecGTAPwr + setup.NO_ESS.iVecGTBPwr + setup.NO_ESS.iVecGTCPwr + setup.NO_ESS.iVecGTDPwr;
GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

%     plot(ttData.time(t_start : t_end),GTpowNoESS,'--k','LineWidth',1.5);
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
%% SELECT SPECIFIT t TO PLOT SCENARIO FORECASTS
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