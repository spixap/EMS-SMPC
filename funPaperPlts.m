function  funPaperPlts(par, ttData, t_start, t_end, x, u_0, rslt, RSLT)
    %funPaperPlts Paper plots
    %   To plot the MPC states evolution and control effort ofr the paper
    %% \\\\\\\\\\\\\\\\\\\\\\PLOT 1: STATES\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    myFigs.states.figWidth = 7; myFigs.states.figHeight = 5;
    myFigs.states.figBottomLeftX0 = 2; myFigs.states.figBottomLeftY0 =2;
    myFigs.states.fig = figure('Name','states','NumberTitle','off','Units','inches',...
        'Position',[myFigs.states.figBottomLeftX0 myFigs.states.figBottomLeftY0 myFigs.states.figWidth myFigs.states.figHeight],...
        'PaperPositionMode','auto');
    
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

    myFigs.states.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.states.ax.YAxis.Label.String ='$\bf{x}$';
    myFigs.states.ax.YAxis.Color = 'black';
    myFigs.states.ax.YAxis.FontSize  = 12;
    myFigs.states.ax.YAxis.FontName = 'Times New Roman';
    myFigs.states.ax.YAxis.Color = 'black';
    
    myFigs.states.ax.XLabel.FontSize  = 12;
    myFigs.states.ax.XLabel.Interpreter = 'latex';
    myFigs.states.ax.XLabel.String = 'Date';
    myFigs.states.ax.XLabel.FontName = 'Times New Roman';
    myFigs.states.ax.XAxis.FontName = 'Times New Roman';
    myFigs.states.ax.XAxis.FontSize  = 12;
    
    myFigs.states.ax.YLim = [0,1];
    myFigs.states.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.states.ax.XGrid = 'on';
    myFigs.states.ax.YGrid = 'on';
    legend(plt,{'SoC','GT A','GT B','GT C','GT D'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','southwest');

    %% \\\\\\\\\\\\\\\\\\\\\\PLOT 2: BAT_PWR\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    myFigs.batPwr.figWidth = 7; myFigs.batPwr.figHeight = 5;
    myFigs.batPwr.figBottomLeftX0 = 2; myFigs.batPwr.figBottomLeftY0 =2;
    myFigs.batPwr.fig = figure('Name','batPwr','NumberTitle','off','Units','inches',...
        'Position',[myFigs.batPwr.figBottomLeftX0 myFigs.batPwr.figBottomLeftY0 myFigs.batPwr.figWidth myFigs.batPwr.figHeight],...
        'PaperPositionMode','auto');
    myFigs.batPwr.ax = gca;
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

    myFigs.batPwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.batPwr.ax.YAxis.Label.String ='Power [p.u.]';
    myFigs.batPwr.ax.YAxis.Color = 'black';
    myFigs.batPwr.ax.YAxis.FontSize  = 12;
    myFigs.batPwr.ax.YAxis.FontName = 'Times New Roman';
    myFigs.batPwr.ax.YLim = [-1,1];
    %     myFigs.batPwr.ax.YLim = [0,1];
        
    myFigs.batPwr.ax.XLabel.FontSize  = 12;
    myFigs.batPwr.ax.XLabel.Interpreter = 'latex';
    myFigs.batPwr.ax.XLabel.String = 'Date';
    myFigs.batPwr.ax.XLabel.FontName = 'Times New Roman';
    myFigs.batPwr.ax.XAxis.FontName = 'Times New Roman';
    myFigs.batPwr.ax.XAxis.FontSize  = 12;
    

    myFigs.batPwr.ax.XGrid = 'on';
    myFigs.batPwr.ax.YGrid = 'on';
    
    myFigs.batPwr.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];


    myFigs.batPwr.ax.YTick = [-1 -0.75 -0.50 -0.25 0 0.25 0.50 0.75 1];
    %     myFigs.batPwr.ax.YTick = [0 0.25 0.50 0.75 1];
    legend(myFigs.batPwr.ax,{'$P^{b,c}$', '$P^{b,d}$', '$P^{b}$'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','southwest');


    %% \\\\\\\\\\\\\\\\\\\PLOT 3: GT ON/OFF CMD\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    myFigs.statusGT.figWidth = 7; myFigs.statusGT.figHeight = 5;
    myFigs.statusGT.figBottomLeftX0 = 2; myFigs.statusGT.figBottomLeftY0 =2;
    myFigs.statusGT.fig = figure('Name','gtStatus','NumberTitle','off','Units','inches',...
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
    myFigs.statusGT.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.statusGT.ax.YLim = [0,1];
    myFigs.statusGT.ax.YTick = [0 1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

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
    
    myFigs.statusGT.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.statusGT.ax.YLim = [0,1];
    myFigs.statusGT.ax.YTick = [0 1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

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
    myFigs.statusGT.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.statusGT.ax.YLim = [0,1];
    myFigs.statusGT.ax.YTick = [0 1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');

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
    myFigs.statusGT.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.statusGT.ax.YLim = [0,1];
    myFigs.statusGT.ax.YTick = [0 1];
    legend(myFigs.statusGT.ax,{'ON cmd', 'OFF cmd'},'FontSize',8,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');


    iVecLoad       = zeros(par.N_steps + 1,1);
    iVecWndPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwr     = zeros(par.N_steps + 1,1);
    iVecGTAPwr     = zeros(par.N_steps + 1,1);
    iVecGTBPwr     = zeros(par.N_steps + 1,1);
    iVecGTCPwr     = zeros(par.N_steps + 1,1);
    iVecGTDPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
    iVecONGTnum = zeros(par.N_steps + 1,1);


    % POWER CALCULATION
    for i = 1 : par.N_steps + 1
        iVecLoad(i)   = rslt.xi(i).L(1,1) * par.spinRes;
%         iVecLoad(i)   = rslt.xi(i).L(1,1) ;

        iVecWndPwr(i) = rslt.xi(i).W(1,1);
        iVecDmpPwr(i) = mean(rslt.sol(i).Power_dump(1,:));
        iVecGTAPwr(i) = mean(rslt.sol(i).Power_GT(1,:,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
        iVecGTBPwr(i) = mean(rslt.sol(i).Power_GT(1,:,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
        iVecGTCPwr(i) = mean(rslt.sol(i).Power_GT(1,:,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
        iVecGTDPwr(i) = mean(rslt.sol(i).Power_GT(1,:,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));

        iVecDmpPwrTrue(i) = iVecGTAPwr(i)+iVecGTBPwr(i)+iVecGTCPwr(i)+iVecGTDPwr(i) - ...
            (u_0(1,i) - u_0(2,i)) - (iVecLoad(i)-iVecWndPwr(i));
        
        iVecONGTnum(i) = RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.x(4,i) +RSLT.ESS_scn.x(5,i);

    end

    %% \\\\\\\\\\\\\PLOT 4: DISTRUBANCE (LOAD & WIND & NET LOAD)\\\\\\\\\\\\
    myFigs.dstrb.figWidth = 7; myFigs.dstrb.figHeight = 5;
    myFigs.dstrb.figBottomLeftX0 = 2; myFigs.dstrb.figBottomLeftY0 =2;
    myFigs.dstrb.fig = figure('Name','disturbance','NumberTitle','off','Units','inches',...
        'Position',[myFigs.dstrb.figBottomLeftX0 myFigs.dstrb.figBottomLeftY0 myFigs.dstrb.figWidth myFigs.dstrb.figHeight],...
        'PaperPositionMode','auto');

    %     subplot(2,1,1);
    myFigs.dstrb.ax = gca;
    hold on;
%     plot(ttData.time(t_start : t_end),iVecLoad,'-r','LineWidth',1);
%     plot(ttData.time(t_start : t_end),iVecWndPwr,'-g','LineWidth',1);
%     plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);
%     plot(ttData.time(t_start : t_end),iVecDmpPwrTrue ,'-m','LineWidth',1.5);
    plot(ttData.time(t_start : t_end),iVecLoad,'--k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-.k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);
%     plot(ttData.time(t_start : t_end),iVecDmpPwrTrue ,'-m','LineWidth',1.5);
    hold off;
%     myFigs.dstrb.ax.Title.String = 'Net Load and Dumped power';
    myFigs.dstrb.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.dstrb.ax.YAxis.Label.String ='Power [MW]';
    myFigs.dstrb.ax.YAxis.Color = 'black';
    myFigs.dstrb.ax.YLabel.FontSize  = 12;
    myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.YAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XLabel.FontSize  = 12;
    myFigs.dstrb.ax.XLabel.Interpreter = 'latex';
    myFigs.dstrb.ax.XLabel.String = 'Date';
    myFigs.dstrb.ax.XLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XGrid = 'on';
    myFigs.dstrb.ax.YGrid = 'on';
    myFigs.dstrb.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.dstrb.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.dstrb.ax,{'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northwest');
    
     %% \\\\\\\PLOT 4b: DISTRUBANCE (LOAD & WIND & NET LOAD) with GT area patches\\\\\\\\\
    myFigs.dstrb.figWidth = 7; myFigs.dstrb.figHeight = 5;
    myFigs.dstrb.figBottomLeftX0 = 2; myFigs.dstrb.figBottomLeftY0 =2;
    myFigs.dstrb.fig = figure('Name','disturbance_gtAreas','NumberTitle','off','Units','inches',...
        'Position',[myFigs.dstrb.figBottomLeftX0 myFigs.dstrb.figBottomLeftY0 myFigs.dstrb.figWidth myFigs.dstrb.figHeight],...
        'PaperPositionMode','auto');

   
    myFigs.dstrb.ax = gca;
    hold on;

    plot(ttData.time(t_start : t_end),iVecLoad,'--k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-.k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);

    x_patch = [0 2 2 0];
%     y_patch_0 = [min(iVecLoad-iVecWndPwr) min(iVecLoad-iVecWndPwr) 0 0];
%     y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
%     y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
%     y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max 3*par.P_gt_max 3*par.P_gt_max];
%     y_patch_4 = [3*par.P_gt_max 3*par.P_gt_max 4*par.P_gt_max 4*par.P_gt_max];

if min((iVecLoad-iVecWndPwr)) < 0
    y_patch_0 = [min((iVecLoad-iVecWndPwr)) min((iVecLoad-iVecWndPwr)) 0 0];
    x_patch_0 = x_patch;
else
    y_patch_0 = [];
    x_patch_0 = [];
end 

    
    if max(iVecLoad) >= 3*par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
        y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max 3*par.P_gt_max 3*par.P_gt_max];
        y_patch_4 = [3*par.P_gt_max 3*par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
    
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_4,'magenta','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT','3 GT','4 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT','3 GT','4 GT'};
        end

        colNum = 4;
        
    elseif max(iVecLoad) >= 2*par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
        y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT','3 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT','3 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= 0
        
        y_patch_1 = [0 0 max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT'};
        end
        
        colNum = 2;
    else
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT'};
        end
        
        colNum = 2;
    end

    
    hold off;
    myFigs.dstrb.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.dstrb.ax.YAxis.Label.String ='Power [MW]';
    myFigs.dstrb.ax.YAxis.Color = 'black';
    myFigs.dstrb.ax.YLabel.FontSize  = 12;
    myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.YAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XLabel.FontSize  = 12;
    myFigs.dstrb.ax.XLabel.Interpreter = 'latex';
    myFigs.dstrb.ax.XLabel.String = 'Date';
    myFigs.dstrb.ax.XLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XGrid = 'on';
    myFigs.dstrb.ax.YGrid = 'on';
    myFigs.dstrb.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
    myFigs.dstrb.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.pwr.ax.YLim = [0,1];
    legend(myFigs.dstrb.ax,lgdCell,'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',colNum,'interpreter','latex','Location','northwest');

    %% \\\\\\\PLOT 4c: DISTRUBANCE (LOAD & WIND & NET LOAD) with GT area patches and No of GTs ON \\\\\\\\\
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
    
    
    
    myFigs.dstrb.figWidth = 7; myFigs.dstrb.figHeight = 5;
    myFigs.dstrb.figBottomLeftX0 = 2; myFigs.dstrb.figBottomLeftY0 =2;
    myFigs.dstrb.fig = figure('Name','disturbance_gtAreas_gtNum','NumberTitle','off','Units','inches',...
        'Position',[myFigs.dstrb.figBottomLeftX0 myFigs.dstrb.figBottomLeftY0 myFigs.dstrb.figWidth myFigs.dstrb.figHeight],...
        'PaperPositionMode','auto');

   
    myFigs.dstrb.ax = gca;
    hold on;

    plot(ttData.time(t_start : t_end),iVecLoad,'--k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-.k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);

    x_patch = [0 2 2 0];
%     y_patch_0 = [min(iVecLoad-iVecWndPwr) min(iVecLoad-iVecWndPwr) 0 0];
%     y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
%     y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
%     y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max 3*par.P_gt_max 3*par.P_gt_max];
%     y_patch_4 = [3*par.P_gt_max 3*par.P_gt_max 4*par.P_gt_max 4*par.P_gt_max];

if min((iVecLoad-iVecWndPwr)) < 0
    y_patch_0 = [min((iVecLoad-iVecWndPwr)) min((iVecLoad-iVecWndPwr)) 0 0];
    x_patch_0 = x_patch;
else
    y_patch_0 = [];
    x_patch_0 = [];
end 

    
    if max(iVecLoad) >= 3*par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
        y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max 3*par.P_gt_max 3*par.P_gt_max];
        y_patch_4 = [3*par.P_gt_max 3*par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
    
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_4,'magenta','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT','3 GT','4 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT','3 GT','4 GT'};
        end

        colNum = 4;
        
    elseif max(iVecLoad) >= 2*par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
        y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT','3 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT','3 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT','2 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT','2 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= 0
        
        y_patch_1 = [0 0 max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','1 GT'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT','1 GT'};
        end
        
        colNum = 2;
    else
        
        patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$'};
        else
            lgdCell = {'$P^{\ell}$', '$P^{w}$', '$P^{\ell}-P^{w}$','0 GT'};
        end
        
        colNum = 2;
    end
    
    yyaxis right;
    
    scatter(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,20,'k','+');
    scatter(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,20,'k','x');

    
    hold off;
%     myFigs.dstrb.ax.YAxis.Label.Interpreter = 'latex';
%     myFigs.dstrb.ax.YAxis.Label.String ='Power [MW]';
%     myFigs.dstrb.ax.YAxis.Color = 'black';
%     myFigs.dstrb.ax.YLabel.FontSize  = 12;
%     myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
%     myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
%     myFigs.dstrb.ax.YAxis.FontSize  = 12;
    
    
    myFigs.dstrb.ax.YAxis(1).Label.Interpreter = 'latex';
    myFigs.dstrb.ax.YAxis(1).Label.String = 'Power [MW]';
    myFigs.dstrb.ax.YAxis(1).Color = 'black';
    myFigs.dstrb.ax.YAxis(1).FontSize  = 12;
    myFigs.dstrb.ax.YAxis(1).FontName = 'Times New Roman';
    
    myFigs.dstrb.ax.YAxis(2).Label.Interpreter = 'latex';
    myFigs.dstrb.ax.YAxis(2).Label.String ='# GT on';
    myFigs.dstrb.ax.YAxis(2).Color = 'black';
    myFigs.dstrb.ax.YAxis(2).FontSize  = 12;
    myFigs.dstrb.ax.YAxis(2).FontName = 'Times New Roman';
    myFigs.dstrb.ax.YAxis(2).Limits  = [0,4];
    myFigs.dstrb.ax.YAxis(2).TickValues  = 0:1:4;
% yticks(0:1:4);
    
    
    myFigs.dstrb.ax.XLabel.FontSize  = 12;
    myFigs.dstrb.ax.XLabel.Interpreter = 'latex';
    myFigs.dstrb.ax.XLabel.String = 'Date';
    myFigs.dstrb.ax.XLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XGrid = 'on';
    myFigs.dstrb.ax.YGrid = 'on';
    myFigs.dstrb.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    % myFigs.pwr.ax.YAxis.FontSize  = 18;
%     myFigs.dstrb.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.pwr.ax.YLim = [0,1];
    
    
        legend(myFigs.dstrb.ax,[lgdCell,{'mean', 'scn'}],'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',colNum,'interpreter','latex','Location','northwest');
%     legend(myFigs.dstrb.ax,lgdCell,'FontSize',12,...
%         'Fontname','Times New Roman','NumColumns',colNum,'interpreter','latex','Location','northwest');

    %% \\\\\\\\\\\\\\\\\\\\\PLOT 5: ALL GT PWR \\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    myFigs.gtAllPwr.figWidth = 7; myFigs.gtAllPwr.figHeight = 5;
    myFigs.gtAllPwr.figBottomLeftX0 = 2; myFigs.gtAllPwr.figBottomLeftY0 =2;
    myFigs.gtAllPwr.fig = figure('Name','gtAllPwr','NumberTitle','off','Units','inches',...
        'Position',[myFigs.gtAllPwr.figBottomLeftX0 myFigs.gtAllPwr.figBottomLeftY0 myFigs.gtAllPwr.figWidth myFigs.gtAllPwr.figHeight],...
        'PaperPositionMode','auto');

    myFigs.gtAllPwr.ax = gca;
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

    myFigs.gtAllPwr.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.gtAllPwr.ax.YAxis.Label.String ='$P^{gt}\;[MW]$';
    myFigs.gtAllPwr.ax.YAxis.Color = 'black';
    myFigs.gtAllPwr.ax.YLabel.FontSize  = 12;
    myFigs.gtAllPwr.ax.YLabel.Interpreter = 'latex';
    myFigs.gtAllPwr.ax.YLabel.FontName = 'Times New Roman';
    myFigs.gtAllPwr.ax.YAxis.FontName = 'Times New Roman';
    myFigs.gtAllPwr.ax.YAxis.FontSize  = 12;
    
    myFigs.gtAllPwr.ax.XLabel.FontSize  = 12;
    myFigs.gtAllPwr.ax.XLabel.Interpreter = 'latex';
    myFigs.gtAllPwr.ax.XLabel.String = 'Date';
    myFigs.gtAllPwr.ax.XLabel.FontName = 'Times New Roman';
    myFigs.gtAllPwr.ax.XAxis.FontName = 'Times New Roman';
    myFigs.gtAllPwr.ax.XAxis.FontSize  = 12;
    
    myFigs.gtAllPwr.ax.XGrid = 'on';
    myFigs.gtAllPwr.ax.YGrid = 'on';
    myFigs.gtAllPwr.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    
    % myFigs.gtAllPwr.ax.YAxis.FontSize  = 18;
    myFigs.gtAllPwr.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.gtAllPwr.ax.YLim = [0,1];
    legend(myFigs.gtAllPwr.ax,{'GT A', 'GT B', 'GT C', 'GT D'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Location','southwest');
end