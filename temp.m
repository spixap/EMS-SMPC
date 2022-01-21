open('example.fig');
a = get(gca,'Children');
xdata = get(a, 'XData');
ydata = get(a, 'YData');
zdata = get(a, 'ZData');
%%
    %% FIGURE: COMPARE RESULTS
    myFigs.crps.figWidth = 7; myFigs.crps.figHeight = 6;
    myFigs.crps.figBottomLeftX0 = 2; myFigs.crps.figBottomLeftY0 =2;
    myFigs.crps.fig = figure('Name',['crps_',varNameTitle],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.crps.figBottomLeftX0 myFigs.crps.figBottomLeftY0 myFigs.crps.figWidth myFigs.crps.figHeight],...
    'PaperPositionMode','auto');

    str_k = cell(1,12);
    for k = 1 : par.N_prd
        str_k{k} = ['t+',num2str(k)];
    end

    myFigs.crps.ax = gca;
    myFigs.crps.p1 = plot(xdata{2},ydata{2},'--sk','Linewidth',1.6);
    hold on;
    myFigs.crps.p2 = plot(xdata{1},ydata{1},'--sr','Linewidth',1.2);
    hold off;

    myFigs.crps.ax.XAxis.Label.Interpreter = 'latex';
    myFigs.crps.ax.XTick = xdata{1};
    myFigs.crps.ax.XLim = [1 12];
    myFigs.crps.ax.XTickLabel = str_k;
    myFigs.crps.ax.XAxis.FontSize  = 20;
    myFigs.crps.ax.XLabel.FontSize  = 20;
    myFigs.crps.ax.XTickLabelRotation = 45;



    myFigs.crps.ax.TickLabelInterpreter  = 'latex';

    myFigs.crps.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.crps.ax.YAxis.Label.String = 'CRPS [\%]';
    myFigs.crps.ax.YAxis.Color = 'black';
    myFigs.crps.ax.YAxis.FontSize  = 20;
    myFigs.crps.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.crps.ax.YLim = [0,1];

    myFigs.crps.ax.XGrid = 'on';
%     myFigs.crps.ax.YGrid = 'on';

    legend(myFigs.crps.ax,{'QRF','CH-PeEn'},'FontSize',20,'Box', 'off','color','none',...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','best');