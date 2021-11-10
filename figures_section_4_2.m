%-----FIGURES OF SECTION 4.2-----
%%
user_defined_inputs;
%%
clearvars -except DataTot GFA_15_min RES Mdl_wp Mdl_ld Data_ld Data_wp spi w8bar crps input t_current
close all; clc;
if exist('w8bar')==1
    delete(w8bar);
end
rng(0,'twister');

preamble;

FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Results\Revision';   % Your destination folder
outFileName     =  [input.simulPeriodName,'.mat'];
matFileName     = fullfile(FolderDestination,outFileName); 

load(matFileName)

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
%% \\\\\\\\\\FIGURE: NET LOAD vs SOC (DMPC/SMPC)\\\\\\\\\\\\

iVecLoad       = zeros(idx_end - idx_start + 1,1);
iVecWndPwr     = zeros(idx_end - idx_start + 1,1);

for i = 1 : idx_end - idx_start + 1
    iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(i).L(1,1)*par.spinRes;
    iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(i).W(1,1);
end

myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
myFigs.netLoadSoC.fig = figure('Name',['SoC_day_',int2str(input.startingDay)],'NumberTitle','off','Units','inches',...
    'Position',[myFigs.netLoadSoC.figBottomLeftX0 myFigs.netLoadSoC.figBottomLeftY0 myFigs.netLoadSoC.figWidth myFigs.netLoadSoC.figHeight],...
    'PaperPositionMode','auto');

myFigs.states.ax = gca;
hold on;

p1=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.x(1,idx_start:idx_end),'-','Color' , '#bdbdbd','LineWidth',1.5);
p2=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.x(1,idx_start:idx_end),'-','Color' , '#737373','LineWidth',1.8);


yl1=yline(par.socDOWNlim,'--','LineWidth',3);
yl1.Color = [0.8500, 0.3250, 0.0980];
yl1.Interpreter = 'latex';
yl1.Label = '$SoC_{min}$';
yl1.LabelVerticalAlignment = 'top'; %{'top', 'down'}
yl1.LabelHorizontalAlignment = 'right'; %{'left', 'right'}
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
myFigs.netLoadSoC.ax.XTick = (ttData.time(t_start):hours(2.25):ttData.time(t_end));
myFigs.netLoadSoC.ax.XTickLabelRotation = 45;

myFigs.netLoadSoC.ax.YAxis(1).Label.Interpreter = 'latex';
myFigs.netLoadSoC.ax.YAxis(1).Label.String ='$x^{SoC}(t)$';
myFigs.netLoadSoC.ax.YAxis(1).Color = 'black';
myFigs.netLoadSoC.ax.YAxis(1).FontSize  = 12;
myFigs.netLoadSoC.ax.YAxis(1).FontName = 'Times New Roman';
% myFigs.netLoadSoC.ax.YAxis(1).Limits = [0.1,0.9];

%         myFigs.netLoadSoC.ax.YAxis(1).TickValues  = (-param.Usat*0.5:0.1:param.Usat*0.5);

myFigs.netLoadSoC.ax.YAxis(2).Label.Interpreter = 'latex';
myFigs.netLoadSoC.ax.YAxis(2).Label.String ='$\xi_0(t)\;[MW]$';
myFigs.netLoadSoC.ax.YAxis(2).Color = 'black';
myFigs.netLoadSoC.ax.YAxis(2).FontSize  = 12;
myFigs.netLoadSoC.ax.YAxis(2).FontName = 'Times New Roman';

myFigs.netLoadSoC.ax.XGrid = 'on';
% myFigs.netLoadSoC.ax.YGrid = 'on';

%     myFigs.netLoadSoC.ax.Title.String = 'GT power';
%     myFigs.netLoadSoC.ax.YAxis.Label.Interpreter = 'latex';
%     myFigs.netLoadSoC.ax.YAxis.Label.String ='[MW]';
%     myFigs.netLoadSoC.ax.YAxis.Color = 'black';
%     myFigs.netLoadSoC.ax.XGrid = 'on';
%     myFigs.netLoadSoC.ax.YGrid = 'on';
%     % myFigs.pwr.ax.YAxis.FontSize  = 18;
%     myFigs.netLoadSoC.ax.YAxis.FontName = 'Times New Roman';
% %     myFigs.pwr.ax.YLim = [0,1];

