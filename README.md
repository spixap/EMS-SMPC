# EMS-SMPC # 
 This repository contains the scripts :scroll: and data :open_file_folder: used for the EMS-SMPC paper :page_facing_up:.
 
 ## RANDOM FORESTS (RF) :deciduous_tree: ## 
 
  _Need to load data:_
  
  - `GFA_15_min` &nbsp;&nbsp;(_platform load_)
  - `RES` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (_wind speed_)
 
 `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\DataFiles\dataTimeseries.mat')`
 
  1. __TRAINING__
       * `train_RF.m` &nbsp; train RF models
       * Output: 
         - `Mdl_ld` (_load RF models_)
         - `Mdl_wp` (_wind power RF models_)

  2. __OUTPUT FIGURES__  
       * `figures_section_2_2.m` &nbsp;&nbsp; create figures of paper Section 2.2 (MSE, NRMSE, zoom forecasts k=1/k=6) (Figures 2-3)
       * `forecast_plots.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create plots for deterministic, probabilistic and scenario forecasts for selected date

 
 ## MAIN (DMPC/SMPC) SIMULATIONS :notebook_with_decorative_cover: ##
 _Need to load trained RF models:_
 
 `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\DataFiles\trainedRFmodels.mat')`

 1. __INPUTS :clipboard: :floppy_disk:__
    * `user_defined_inputs.m` &nbsp; define the input structure

 2. __SYSTEM SIMULATION__  
    * `main.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; simulate system with DMPC/SMPC
    * `optProb.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; formulate the MILP optimization for poblem for DMPC/SMPC
    * `control_plots.m` &nbsp; plot MPC states evolution and control effort for selected method (DMPC/SMPC)

 3. __PAPER RESULTS__  
    * `kpi_compare.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; perform KPI comparison on the results with DMPC/SMPC (Table 8)
    * `figures_section_4_1_2.m` &nbsp;&nbsp; create figures of Section 4.1.2 (forecasts on events, mean, quantiles, scenarios) (Figures 7-9)
    * `figures_section_4_2.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create figures of Section 4.2 (net load, rule-based areas, GT status and SoC (DMPC/SMPC)) (Figures 10-15)



 <details>
  <summary> Default <code>input</code> values :1234:</summary>

  * `input.startingDay  = 100`
  * `input.durationDays = 1`
  * `input.giveStartingTime = 0`              % {0, 1}
  * `inut.startingTime = 7630`
  * `input.doAnimation = 0`                   % {0, 1}
  * `input.animationVar = 'load'`             % {'load', 'wind'}
  * `input.randomSeed = 24`
  * `input.method = 'scn_frcst'`              % {'point_frcst', 'scn_frcst'}
  * `input.degradWeight = 'noWeight'`         % {'noWeight','none', 'normal', 'low', 'medium', 'high'}
  * `input.N_steps = 300`
  * `input.N_prd = 6`                         % {_MPC simulation_, _CRPS calculation_} = {6, 12}
  * `input.lgdLocationDstrb = 'southwest'`
  * `input.lgdLocationIgtOn = 'southeast'`
  * `input.lgdLocationSoC = 'southeast'`

