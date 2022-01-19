function myFig = funFrcstFig1step(ttData, par, Data, t, Mdl, varName, myFigtitle)
%funFrcstFig1step Summary of this function goes here
%   Plot mean, scenarios and probabilistic forecasts

mu = zeros(1,par.N_prd);       % MVN(0,Sigma)
idx_gif = 1;                            % index to measure frames - indicates how many time steps have been executed

%     window.width  = 2 * par.N_prd;
window.width  = 2 * 2;

window.t_slide_start = t - window.width;
window.t_slide_end   = t + par.N_prd + window.width;
window.t_slide_range = window.t_slide_start : window.t_slide_end;

predX = zeros(1,par.lagsNum);
for n = 0 : par.lagsNum-1
    predX(1,n+1) = Data(t-n);
end

predY = zeros(1,par.N_prd);
trueY = zeros(1,par.N_prd);
for k = 1 : par.N_prd
    predY(1,k) = predict(Mdl.M{k,par.leafSizeIdx},predX);
    trueY(1,k) = Data(t+k);
end

window.trueY(1                           : window.width + 1,1) = NaN;
window.trueY(window.width + 2            : window.width + par.N_prd + 1 ,1) = trueY;
window.trueY(window.width + par.N_prd + 2 : length(window.t_slide_range) ,1) = NaN;