legend(myFigs.netLoadSoC.h,{'DMPC','SMPC', '$\xi_0(t)$'},'FontSize',12,'Box', 'off','color','none',...
    'Fontname','Times New Roman','Orientation','horizontal','NumColumns',3,'interpreter','latex','Location',input.lgdLocationSoC);
    
%% \\\\\\\FIGURE: DISTRUBANCE (LOAD & WIND & NET LOAD) with GT area patches and No. of GTs ON \\\\\\\\\
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
    
%     setup.ESS_mean.iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1);
%     setup.ESS_mean.iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);
%     setup.ESS_mean.iVecDmpPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_dump(1,:));
%     setup.ESS_mean.iVecGTAPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.u_0(3,i) - RSLT.ESS_mean.u_0(4,i));
%     setup.ESS_mean.iVecGTBPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.u_0(5,i) - RSLT.ESS_mean.u_0(6,i));
%     setup.ESS_mean.iVecGTCPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_mean.x(4,i) + RSLT.ESS_mean.u_0(7,i) - RSLT.ESS_mean.u_0(8,i));
%     setup.ESS_mean.iVecGTDPwr(i) = mean(RSLT.ESS_mean.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_mean.x(5,i) + RSLT.ESS_mean.u_0(9,i) - RSLT.ESS_mean.u_0(10,i));
%     
%     setup.ESS_mean.iVecDmpPwrTrue(i) = setup.ESS_mean.iVecGTAPwr(i)+setup.ESS_mean.iVecGTBPwr(i)+setup.ESS_mean.iVecGTCPwr(i)+setup.ESS_mean.iVecGTDPwr(i) - ...
%         (RSLT.ESS_mean.u_0(1,i) - RSLT.ESS_mean.u_0(2,i)) - (setup.ESS_mean.iVecLoad(i)-setup.ESS_mean.iVecWndPwr(i));
%     
%     setup.ESS_mean.iAllGTstates(i) = RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.x(4,i) +RSLT.ESS_mean.x(5,i);
%     
%     setup.ESS_scn.iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(i).L(1,1);
%     setup.ESS_scn.iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(i).W(1,1);
%     setup.ESS_scn.iVecDmpPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_dump(1,:));
%     setup.ESS_scn.iVecGTAPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,1)) * (RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.u_0(3,i) - RSLT.ESS_scn.u_0(4,i));
%     setup.ESS_scn.iVecGTBPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,2)) * (RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.u_0(5,i) - RSLT.ESS_scn.u_0(6,i));
%     setup.ESS_scn.iVecGTCPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,3)) * (RSLT.ESS_scn.x(4,i) + RSLT.ESS_scn.u_0(7,i) - RSLT.ESS_scn.u_0(8,i));
%     setup.ESS_scn.iVecGTDPwr(i) = mean(RSLT.ESS_scn.rslt.sol(i).Power_GT(1,:,4)) * (RSLT.ESS_scn.x(5,i) + RSLT.ESS_scn.u_0(9,i) - RSLT.ESS_scn.u_0(10,i));
%     
%     setup.ESS_scn.iVecDmpPwrTrue(i) = setup.ESS_scn.iVecGTAPwr(i)+setup.ESS_scn.iVecGTBPwr(i)+setup.ESS_scn.iVecGTCPwr(i)+setup.ESS_scn.iVecGTDPwr(i) - ...
%         (RSLT.ESS_scn.u_0(1,i) - RSLT.ESS_scn.u_0(2,i)) - (setup.ESS_scn.iVecLoad(i)-setup.ESS_scn.iVecWndPwr(i));
%     
    setup.ESS_scn.iAllGTstates(i) = RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.x(4,i) +RSLT.ESS_scn.x(5,i);
    setup.ESS_mean.iAllGTstates(i) = RSLT.ESS_mean.x(2,i) + RSLT.ESS_mean.x(3,i) + RSLT.ESS_mean.x(4,i) +RSLT.ESS_mean.x(5,i);
    
