%%%%%%%%%%%%%%%%%%%%%%%%%%% EMS_SMPC_MILP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----SOLVE EMS PROBLEM AS SMPC-----

%-----author : Spyridon Chapaloglou
%-----date   : 14/10/2021
%-----version: 2.0
%-----paper  : "A data-informed stochastic model predictive control approach for energy management of isolated power systems"

%--- DESCRIPTION:{
% Design the energy managemnt algorithm (EMS) as a stochastic model predictive controller (SMPC) 
% under a MILP formulation. This program simulates a wind powered offshore O&G simplified system
% by applying the proposed SMPC_MILP technique.
%..................................................................}
%% --------------------------\\ INPUTS \\------------------------------
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\DataFiles\models.mat')
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\DataFiles\dataTimeseries.mat')


user_defined_inputs;

clearvars -except DataTot GFA_15_min RES Mdl_wp Mdl_ld Data_ld Data_wp spi w8bar crps input t_current y1 test1
close all; clc;
if exist('w8bar')==1
    delete(w8bar);
end
rng(0,'twister');

preamble;
%% --------------------------\\ SIM-START \\-------------------------------
t_start = t_current;
t_end   = t_start + par.N_steps;

u_0 = zeros(2 + 2*par.N_gt , par.N_steps + 1);
x   = zeros(1 + par.N_gt , par.N_steps + 1);
netLoad = zeros(par.N_steps + 1, 1);
netLoadFrcst = zeros(par.N_steps + 1, par.N_scn);

w8bar = waitbar(0,'Simulation started');

simIter = 1;
for t = t_start : t_end
    %% ---------------------------\\ MPC-START \\------------------------------
    % --------------------------\\ CURRENT STATE \\----------------------------
    if simIter==1
%         x_gt_0  = ones(N_gt,1);
        x_gt_0  = zeros(par.N_gt,1);
%         x_gt_0(1) = 1;
%         x_gt_0(2) = 1;
        x_soc_0 = 0.5;
%         x_soc_0 = 0.2135;
        E_s_0   = x_soc_0 * par.E_bat_max;  % Initial capacity @ k = 0 (this will become input)
        x_0     = [x_soc_0;x_gt_0];
        x(:,1)  = x_0;
%         x_0_ini = x_0;
    else
        x_soc_0 = x_0(1);
        E_s_0   = x_soc_0 * par.E_bat_max;  % Initial capacity @ k = 0 (this will become input)
        x_gt_0  = x_0(2:end);
    end
    
%     if simIter < 20
%         par.SoC_ref = 0.78;
%     elseif simIter < 40
%         par.SoC_ref = 0.36;
%     elseif simIter < 60
%         par.SoC_ref = 0.44;
%     elseif simIter < 80
%         par.SoC_ref = 0.59;
%     else
%         par.SoC_ref = 0.71;
%     end
    %% ----------------------\\ FORECAST - SCENARIOS \\------------------------
    xi.L = zeros(par.N_prd,par.N_scn);
    xi.W = zeros(par.N_prd,par.N_scn);
    
    % PART A - LOAD
    ttData = GFA_15_min;
    ttData.Properties.DimensionNames{1} = 'time';
    ttData.Properties.VariableNames{1} = 'data';
    Mdl  = Mdl_ld;
%     Data = Data_ld;
    Data = ttData.data;
    
    % Recursively update Sigma (initialization for the first simulation timestep)    
    if simIter == 1
        Sigma_rec_t_prev_inf_memory_ld = diag(ones(par.N_prd,1));
        funOut = funScenGenQRF1step(ttData, par, Data, t, Mdl, [], Sigma_rec_t_prev_inf_memory_ld, simIter, 0);
    else
        funOut = funScenGenQRF1step(ttData, par, Data, t, Mdl, [], Sigma_rec_t_prev_inf_memory_ld, simIter, 0);
    end
    Sigma_rec_t_prev_inf_memory_ld = funOut.Sigma_hat_rec_t_inf;

    % Measurement (k = 0)
    xi.L(1,:) = Data(t);
    % Forecast (k = 1...K-1)
    if strcmp(input.method,'scn_frcst')==1
        xi.L(2:end,:) = funOut.scen(:,1:end-1,:);
    elseif strcmp(input.method,'point_frcst')==1
        xi.L(2:end,1) = funOut.meanFrcst(1:end-1);
    end
   
    % PART B - WIND POWER
    newTimes = (datetime(2018,1,1,00,00,00):minutes(15):datetime(2018,12,31,23,45,00))';
    ttData   = retime(RES,newTimes,'linear');
    Mdl  = Mdl_wp;
    ttData.Properties.DimensionNames{1} = 'time';
    ttData.Properties.VariableNames{1} = 'data';