</details>
   

 _Specialized functions used by the above main scripts :arrow_down:_
 
 1. ### PARAMETERS :bar_chart: ###
    `preamble.m` assigns :paperclip: parameter values.

    <details>
     <summary> Default <code>par</code> values  :1234:</summary>

     * `par.Ts = 15`                                     % Timestep (minutes)
     * `par.dol2eur    = 0.89`                           % dollars to euros conversion
     * `par.rhoGas     = 0.717`                          % Natural Gas density [kg/m^3]
     * `par.c_dump     = 10*100`                         % artificial cost (per unit of dumped power per period)
     * `par.c_soc_dev  = 0*10*100*100`                   % artificial cost (per unit of absolute SoC deviation in the end)
     * `par.c_fuel     = 0.24/par.rhoGas * par.dol2eur`  % [euros/kgGas]
     * `par.c_gt_srt   = 1217`                           % [euros/GTstart]
     * `par.c_gt_ON    = 5000`                           % [euros/GT_ON sattus]
     * `par.c_Bat_rpl  = par.degradWeight * 500000 * par.dol2eur`     % replacement cost [euros/MWh]
     * `par.c_Bat_res  = par.degradWeight * 50000  * par.dol2eur`     % residual value [euros/MWh]
     * `par.leafSizeIdx = 1`
     * `par.lamda       = 0.5`
     * `par.tau         = linspace(0,1,21)`
     * `par.lagsNum     = 6`
     * `par.N_pwl = 11`      % # of discretization points for PieceWise Linear approx.
     * `par.N_gt  = 4`       % # of Gas Turbines
     * `par.P_gt_nom  = 20.2`                   % Nominal GT power rating
     * `par.P_gt_min  = 0.20 * par.P_gt_nom`
     * `par.P_gt_max  = 1.09 * par.P_gt_nom`
     * `par.gt_RR     = par.P_gt_max`           % Ramping Rate
     * `par.spinRes   = 1.05`
     * `par.idleFuel  = 172*0.2*20.2+984`       % [kg/h] coming from min GT fuel consumption (linear curve) - intercept @ no load: 172*0.2*20.2+984
     * `par.P_gt_data = linspace(par.P_gt_min,par.P_gt_max,par.N_pwl)`
     * `par.fuel_data = (0.5109 * par.P_gt_data.^2 -20.933 .* par.P_gt_data + 433.83)`   % [kg/MWh]
     * `par.batLifetime = 10`        % Lifetime expectancy of battery
     * `par.daysOfYear  = 365`       % To convert to equivalent daily cost
     * `par.hoursOfday  = 24`        % To convert to equivalent hourly cost
     * `par.qrtrOfHour  = 4`         % To convert to equivalent cost/quarter
     * `par.a           = 1591.1`    % Proportional constant of cycling curve
     * `par.k           = 2.089`     % Exponent of cycling curve
     * `ar.DoD_data    = linspace(0,1,par.N_pwl)'`        % Depth-Of-Discharge [0-1]
     * `par.Ncyc        = par.a*par.DoD_data.^(-par.k)`     % Cycle lifetime (# of cycles)
     * `par.rho_data    = 100*100./par.Ncyc`               % Percentage degradation [%] - (times 100 for scaling purposes)
     * `par.eta_ch     = 0.95`        % charging efficieny
     * `par.eta_dis    = 0.95`        % discharging efficieny
     * `par.P_bat_max  = 5`           % power rating [MW] nominal: 5
     * `par.E_bat_max  = 10`          % capacity rating [MWh] nominal: 10
     * `par.socUPlim   = 0.8`         % up SoC limit [-]
     * `par.socDOWNlim = 0.2`         % down SoC limit [-]
     * `par.SoC_ref    = 0.5`         % reference SoC 
     * `par.N_scn = 10`

   </details>
       
    
 2. ### SCENARIO FORECASTING :crystal_ball: ###
    1. - `funScenGenQRF1.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; generate scenarios 1 step ahead 
    2. - `funScenGenQRF.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; generate scenarios many steps ahead (_used to make gifs along with_ `funAnimateQRF.m`)
    3. - `funScenFrcstFig1step.m` &nbsp; plot scenario forecasts for selected time
    4. - `funProbFrcstFig1step.m` &nbsp; plot quantile forecasts for selected time
    5. - `funFrcstFig1step.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; plot both scenario and quantile forecasts for selected time
    6. - `funAnimateQRF.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; produce gifs of forecasting             
                      

 3. ### GET/PLOT RESULTS :bulb: ###
    1. - `funGetCtrlRslt.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; calculated KPIs from simulation in <code>kpi</code> 
    2. - `funPltCtrlRslt.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; plot the control variables (states and inputs) results for a method (DMPC/SMPC) 
    3. - `funPltCtrlRsltPretty.m` &nbsp; plot the control variables (states and inputs) results for a method (DMPC/SMPC) _in a pretty way_

 4. ### CRPS :chart_with_upwards_trend: ###
    1. - `funCalcCRPS.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; calculate CRPS, skill score and plot CRPS for all lead times, for selected period of                                                                                             time with QRF forecasts and benchmark method (paper: Figure 6, Table 1)
    2. - `funCalcCRPS1step.m` &nbsp; calculate CRPS for single predictions and plot cdf to compare QRF and benchmark method forecasts for each lead time
    3. - `funCovCorrGenQRF.m` &nbsp; Estimate covariance and correlation matrices from inverse transformed data based on probabilistic forecasts from QRF models


## SIMULATION CASE STUDIES :hourglass: ##

<details>
  <summary>Cases studies (Section 4.2) :date:</summary>
  
  * Day 100: 10 April 
  * Day 118: 27 April
  * Day 226: 14 August
  * Day 61:  02 March
  * Day 166: 15 June
  * Day 160: 09 June

</details>


<details>
  <summary>Irregular events (Section 4.1.2) :date:</summary>
  
 
  __Load__ 
  * current time: 7630
  * current time: 7635
  * current time: 7636
  * current time: 7709
 
   __Wind__ 
  * current time: 7646
  * current time: 7647
  * current time: 7648
  * current time: 7749
 
  * current time: 7760
  * current time: 7761
  * current time: 7762
  * current time: 7763

</details>

## DATA FILES :open_file_folder: ##
- [ ] To upload the data