end
    
    
    
    myFigs.dstrb.figWidth = 7; myFigs.dstrb.figHeight = 5;
    myFigs.dstrb.figBottomLeftX0 = 2; myFigs.dstrb.figBottomLeftY0 =2;
    myFigs.dstrb.fig = figure('Name',['dstrb_day_',int2str(input.startingDay)],'NumberTitle','off','Units','inches',...
        'Position',[myFigs.dstrb.figBottomLeftX0 myFigs.dstrb.figBottomLeftY0 myFigs.dstrb.figWidth myFigs.dstrb.figHeight],...
        'PaperPositionMode','auto');

   
%     myFigs.dstrb.ax = gca;
    myFigs.dstrb.ax = axes(myFigs.dstrb.fig);

%     yyaxis left

    hold on;

    plot(ttData.time(t_start : t_end),iVecLoad,'--k','LineWidth',1.3);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-.k','LineWidth',1.3);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.6);

    x_patch = [0 2 2 0];

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
    
%         patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_4,'magenta','FaceAlpha',0.3,'EdgeColor','none');

        patch(x_patch_0,y_patch_0,[118/255 102/255 167/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,[34/255 131/255 122/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,[22/255 10/255 100/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,[224/255 183/255 46/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_4,[255/255 0/255 0/255],'FaceAlpha',0.3,'EdgeColor','none');

        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','1 GT','2 GT','3 GT','4 GT'};
        else
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','0 GT','1 GT','2 GT','3 GT','4 GT'};
        end

        colNum = 3;
        
    elseif max(iVecLoad) >= 2*par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max 2*par.P_gt_max 2*par.P_gt_max];
        y_patch_3 = [2*par.P_gt_max 2*par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
%         patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_3,'cyan','FaceAlpha',0.3,'EdgeColor','none');
        
        patch(x_patch_0,y_patch_0,[118/255 102/255 167/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,[34/255 131/255 122/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,[22/255 10/255 100/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_3,[224/255 183/255 46/255],'FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','1 GT','2 GT','3 GT'};
        else
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','0 GT','1 GT','2 GT','3 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= par.P_gt_max
        
        y_patch_1 = [0 0 par.P_gt_max par.P_gt_max];
        y_patch_2 = [par.P_gt_max par.P_gt_max max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
%         patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_2,'blue','FaceAlpha',0.3,'EdgeColor','none');
        
        patch(x_patch_0,y_patch_0,[118/255 102/255 167/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,[34/255 131/255 122/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_2,[22/255 10/255 100/255],'FaceAlpha',0.3,'EdgeColor','none');
        
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','1 GT','2 GT'};
        else
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','0 GT','1 GT','2 GT'};
        end
        
        colNum = 3;
    elseif max(iVecLoad) >= 0
        
        y_patch_1 = [0 0 max(max(iVecLoad),max(iVecWndPwr)) max(max(iVecLoad),max(iVecWndPwr))];
        
%         patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
%         patch(x_patch,y_patch_1,'green','FaceAlpha',0.3,'EdgeColor','none');
        
        patch(x_patch_0,y_patch_0,[118/255 102/255 167/255],'FaceAlpha',0.3,'EdgeColor','none');
        patch(x_patch,y_patch_1,[34/255 131/255 122/255],'FaceAlpha',0.3,'EdgeColor','none');
        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','1 GT'};
        else
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','0 GT','1 GT'};
        end
        
        colNum = 3;
    else
        
%         patch(x_patch_0,y_patch_0,'red','FaceAlpha',0.3,'EdgeColor','none');
        
        patch(x_patch_0,y_patch_0,[118/255 102/255 167/255],'FaceAlpha',0.3,'EdgeColor','none');

        
        if isempty(y_patch_0)
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$'};
        else
            lgdCell = {'$P^{\ell}(t)$', '$P^{w}(t)$', '$\xi_0(t)$','0 GT'};
        end
        
        colNum = 3;
    end
    
    
    legend(myFigs.dstrb.ax,lgdCell,'FontSize',12,'orientation','horizontal',...
        'Fontname','Times New Roman','EdgeColor','none', 'NumColumns',colNum,'interpreter','latex','Location',input.lgdLocationDstrb);
    
    ax2 = copyobj(myFigs.dstrb.ax,gcf);
    delete( get(ax2,'Children') )            %# delete its children


    hold on;
    
%     yyaxis right;
    
    
    scatter(ttData.time(t_start : t_end),setup.ESS_mean.iAllGTstates,20,'Parent',ax2,'k','+');
    scatter(ttData.time(t_start : t_end),setup.ESS_scn.iAllGTstates,20,'Parent',ax2,'k','x');
    
    set(ax2, 'Color','none', 'XTick',[], 'YTick',[], ...
        'YAxisLocation','right', 'box','off')   %# make it transparent


    
%     hold off;
%     myFigs.dstrb.ax.YAxis.Label.Interpreter = 'latex';
%     myFigs.dstrb.ax.YAxis.Label.String ='Power [MW]';
%     myFigs.dstrb.ax.YAxis.Color = 'black';
%     myFigs.dstrb.ax.YLabel.FontSize  = 12;
%     myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
%     myFigs.dstrb.ax.YLabel.FontName = 'Times New Roman';
%     myFigs.dstrb.ax.YAxis.FontSize  = 12;
    
    
    myFigs.dstrb.ax.YAxis(1).Label.Interpreter = 'latex';
    myFigs.dstrb.ax.YAxis(1).Label.String = '$P^{\ell}(t), \; P^{w}(t), \; \xi_0(t) \;[MW]$';
    myFigs.dstrb.ax.YAxis(1).Color = 'black';
    myFigs.dstrb.ax.YAxis(1).FontSize  = 12;
    myFigs.dstrb.ax.YAxis(1).FontName = 'Times New Roman';
    
    ax2.YAxis.Label.Interpreter = 'latex';
%     ax2.YAxis.Label.String = ' $\sum_{g \in N_g} x_{g}^{gt}(t)$ [\verb|#| GT ON]';
    ax2.YAxis.Label.String = ' $I_{on}^{gt}(t)$';

    ax2.YAxis.Color = 'black';
    ax2.YAxis.FontSize  = 12;
    ax2.YAxis.FontName = 'Times New Roman';
    ax2.YAxis.Limits  = [0,4];
    ax2.YAxis.TickValues  = 0:1:4;
%     
%     myFigs.dstrb.ax.YAxis(2).Label.Interpreter = 'latex';
%     myFigs.dstrb.ax.YAxis(2).Label.String = '\verb|#| GT ON';
%     myFigs.dstrb.ax.YAxis(2).Color = 'black';
%     myFigs.dstrb.ax.YAxis(2).FontSize  = 12;
%     myFigs.dstrb.ax.YAxis(2).FontName = 'Times New Roman';
%     myFigs.dstrb.ax.YAxis(2).Limits  = [0,4];
%     myFigs.dstrb.ax.YAxis(2).TickValues  = 0:1:4;
    
        
    
    myFigs.dstrb.ax.XLabel.FontSize  = 12;
    myFigs.dstrb.ax.XLabel.Interpreter = 'latex';
    myFigs.dstrb.ax.XLabel.String = 'Date';
    myFigs.dstrb.ax.XLabel.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontName = 'Times New Roman';
    myFigs.dstrb.ax.XAxis.FontSize  = 12;
    
    myFigs.dstrb.ax.XGrid = 'on';
    myFigs.dstrb.ax.XLim = [ttData.time(t_start),ttData.time(t_end)];
    myFigs.dstrb.ax.XTick = (ttData.time(t_start):hours(2.25):ttData.time(t_end));
    myFigs.dstrb.ax.XTickLabelRotation = 45;
    
    
    ax2.XLabel.FontSize  = 12;
    ax2.XLabel.Interpreter = 'latex';
    ax2.XLabel.String = 'Date';
    ax2.XLabel.FontName = 'Times New Roman';
    ax2.XAxis.FontName = 'Times New Roman';
    ax2.XAxis.FontSize  = 12;
    
    ax2.XLim = [ttData.time(t_start),ttData.time(t_end)];
    ax2.XTick = (ttData.time(t_start):hours(2.25):ttData.time(t_end));
    ax2.XTickLabelRotation = 45;
  
    
%         legend(myFigs.dstrb.ax,[lgdCell,{'DMPC', 'SMPC'}],'FontSize',12,...
%         'Fontname','Times New Roman','NumColumns',colNum,'interpreter','latex','Location','northwest');

    legend(ax2,{'$I_{on}^{gt} \; \textit{(DMPC)}$', '$I_{on}^{gt} \; \textit{(SMPC)}$'},'FontSize',10,'Box', 'off','color','none',...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location',input.lgdLocationIgtOn);

%     yyaxis left;

    hold off;
    
%% \\\\\\\\\\\\\\\\FIGURE: NET LOAD vs SOC (DMPC/SMPC) with degrdation weight\\\\\\\\\\\\\\\\\\\
% {'noWeight','none', 'normal', 'low', 'medium', 'high'}
if strcmp('none',input.degradWeight) ||  strcmp('normal',input.degradWeight) ||  strcmp('high',input.degradWeight)
    iVecLoad       = zeros(idx_end - idx_start + 1,1);
    iVecWndPwr     = zeros(idx_end - idx_start + 1,1);
    
    for i = 1 : idx_end - idx_start + 1
        iVecLoad(i)   = RSLT.ESS_mean.normalDegrad.rslt.xi(i).L(1,1);
        iVecWndPwr(i) = RSLT.ESS_mean.normalDegrad.rslt.xi(i).W(1,1);
    end
    
    myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
    myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
    myFigs.netLoadSoC.fig = figure('Name','degradWeightSocScn','NumberTitle','off','Units','inches',...
        'Position',[myFigs.netLoadSoC.figBottomLeftX0 myFigs.netLoadSoC.figBottomLeftY0 myFigs.netLoadSoC.figWidth myFigs.netLoadSoC.figHeight],...
        'PaperPositionMode','auto');
    
    %     subplot(2,1,1);
    myFigs.netLoadSoC.ax = gca;
    hold on;
    
    
    % p1=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.noDegrad.x(1,idx_start:idx_end),'-','Color' , '#6f8bfb','LineWidth',1.8);
    p2=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.noDegrad.x(1,idx_start:idx_end),'-','Color' , '#ffcccc','LineWidth',1.8);
    
    % p3=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.normalDegrad.x(1,idx_start:idx_end),'--','Color' , '#3f64fa','LineWidth',1.5);
    p4=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.normalDegrad.x(1,idx_start:idx_end),'--','Color' , '#ff6666','LineWidth',1.5);
    
    % p5=plot(ttData.time(t_start : t_end),RSLT.ESS_mean.highDegrad.x(1,idx_start:idx_end),'-','Color' , '#0f3df9','LineWidth',2);
    p6=plot(ttData.time(t_start : t_end),RSLT.ESS_scn.highDegrad.x(1,idx_start:idx_end),'-','Color' , '#ff0000','LineWidth',2);
    
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
    yl2.LabelVerticalAlignment = 'top';
    yl2.LabelHorizontalAlignment = 'right';
    yl2.FontSize = 12;
    
    
    yyaxis right;
    p7=plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);
    
    hold off;
    
    myFigs.netLoadSoC.ax = gca;
    % myFigs.netLoadSoC.h = [p1;p2;p3;p4;p5;p6;p7];
    % myFigs.netLoadSoC.h = [p1;p3;p5;p7];
    myFigs.netLoadSoC.h = [p2;p4;p6;p7];
    
    
    
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
    
    
    % legend(myFigs.netLoadSoC.h,{'noDegrad DMPC','noDegrad SMPC','normalDegrad DMPC','normalDegrad SMPC',...
    %     'highDegrad DMPC','highDegrad SMPC','$\xi_0(t)$'},'FontSize',12,'Box', 'off','color','none',...
    %     'Fontname','Times New Roman','Orientation','horizontal','NumColumns',4,'interpreter','latex','Location','northwest');
    
    legend(myFigs.netLoadSoC.h,{'$w_{dg}=0$','$w_{dg}=1$',...
        '$w_{dg}=1000$','$\xi_0(t)$'},'FontSize',12,'Box', 'off','color','none',...
        'Fontname','Times New Roman','Orientation','horizontal','NumColumns',3,'interpreter','latex','Location','northwest');
end