%     Data = Data_wp;
    Data = ttData.data;

    
    % Recursively update Sigma (initialization for the first simulation timestep)
    if simIter == 1
        Sigma_rec_t_prev_inf_memory_wp = diag(ones(par.N_prd,1));
        funOut = funScenGenQRF1step(ttData, par, Data, t, Mdl, [], Sigma_rec_t_prev_inf_memory_wp, simIter, 0);
    else
        funOut = funScenGenQRF1step(ttData, par, Data, t, Mdl, [], Sigma_rec_t_prev_inf_memory_wp, simIter, 0);
    end
    Sigma_rec_t_prev_inf_memory_wp = funOut.Sigma_hat_rec_t_inf;
    
    
    % Measurement (k = 0)
    xi.W(1,:) = Data(t);
    % Forecast (k = 1...K-1)
    if strcmp(input.method,'scn_frcst')==1
        xi.W(2:end,:) = funOut.scen(:,1:end-1,:);
    elseif strcmp(input.method,'point_frcst')==1
        xi.W(2:end,1) = funOut.meanFrcst(1:end-1);
    end
    
    % ---------------\\ Formulate Optimization Problem \\------------------
    optProb;
    
    % ------------------\\Solve Optimization Problem \\--------------------
    options            = optimoptions('intlinprog');
    options.MaxTime    = 5*60;
    options.RelativeGapTolerance = 0.005;
    [sol,fsol]         = solve(probMPC,'Options',options);
    rslt.sol(simIter)  = sol;
    rslt.fsol(simIter) = fsol;
    rslt.xi(simIter)   = xi;
    % ---------------------------\\ MPC-END \\---------------------------------
    %% GET CONTROL ACTION FROM THE OPTIMISATION RESULT
    u       = zeros(par.N_prd,2 + 2*par.N_gt);
    u_Pch   = zeros(par.N_prd,1);
    u_Pdis  = zeros(par.N_prd,1);
    u_GTon  = zeros(par.N_prd,par.N_gt);
    u_GToff = zeros(par.N_prd,par.N_gt);
    
    for w = 1 : par.N_scn
        for prdIndx = 0 : par.N_prd - 1
            u_Pch(prdIndx+1,1)  = sol.Power_charging(prdIndx+1,1);
            u_Pdis(prdIndx+1,1) = sol.Power_discharging(prdIndx+1,1);
            for g = 1 : par.N_gt
                u_GTon(prdIndx+1,g)  = sol.GT_startUP_indicator(prdIndx+1,1,g);
                u_GToff(prdIndx+1,g) = sol.GT_shutDOWN_indicator(prdIndx+1,1,g);
            end
        end
        u = [u_Pch u_Pdis];
        for g = 1 : par.N_gt
            u(:,2+2*g-1) = u_GTon(:,g);
            u(:,2+2*g)   = u_GToff(:,g);
        end
    end
    % KEEP FIRST CONTROL ACTION (for current time k = 0)
    u_0(:,simIter) = u(1,:)';
    % KEEP NET LOAD DATA AND FORECASTS (for each iteration)
    netLoad(simIter) = xi.L(1,1) - xi.W(1,1);
    netLoadFrcst(simIter,:) = xi.L(2,:) - xi.W(2,:);
    % ---------------------------\\ STATE UPDATE \\----------------------------
    x(:,simIter+1) = par.A_sys * x_0 + par.B_sys * u_0(:,simIter);
    x_0            = x(:,simIter+1);
    
    disp(['iter = ', num2str(simIter),' out of ',num2str(par.N_steps+1)]);
    if par.N_steps > 0
        disp(['Simulation Status: ', num2str(((simIter-1)/(par.N_steps)*100),3),' %']);
        waitbar((simIter-1)/(par.N_steps),w8bar,['Simulation status: ',num2str(((simIter-1)/(par.N_steps)*100),3),' %'])
    end
    
    simIter        = simIter + 1;
    
    clearvars -except simIter par rslt...
                      A_sys B_sys x_0 x u_0...
                      N_pwl N_prd N_scn N_gt...
                      GFA_15_min RES Mdl_wp Mdl_ld...
                      t_start t_end netLoad netLoadFrcst...
                      probMPC...
                      P_gt pwl_fuel_w pwl_fuel_bin pwl_deg_w pwl_deg_bin deg...
                      deg_cyc DP_cyc DP_cal DP bin_dis P_d soc_dev_abs soc_dev_p...
                      soc_dev_n DOD bin_gt P_ch P_dis bin_strUP_gt bin_shtDOWN_gt...
                      spi ...
                      DOD_vec P_ch_vec P_dis_vec ...
                      nrgUpdtMtrxBig powBalanceCnstr statesGTCnstr strtUPCnstr shtDOWNCnstr shtDOWNCnstr2 ...
                      x_0_ini w8bar ...
                      C_fuel C_deg C_gt_strUP C_gt_ON C_dump C_soc_dev ...
                      Sigma_rec_t_prev_inf_memory_ld Sigma_rec_t_prev_inf_memory_wp...
                      input t_current...
                      %  DataTot GFA_15_min RES Mdl_wp Mdl_ld Data_ld Data_wp...

