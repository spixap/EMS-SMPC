%% --------------------------\\ INPUTS \\------------------------------
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\DataFiles\models.mat')


input.startingDay  = 290; %118, 112, 126, 226, 237, 61, 11, 166, 290  (238 bad, not 301)
input.durationDays = 1;

input.doAnimation = 0;
input.animationVar = 'wind'; % {'load', 'wind'}

input.randomSeed = 24;


input.method = 'scn_frcst'; % {'point_frcst', 'scn_frcst'}


if ~xor(strcmp(input.method,'point_frcst')==1, strcmp(input.method,'scn_frcst')==1)
    error(['Non valid argument for input.method.' newline...
           'Insert: point_frcst OR scn_frcst']);
end

if input.durationDays == 1
    input.simulPeriodName = ['day_',int2str(input.startingDay)];
    input.N_steps = 4*24*input.durationDays;
    t_current   = 4*24*(input.startingDay-1);    

elseif input.durationDays > 1
    input.simulPeriodName = ['days_',int2str(input.startingDay),'_',int2str(input.startingDay + input.durationDays)];
    input.N_steps = 4*24*input.durationDays;
    t_current   = 4*24*(input.startingDay-1);    

elseif input.durationDays == 0
    input.N_steps = 0;    % number of timesteps to simulate 576 (nice period)
    input.simulPeriodName = ['day_',int2str(input.startingDay),'_steps_',int2str(input.N_steps)];
    t_current   = 4*24*(input.startingDay-1);    
end

input.N_prd = 6; % {6, 12}

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

%
t_start = t_current;
t_end = t_start + par.N_steps;
% t_start = 7681;
% t_end = 7753;
idx_start = t_start - t_current + 1;
idx_end = t_end - t_current +1;
% SELECT DATA TYPE
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
% \\\\\\\\\\\\\\\\\PLOT 1: soc vs net load (scn & mean)\\\\\\\\\\\\\\\\\\\

iVecLoad       = zeros(idx_end - idx_start + 1,1);
iVecWndPwr     = zeros(idx_end - idx_start + 1,1);

for i = 1 : idx_end - idx_start + 1
%     iVecLoad(i)   = RSLT.ESS_mean.rslt.xi(i).L(1,1)*par.spinRes;
%     iVecWndPwr(i) = RSLT.ESS_mean.rslt.xi(i).W(1,1);

    iVecLoad(i)   = RSLT.ESS_scn.rslt.xi(i).L(1,1)*par.spinRes;
    iVecWndPwr(i) = RSLT.ESS_scn.rslt.xi(i).W(1,1);
end

myFigs.netLoadSoC.figWidth = 7; myFigs.netLoadSoC.figHeight = 5;
myFigs.netLoadSoC.figBottomLeftX0 = 2; myFigs.netLoadSoC.figBottomLeftY0 =2;
myFigs.netLoadSoC.fig = figure('Name',['SoC_day_',int2str(input.startingDay)],'NumberTitle','off','Units','inches',...
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

%  iVecLoad       = zeros(par.N_steps + 1,1);
%     iVecWndPwr     = zeros(par.N_steps + 1,1);
%     iVecDmpPwr     = zeros(par.N_steps + 1,1);
%     iVecGTAPwr     = zeros(par.N_steps + 1,1);
%     iVecGTBPwr     = zeros(par.N_steps + 1,1);
%     iVecGTCPwr     = zeros(par.N_steps + 1,1);
%     iVecGTDPwr     = zeros(par.N_steps + 1,1);
%     iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
%     iVecONGTnum = zeros(par.N_steps + 1,1);


%     % POWER CALCULATION
%     for i = 1 : par.N_steps + 1
%         iVecLoad(i)   = rslt.xi(i).L(1,1) * par.spinRes;
% %         iVecLoad(i)   = rslt.xi(i).L(1,1) ;

%         iVecWndPwr(i) = rslt.xi(i).W(1,1);
%         iVecDmpPwr(i) = mean(rslt.sol(i).Power_dump(1,:));
%         iVecGTAPwr(i) = mean(rslt.sol(i).Power_GT(1,:,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
%         iVecGTBPwr(i) = mean(rslt.sol(i).Power_GT(1,:,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
%         iVecGTCPwr(i) = mean(rslt.sol(i).Power_GT(1,:,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
%         iVecGTDPwr(i) = mean(rslt.sol(i).Power_GT(1,:,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));
% 
%         iVecDmpPwrTrue(i) = iVecGTAPwr(i)+iVecGTBPwr(i)+iVecGTCPwr(i)+iVecGTDPwr(i) - ...
%             (u_0(1,i) - u_0(2,i)) - (iVecLoad(i)-iVecWndPwr(i));
%         
%         iVecONGTnum(i) = RSLT.ESS_scn.x(2,i) + RSLT.ESS_scn.x(3,i) + RSLT.ESS_scn.x(4,i) +RSLT.ESS_scn.x(5,i);

%     end
    
 % \\\\\\\PLOT 4c: DISTRUBANCE (LOAD & WIND & NET LOAD) with GT area patches and No of GTs ON \\\\\\\\\
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

   
    myFigs.dstrb.ax = gca;
    hold on;

    plot(ttData.time(t_start : t_end),iVecLoad,'--k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecWndPwr,'-.k','LineWidth',1);
    plot(ttData.time(t_start : t_end),iVecLoad-iVecWndPwr,'-k','LineWidth',1.5);

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






%% Appendix-1: Save produced figures
%
% prompt = 'Save figure? Y/N [Y]: ';
% str = input(prompt,'s');
% if isempty(str)
%     str = 'Y';
% end

    
    FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Figs_Out\Revision';   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        FigHandle = FigList(iFig);
        %       FigName   = num2str(get(FigHandle, 'Number'));
        FigName   = get(FigHandle,'Name');
        %     set(0, 'CurrentFigure', FigHandle);
        %     savefig(fullfile(FolderName, [FigName '.fig']));
        print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')
    end
