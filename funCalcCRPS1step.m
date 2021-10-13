function [CRPS_qrf,CRPS_bnch] = funCalcCRPS1step(par,Data,ttData,Mdl,varName,t_current)
    %funCalcCRPS1step CALCULATE CRPS FOR 1 DATA POINT FOR ALL k
    %   This function calculated CRPS metric from a QRF model and compares it
    %   against the becnhmark method as described inthe paper: "A universal benchmarking
    %   method for probabilistic solar irradiance forecasting"

    delta_y = 0.001;

    Data_norm = rescale(Data);

    bench_datX = DataX(Data_norm);
    bench_datX.iniVec      = bench_datX.GroupSamplesBy(96);
    bench_datX.iniVecResol = 'Quarters';
    bench_datX.iniVecUnits = 'MW';

    y_obs       = zeros(1,par.N_prd);
    cdf_inv_hat = zeros(par.N_prd,length(par.tau));
    CRPS_qrf    = zeros(par.N_steps,par.N_prd);
    CRPS_bnch   = zeros(par.N_steps,par.N_prd);
%% SIMULATION
% k = 8;

i_quart = hour(ttData.time(t_current))*4 + floor(minute(ttData.time(t_current))/15) + 1;
[ecdf_hat_bnch,y_bnch] = ecdf(bench_datX.iniVec(i_quart,:));

for k = 1 : par.N_prd
    sum_qrf = 0;
    sum_bnch = 0;
    
    y_obs(1,k) = Data_norm(t_current + k);
    
    predX = zeros(1,par.lagsNum);
    for n = 0 : par.lagsNum-1
        predX(1,n+1) = Data(t_current - n);
    end
    
    [quantiles.Q{k}, quantiles.W{k}]  = quantilePredict(Mdl.M{k,par.leafSizeIdx},predX,'Quantile',par.tau);

    quantiles_norm.Q{k} = rescale(quantiles.Q{k},0,1,'InputMin',min(Data),'InputMax',max(Data));
    
    cdf_inv_hat(k,:) = quantiles_norm.Q{k};
    [ecdf_hat,y] = ecdf(cdf_inv_hat(k,:));

%     for dy = 0 : 0.01 : 1
    for dy = min(y) : delta_y : max(y)

        if length(y) <= 1
            cdf_hat_k = ecdf_hat(1) ;
        elseif length(y) <= 2
            cdf_hat_k = (ecdf_hat(1) + ecdf_hat(2))/2;            
        elseif length(y) <= 3
            cdf_hat_k = (ecdf_hat(2) + ecdf_hat(3))/2; 
        else
            cdf_hat_k = interp1(y(2:end),ecdf_hat(2:end),dy,'linear','extrap');
        end
        
        if dy <= y_obs(1,k)
            sum_qrf = sum_qrf + cdf_hat_k^2 * delta_y;
        else
            sum_qrf = sum_qrf + (cdf_hat_k-1)^2 * delta_y;
        end
    end
    
    % CRPS calculation from Benchamrk
    for dy = min(y_bnch) : delta_y : max(y_bnch)        
                
        if length(y_bnch) <= 1
            cdf_hat_k_bnch = ecdf_hat_bnch(1) ;
        elseif length(y_bnch) <= 2
            cdf_hat_k_bnch = (ecdf_hat_bnch(1) + ecdf_hat_bnch(2))/2;
        elseif length(y_bnch) <= 3
            cdf_hat_k_bnch = (ecdf_hat_bnch(2) + ecdf_hat_bnch(3))/2;
        else
            cdf_hat_k_bnch = interp1(y_bnch(2:end),ecdf_hat_bnch(2:end),dy,'linear','extrap');
        end
        
        if dy <= y_obs(1,k)
            sum_bnch = sum_bnch + cdf_hat_k_bnch^2 * delta_y;
        else
            sum_bnch = sum_bnch + (cdf_hat_k_bnch-1)^2 * delta_y;
        end
    end
    
   
    CRPS_qrf(1,k) = sum_qrf * 100;
    CRPS_bnch(1,k)= sum_bnch * 100;
    %% FIGURE: COMPARE CDFs
    myFigs.cdf.figWidth = 7; myFigs.cdf.figHeight = 5;
    myFigs.cdf.figBottomLeftX0 = 2; myFigs.cdf.figBottomLeftY0 =2;
    myFigs.cdf.fig(k) = figure('Name',['CDFs_t_',datestr(ttData.time(t_current)),'_k _',num2str(k)],...
        'NumberTitle','off','Units','inches','Position',[myFigs.cdf.figBottomLeftX0 myFigs.cdf.figBottomLeftY0 myFigs.cdf.figWidth myFigs.cdf.figHeight],...
        'PaperPositionMode','auto');

    str_k = ['{t+',num2str(k),'|t}'];


    myFigs.cdf.ax = gca;
    
    hold on;
    cdfplot(bench_datX.iniVec(i_quart,:));
    
    myFigs.cdf.c2 = cdfplot(cdf_inv_hat(k,:));
    myFigs.cdf.c2.Color = 'green';
    myFigs.cdf.c2.LineStyle = '-';
    myFigs.cdf.c2.LineWidth = 1;
    
    plot(y,ecdf_hat,'-k','Linewidth',1.3);
    
    syms y_heavi
    fplot(heaviside(y_heavi-y_obs(k)),[min(y_bnch), max(y_bnch)],'-r','Linewidth',2)
     
    hold off;
  
    myFigs.cdf.ax.Title.String = '';
    myFigs.cdf.ax.XAxis.Label.Interpreter = 'latex';
%     myFigs.cdf.ax.XAxis.Label.String = '$P_{\ell}\;[p.u.]$';
    myFigs.cdf.ax.XAxis.Label.String = varName;


%     myFigs.cdf.ax.XTick = (1:par.N_prd);
%     myFigs.cdf.ax.XLim = [1 par.N_prd];
%     myFigs.cdf.ax.XTickLabel = str_k;
    myFigs.cdf.ax.TickLabelInterpreter  = 'latex';

    myFigs.cdf.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.cdf.ax.YAxis.Label.String = 'Probability';
    myFigs.cdf.ax.YAxis.Color = 'black';
    % myFigs.cdf.ax.YAxis.FontSize  = 18;
    myFigs.cdf.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.crps.ax.YLim = [0,1];

    myFigs.cdf.ax.XGrid = 'on';
    myFigs.cdf.ax.YGrid = 'on';

    legend(myFigs.cdf.ax,['$\hat{F}^{e,bnch}_','{quart = ',num2str(i_quart),'}$'],['$\hat{F}^e_',str_k,'$'],['$\hat{F}^{intrp}_',str_k,'$'],['$H(y_{obs}= ', num2str(y_obs(k)),')$'],'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','southeast');
end