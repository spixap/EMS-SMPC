%---------------------------GENERATE RSLT PLOTS----------------------------
%%
preamble;
% load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\Period_7500_7800\rslts_gtONcst_5000.mat','RSLT');
load( '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\Results\day100.mat','RSLT');

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
%%
% par.N_steps = 576;                  % number of timesteps to simulate 576 (nice period)

 % STATES
    myFigs.states.figWidth = 7; myFigs.states.figHeight = 5;
    myFigs.states.figBottomLeftX0 = 2; myFigs.states.figBottomLeftY0 =2;
    myFigs.states.fig = figure('Name',['States from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.states.figBottomLeftX0 myFigs.states.figBottomLeftY0 myFigs.states.figWidth myFigs.states.figHeight],...
    'PaperPositionMode','auto');

    subplot(2,1,1);
    myFigs.states.ax = gca;
    hold on;
%     plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,1:end-1),'--r','LineWidth',1.5);
%     plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,1:end-1),'b','LineWidth',1.2);
    plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,idx_start:idx_end),'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,idx_start:idx_end),'b','LineWidth',1.2);

    hold off;
    myFigs.states.ax.Title.String = 'SoC';
    myFigs.states.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.YAxis.Label.String ='[p.u.]';
    myFigs.states.ax.YAxis.Color = 'black';
    % myFigs.states.ax.YAxis.FontSize  = 18;
    myFigs.states.ax.YAxis.FontName = 'Times New Roman';
    myFigs.states.ax.YLim = [0,1];
    myFigs.states.ax.XGrid = 'on';
    myFigs.states.ax.YGrid = 'on';
    legend(myFigs.states.ax,{'$SoC_{mean}$','$SoC_{scn}$'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');
    
    subplot(2,1,2);
    myFigs.states.ax = gca;
    hold on;
     
    plot(ttData.time(t_start : t_end),(RSLT.ESS_mean.u_0(1,1:end) * par.eta_ch - RSLT.ESS_mean.u_0(2,1:end)./par.eta_dis)./par.P_bat_max,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),(RSLT.ESS_scn.u_0(1,1:end) * par.eta_ch - RSLT.ESS_scn.u_0(2,1:end)./par.eta_dis)./par.P_bat_max,'b','LineWidth',1.2);

    hold off;
    myFigs.states.ax.Title.String = 'ESS power';
    myFigs.states.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.YAxis.Label.String ='[p.u.]';
    myFigs.states.ax.YAxis.Color = 'black';
    % myFigs.states.ax.YAxis.FontSize  = 18;
    myFigs.states.ax.YAxis.FontName = 'Times New Roman';
    myFigs.states.ax.YLim = [-1,1];
%     myFigs.states.ax.YLim = [0,1];


    myFigs.states.ax.XAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.XAxis.FontName = 'Times New Roman';
    myFigs.states.ax.XAxis.FontSize  = 12;
    myFigs.states.ax.XAxis.Color = 'black';
    myFigs.states.ax.XAxis.Label.String = 'Date';
    % myFigs.states.ax.XTick = ttCompare.plotTimes;
%     myFigs.states.ax.XTick = (ttCompare.plotTimes(1):hours(6):ttCompare.plotTimes(end));
    myFigs.states.ax.XLabel.Color = 'black';
    myFigs.states.ax.XLabel.FontSize  = 12;
    myFigs.states.ax.XLabel.FontName = 'Times New Roman';
    myFigs.states.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];

    myFigs.states.ax.XGrid = 'on';
    myFigs.states.ax.YGrid = 'on';

    myFigs.states.ax.YTick = [-1 -0.75 -0.50 -0.25 0 0.25 0.50 0.75 1];
    legend(myFigs.states.ax,{'$P_{b}^{mean}$', '$P_{b}^{scn}$'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');
    %%
    %
    iVecLoad       = zeros(par.N_steps + 1,1);
    iVecWndPwr     = zeros(par.N_steps + 1,1);




    for i = 1 : par.N_steps + 1
        iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1);
        iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);
    end
    
    
    
    
      
    myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
    myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
    myFigs.netLoadSoC.fig = figure('Name',['SoC = f(netLoad) from : ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.netLoadSoC.figBottomLeftX0 myFigs.netLoadSoC.figBottomLeftY0 myFigs.netLoadSoC.figWidth myFigs.netLoadSoC.figHeight],...
    'PaperPositionMode','auto');

    hold on;
%     p1=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,1:end-1),'--r','LineWidth',1.5);
    p1=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.noDegrad.x(1,1:end-1),'--r','LineWidth',1.5);
    p2=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,1:end-1),'b','LineWidth',1.2);
    
    yl1=yline(par.socDOWNlim,'--y','LineWidth',3);
    yl1.Interpreter = 'latex';
    yl1.Label = '$SoC_{min}$';
    yl1.LabelVerticalAlignment = 'bottom';
    yl1.LabelHorizontalAlignment = 'left';
    yl1.FontSize = 12;
    
    yl2=yline(par.socUPlim,'--y','LineWidth',3);
    yl2.Interpreter = 'latex';
    yl2.Label = '$SoC_{max}$';
    yl2.LabelVerticalAlignment = 'top';
    yl2.LabelHorizontalAlignment = 'left';
    yl2.FontSize = 12;
    
    
    yyaxis right;
    p3=plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1);
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


