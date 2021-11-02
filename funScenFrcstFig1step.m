function myFig = funScenFrcstFig1step(ttData, par, Data, t, Mdl, varName, myFigtitle)
%funFrcstFig1step Summary of this function goes here
%   Plot mean, scenarios and probabilistic forecasts

    mu = zeros(1,par.N_prd);       % MVN(0,Sigma)
    idx_gif = 1;                            % index to measure frames - indicates how many time steps have been executed
%     par.randomSeed = 24; % 24, 4, 20, 1

%     t = t_current;

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
    %% Figure
    myFig.figWidth = 7; myFig.figHeight = 5;
    myFig.figBottomLeftX0 = 2; myFig.figBottomLeftY0 = 2;
    myFig.fig = figure('Name',myFigtitle,'NumberTitle','off','Units','inches',...
        'Position',[myFig.figBottomLeftX0 myFig.figBottomLeftY0 myFig.figWidth myFig.figHeight],...
        'PaperPositionMode','auto');

    myFig.ax = gca;

    myFig.scnplot = gobjects(par.N_scn,1);    % scnearios graphics placeholder

    myFig.p1 = plot(ttData.time(window.t_slide_range), Data(window.t_slide_range),'-k','LineWidth',0.1);

    hold all

%     myFig.ax.YLim = ([min(trueY)-2 max(trueY)+5]);

%     grid on;
    myFig.s1 = scatter(myFig.ax,ttData.time(t),Data(t),100,'+b','LineWidth',3);

    myFig.p2 = plot(ttData.time(window.t_slide_range),window.trueY,'-k*','LineWidth',2);
%     myFig.p3 = plot(ttData.time(window.t_slide_range),window.predY,'--r*','LineWidth',2);
    myFig.p4 = plot(ttData.time(window.t_slide_range),window.quant005Y, '-g','LineWidth',3);
%     myFig.p5 = plot(ttData.time(window.t_slide_range),window.quant05Y , '-b','LineWidth',2);
    myFig.p6 = plot(ttData.time(window.t_slide_range),window.quant095Y, '-g','LineWidth',3);


    for i_scn = 1 : par.N_scn
        window.scenY(1:window.width + 1,1) = NaN;
        window.scenY(window.width + 2 : window.width + par.N_prd + 1,1) = xi.scen(1,:,i_scn);
        window.scenY(window.width + par.N_prd + 2 : length(window.t_slide_start:window.t_slide_end) ,1) = NaN;

        myFig.scnplot(i_scn) = plot(myFig.ax,ttData.time(window.t_slide_start : window.t_slide_end),window.scenY,'--m','LineWidth',0.5);
    end


    hold off;


    legend([myFig.p1 myFig.s1 myFig.p2 myFig.p4 myFig.p6 myFig.scnplot(1)],{'$y$','$y_{t \mid t}$','$y_{t + k \mid t}$','$Q_{0.05}(x)$',...
        '$Q_{0.95}(x)$','$\hat{y}_{t+k \mid t}^{(i)}$'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',2,'interpreter','latex','Box','off','color','none','Location','northwest');
    


    myFig.ax.YAxis.Label.Interpreter = 'latex';
    myFig.ax.YAxis.Label.String = varName;
    myFig.ax.YAxis.Color = 'black';
    myFig.ax.YLabel.Color = 'black';
    myFig.ax.YAxis.FontSize  = 12;
    % myFig.ax.YLabel.FontSize  = 12;
    myFig.ax.YAxis.FontName = 'Times New Roman';
    myFig.ax.YLim = ([min(Data(window.t_slide_range))-2 max(Data(window.t_slide_range))+5]);

    myFig.ax.XAxis.Label.Interpreter = 'latex';
    myFig.ax.XAxis.FontName = 'Times New Roman';
    myFig.ax.XAxis.FontSize  = 12;
    myFig.ax.XAxis.Color = 'black';
    myFig.ax.XAxis.Label.String ='Date';


    myFig.ax.XLabel.Color = 'black';
    myFig.ax.XLabel.FontSize  = 12;
    myFig.ax.XLabel.FontName = 'Times New Roman';
    myFig.ax.XLim = [ttData.time(window.t_slide_start),ttData.time(window.t_slide_end)];
    
    set(myFig.ax.YAxis, 'visible', 'off')
    set(myFig.ax, 'Box', 'off')

    
%     myFig.ax.XGrid = 'on';
%     myFig.ax.YGrid = 'on';

end