window.predY(1                          : window.width + 1,1) = NaN;
window.predY(window.width + 2           : window.width + par.N_prd + 1,1) = predY;
window.predY(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

% Define the quantiles i am interested
par.tau = linspace(0,1,21);

quant005Y = zeros(1,par.N_prd);
quant050Y = zeros(1,par.N_prd);
quant095Y = zeros(1,par.N_prd);

quant010Y = zeros(1,par.N_prd);
quant090Y = zeros(1,par.N_prd);
quant020Y = zeros(1,par.N_prd);
quant080Y = zeros(1,par.N_prd);
quant030Y = zeros(1,par.N_prd);
quant070Y = zeros(1,par.N_prd);
quant040Y = zeros(1,par.N_prd);
quant060Y = zeros(1,par.N_prd);

for k = 1 : par.N_prd
    [quantiles.Q{k}, quantiles.W{k}]  = quantilePredict(Mdl.M{k,par.leafSizeIdx},predX,'Quantile',par.tau);
    % Median
    quant050Y(1,k) = quantiles.Q{k}(11);
    % 5%-95%
    quant005Y(1,k) = quantiles.Q{k}(2);
    quant095Y(1,k) = quantiles.Q{k}(20);
    % 10%-90%
    quant010Y(1,k) = quantiles.Q{k}(3);
    quant090Y(1,k) = quantiles.Q{k}(19);
    % 20%-80%
    quant020Y(1,k) = quantiles.Q{k}(5);
    quant080Y(1,k) = quantiles.Q{k}(17);
    % 30%-70%
    quant030Y(1,k) = quantiles.Q{k}(7);
    quant070Y(1,k) = quantiles.Q{k}(15);
    % 40%-60%
    quant040Y(1,k) = quantiles.Q{k}(9);
    quant060Y(1,k) = quantiles.Q{k}(13);
end

quantsY.quant050Y(1,:) = quant050Y(1,:);
quantsY.quant005Y(1,:) = quant005Y(1,:);
quantsY.quant095Y(1,:) = quant095Y(1,:);
quantsY.quant010Y(1,:) = quant010Y(1,:);
quantsY.quant090Y(1,:) = quant090Y(1,:);
quantsY.quant020Y(1,:) = quant020Y(1,:);
quantsY.quant080Y(1,:) = quant080Y(1,:);
quantsY.quant030Y(1,:) = quant030Y(1,:);
quantsY.quant070Y(1,:) = quant070Y(1,:);
quantsY.quant040Y(1,:) = quant040Y(1,:);
quantsY.quant060Y(1,:) = quant060Y(1,:);

% Median
window.quant05Y(1                           : window.width + 1,1) = NaN;
window.quant05Y(window.width + 2            : window.width + par.N_prd + 1,1) = quant050Y;
window.quant05Y(window.width + par.N_prd + 2  : length(window.t_slide_range) ,1) = NaN;

% Prediction Intervals
% 5%-95%
window.quant005Y(1                          : window.width + 1,1) = NaN;
window.quant005Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant005Y;
window.quant005Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;
window.quant095Y(1                          : window.width + 1,1) = NaN;
window.quant095Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant095Y;
window.quant095Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

% 10%-90%
window.quant01Y(1                          : window.width + 1,1) = NaN;
window.quant01Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant010Y;
window.quant01Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

window.quant090Y(1                          : window.width + 1,1) = NaN;
window.quant090Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant090Y;
window.quant090Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

% 20%-80%
window.quant02Y(1                          : window.width + 1,1) = NaN;
window.quant02Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant020Y;
window.quant02Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

window.quant080Y(1                          : window.width + 1,1) = NaN;
window.quant080Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant080Y;
window.quant080Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

% 30%-70%
window.quant03Y(1                          : window.width + 1,1) = NaN;
window.quant03Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant030Y;
window.quant03Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

window.quant070Y(1                          : window.width + 1,1) = NaN;
window.quant070Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant070Y;
window.quant070Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

% 50%-60%
window.quant04Y(1                          : window.width + 1,1) = NaN;
window.quant04Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant040Y;
window.quant04Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;

window.quant060Y(1                          : window.width + 1,1) = NaN;
window.quant060Y(window.width + 2           : window.width + par.N_prd + 1,1) = quant060Y;
window.quant060Y(window.width + par.N_prd +2 : length(window.t_slide_range) ,1) = NaN;
%% Calculate Covvariance for time t_current
funOut = funCovCorrGenQRF(par, Data, t, Mdl);
temp = funOut.recursive.Rho(end,:,:);
Rho_t = zeros(par.N_prd,par.N_prd);
for k = 1 : par.N_prd
    Rho_t(k,:) = temp(:,:,k);
end
%% Generate Copula samples
rng(par.randomSeed);

R = chol(Rho_t);
X_k_norm = repmat(mu,par.N_scn,1) + randn(par.N_scn,par.N_prd)*R;
U_k = normcdf(X_k_norm);

P_k = zeros(par.N_scn,par.N_prd);
for k = 1 : par.N_prd
    P_k(:,k) = interp1(par.tau(2:end-1),quantiles.Q{1,k}(2:end-1),U_k(:,k),'linear','extrap');
    % ASSIGN SCENARIOS
    xi.scen(idx_gif,k,:) = P_k(:,k);
end

%%
myFig.figWidth = 7; myFig.figHeight = 5;
myFig.figBottomLeftX0 = 2; myFig.figBottomLeftY0 = 2;
myFig.fig = figure('Name',myFigtitle,'NumberTitle','off','Units','inches',...
    'Position',[myFig.figBottomLeftX0 myFig.figBottomLeftY0 myFig.figWidth myFig.figHeight],...
    'PaperPositionMode','auto');
tilesObj = tiledlayout(2,1);
%% Figure
myFig.axProb = nexttile;

% myFig.scnplot = gobjects(par.N_scn,1);    % scnearios graphics placeholder

myFig.p1 = plot(ttData.time(window.t_slide_range), Data(window.t_slide_range),'-k','LineWidth',0.1);

hold all

myFig.s1 = scatter(myFig.axProb,ttData.time(t),Data(t),100,'+b','LineWidth',3);

myFig.p2 = plot(ttData.time(window.t_slide_range),window.trueY,'-k*','LineWidth',3);
myFig.p3 = plot(ttData.time(window.t_slide_range),window.predY,'--r','LineWidth',2);
myFig.p4 = plot(ttData.time(window.t_slide_range),window.quant005Y, '-g','LineWidth',2.5);
myFig.p6 = plot(ttData.time(window.t_slide_range),window.quant095Y, '-g','LineWidth',2.5);

% % 5%-95%
% myFig.X_plot = [ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start+ window.width + par.N_prd)' , ...
%     fliplr(ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start + window.width + par.N_prd)')];
% myFig.Y_plot  = [quantsY.quant005Y, fliplr(quantsY.quant095Y)];
% myFig.f1      = fill(myFig.axProb,myFig.X_plot, myFig.Y_plot , 1,'facecolor',[238/255 248/255 235/255],'edgecolor','none', 'facealpha', 0.3);
% % 10%-90%
% myFig.Y_plot  = [quantsY.quant010Y, fliplr(quantsY.quant090Y)];
% myFig.f2      = fill(myFig.axProb,myFig.X_plot, myFig.Y_plot , 1,'facecolor',[203/255 233/255 196/255],'edgecolor','none', 'facealpha', 0.3);
% % 20%-80%
% myFig.Y_plot  = [quantsY.quant020Y, fliplr(quantsY.quant080Y)];
% myFig.f3      = fill(myFig.axProb,myFig.X_plot, myFig.Y_plot , 1,'facecolor',[168/255 219/255 157/255],'edgecolor','none', 'facealpha', 0.3);
% % 30%-70%
% myFig.Y_plot  = [quantsY.quant030Y, fliplr(quantsY.quant070Y)];
% myFig.f4      = fill(myFig.axProb,myFig.X_plot, myFig.Y_plot , 1,'facecolor',[133/255 205/255 118/255],'edgecolor','none', 'facealpha', 0.3);
% % 40%-60%
% myFig.Y_plot  = [quantsY.quant040Y, fliplr(quantsY.quant060Y)];
% myFig.f5      = fill(myFig.axProb,myFig.X_plot, myFig.Y_plot , 1,'facecolor',[98/255 190/255 79/255],'edgecolor','none', 'facealpha', 0.3);


% hold off;

legend(myFig.axProb,[myFig.p1 myFig.s1 myFig.p2 myFig.p3 myFig.p4 myFig.p6],{'$y$','$y_{t \mid t}$','$y_{t + k \mid t}$','$\hat{E}(Y \mid X=x)$','$Q_{0.05}(x)$',...
    '$Q_{0.95}(x)$'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Box','off','color','none','Location','northwest');

ax2 = copyobj(myFig.axProb,tilesObj);
delete( get(ax2,'Children') )            %# delete its children

hold on;

set(ax2, 'Color','none', 'XTick',[], 'YTick',[], ...
    'YAxisLocation','right', 'box','off')   %# make it transparent

% 5%-95%
myFig.X_plot = [ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start+ window.width + par.N_prd)' , ...
    fliplr(ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start + window.width + par.N_prd)')];
myFig.Y_plot  = [quantsY.quant005Y, fliplr(quantsY.quant095Y)];
myFig.f1      = fill(myFig.X_plot, myFig.Y_plot , 1,'Parent',ax2,'facecolor',[238/255 248/255 235/255],'edgecolor','none', 'facealpha', 0.3);
% 10%-90%
myFig.Y_plot  = [quantsY.quant010Y, fliplr(quantsY.quant090Y)];
myFig.f2      = fill(myFig.X_plot, myFig.Y_plot , 1,'Parent',ax2,'facecolor',[203/255 233/255 196/255],'edgecolor','none', 'facealpha', 0.3);
% 20%-80%
myFig.Y_plot  = [quantsY.quant020Y, fliplr(quantsY.quant080Y)];
myFig.f3      = fill(myFig.X_plot, myFig.Y_plot , 1,'Parent',ax2,'facecolor',[168/255 219/255 157/255],'edgecolor','none', 'facealpha', 0.3);
% 30%-70%
myFig.Y_plot  = [quantsY.quant030Y, fliplr(quantsY.quant070Y)];
myFig.f4      = fill(myFig.X_plot, myFig.Y_plot , 1,'Parent',ax2,'facecolor',[133/255 205/255 118/255],'edgecolor','none', 'facealpha', 0.3);
% 40%-60%
myFig.Y_plot  = [quantsY.quant040Y, fliplr(quantsY.quant060Y)];
myFig.f5      = fill(myFig.X_plot, myFig.Y_plot , 1,'Parent',ax2,'facecolor',[98/255 190/255 79/255],'edgecolor','none', 'facealpha', 0.3);


myFig.axProb.YAxis.Label.Interpreter = 'latex';
myFig.axProb.YAxis.Label.String = varName;
myFig.axProb.YAxis.Color = 'black';
myFig.axProb.YLabel.Color = 'black';
myFig.axProb.YAxis.FontSize  = 12;
% myFig.axProb.YLabel.FontSize  = 12;
myFig.axProb.YAxis.FontName = 'Times New Roman';
% myFig.axProb.YLim = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+5]);
myFig.axProb.YAxis.Limits  = [min(Data(window.t_slide_range))-10 max(Data(window.t_slide_range))+5];
% myFig.axProb.YAxis.Limits  = [min(Data(window.t_slide_range))-5 max(Data(window.t_slide_range))+5];
% myFig.axProb.YLim = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+8]);