end
% -----------------------------\\ SIM-END \\-------------------------------
%% ----------------------------\\ RESULTS \\-------------------------------
ttData = GFA_15_min;
ttData.Properties.DimensionNames{1} = 'time';

funPltCtrlRslt(par, ttData, t_start, t_end, x, u_0, rslt);
% funPltCtrlRslt(par, x, u_0, rslt);


% GET PARTICIPATION OF EACH TERM TO OBJECTIVE VALUE FOR A SINGLE ITERATION
%{
costBars = [evaluate(C_fuel,rslt.sol) evaluate(C_deg,rslt.sol)...
    evaluate(C_gt_strUP,rslt.sol) evaluate(C_gt_ON,rslt.sol)...
    evaluate(C_dump,rslt.sol) evaluate(C_soc_dev,rslt.sol)];

figure;
hold on;
bar(costBars,'stacked');legend('Fuel consumption','Degradation','GT start up','GT on status','Dumping','SoC deviation');
yline(evaluate((1/N_scn) * sum(y_w),rslt.sol),'--r','Objective value of expectation');
hold off;
%}

% kpi = funGetCtrlRslt(par, ttData, t_start, t_end, x, u_0, rslt);
kpi = funGetCtrlRslt(par, x, u_0, rslt);
%% --------------------------\\ SAVE RESULTS \\----------------------------
%{
FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EMS_V02\OutputFiles';   % Your destination folder
outFileName     = ['MPC_run_',date,'-',datestr(now,'HHMMSS')];
matFileName     = fullfile(FolderDestination,outFileName);  
save(matFileName,'par','ttData','t_start','t_end','x','u_0','rslt','kpi');
%}

FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Results\Revision\degradWeight';   % Your destination folder
outFileName     =  [input.simulPeriodName,'.mat'];
matFileName     = fullfile(FolderDestination,outFileName); 

if isfile(matFileName)
   load(matFileName,'RSLT')
end
% 

