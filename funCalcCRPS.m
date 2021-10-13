function [skill_sc,CRPS_ave_qrf,CRPS_ave_bnch] = funCalcCRPS(par,Data,ttData,Mdl,t_current)
    %UNTITLED CALCULATE CRPS FOR REFERENCE PERIOD
    %   This function calculated CRPS metric from a QRF model and compares it
    %   against the becnhmark method as described inthe paper: "A universal benchmarking
    %   method for probabilistic solar irradiance forecasting"

    delta_y = 0.001;

    Data_norm = rescale(Data);

    bench_datX = DataX(Data_norm);
    bench_datX.iniVec      = bench_datX.GroupSamplesBy(96);
    bench_datX.iniVecResol = 'Quarters';
    bench_datX.iniVecUnits = 'MW';

    idx = 1;
    % For September month: t_current = 23329, 23329 par.N_steps = 2880 
    t_final = t_current + par.N_steps;

    y_obs       = zeros(1,par.N_prd);
    cdf_inv_hat = zeros(par.N_prd,length(par.tau));
    CRPS_qrf    = zeros(par.N_steps,par.N_prd);
    CRPS_bnch   = zeros(par.N_steps,par.N_prd);
    %% SIMULATION
    for t = t_current : t_final

        i_quart = hour(ttData.time(t))*4 + floor(minute(ttData.time(t))/15) + 1;
        [ecdf_hat_bnch,y_bnch] = ecdf(bench_datX.iniVec(i_quart,:));

        for k = 1 : par.N_prd
            sum_qrf = 0;
            sum_bnch = 0;

            y_obs(1,k) = Data_norm(t + k);

            predX = zeros(1,par.lagsNum);
            for n = 0 : par.lagsNum - 1
                predX(1,n+1) = Data(t - n);
            end

            [quantiles.Q{k}, quantiles.W{k}]  = quantilePredict(Mdl.M{k,par.leafSizeIdx},predX,'Quantile',par.tau);

            quantiles_norm.Q{k} = rescale(quantiles.Q{k},0,1,'InputMin',min(Data),'InputMax',max(Data));

            cdf_inv_hat(k,:) = quantiles_norm.Q{k};
            [ecdf_hat,y] = ecdf(cdf_inv_hat(k,:));

            % CRPS calculation from QRF
            for dy = min(y) : delta_y : max(y) % should it be maybe:  for dy = 0 : 0.01 : 1 (?)

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
                    cdf_hat_k_bnch = ecdf_hat_bnch(1);
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

            CRPS_qrf(idx,k)  = sum_qrf  * 100;
            CRPS_bnch(idx,k) = sum_bnch * 100;

        end
        idx = idx + 1;
    end

    CRPS_ave_qrf  = mean(CRPS_qrf,1);
    CRPS_ave_bnch = mean(CRPS_bnch,1);

    skill_sc = (1 - (mean(CRPS_ave_qrf)/mean(CRPS_ave_bnch)))*100;
    %% FIGURE: COMPARE RESULTS
    myFigs.crps.figWidth = 7; myFigs.crps.figHeight = 5;
    myFigs.crps.figBottomLeftX0 = 2; myFigs.crps.figBottomLeftY0 =2;
    myFigs.crps.fig = figure('Name',['CRPS_t_',datestr(ttData.time(t_current)),'_to_t_',datestr(ttData.time(t_final))],...
        'NumberTitle','off','Units','inches','Position',[myFigs.crps.figBottomLeftX0 myFigs.crps.figBottomLeftY0 myFigs.crps.figWidth myFigs.crps.figHeight],...
        'PaperPositionMode','auto');

    str_k = cell(1,par.N_prd);
    for k = 1 : par.N_prd
        str_k{k} = ['t+',num2str(k)];
    end

    myFigs.crps.ax = gca;
    myFigs.crps.p1 = plot(1:par.N_prd,CRPS_ave_qrf,'--sk','Linewidth',1.3);
    hold on;
    myFigs.crps.p2 = plot(1:par.N_prd,CRPS_ave_bnch,'--sr','Linewidth',1);
    hold off;

    myFigs.crps.ax.XAxis.Label.Interpreter = 'latex';
    myFigs.crps.ax.XTick = (1:par.N_prd);
    myFigs.crps.ax.XLim = [1 par.N_prd];
    myFigs.crps.ax.XTickLabel = str_k;
    myFigs.crps.ax.TickLabelInterpreter  = 'latex';

    myFigs.crps.ax.YAxis.Label.Interpreter = 'latex';
    myFigs.crps.ax.YAxis.Label.String = 'CRPS [\%]';
    myFigs.crps.ax.YAxis.Color = 'black';
    % myFigs.crps.ax.YAxis.FontSize  = 18;
    myFigs.crps.ax.YAxis.FontName = 'Times New Roman';
    %     myFigs.crps.ax.YLim = [0,1];

    myFigs.crps.ax.XGrid = 'on';
    myFigs.crps.ax.YGrid = 'on';

    legend(myFigs.crps.ax,{'QRF','CH-PeEn'},'FontSize',12,...
        'Fontname','Times New Roman','NumColumns',1,'interpreter','latex','Location','northeast');
end