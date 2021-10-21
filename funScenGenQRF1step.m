function [xi] = funScenGenQRF1step(ttData, par, Data, t_current, Mdl, animPar, Sigma_rec_t_prev_inf, simIter, fig_ctrl)
%QRF_frcst Summary of this function goes here
%   Generate scenarios based on probabilistic QRF forecasts

mu = zeros(1,par.N_prd);       % MVN(0,Sigma)

if fig_ctrl == 1
    FigH = figure('WindowState','maximized');
    axis tight manual                       % this ensures that getframe() returns a consistent size
    ax = gca;
    ax.YLim = ([min(Data) max(Data)]);
end

% SIMULATION
idx_gif = 1;                            % index to measure frames - indicates how many time steps have been executed
% par.randomSeed = 24;
idx_t = t_current;


cdf_inv_hat = zeros(par.N_prd,length(par.tau));
Y_k         = zeros(1,par.N_prd);
X_k         = zeros(1,par.N_prd);

window.width  = 2 * par.N_prd;
window.t_slide_start = idx_t - window.width;
window.t_slide_end   = idx_t + window.width;
window.t_slide_range = window.t_slide_start : window.t_slide_end;

predX = zeros(1,par.lagsNum);
for n = 0 : par.lagsNum-1
    predX(1,n+1) = Data(idx_t-n);
end

predY = zeros(1,par.N_prd);
trueY = zeros(1,par.N_prd);
for k = 1 : par.N_prd
    predY(1,k) = predict(Mdl.M{k,par.leafSizeIdx},predX);
    trueY(1,k) = Data(idx_t+k);
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


% Create non-parametric forecast of the pdf
% gathering the m quantile forecasts inverse of cdf)

% Querry Points p(k): Power measurements at eack k = 1,...,K
% Y_k: K random variables ~ U[0,1] (ideally)
% X_k: K transformed random variables ~ N(0,1) (ideally)

for k = 1 : par.N_prd
    
    cdf_inv_hat(k,:) = quantiles.Q{1,k};
    [f_ecdf,x_ecdf] = ecdf(cdf_inv_hat(k,:));
    
    if length(x_ecdf) <= 1
        Y_k(idx_gif,k) = f_ecdf(1);
    elseif length(x_ecdf) <= 2
        Y_k(idx_gif,k) = (f_ecdf(1) + f_ecdf(2))/2;
    elseif length(x_ecdf) <= 3
        Y_k(idx_gif,k) = (f_ecdf(2) + f_ecdf(3))/2;
    else
        Y_k(idx_gif,k) = interp1(x_ecdf(2:end),f_ecdf(2:end),trueY(k),'linear','extrap');
    end
    
    X_k(idx_gif,k) = norminv(Y_k(idx_gif,k));
    
    
    if abs(X_k(idx_gif,k)) >= 5
        if X_k(idx_gif,k) >= 0
            X_k(idx_gif,k) = 5;
        else
            X_k(idx_gif,k) = -5;
        end
    end
    
end
%%
% Calculation of unbiased estimate of covariance matrix at time t
% Based on:
% P. Pinson, H. Madsen, H. A. Nielsen, G. Papaefthymiou, and B. Klöckl, “From probabilistic forecasts to statistical scenarios of short-term wind power production,” Wind Energy, vol. 12, no. 1, pp. 51–62, 2009, doi: 10.1002/we.284.
% K: maximum forecastHorizon (predHorK)
% X: vector of random variables for lead times k = 1,...K
%% Recursively updated Sigma (initialization at the first simulation timestep)
if simIter == 1
    Sigma_hat_rec_t_inf = Sigma_rec_t_prev_inf;
else
    %             X = zeros(par.N_prd,1);
    %             for k = 1 : par.N_prd
    %                 X(k,1) = X_k(simIter-par.N_prd,k);
    %             end
    X = X_k';
    Sigma_hat_rec_t_inf  = par.lamda * Sigma_rec_t_prev_inf + (1-par.lamda) * (X*X');
end

% Covariance Matrix Singularity Check

eig_Sigma = eig(Sigma_hat_rec_t_inf);
if min(eig_Sigma) < 0
   Sigma_hat_rec_t_inf = Sigma_hat_rec_t_inf + 0.001*eye(par.N_prd);
end

Rho_hat_rec_t_inf = corrcov(Sigma_hat_rec_t_inf);

%         if abs(sum(Rho_hat_rec_t_inf,'all') - par.N_prd^2) <= 0.00001
%            Rho_hat_rec_t_inf = diag(ones(par.N_prd,1));
%         end

%         if sum(sum(Rho_hat_rec_t_inf(1:end-1,1:end-1))) >= (par.N_prd-1)^2-1
%            Rho_hat_rec_t_inf = diag(ones(par.N_prd,1));
%         end


idx_diag = eye(par.N_prd,par.N_prd);
% Y = (1-idx_diag).*Rho_hat_rec_t_inf;
nonDiag = Rho_hat_rec_t_inf(~idx_diag);

if ~isempty(find(nonDiag==1,1)) || min(abs(nonDiag-1))<= 0.01
    Rho_hat_rec_t_inf = diag(ones(par.N_prd,1));
end

%% Generate Copula samples
rng(par.randomSeed);

R = chol(Rho_hat_rec_t_inf);
X_k_norm = repmat(mu,par.N_scn,1) + randn(par.N_scn,par.N_prd)*R;

U_k = normcdf(X_k_norm);

P_k = zeros(par.N_scn,par.N_prd);
for k = 1 : par.N_prd
    %     P_k(:,k) = interp1(par.tau,quantiles.Q{1,k},U_k(:,k));
    %     P_k(:,k) = interp1(par.tau(2:end),quantiles.Q{1,k}(2:end),U_k(:,k));
    P_k(:,k) = interp1(par.tau(2:end-1),quantiles.Q{1,k}(2:end-1),U_k(:,k),'linear','extrap');
    % ASSIGN SCENARIOS
    xi.scen(idx_gif,k,:) = P_k(:,k);
end

xi.Sigma_hat_rec_t_inf = Sigma_hat_rec_t_inf;
xi.Rho_hat_rec_t_inf   = Rho_hat_rec_t_inf;
xi.meanFrcst           = predY;

if fig_ctrl == 1
    funAnimateQRF(ttData, ax, FigH, quantsY, t_current, par, Data, idx_t, window, idx_gif, animPar, xi.scen(idx_gif,:,:));
end


%     end
end