% myFig.axProb.YLimitMethod = 'tight';

% ax2.YAxis.Label.Interpreter = 'latex';
% ax2.YAxis.Label.String = ' $I_{on}^{gt}(t)$';
% ax2.YAxis.Color = 'black';
% ax2.YAxis.FontSize  = 12;
% ax2.YAxis.FontName = 'Times New Roman';
% ax2.YAxis.Limits  = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+5]);
ax2.YAxis.Limits  = [min(Data(window.t_slide_range))-10 max(Data(window.t_slide_range))+5];
% ax2.YAxis.Limits  = [min(Data(window.t_slide_range))-5 max(Data(window.t_slide_range))+5];
% ax2.YAxis.Limits  = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+8]);



myFig.axProb.XAxis.Label.Interpreter = 'latex';
myFig.axProb.XAxis.FontName = 'Times New Roman';
myFig.axProb.XAxis.FontSize  = 12;
myFig.axProb.XAxis.Color = 'black';
myFig.axProb.XAxis.Label.String ='Date';


myFig.axProb.XLabel.Color = 'black';
myFig.axProb.XLabel.FontSize  = 12;
myFig.axProb.XLabel.FontName = 'Times New Roman';
myFig.axProb.XLim = [ttData.time(window.t_slide_start),ttData.time(window.t_slide_end)];

