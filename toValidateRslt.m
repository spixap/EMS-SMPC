%funGetCtrlRslt To get the the results of MPC and calculate KPI's
%   To get the the results of MPC and calculate KPI's


    iVecLoad       = zeros(par.N_steps + 1,1);
    iVecWndPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwr     = zeros(par.N_steps + 1,1);
    iVecGTAPwr     = zeros(par.N_steps + 1,1);
    iVecGTBPwr     = zeros(par.N_steps + 1,1);
    iVecGTCPwr     = zeros(par.N_steps + 1,1);
    iVecGTDPwr     = zeros(par.N_steps + 1,1);
    iVecDmpPwrTrue = zeros(par.N_steps + 1,1);
    iVecFuelGTA    = zeros(par.N_steps + 1,1);
    iVecFuelGTB    = zeros(par.N_steps + 1,1);
    iVecFuelGTC    = zeros(par.N_steps + 1,1);
    iVecFuelGTD    = zeros(par.N_steps + 1,1);
    iVecCostGTA    = zeros(par.N_steps + 1,1);
    iVecCostGTB    = zeros(par.N_steps + 1,1);
    iVecCostGTC    = zeros(par.N_steps + 1,1);
    iVecCostGTD    = zeros(par.N_steps + 1,1);
    iVecDegrad    = zeros(par.N_steps + 1,1);
    fuelWeightsGTA = zeros(par.N_steps + 1,par.N_pwl);
    fuelWeightsGTB = zeros(par.N_steps + 1,par.N_pwl);
    fuelWeightsGTC = zeros(par.N_steps + 1,par.N_pwl);
    fuelWeightsGTD = zeros(par.N_steps + 1,par.N_pwl);

    for i = 1 : par.N_steps + 1
        iVecLoad(i)   = rslt.xi(i).L(1,1);
        iVecWndPwr(i) = rslt.xi(i).W(1,1);
        iVecDmpPwr(i) = mean(rslt.sol(i).Power_dump(1,:));
        iVecGTAPwr(i) = mean(rslt.sol(i).Power_GT(1,:,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
        iVecGTBPwr(i) = mean(rslt.sol(i).Power_GT(1,:,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
        iVecGTCPwr(i) = mean(rslt.sol(i).Power_GT(1,:,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
        iVecGTDPwr(i) = mean(rslt.sol(i).Power_GT(1,:,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));

        iVecDmpPwrTrue(i) = iVecGTAPwr(i)+iVecGTBPwr(i)+iVecGTCPwr(i)+iVecGTDPwr(i) - ...
                            (u_0(1,i) - u_0(2,i)) - (iVecLoad(i)-iVecWndPwr(i));
                        
        fuelWeightsGTA(i,:) = rslt.sol(i).fuel_PWA_weight(1,1,1,:);
        fuelWeightsGTB(i,:) = rslt.sol(i).fuel_PWA_weight(1,1,2,:);
        fuelWeightsGTC(i,:) = rslt.sol(i).fuel_PWA_weight(1,1,3,:);
        fuelWeightsGTD(i,:) = rslt.sol(i).fuel_PWA_weight(1,1,4,:);


        iVecFuelGTA(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTA(i,:)' * rslt.sol(i).Power_GT_k0(1) + par.c_gt_ON * rslt.sol(i).GT_status_indicator(1,1,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
        iVecFuelGTB(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTB(i,:)' * rslt.sol(i).Power_GT_k0(2) + par.c_gt_ON * rslt.sol(i).GT_status_indicator(1,1,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
        iVecFuelGTC(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTC(i,:)' * rslt.sol(i).Power_GT_k0(3) + par.c_gt_ON * rslt.sol(i).GT_status_indicator(1,1,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
        iVecFuelGTD(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTD(i,:)' * rslt.sol(i).Power_GT_k0(4) + par.c_gt_ON * rslt.sol(i).GT_status_indicator(1,1,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));
%         

%         iVecFuelGTA(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTA(i,:)' * rslt.sol(i).Power_GT_k0(1) + 1600 * rslt.sol(i).GT_status_indicator(1,1,1)) * (x(2,i) + u_0(3,i) - u_0(4,i));
%         iVecFuelGTB(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTA(i,:)' * rslt.sol(i).Power_GT_k0(2) + 1600 * rslt.sol(i).GT_status_indicator(1,1,2)) * (x(3,i) + u_0(5,i) - u_0(6,i));
%         iVecFuelGTC(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTA(i,:)' * rslt.sol(i).Power_GT_k0(3) + 1600 * rslt.sol(i).GT_status_indicator(1,1,3)) * (x(4,i) + u_0(7,i) - u_0(8,i));
%         iVecFuelGTD(i) = (par.Ts/60) * (par.fuel_data * fuelWeightsGTA(i,:)' * rslt.sol(i).Power_GT_k0(4) + 1600 * rslt.sol(i).GT_status_indicator(1,1,4)) * (x(5,i) + u_0(9,i) - u_0(10,i));
%         


        iVecCostGTA(i) = par.c_fuel *  iVecFuelGTA(i) * (x(2,i) + u_0(3,i) - u_0(4,i));
        iVecCostGTB(i) = par.c_fuel *  iVecFuelGTB(i) * (x(3,i) + u_0(5,i) - u_0(6,i));
        iVecCostGTC(i) = par.c_fuel *  iVecFuelGTC(i) * (x(4,i) + u_0(7,i) - u_0(8,i));
        iVecCostGTD(i) = par.c_fuel *  iVecFuelGTD(i) * (x(5,i) + u_0(9,i) - u_0(10,i));

        iVecDegrad(i)  = rslt.sol(i).Total_degradation(1);
    end

   % KPI 1: Dumped Energy
   kpi.cumDumpNrg = sum(iVecDmpPwrTrue);
   
   % KPI 2: Fuel Consumption
   kpi.cumFuelGTA = sum(iVecFuelGTA);
   kpi.cumFuelGTB = sum(iVecFuelGTB);
   kpi.cumFuelGTC = sum(iVecFuelGTC);
   kpi.cumFuelGTD = sum(iVecFuelGTD);
   kpi.cumFuelAllGT = sum(iVecFuelGTA)+sum(iVecFuelGTB)+sum(iVecFuelGTC)+sum(iVecFuelGTD);
   
   % KPI 3: Total Cost
%    kpi.cumCostGTA = sum(iVecCostGTA) + par.c_gt_srt * sum(rslt.sol(:).GT_startUP_indicator(1,1,1));
%    kpi.cumCostGTB = sum(iVecCostGTB) + par.c_gt_srt * sum(rslt.sol(:).GT_startUP_indicator(1,1,2));
%    kpi.cumCostGTC = sum(iVecCostGTC) + par.c_gt_srt * sum(rslt.sol(:).GT_startUP_indicator(1,1,3));
%    kpi.cumCostGTD = sum(iVecCostGTD) + par.c_gt_srt * sum(rslt.sol(:).GT_startUP_indicator(1,1,4));
   
   kpi.cumCostGTA = sum(iVecCostGTA) + par.c_gt_srt * sum(u_0(3,:));
   kpi.cumCostGTB = sum(iVecCostGTB) + par.c_gt_srt * sum(u_0(5,:));
   kpi.cumCostGTC = sum(iVecCostGTC) + par.c_gt_srt * sum(u_0(7,:));
   kpi.cumCostGTD = sum(iVecCostGTD) + par.c_gt_srt * sum(u_0(9,:));
   kpi.cumCostAllGT = kpi.cumCostGTA+kpi.cumCostGTB+kpi.cumCostGTC+kpi.cumCostGTD;

   % KPI 4: Variance of Pgt
   kpi.varPgtA = var(iVecGTAPwr);
   kpi.varPgtB = var(iVecGTBPwr);
   kpi.varPgtC = var(iVecGTCPwr);
   kpi.varPgtD = var(iVecGTDPwr);
   
   % KPI 5: Total ON/OFF moves
   kpi.OnOffcmdGTA = sum(u_0(3,:)) + sum(u_0(4,:));
   kpi.OnOffcmdGTB = sum(u_0(5,:)) + sum(u_0(6,:));
   kpi.OnOffcmdGTC = sum(u_0(7,:)) + sum(u_0(8,:));
   kpi.OnOffcmdGTD = sum(u_0(9,:)) + sum(u_0(10,:));
   
   % KPI 6: Total degradation in [%]
   kpi.cumDegrad = sum(iVecDegrad)/100;