switch input.degradWeight

    case 'none'
        
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.noDegrad.u_0 = u_0;
            RSLT.ESS_scn.noDegrad.rslt = rslt;
            RSLT.ESS_scn.noDegrad.x = x;
            RSLT.ESS_scn.noDegrad.kpi = kpi;
            RSLT.ESS_scn.noDegrad.t_start = t_start;
            RSLT.ESS_scn.noDegrad.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.noDegrad.u_0 = u_0;
            RSLT.ESS_mean.noDegrad.rslt = rslt;
            RSLT.ESS_mean.noDegrad.x = x;
            RSLT.ESS_mean.noDegrad.kpi = kpi;
            RSLT.ESS_mean.noDegrad.t_start = t_start;
            RSLT.ESS_mean.noDegrad.t_end = t_end;
        end
        
    case 'normal'
        
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.normalDegrad.u_0 = u_0;
            RSLT.ESS_scn.normalDegrad.rslt = rslt;
            RSLT.ESS_scn.normalDegrad.x = x;
            RSLT.ESS_scn.normalDegrad.kpi = kpi;
            RSLT.ESS_scn.normalDegrad.t_start = t_start;
            RSLT.ESS_scn.normalDegrad.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.normalDegrad.u_0 = u_0;
            RSLT.ESS_mean.normalDegrad.rslt = rslt;
            RSLT.ESS_mean.normalDegrad.x = x;
            RSLT.ESS_mean.normalDegrad.kpi = kpi;
            RSLT.ESS_mean.normalDegrad.t_start = t_start;
            RSLT.ESS_mean.normalDegrad.t_end = t_end;
        end
        
    case 'low'
        
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.lowDegrad.u_0 = u_0;
            RSLT.ESS_scn.lowDegrad.rslt = rslt;
            RSLT.ESS_scn.lowDegrad.x = x;
            RSLT.ESS_scn.lowDegrad.kpi = kpi;
            RSLT.ESS_scn.lowDegrad.t_start = t_start;
            RSLT.ESS_scn.lowDegrad.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.lowDegrad.u_0 = u_0;
            RSLT.ESS_mean.lowDegrad.rslt = rslt;
            RSLT.ESS_mean.lowDegrad.x = x;
            RSLT.ESS_mean.lowDegrad.kpi = kpi;
            RSLT.ESS_mean.lowDegrad.t_start = t_start;
            RSLT.ESS_mean.lowDegrad.t_end = t_end;
        end
        
    case 'medium'
        
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.mediumDegrad.u_0 = u_0;
            RSLT.ESS_scn.mediumDegrad.rslt = rslt;
            RSLT.ESS_scn.mediumDegrad.x = x;
            RSLT.ESS_scn.mediumDegrad.kpi = kpi;
            RSLT.ESS_scn.mediumDegrad.t_start = t_start;
            RSLT.ESS_scn.mediumDegrad.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.mediumDegrad.u_0 = u_0;
            RSLT.ESS_mean.mediumDegrad.rslt = rslt;
            RSLT.ESS_mean.mediumDegrad.x = x;
            RSLT.ESS_mean.mediumDegrad.kpi = kpi;
            RSLT.ESS_mean.mediumDegrad.t_start = t_start;
            RSLT.ESS_mean.mediumDegrad.t_end = t_end;
        end
        
    case 'high'
        
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.highDegrad.u_0 = u_0;
            RSLT.ESS_scn.highDegrad.rslt = rslt;
            RSLT.ESS_scn.highDegrad.x = x;
            RSLT.ESS_scn.highDegrad.kpi = kpi;
            RSLT.ESS_scn.highDegrad.t_start = t_start;
            RSLT.ESS_scn.highDegrad.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.highDegrad.u_0 = u_0;
            RSLT.ESS_mean.highDegrad.rslt = rslt;
            RSLT.ESS_mean.highDegrad.x = x;
            RSLT.ESS_mean.highDegrad.kpi = kpi;
            RSLT.ESS_mean.highDegrad.t_start = t_start;
            RSLT.ESS_mean.highDegrad.t_end = t_end;
        end
        
    otherwise
            
        if strcmp('scn_frcst',input.method)
            RSLT.ESS_scn.u_0 = u_0;
            RSLT.ESS_scn.rslt = rslt;
            RSLT.ESS_scn.x = x;
            RSLT.ESS_scn.kpi = kpi;
            RSLT.ESS_scn.t_start = t_start;
            RSLT.ESS_scn.t_end = t_end;
        elseif strcmp('point_frcst',input.method)
            RSLT.ESS_mean.u_0 = u_0;
            RSLT.ESS_mean.rslt = rslt;
            RSLT.ESS_mean.x = x;
            RSLT.ESS_mean.kpi = kpi;
            RSLT.ESS_mean.t_start = t_start;
            RSLT.ESS_mean.t_end = t_end;
        end
end

save(matFileName,'RSLT')
%% ------ANIMATE THE FORECASTS FOR A GIVEN (SIMULATION) TIME PERIOD--------
if input.doAnimation == 1
    if strcmp('load',input.animationVar)      
        ttData = GFA_15_min;
        ttData.Properties.DimensionNames{1} = 'time';
        ttData.Properties.VariableNames{1} = 'data';
        Mdl  = Mdl_ld;
        %     Data = Data_ld;
        Data = ttData.data;

        
    elseif strcmp('wind',input.animationVar)
        newTimes = (datetime(2018,1,1,00,00,00):minutes(15):datetime(2018,12,31,23,45,00))';
        ttData   = retime(RES,newTimes,'linear');
        Mdl  = Mdl_wp;
        ttData.Properties.DimensionNames{1} = 'time';
        ttData.Properties.VariableNames{1} = 'data';
        %     Data = Data_wp;
        Data = ttData.data;
        
    end
%     animPar.fulVidName = [input.simulPeriodName,'_',input.animationVar,'.mp4'];
    animPar.fulGifName = [input.simulPeriodName,'_',input.animationVar,'.gif'];
        
    funScenGenQRF(ttData, par, Data, t_current, Mdl, animPar, 1)
end