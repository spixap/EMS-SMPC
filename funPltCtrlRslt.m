function  funPltCtrlRslt(par, ttData, t_start, t_end, x, u_0, rslt)
%funPltCtrlRslt To plot the MPC states evolution and control effort
%   To plot the MPC states evolution and control effort

    % STATES
    myFigs.states.figWidth = 7; myFigs.states.figHeight = 5;
    myFigs.states.figBottomLeftX0 = 2; myFigs.states.figBottomLeftY0 =2;
    myFigs.states.fig = figure('Name',['States from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.states.figBottomLeftX0 myFigs.states.figBottomLeftY0 myFigs.states.figWidth myFigs.states.figHeight],...
    'PaperPositionMode','auto');

    subplot(2,1,1);
    myFigs.states.ax = gca;
    hold on;
%     plt = plot(ttData.time(t_start : t_end +1),x(:,1:end),'LineWidth',1.5);
    plt = plot(ttData.time(t_start : t_end),x(:,1:end-1),'LineWidth',1.5);

    scatter(ttData.time(t_start : t_end),x(2,1:end-1),80,'o','filled',...
        'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0 0 0],'MarkerFaceAlpha',0.5);
    scatter(ttData.time(t_start : t_end),x(3,1:end-1),100,'s','filled',...
        'MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor',[0 0 0],'MarkerFaceAlpha',0.5);
    scatter(ttData.time(t_start : t_end),x(4,1:end-1),100,'^','filled',...
        'MarkerFaceColor',[0.4940 0.1840 0.5560],'MarkerEdgeColor',[0 0 0],'MarkerFaceAlpha',0.5);
    scatter(ttData.time(t_start : t_end),x(5,1:end-1),100,'v','filled',...
        'MarkerFaceColor',[0.4660 0.6740 0.1880],'MarkerEdgeColor',[0 0 0],'MarkerFaceAlpha',0.5);
    hold off;
    myFigs.states.ax.Title.String = 'States';
    myFigs.states.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.YAxis.Label.String ='[p.u.]';
    myFigs.states.ax.YAxis.Color = 'black';
    % myFigs.states.ax.YAxis.FontSize  = 18;
    myFigs.states.ax.YAxis.FontName = 'Times New Roman';
    myFigs.states.ax.YLim = [0,1];
    myFigs.states.ax.XGrid = 'on';
    myFigs.states.ax.YGrid = 'on';
    legend(plt,{'SoC','GT A','GT B','GT C','GT D'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',6,'interpreter','latex','Location','northeast');


    subplot(2,1,2);
    myFigs.states.ax = gca;
    hold on;
%     plot(ttData.time(t_start : t_end),u_0(1,1:end)./par.P_bat_max,'.-g', 'MarkerSize',30,'LineWidth',1.3);
%     plot(ttData.time(t_start : t_end),u_0(2,1:end)./par.P_bat_max,'.-r', 'MarkerSize',30,'LineWidth',1.3);
    stem(ttData.time(t_start : t_end),u_0(1,1:end)./par.P_bat_max,'Color','g','LineStyle','-','MarkerFaceColor','green',...
         'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',6);
    stem(ttData.time(t_start : t_end),-u_0(2,1:end)./par.P_bat_max,'Color','r','LineStyle','-','MarkerFaceColor','red',...
         'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',6);
%     plot(ttData.time(t_start : t_end),(u_0(1,1:end) * par.eta_ch - u_0(2,1:end)./par.eta_dis)./par.P_bat_max,'.--k', 'MarkerSize',30,'LineWidth',1.5);
    plot(ttData.time(t_start : t_end),(u_0(1,1:end) * par.eta_ch - u_0(2,1:end)./par.eta_dis)./par.P_bat_max,'k','LineWidth',1.2);
    hold off;
    myFigs.states.ax.Title.String = 'ESS';
    myFigs.states.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.YAxis.Label.String ='[p.u.]';
    myFigs.states.ax.YAxis.Color = 'black';
    % myFigs.states.ax.YAxis.FontSize  = 18;
    myFigs.states.ax.YAxis.FontName = 'Times New Roman';
    myFigs.states.ax.YLim = [-1,1];
%     myFigs.states.ax.YLim = [0,1];

    myFigs.states.ax.XGrid = 'on';
    myFigs.states.ax.YGrid = 'on';

    myFigs.states.ax.YTick = [-1 -0.75 -0.50 -0.25 0 0.25 0.50 0.75 1];
%     myFigs.states.ax.YTick = [0 0.25 0.50 0.75 1];
    legend(myFigs.states.ax,{'Charging Power', 'Discharging Power', 'ESS Power'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');


    % ACTUATION
    myFigs.statusGT.figWidth = 7; myFigs.statusGT.figHeight = 5;
    myFigs.statusGT.figBottomLeftX0 = 2; myFigs.statusGT.figBottomLeftY0 =2;
    myFigs.statusGT.fig = figure('Name',['GT status from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.statusGT.figBottomLeftX0 myFigs.statusGT.figBottomLeftY0 myFigs.statusGT.figWidth myFigs.statusGT.figHeight],...
    'PaperPositionMode','auto');

    subplot(2,2,1);
    myFigs.statusGT.ax = gca;
    hold on;
    stem(ttData.time(t_start : t_end),u_0(3,1:end),'Color','g','LineStyle','-','MarkerFaceColor','green',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    stem(ttData.time(t_start : t_end),u_0(4,1:end),'Color','r','LineStyle','-','MarkerFaceColor','red',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    hold off;
    myFigs.statusGT.ax.Title.String = 'GT A';
    myFigs.statusGT.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.statusGT.ax.YAxis.Label.String ='[-]';
    myFigs.statusGT.ax.YAxis.Color = 'black';
    myFigs.statusGT.ax.XGrid = 'on';
    myFigs.statusGT.ax.YGrid = 'on';
    % myFigs.statusGT.ax.YAxis.FontSize  = 18;
    myFigs.statusGT.ax.YAxis.FontName = 'Times New Roman';
    myFigs.statusGT.ax.YLim = [0,1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');


    subplot(2,2,2);
    myFigs.statusGT.ax = gca;
    hold on;
    stem(ttData.time(t_start : t_end),u_0(5,1:end),'Color','g','LineStyle','-','MarkerFaceColor','green',...
        'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    stem(ttData.time(t_start : t_end),u_0(6,1:end),'Color','r','LineStyle','-','MarkerFaceColor','red',...
        'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    hold off;
    myFigs.statusGT.ax.Title.String = 'GT B';
    myFigs.statusGT.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.statusGT.ax.YAxis.Label.String ='[-]';
    myFigs.statusGT.ax.YAxis.Color = 'black';
    myFigs.statusGT.ax.XGrid = 'on';
    myFigs.statusGT.ax.YGrid = 'on';
    % myFigs.statusGT.ax.YAxis.FontSize  = 18;
    myFigs.statusGT.ax.YAxis.FontName = 'Times New Roman';
    myFigs.statusGT.ax.YLim = [0,1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');

    subplot(2,2,3);
    myFigs.statusGT.ax = gca;
    hold on;
    stem(ttData.time(t_start : t_end),u_0(7,1:end),'Color','g','LineStyle','-','MarkerFaceColor','green',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    stem(ttData.time(t_start : t_end),u_0(8,1:end),'Color','r','LineStyle','-','MarkerFaceColor','red',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    hold off;
    myFigs.statusGT.ax.Title.String = 'GT C';
    myFigs.statusGT.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.statusGT.ax.YAxis.Label.String ='[-]';
    myFigs.statusGT.ax.YAxis.Color = 'black';
    myFigs.statusGT.ax.XGrid = 'on';
    myFigs.statusGT.ax.YGrid = 'on';
    % myFigs.statusGT.ax.YAxis.FontSize  = 18;
    myFigs.statusGT.ax.YAxis.FontName = 'Times New Roman';
    myFigs.statusGT.ax.YLim = [0,1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');

    subplot(2,2,4);
    myFigs.statusGT.ax = gca;
    hold on;
    stem(ttData.time(t_start : t_end),u_0(9,1:end),'Color','g','LineStyle','-','MarkerFaceColor','green',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    stem(ttData.time(t_start : t_end),u_0(10,1:end),'Color','r','LineStyle','-','MarkerFaceColor','red',...
     'MarkerEdgeColor','black','LineWidth',1.5,'MarkerSize',8);
    hold off;
    myFigs.statusGT.ax.Title.String = 'GT D';
    myFigs.statusGT.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.statusGT.ax.YAxis.Label.String ='[-]';
    myFigs.statusGT.ax.YAxis.Color = 'black';
    myFigs.statusGT.ax.XGrid = 'on';
    myFigs.statusGT.ax.YGrid = 'on';
    % myFigs.statusGT.ax.YAxis.FontSize  = 18;
    myFigs.statusGT.ax.YAxis.FontName = 'Times New Roman';
    myFigs.statusGT.ax.YLim = [0,1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');
    
    iVecLoad       = zeros(par.N_steps + 1,1);
    iVecWndPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwr     = zeros(par.N_steps + 1,1);
    iVecGTAPwr     = zeros(par.N_steps + 1,1);
    iVecGTBPwr     = zeros(par.N_steps + 1,1);
    iVecGTCPwr     = zeros(par.N_steps + 1,1);
    iVecGTDPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwrTrue = zeros(par.N_steps + 1,1);



    % POWERs
    for i = 1 : par.N_steps + 1
        iVecLoad(i)   = rslt.xi(i).L(1,1);
        iVecWndPwr(i) = rslt.xi(i).W(1,1);
        iVecDmpPwr(i) = mean(rslt.sol(i).Power_dump(1,:));
        iVecGTAPwr(i) = mean(rslt.sol(i).Power_GT(1,:,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
        iVecGTBPwr(i) = mean(rslt.sol(i).Power_GT(1,:,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
        iVecGTCPwr(i) = mean(rslt.sol(i).Power_GT(1,:,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
        iVecGTDPwr(i) = mean(rslt.sol(i).Power_GT(1,:,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));

        iVecDmpPwrTrue(i) = iVecGTAPwr(i)+iVecGTBPwr(i)+iVecGTCPwr(i)+iVecGTDPwr(i) - ...
                            (u_0(1,i) - u_0(2,i)) - (iVecLoad(i)-iVecWndPwr(i));

    end

    
    
    myFigs.pwr.figWidth = 7; myFigs.pwr.figHeight = 5;
    myFigs.pwr.figBottomLeftX0 = 2; myFigs.pwr.figBottomLeftY0 =2;
    myFigs.pwr.fig = figure('Name',['Powers from t = ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.pwr.figBottomLeftX0 myFigs.pwr.figBottomLeftY0 myFigs.pwr.figWidth myFigs.pwr.figHeight],...
    'PaperPositionMode','auto');

    subplot(2,1,1);
    myFigs.pwr.ax = gca;
    hold on;
%     plot(ttData.time(t_start : t_end),iVecLoad,'.-r','LineWidth',1, 'MarkerSize',30);
%     plot(ttData.time(t_start : t_end),iVecWndPwr,'.-g','LineWidth',1, 'MarkerSize',30);
%     plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'.-k','LineWidth',1.5, 'MarkerSize',30);
%     plot(ttData.time(t_start : t_end),iVecDmpPwrTrue ,'.-m','LineWidth',1.5, 'MarkerSize',30);
    plot(ttData.time(t_start : t_end),iVecLoad,'-r','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-g','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),iVecDmpPwrTrue ,'-m','LineWidth',1.5);
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
    legend(myFigs.pwr.ax,{'Load', 'Wind Power', 'Net Load', 'Dump Power'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');


    subplot(2,1,2);
    myFigs.pwr.ax = gca;
    hold on;
    plot(ttData.time(t_start : t_end),iVecGTAPwr,'LineWidth',1.2,'Color',[0.8500 0.3250 0.0980],'Marker','o',...
        'MarkerSize',5,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[0 0 0]);
    plot(ttData.time(t_start : t_end),iVecGTBPwr,'LineWidth',1.2,'Color',[0.9290 0.6940 0.1250],'Marker','s',...
        'MarkerSize',5,'MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor',[0 0 0]);
    plot(ttData.time(t_start : t_end),iVecGTCPwr,'LineWidth',1.2,'Color',[0.4940 0.1840 0.5560],'Marker','^',...
        'MarkerSize',5,'MarkerFaceColor',[0.4940 0.1840 0.5560],'MarkerEdgeColor',[0 0 0]);
    plot(ttData.time(t_start : t_end),iVecGTDPwr ,'LineWidth',1.2,'Color',[0.4660 0.6740 0.1880],'Marker','v',...
        'MarkerSize',5,'MarkerFaceColor',[0.4660 0.6740 0.1880],'MarkerEdgeColor',[0 0 0]);
    hold off;

    myFigs.pwr.ax.Title.String = 'GT power';
    myFigs.pwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.pwr.ax.YAxis.Label.String ='[MW]';
    myFigs.pwr.ax.YAxis.Color = 'black';
    myFigs.pwr.ax.XGrid = 'on';
    myFigs.pwr.ax.YGrid = 'on';
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.pwr.ax.YAxis.FontName = 'Times New Roman';
%     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.pwr.ax,{'GT A', 'GT B', 'GT C', 'GT D'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');
    
    
    
    myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
    myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
    myFigs.netLoadSoC.fig = figure('Name',['SoC = f(netLoad) from : ',datestr(ttData.time(t_start))],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.netLoadSoC.figBottomLeftX0 myFigs.netLoadSoC.figBottomLeftY0 myFigs.netLoadSoC.figWidth myFigs.netLoadSoC.figHeight],...
    'PaperPositionMode','auto');

    hold on;
    p1=plot(ttData.time(t_start : t_end),x(1,1:end-1),'LineWidth',1.5);
    
    yl1=yline(par.socDOWNlim,'--r','LineWidth',3);
    yl1.Interpreter = 'latex';
    yl1.Label = '$SoC_{min}$';
    yl1.LabelVerticalAlignment = 'bottom';
    yl1.LabelHorizontalAlignment = 'left';
    yl1.FontSize = 12;
    
    yl2=yline(par.socUPlim,'--r','LineWidth',3);
    yl2.Interpreter = 'latex';
    yl2.Label = '$SoC_{max}$';
    yl2.LabelVerticalAlignment = 'top';
    yl2.LabelHorizontalAlignment = 'left';
    yl2.FontSize = 12;
    
    
    yyaxis right;
    p2=plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.2);
    hold off;
    
        myFigs.netLoadSoC.ax = gca;
        myFigs.netLoadSoC.h = [p1;p2];

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
    legend(myFigs.netLoadSoC.h,{'SoC', 'NetLoad'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','northeast');


end