ax2.XLabel.FontSize  = 12;
ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String = 'Date';
ax2.XLabel.FontName = 'Times New Roman';
ax2.XAxis.FontName = 'Times New Roman';
ax2.XAxis.FontSize  = 12;

ax2.XLim = [ttData.time(window.t_slide_start),ttData.time(window.t_slide_end)];
% ax2.XTick = (ttData.time(t_start):hours(2.25):ttData.time(t_end));
% ax2.XTickLabelRotation = 45;

legend(ax2,[myFig.f1, myFig.f2 myFig.f3 myFig.f4 myFig.f5],{'$\hat{\alpha}(x)=90\%$','$\hat{\alpha}(x)=80\%$','$\hat{\alpha}(x)=60\%$',...
    '$\hat{\alpha}(x)=40\%$','$\hat{\alpha}(x)=20\%$'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Box','off','color','none','Location','northeast');

% legend([myFig.p1 myFig.s1 myFig.p2 myFig.p3 myFig.p4 myFig.p6 myFig.f1 ...
%     myFig.f2 myFig.f3 myFig.f4 myFig.f5],{'$y$','$y_{t \mid t}$','$y_{t + k \mid t}$','$\hat{E}(Y \mid X=x)$','$Q_{0.05}(x)$',...
%     '$Q_{0.95}(x)$','$\hat{\alpha}(x)=90\%$','$\hat{\alpha}(x)=80\%$','$\hat{\alpha}(x)=60\%$',...
%     '$\hat{\alpha}(x)=40\%$','$\hat{\alpha}(x)=20\%$'},'FontSize',14,...
%     'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Box','off','color','none','Location','northwest');

  
hold off;

set(myFig.axProb.YAxis, 'visible', 'off');
set(myFig.axProb.XAxis, 'visible', 'off');

set(ax2.YAxis, 'visible', 'off');
set(ax2.XAxis, 'visible', 'off');

set(myFig.axProb, 'Box', 'off');
%% Figure
myFig.axScen = nexttile;

myFig.scnplot = gobjects(par.N_scn,1);    % scnearios graphics placeholder

myFig.p1 = plot(ttData.time(window.t_slide_range), Data(window.t_slide_range),'-k','LineWidth',0.1);

hold all

myFig.s1 = scatter(myFig.axScen,ttData.time(t),Data(t),100,'+b','LineWidth',3);

myFig.p2 = plot(ttData.time(window.t_slide_range),window.trueY,'-k*','LineWidth',2);
myFig.p4 = plot(ttData.time(window.t_slide_range),window.quant005Y, '-g','LineWidth',3);
myFig.p6 = plot(ttData.time(window.t_slide_range),window.quant095Y, '-g','LineWidth',3);

for i_scn = 1 : par.N_scn
    window.scenY(1:window.width + 1,1) = NaN;
    window.scenY(window.width + 2 : window.width + par.N_prd + 1,1) = xi.scen(1,:,i_scn);
    window.scenY(window.width + par.N_prd + 2 : length(window.t_slide_start:window.t_slide_end) ,1) = NaN;
    
    myFig.scnplot(i_scn) = plot(myFig.axScen,ttData.time(window.t_slide_start : window.t_slide_end),window.scenY,'--m','LineWidth',0.5);
end


hold off;


% legend([myFig.p1 myFig.s1 myFig.p2 myFig.p4 myFig.p6 myFig.scnplot(1)],{'$y$','$y_{t \mid t}$','$y_{t + k \mid t}$','$Q_{0.05}(x)$',...
%     '$Q_{0.95}(x)$','$\hat{y}_{t+k \mid t}^{(i)}$'},'FontSize',14,...
%     'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Box','off','color','none','Location','northwest');

legend([myFig.scnplot(1)],{'$\hat{y}_{t+k \mid t}^{(i)}$'},'FontSize',12,...
    'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Box','off','color','none','Location','northeast');



myFig.axScen.YAxis.Label.Interpreter = 'latex';
myFig.axScen.YAxis.Label.String = varName;
myFig.axScen.YAxis.Color = 'black';
myFig.axScen.YLabel.Color = 'black';
myFig.axScen.YAxis.FontSize  = 12;
% myFig.axScen.YLabel.FontSize  = 12;
myFig.axScen.YAxis.FontName = 'Times New Roman';
% myFig.axScen.YLim = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+5]);
myFig.axScen.YLim = [min(Data(window.t_slide_range))-10 max(Data(window.t_slide_range))+5];
% myFig.axScen.YLim = [min(Data(window.t_slide_range))-5 max(Data(window.t_slide_range))+5];
% myFig.axScen.YLim = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+8]);



myFig.axScen.XAxis.Label.Interpreter = 'latex';
myFig.axScen.XAxis.FontName = 'Times New Roman';
myFig.axScen.XAxis.FontSize  = 12;
myFig.axScen.XAxis.Color = 'black';
myFig.axScen.XAxis.Label.String ='Date';


myFig.axScen.XLabel.Color = 'black';
myFig.axScen.XLabel.FontSize  = 12;
myFig.axScen.XLabel.FontName = 'Times New Roman';
myFig.axScen.XLim = [ttData.time(window.t_slide_start),ttData.time(window.t_slide_end)];

set(myFig.axScen.YAxis, 'visible', 'off');
set(myFig.axScen, 'Box', 'off');


linkaxes([myFig.axProb,myFig.axScen],'x');

% tilesObj.Padding = 'none';
tilesObj.TileSpacing = 'none';

xticklabels(myFig.axProb,{});


end