% 
%     legend(myFigs.netLoadSoC.h,{'$SoC_{mean}$','$SoC_{scn}$', 'Net Load'},'FontSize',12,...
%         'Fontname','Times New Roman','NumColumns',3,'interpreter','latex','Location','northeast');
    
        legend(myFigs.netLoadSoC.h,{'$SoC_{noDeg}$','$SoC_{scn}$', 'Net Load'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',3,'interpreter','latex','Location','northeast');
  
        %% NEW
    
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

    subplot(2,1,1);
    myFigs.states.ax = gca;
    hold on;
    
    p1=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,idx_start:idx_end),'--r','LineWidth',1.5);
    p2=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,idx_start:idx_end),'b','LineWidth',1.2);
    
    yl1=yline(par.socDOWNlim,'--','LineWidth',3);
    yl1.Color = [0.8500, 0.3250, 0.0980];
    yl1.Interpreter = 'latex';
    yl1.Label = '$SoC_{min}$';
    yl1.LabelVerticalAlignment = 'bottom';
    yl1.LabelHorizontalAlignment = 'left';
    yl1.FontSize = 12;
    
    yl2=yline(par.socUPlim,'--','LineWidth',3);
    yl2.Color = [0.8500, 0.3250, 0.0980];
    yl2.Interpreter = 'latex';
    yl2.Label = '$SoC_{max}$';
    yl2.LabelVerticalAlignment = 'top';
    yl2.LabelHorizontalAlignment = 'left';
    yl2.FontSize = 12;
    
    
    yyaxis right;
