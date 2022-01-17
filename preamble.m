%-----INITIALIZE PARAMETER VALUES-----
%% ----------------------------\\ BASICS \\--------------------------------
par.Ts      = 15;               % Timestep (minutes)
par.N_prd   = input.N_prd;  
par.N_steps = input.N_steps;  
if strcmp(input.method,'point_frcst')==1
    par.N_scn   = 1;
else
    par.N_scn   = 25;           % # of scenarios
end
par.randomSeed = input.randomSeed;  
%% --------------------------\\ COST COEFS \\ -----------------------------
par.dol2eur    = 0.89;                 % dollars to euros conversion
par.rhoGas     = 0.717;                % Natural Gas density [kg/m^3]
par.c_dump     = 10*100;               % artificial cost (per unit of dumped power per period)
par.c_soc_dev  = 0*10*100*100;         % artificial cost (per unit of absolute SoC deviation in the end)
par.c_fuel     = 0.24/par.rhoGas * par.dol2eur;  % [euros/kgGas]
par.c_gt_srt   = 1217;                 % [euros/GTstart]
par.c_gt_ON    = 5000;                 % [euros/GT_ON sattus]

switch input.degradWeight
    case 'none'
         par.degradWeight = 0;
    case 'normal'
         par.degradWeight = 1;
    case 'high'
         par.degradWeight = 10000;
    otherwise
        par.degradWeight = 1;
end

par.c_Bat_rpl  = par.degradWeight * 500000 * par.dol2eur;     % replacement cost [euros/MWh]
par.c_Bat_res  = par.degradWeight * 50000  * par.dol2eur;     % residual value [euros/MWh]
%% --------------------------\\ PARAMETERS \\------------------------------
% FOREST
par.leafSizeIdx = 1;
par.lamda       = 0.5; 
par.tau         = linspace(0,1,21);
par.lagsNum     = 6;
                  
% ORGANIZE LOAD DATA AS DATAX OBJECT
% netLoadX        = DataX(Data_ld-Data_wp);      
% netLoadX.iniVec = netLoadX.GroupSamplesBy(96);

%-------------------------------- SETS ------------------------------------
par.N_pwl = 11;      % # of discretization points for PieceWise Linear approx.
par.N_gt  = 4;       % # of Gas Turbines
%--------------------------------- GT -------------------------------------
par.P_gt_nom  = 20.2;                   % Nominal GT power rating
par.P_gt_min  = 0.20 * par.P_gt_nom;
par.P_gt_max  = 1.09 * par.P_gt_nom;
par.gt_RR     = par.P_gt_max;           % Ramping Rate
par.spinRes   = 1.05;
par.idleFuel  = 172*0.2*20.2+984;       % [kg/h] coming from min GT fuel consumption (linear curve) - intercept @ no load: 172*0.2*20.2+984
% Fuel Curve (Technical_Specifications.txt)
par.P_gt_data = linspace(par.P_gt_min,par.P_gt_max,par.N_pwl);
par.fuel_data = (0.5109 * par.P_gt_data.^2 -20.933 .* par.P_gt_data + 433.83);   % [kg/MWh]
% fuel_data = 208.45*P_gt_data.^2-422.84.*P_gt_data+433.82; % [kg/puMWh]
%----------------------------- DEGRADATION --------------------------------
par.batLifetime = 10;        % Lifetime expectancy of battery
par.daysOfYear  = 365;       % To convert to equivalent daily cost
par.hoursOfday  = 24;        % To convert to equivalent hourly cost
par.qrtrOfHour  = 4;         % To convert to equivalent cost/quarter
par.a           = 1591.1;    % Proportional constant of cycling curve
par.k           = 2.089;     % Exponent of cycling curve
% Degradation Curve
par.DoD_data    = linspace(0,1,par.N_pwl)';         % Depth-Of-Discharge [0-1]
par.Ncyc        = par.a*par.DoD_data.^(-par.k);     % Cycle lifetime (# of cycles)
par.rho_data    = 100*100./par.Ncyc;                % Percentage degradation [%] - (times 100 for scaling purposes)
%-------------------------------- BESS ------------------------------------
par.eta_ch     = 0.95;        % charging efficieny
par.eta_dis    = 0.95;        % discharging efficieny
par.P_bat_max  = 5;           % power rating [MW] nominal: 5
par.E_bat_max  = 10;          % capacity rating [MWh] nominal: 10
par.socUPlim   = 0.8;         % up SoC limit [-]
par.socDOWNlim = 0.2;         % down SoC limit [-]
par.SoC_ref    = 0.5;         % reference SoC 
%------------------------------ SYSTEM ------------------------------------
par.A_sys  = diag(ones(1 + par.N_gt,1));
B_soc      = [par.eta_ch * (par.Ts/60) / par.E_bat_max , -(par.Ts/60) / par.eta_dis / par.E_bat_max];
B_gt       = [1 -1];
B_gt_cell  = repmat({B_gt}, 1, par.N_gt);
par.B_sys  = blkdiag(B_soc, blkdiag(B_gt_cell{:}));