%     p3=plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1);
    p3=plot(ttData.time(t_start : t_end),iVecLoad,'-k','LineWidth',1);
    p4=plot(ttData.time(t_start : t_end),iVecWndPwr,'--k','LineWidth',1);
    hold off;
    
        myFigs.netLoadSoC.ax = gca;
        myFigs.netLoadSoC.h = [p1;p2;p3;p4];

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

    legend(myFigs.netLoadSoC.h,{'mean','scn', 'ld', 'wp'},'FontSize',10,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','best');
    
    
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

    
    
    
    % setup = NO_ESS, ESS_mean, ESS_scn
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
    
    subplot(2,1,2);
    myFigs.netLoadSoC.ax = gca;
    hold on;
         
%     GTpowNoESS = setup.NO_ESS.iVecGTAPwr + setup.NO_ESS.iVecGTBPwr + setup.NO_ESS.iVecGTCPwr + setup.NO_ESS.iVecGTDPwr;
    GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
    GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

%     plot(ttData.time(t_start : t_end),GTpowNoESS,'--k','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),GTpowESSmean,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),GTpowESSscn,'--g','LineWidth',1.5);
    hold off;

    
    myFigs.netLoadSoC.ax.XLabel.Interpreter = 'latex';
    myFigs.netLoadSoC.ax.XLabel.String ='Date';
    myFigs.netLoadSoC.ax.XLabel.Color = 'black';
    myFigs.netLoadSoC.ax.XLabel.FontSize  = 12;
    myFigs.netLoadSoC.ax.XLabel.FontName = 'Times New Roman';
    myFigs.netLoadSoC.ax.XAxis.FontSize  = 12;
    myFigs.netLoadSoC.ax.FontName = 'Times New Roman';
    myFigs.netLoadSoC.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    %         myFigs.netLoadSoC.ax.XLim = [0,max(sim4Opt(1,1).tout)+dt];
    %         myFigs.netLoadSoC.ax.XTick = (0:1:max(sim4Opt(1,1).tout)+dt);


%     myFigs.netLoadSoC.ax.Title.String = 'Total GT power';
    myFigs.netLoadSoC.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.netLoadSoC.ax.YAxis.Label.String ='Total GT power [MW]';
    myFigs.netLoadSoC.ax.YAxis.Color = 'black';
    myFigs.netLoadSoC.ax.XGrid = 'on';
    myFigs.netLoadSoC.ax.YGrid = 'on';
    myFigs.netLoadSoC.ax.YAxis.FontSize  = 12;
    myFigs.netLoadSoC.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.netLoadSoC.ax,{'mean', 'scn'},'FontSize',10,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');
    
    
    %%
    
    
    setup.NO_ESS.iVecDmpPwr     = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iVecGTAPwr     = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iVecGTBPwr     = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iVecGTCPwr     = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iVecGTDPwr     = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
    setup.NO_ESS.iAllGTstates   = zeros(par.N_steps + 1,1);

    
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

    
    
    
    % setup = NO_ESS, ESS_mean, ESS_scn
    for i = 1 : par.N_steps + 1
        setup.NO_ESS.iVecLoad(i)   = RSLT.NO_ESS.rslt.xi(i).L(1,1);
        setup.NO_ESS.iVecWndPwr(i) = RSLT.NO_ESS.rslt.xi(i).W(1,1);
        setup.NO_ESS.iVecDmpPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_dump(1,:));
        setup.NO_ESS.iVecGTAPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.NO_ESS.x(2,i) + RSLT.NO_ESS.u_0(3,i) - RSLT.NO_ESS.u_0(4,i));
        setup.NO_ESS.iVecGTBPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.NO_ESS.x(3,i) + RSLT.NO_ESS.u_0(5,i) - RSLT.NO_ESS.u_0(6,i));
        setup.NO_ESS.iVecGTCPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.NO_ESS.x(4,i) + RSLT.NO_ESS.u_0(7,i) - RSLT.NO_ESS.u_0(8,i));
        setup.NO_ESS.iVecGTDPwr(i) = mean(RSLT.NO_ESS.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.NO_ESS.x(5,i) + RSLT.NO_ESS.u_0(9,i) - RSLT.NO_ESS.u_0(10,i));

        setup.NO_ESS.iVecDmpPwrTrue(i) = setup.NO_ESS.iVecGTAPwr(i)+setup.NO_ESS.iVecGTBPwr(i)+setup.NO_ESS.iVecGTCPwr(i)+setup.NO_ESS.iVecGTDPwr(i) - ...
                            (RSLT.NO_ESS.u_0(1,i) - RSLT.NO_ESS.u_0(2,i)) - (setup.NO_ESS.iVecLoad(i)-setup.NO_ESS.iVecWndPwr(i));
                        
        setup.NO_ESS.iAllGTstates(i) = RSLT.NO_ESS.x(2,i) + RSLT.NO_ESS.x(3,i) + RSLT.NO_ESS.x(3,i) +RSLT.NO_ESS.x(4,i);
                        
                        
        setup.ESS_mean.iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1);
        setup.ESS_mean.iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);
        setup.ESS_mean.iVecDmpPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_dump(1,:));
        setup.ESS_mean.iVecGTAPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.u_0(3,i) - RSLT.ESS_mean.u_0(4,i));
        setup.ESS_mean.iVecGTBPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.u_0(5,i) - RSLT.ESS_mean.u_0(6,i));
        setup.ESS_mean.iVecGTCPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_mean.x(4,i) + RSLT.ESS_mean.u_0(7,i) - RSLT.ESS_mean.u_0(8,i));
        setup.ESS_mean.iVecGTDPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_mean.x(5,i) + RSLT.ESS_mean.u_0(9,i) - RSLT.ESS_mean.u_0(10,i));

        setup.ESS_mean.iVecDmpPwrTrue(i) = setup.ESS_mean.iVecGTAPwr(i)+setup.ESS_mean.iVecGTBPwr(i)+setup.ESS_mean.iVecGTCPwr(i)+setup.ESS_mean.iVecGTDPwr(i) - ...
                            (RSLT.ESS_mean.u_0(1,i) - RSLT.ESS_mean.u_0(2,i)) - (setup.ESS_mean.iVecLoad(i)-setup.ESS_mean.iVecWndPwr(i));
                        
        setup.ESS_mean.iAllGTstates(i) = RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.x(3,i) +RSLT.ESS_mean.x(4,i);

                        
                        
        setup.ESS_scn.iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(i).L(1,1);
        setup.ESS_scn.iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(i).W(1,1);
        setup.ESS_scn.iVecDmpPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_dump(1,:));
        setup.ESS_scn.iVecGTAPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.u_0(3,i) - RSLT.ESS_scn.u_0(4,i));
        setup.ESS_scn.iVecGTBPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.u_0(5,i) - RSLT.ESS_scn.u_0(6,i));
        setup.ESS_scn.iVecGTCPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_scn.x(4,i) + RSLT.ESS_scn.u_0(7,i) - RSLT.ESS_scn.u_0(8,i));
        setup.ESS_scn.iVecGTDPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_scn.x(5,i) + RSLT.ESS_scn.u_0(9,i) - RSLT.ESS_scn.u_0(10,i));

        setup.ESS_scn.iVecDmpPwrTrue(i) = setup.ESS_scn.iVecGTAPwr(i)+setup.ESS_scn.iVecGTBPwr(i)+setup.ESS_scn.iVecGTCPwr(i)+setup.ESS_scn.iVecGTDPwr(i) - ...
                            (RSLT.ESS_scn.u_0(1,i) - RSLT.ESS_scn.u_0(2,i)) - (setup.ESS_scn.iVecLoad(i)-setup.ESS_scn.iVecWndPwr(i));
                        
        setup.ESS_scn.iAllGTstates(i) = RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.x(3,i) +RSLT.ESS_scn.x(4,i);

    end  
 
    myFigs.pwr.figWidth = 7; myFigs.pwr.figHeight = 5;
    myFigs.pwr.figBottomLeftX0 = 2; myFigs.pwr.figBottomLeftY0 =2;
    myFigs.pwr.fig = figure('Name',['Powers from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.pwr.figBottomLeftX0 myFigs.pwr.figBottomLeftY0 myFigs.pwr.figWidth myFigs.pwr.figHeight],...
    'PaperPositionMode','auto');

    subplot(3,1,1);
    myFigs.pwr.ax = gca;
    hold on;
    
%     plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-m','LineWidth',1);
    plot(ttData.time(t_start : t_end),setup.NO_ESS.iVecDmpPwrTrue ,'--k','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_mean.iVecDmpPwrTrue ,'-r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_scn.iVecDmpPwrTrue ,'--g','LineWidth',1.5);

    hold off;
    myFigs.pwr.ax.Title.String = 'Net Load and Dumped power';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='[MW]';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'No ESS Dumping', 'ESS mean Dumping', 'ESS scn Dumping'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');


    
    
    subplot(3,1,2);
    myFigs.pwr.ax = gca;
    hold on;
    
    GTpowNoESS = setup.NO_ESS.iVecGTAPwr + setup.NO_ESS.iVecGTBPwr + setup.NO_ESS.iVecGTCPwr + setup.NO_ESS.iVecGTDPwr;
    GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
    GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

    plot(ttData.time(t_start : t_end),GTpowNoESS,'--k','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),GTpowESSmean,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),GTpowESSscn,'--g','LineWidth',1.5);
    hold off;

    myFigs.pwr.ax.Title.String = 'Total GT power';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='[MW]';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'No ESS', 'ESS mean', 'ESS scn'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');
    
    subplot(3,1,3);
    myFigs.pwr.ax = gca;
    hold on;
    
    plot(ttData.time(t_start : t_end),setup.NO_ESS.iAllGTstates,'--k','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,'--g','LineWidth',1.5);
    hold off;

    myFigs.pwr.ax.Title.String = 'GT states';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='No. of GT ON';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'No ESS', 'ESS mean', 'ESS scn'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');
        %%
    
   
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

    
    
    
    % setup = NO_ESS, ESS_mean, ESS_scn
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
 
    myFigs.pwr.figWidth = 7; myFigs.pwr.figHeight = 5;
    myFigs.pwr.figBottomLeftX0 = 2; myFigs.pwr.figBottomLeftY0 =2;
    myFigs.pwr.fig = figure('Name',['Powers from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.pwr.figBottomLeftX0 myFigs.pwr.figBottomLeftY0 myFigs.pwr.figWidth myFigs.pwr.figHeight],...
    'PaperPositionMode','auto');

    subplot(3,1,1);
    myFigs.pwr.ax = gca;
    hold on;
    

    plot(ttData.time(t_start : t_end),setup.ESS_mean.iVecDmpPwrTrue ,'-r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_scn.iVecDmpPwrTrue ,'--g','LineWidth',1.5);

    hold off;
    myFigs.pwr.ax.Title.String = 'Net Load and Dumped power';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='[MW]';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'ESS mean Dumping', 'ESS scn Dumping'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');


    
    
    subplot(3,1,2);
    myFigs.pwr.ax = gca;
    hold on;
    
    GTpowESSmean = setup.ESS_mean.iVecGTAPwr + setup.ESS_mean.iVecGTBPwr + setup.ESS_mean.iVecGTCPwr + setup.ESS_mean.iVecGTDPwr;
    GTpowESSscn = setup.ESS_scn.iVecGTAPwr + setup.ESS_scn.iVecGTBPwr + setup.ESS_scn.iVecGTCPwr + setup.ESS_scn.iVecGTDPwr;

% GTpowESSmean = setup.ESS_mean.iVecGTCPwr;
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

    plot(ttData.time(t_start : t_end),GTpowESSmean,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),GTpowESSscn,'--g','LineWidth',1.5);
    hold off;

    myFigs.pwr.ax.Title.String = 'Total GT power';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='[MW]';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'ESS mean', 'ESS scn'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');
    
    subplot(3,1,3);
    myFigs.pwr.ax = gca;
    hold on;
    
    plot(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,'--r','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,'--g','LineWidth',1.5);
    hold off;

    myFigs.pwr.ax.Title.String = 'GT states';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='No. of GT ON';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'ESS mean', 'ESS scn'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');
    %%
    t_slct = find(ttData.time==datetime('21-Mar-2019 12:30:00'));
    myFigtitle = [varNameTitle,'frcst_t_',num2str(t_slct)];
    funFrcstFig1step(ttData, par, Data, t_slct, Mdl, varName, myFigtitle);
%     tempXI = RSLT.ESS_scn.rslt.xi(t_slct-t_current+1).L;
    tempXI = RSLT.ESS_scn.rslt.xi(t_slct-t_current+1).W;
    hold on;plot(ttData.time(t_slct : t_slct+5),tempXI)
    %%
    
    par.N_steps = 30;
%     funScenGenQRF(ttData, par, Data_ld, 7630, Mdl_ld, [], 1)
    funScenGenQRF(ttData, par, Data_wp, 7630, Mdl_wp, [], 1)