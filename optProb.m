%-----FORMULATE SMPC PROBLEM AS MILP -----
if simIter == 1
    
    %% ----------------------\\ Optimization Model \\--------------------------
    probMPC = optimproblem('ObjectiveSense','minimize');
    % ---------------------\\ Optimization Variables \\------------------------
    % GT Model
    P_gt           = optimvar('Power_GT',N_prd,N_scn,N_gt,'LowerBound',0,'UpperBound',par.P_gt_max);
    % Fuel Model
    pwl_fuel_w     = optimvar('fuel_PWA_weight',N_prd,N_scn,N_gt,N_pwl,'LowerBound',0);
    pwl_fuel_bin   = optimvar('fuel_PWA_indicator',N_prd,N_scn,N_gt,N_pwl,'Type','integer','LowerBound',0,'UpperBound',1);
    % Degradation Model
    pwl_deg_w      = optimvar('degradation_PWA_weight',N_prd,N_scn,N_pwl,'LowerBound',0);                                     % corresponds to \Delta_{t,m}
    pwl_deg_bin    = optimvar('degradation_PWA_indicator',N_prd,N_scn,N_pwl,'Type','integer','LowerBound',0,'UpperBound',1);   % corresponds to \delta_{t,m} interval indicator
    deg            = optimvar('degradation',N_prd,N_scn,'LowerBound',0);                % (Y from PWA)     corresponds to deg_{t}
    deg_cyc        = optimvar('dummy_cyclic_degradation',N_prd,N_scn,'LowerBound',0);            % corresponds to DPcy'_{t}
    DP_cyc         = optimvar('Total_cyclic_degradation',N_scn,'LowerBound',0);                   % corresponds to DPcy
    %         DP_cal         = optimvar('Total_calendar_degradation',N_scn,'LowerBound',0);                 % corresponds to DPshelf
    DP             = optimvar('Total_degradation',N_scn,'LowerBound',0);                          % corresponds to DP
    % Battery Model
    bin_dis       = optimvar('storage_discharge_indicator',N_prd,N_scn,'Type','integer','LowerBound',0,'UpperBound',1); % 1: DIS-charging
    % Dump (slack vriable for over-generation)
    P_d           = optimvar('Power_dump',N_prd,N_scn,'LowerBound',0,'UpperBound',Inf); % this acts as a sluck variable for feasibility of the solution
    % Final SoC penalization (slack vriable for over-generation)
    soc_dev_abs   = optimvar('absolute_SoC_deviation_from_reference',N_scn,'LowerBound',0);
    soc_dev_p     = optimvar('positive_slack_SoC_deviation',N_scn,'LowerBound',0);
    soc_dev_n     = optimvar('negative_slack_SoC_deviation',N_scn,'LowerBound',0);
    
    % States x
    DOD            = optimvar('DoD',N_prd,N_scn,'LowerBound',0,'UpperBound',1); % (X from PWA)     corresponds to 1-SoC_{t} % | state 1-x
    bin_gt         = optimvar('GT_status_indicator',N_prd,N_scn,N_gt,'Type','integer','LowerBound',0,'UpperBound',1);
    % Actuation u
    P_ch           = optimvar('Power_charging',N_prd,N_scn,'LowerBound',0,'UpperBound',par.P_bat_max);
    P_dis          = optimvar('Power_discharging',N_prd,N_scn,'LowerBound',0,'UpperBound',par.P_bat_max);
    bin_strUP_gt   = optimvar('GT_startUP_indicator',N_prd,N_scn,N_gt,'Type','integer','LowerBound',0,'UpperBound',1);
    bin_shtDOWN_gt = optimvar('GT_shutDOWN_indicator',N_prd,N_scn,N_gt,'Type','integer','LowerBound',0,'UpperBound',1);
    
    % Coupling variables @ k = 0 accros all scenarios
    P_ch_k0           = optimvar('Power_charging_k0','LowerBound',0,'UpperBound',par.P_bat_max);
    P_dis_k0          = optimvar('Power_discharging_k0','LowerBound',0,'UpperBound',par.P_bat_max);
    bin_dis_k0        = optimvar('storage_discharge_indicator_k0','Type','integer','LowerBound',0,'UpperBound',1); % 1: DIS-charging
    
    
    P_gt_k0           = optimvar('Power_GT_k0',N_gt,'LowerBound',0,'UpperBound',par.P_gt_max);
    bin_strUP_gt_k0   = optimvar('GT_startUP_indicator_k0',N_gt,'Type','integer','LowerBound',0,'UpperBound',1);
    bin_shtDOWN_gt_k0 = optimvar('GT_shutDOWN_indicator_k0',N_gt,'Type','integer','LowerBound',0,'UpperBound',1);
    
    
    nrgUpdtMtrx    = tril(ones(par.N_prd));
    nrgUpdtMtrxC   = repmat({nrgUpdtMtrx}, 1, par.N_scn);
    nrgUpdtMtrxBig = blkdiag(blkdiag(nrgUpdtMtrxC{:}));
    P_ch_vec       = reshape(P_ch,par.N_prd*par.N_scn,1);
    P_dis_vec      = reshape(P_dis,par.N_prd*par.N_scn,1);
    DOD_vec        = reshape(DOD,par.N_prd*par.N_scn,1);
    
    % Naming variables indexes
    indexNames = cell(1, N_prd + N_scn + N_gt + N_pwl);
    j = 1;
    while j <= N_prd + N_scn + N_gt + N_pwl
        while j<= N_prd
            indexNames{j} = append('k+',int2str(j-1));
            j=j+1;
        end
        while j<= N_prd + N_scn
            indexNames{j} = append('scen_',int2str(j-N_prd));
            j=j+1;
        end
        while j<= N_prd + N_scn + N_gt
            indexNames{j} = append('GT_',int2str(j-N_prd-N_scn));
            j=j+1;
        end
        while j<= N_prd + N_scn + N_gt + N_pwl
            indexNames{j} = append('point_',int2str(j-N_prd-N_scn-N_gt));
            j=j+1;
        end
    end
    
    for i = 1:4
        if i==1
            pwl_fuel_w.IndexNames{i}     = indexNames(1,1:N_prd);
            pwl_fuel_bin.IndexNames{i}   = indexNames(1,1:N_prd);
            P_gt.IndexNames{i}           = indexNames(1,1:N_prd);
            bin_gt.IndexNames{i}         = indexNames(1,1:N_prd);
            bin_strUP_gt.IndexNames{i}   = indexNames(1,1:N_prd);
            bin_shtDOWN_gt.IndexNames{i} = indexNames(1,1:N_prd);
            pwl_deg_w.IndexNames{i}      = indexNames(1,1:N_prd);
            pwl_deg_bin.IndexNames{i}    = indexNames(1,1:N_prd);
            deg.IndexNames{i}            = indexNames(1,1:N_prd);
            DOD.IndexNames{i}            = indexNames(1,1:N_prd);
            deg_cyc.IndexNames{i}        = indexNames(1,1:N_prd);
            bin_dis.IndexNames{i}        = indexNames(1,1:N_prd);
            P_ch.IndexNames{i}           = indexNames(1,1:N_prd);
            P_dis.IndexNames{i}          = indexNames(1,1:N_prd);
            P_d.IndexNames{i}            = indexNames(1,1:N_prd);
            
            DP_cyc.IndexNames{i}         = indexNames(1,N_prd+1:N_prd + N_scn);
            DP_cal.IndexNames{i}         = indexNames(1,N_prd+1:N_prd + N_scn);
            DP.IndexNames{i}             = indexNames(1,N_prd+1:N_prd + N_scn);
            soc_dev_abs.IndexNames{i}    = indexNames(1,N_prd+1:N_prd + N_scn);
            soc_dev_p.IndexNames{i}      = indexNames(1,N_prd+1:N_prd + N_scn);
            soc_dev_n.IndexNames{i}      = indexNames(1,N_prd+1:N_prd + N_scn);
            
            %                 P_ch_k0.IndexNames{i}        = indexNames(1,N_prd+1:N_prd + N_scn);
            %                 P_dis_k0.IndexNames{i}       = indexNames(1,N_prd+1:N_prd + N_scn);
            %                 bin_dis_k0.IndexNames{i}     = indexNames(1,N_prd+1:N_prd + N_scn);
            P_gt_k0.IndexNames{i}            = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            bin_strUP_gt_k0.IndexNames{i}    = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            bin_shtDOWN_gt_k0.IndexNames{i}  = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            
        elseif i==2
            pwl_fuel_w.IndexNames{i}     = indexNames(1,N_prd+1:N_prd + N_scn);
            pwl_fuel_bin.IndexNames{i}   = indexNames(1,N_prd+1:N_prd + N_scn);
            P_gt.IndexNames{i}           = indexNames(1,N_prd+1:N_prd + N_scn);
            bin_gt.IndexNames{i}         = indexNames(1,N_prd+1:N_prd + N_scn);
            bin_strUP_gt.IndexNames{i}   = indexNames(1,N_prd+1:N_prd + N_scn);
            bin_shtDOWN_gt.IndexNames{i} = indexNames(1,N_prd+1:N_prd + N_scn);
            pwl_deg_w.IndexNames{i}      = indexNames(1,N_prd+1:N_prd + N_scn);
            pwl_deg_bin.IndexNames{i}    = indexNames(1,N_prd+1:N_prd + N_scn);
            deg.IndexNames{i}            = indexNames(1,N_prd+1:N_prd + N_scn);
            DOD.IndexNames{i}            = indexNames(1,N_prd+1:N_prd + N_scn);
            deg_cyc.IndexNames{i}        = indexNames(1,N_prd+1:N_prd + N_scn);
            bin_dis.IndexNames{i}        = indexNames(1,N_prd+1:N_prd + N_scn);
            P_ch.IndexNames{i}           = indexNames(1,N_prd+1:N_prd + N_scn);
            P_dis.IndexNames{i}          = indexNames(1,N_prd+1:N_prd + N_scn);
            P_d.IndexNames{i}            = indexNames(1,N_prd+1:N_prd + N_scn);
            
            %                 P_gt_k0.IndexNames{i}            = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            %                 bin_strUP_gt_k0.IndexNames{i}    = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            %                 bin_shtDOWN_gt_k0.IndexNames{i}  = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
        elseif i==3
            pwl_fuel_w.IndexNames{i}     = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            pwl_fuel_bin.IndexNames{i}   = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            P_gt.IndexNames{i}           = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            bin_gt.IndexNames{i}         = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            bin_strUP_gt.IndexNames{i}   = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            bin_shtDOWN_gt.IndexNames{i} = indexNames(1,N_prd + N_scn+1:N_prd + N_scn + N_gt);
            
            pwl_deg_w.IndexNames{i}      = indexNames(1,N_prd + N_scn + N_gt+1:end);
            pwl_deg_bin.IndexNames{i}    = indexNames(1,N_prd + N_scn + N_gt+1:end);
        else
            pwl_fuel_w.IndexNames{i}     = indexNames(1,N_prd + N_scn + N_gt+1:end);
            pwl_fuel_bin.IndexNames{i}   = indexNames(1,N_prd + N_scn + N_gt+1:end);
        end
    end
    %}
    %% -------------------\\ Optimization Objective \\-------------------------
    %
    tic;
    C_fuel     = optimexpr(N_scn);
    C_deg      = optimexpr(N_scn);
    C_gt_strUP = optimexpr(N_scn);
    C_soc_dev  = optimexpr(N_scn);
    C_dump     = optimexpr(N_scn);
    y_w        = optimexpr(N_scn);
    fuel       = optimexpr(N_prd,N_scn,N_gt);
    C_gt_ON    = optimexpr(N_scn);
    
    for w = 1:N_scn
        index_w = append('scen_',int2str(w));
        
        for prdIndx = 0 : N_prd-1
            index_k = append('k+',int2str(prdIndx));
            
            for g = 1:N_gt
                index_g = append('GT_',int2str(g));
                
                tempSum = 0;
                for p = 1:N_pwl
                    index_p = append('point_',int2str(p));
                    tempSum  = tempSum + pwl_fuel_w(index_k,index_w,index_g,index_p) * (Ts/60) * par.fuel_data(p);
                end
                fuel(prdIndx+1,w,g) = tempSum;
                
            end
        end
        C_fuel(w)     = par.c_fuel * sum(sum(fuel(:,w,:)));
        C_deg(w)      = (par.c_Bat_rpl - par.c_Bat_res) * DP(w)./100;
        C_gt_strUP(w) = par.c_gt_srt    * sum(sum(bin_strUP_gt(:,index_w,:)));
        C_dump(w)     = par.c_dump      * (Ts/60) * sum(P_d(:,index_w));
        C_soc_dev(w)  = par.c_soc_dev   * soc_dev_abs(index_w);
        C_gt_ON(w)    = par.c_gt_ON     * sum(sum(bin_gt(:,index_w,:)));
        
        y_w(w)        =  C_fuel(w) + C_deg(w) + C_gt_strUP(w) + C_dump(w) + C_soc_dev(w) + C_gt_ON(w);
    end
    TotFuelCost       = (1/N_scn) * sum(y_w);
    probMPC.Objective = TotFuelCost;
    toc
    %}
    %% ------------------\\ Optimization Constraints \\------------------------
    tic;
    sumWeigthsFuelCnstr    = optimconstr(N_prd,N_scn,N_gt);
    contiguityFuelCnstr    = optimconstr(N_prd,N_scn,N_gt,N_pwl);
    binIndicatorsFuelCnstr = optimconstr(N_prd,N_scn,N_gt);
    strtUPCnstr            = optimconstr(N_prd,N_scn,N_gt);
    shtDOWNCnstr           = optimconstr(N_prd,N_scn,N_gt);
    shtDOWNCnstr2          = optimconstr(N_prd,N_scn,N_gt);
    rampUpPowGTCnstr       = optimconstr(N_prd,N_scn,N_gt);
    rampDownPowGTCnstr     = optimconstr(N_prd,N_scn,N_gt);
    PgtCnstr               = optimconstr(N_prd,N_scn,N_gt);
    statesGTCnstr          = optimconstr(N_prd,N_scn,N_gt);
    maxPowGTCnstr          = optimconstr(N_prd,N_scn,N_gt);
    minPowGTCnstr          = optimconstr(N_prd,N_scn,N_gt);
    sumWeigthsDegCnstr     = optimconstr(N_prd,N_scn);
    contiguityDegCnstr     = optimconstr(N_prd,N_scn,N_pwl);
    binIndicatorsDegCnstr  = optimconstr(N_prd,N_scn);
    degradCnstr            = optimconstr(N_prd,N_scn);
    DoDCnstr               = optimconstr(N_prd,N_scn);
    absCyclesPosCnstr      = optimconstr(N_prd,N_scn);
    absCyclesNegCnstr      = optimconstr(N_prd,N_scn);
    batBoxChCnstr          = optimconstr(N_prd,N_scn);
    batBoxDisCnstr         = optimconstr(N_prd,N_scn);
    powBalanceCnstr        = optimconstr(N_prd,N_scn);
    %         absSoCDevCnstr1        = optimconstr(N_scn);
    %         absSoCDevCnstr2        = optimconstr(N_scn);
    TotCycDegradCnstr      = optimconstr(N_scn);
    %         TotCalDegradCnstr      = optimconstr(N_scn);
    maxCycDegradCnstr      = optimconstr(N_scn);
    %         maxCalDegradCnstr      = optimconstr(N_scn);
    
    for w = 1 : N_scn
        index_w = append('scen_',int2str(w));
        for prdIndx = 0 : N_prd-1
            index_k = append('k+',int2str(prdIndx));
            if prdIndx >= 1
                index_k_prev = append('k+',int2str(prdIndx-1));
            end
            for g = 1 : N_gt
                index_g = append('GT_',int2str(g));
                %--------------------------------- GT -------------------------------------
                % Sum of Linear weights constraints
                sumWeigthsFuelCnstr(prdIndx+1,w,g) = sum(pwl_fuel_w(index_k,index_w,index_g,:)) == bin_gt(index_k,index_w,index_g);
                
                % Linear weights constraints
                contiguityFuelCnstr(prdIndx+1,w,g,1) = pwl_fuel_w(index_k,index_w,index_g,append('point_',int2str(1))) <= ...
                    pwl_fuel_bin(index_k,index_w,index_g,append('point_',int2str(1))) ;
                for p = 2 : N_pwl-1
                    index_p      = append('point_',int2str(p));
                    index_p_prev = append('point_',int2str(p-1));
                    contiguityFuelCnstr(prdIndx+1,w,g,p) = pwl_fuel_w(index_k,index_w,index_g,index_p) <= ...
                        pwl_fuel_bin(index_k,index_w,index_g,index_p_prev) + pwl_fuel_bin(index_k,index_w,index_g,index_p);
                end
                contiguityFuelCnstr(prdIndx+1,w,g,N_pwl) = pwl_fuel_w(index_k,index_w,index_g,append('point_',int2str(N_pwl))) <= ...
                    pwl_fuel_bin(index_k,index_w,index_g,append('point_',int2str(N_pwl-1))) ;
                
                % Sum of Binary indicators constraints
                binIndicatorsFuelCnstr(prdIndx+1,w,g) = sum(pwl_fuel_bin(index_k,index_w,index_g,1:end-1)) == bin_gt(index_k,index_w,index_g);
                
                
                % Sum of PWA P_gt points constraints (approximate X)
                tSum5 = 0;
                for p = 1 : N_pwl
                    index_p = append('point_',int2str(p));
                    tSum5 = tSum5 + par.P_gt_data(p)*pwl_fuel_w(index_k,index_w,index_g,index_p);
                end
                PgtCnstr(prdIndx+1,w,g) = P_gt(index_k,index_w,index_g) == tSum5;
                
                if prdIndx == 0
                    % StartUP constraints
                    strtUPCnstr(prdIndx+1,w,g)  = bin_gt(index_k,index_w,index_g) - x_gt_0(g) <= bin_strUP_gt(index_k,index_w,index_g);
                    % ShutDOWN constraints
                    shtDOWNCnstr(prdIndx+1,w,g)  = x_gt_0(g) - bin_gt(index_k,index_w,index_g) <= bin_shtDOWN_gt(index_k,index_w,index_g);
                    shtDOWNCnstr2(prdIndx+1,w,g) = bin_strUP_gt(index_k,index_w,index_g) + bin_shtDOWN_gt(index_k,index_w,index_g) <= 1;
                    
                    % GT state constraints
                    statesGTCnstr(prdIndx+1,w,g) =  bin_gt(index_k,index_w,index_g) == x_gt_0(g) + bin_strUP_gt(1,w,g)...
                        - bin_shtDOWN_gt(1,w,g);
                else
                    % StartUP constraints
                    strtUPCnstr(prdIndx+1,w,g)  = bin_gt(index_k,index_w,index_g) - bin_gt(index_k_prev,index_w,index_g) <= bin_strUP_gt(index_k,index_w,index_g);
                    % ShutDOWN constraints
                    shtDOWNCnstr(prdIndx+1,w,g) = bin_gt(index_k_prev,index_w,index_g) - bin_gt(index_k,index_w,index_g) <= bin_shtDOWN_gt(index_k,index_w,index_g);
                    shtDOWNCnstr2(prdIndx+1,w,g)=  bin_strUP_gt(index_k,index_w,index_g) + bin_shtDOWN_gt(index_k,index_w,index_g) <= 1;
                    % GT ramp rate constraints
                    rampUpPowGTCnstr(prdIndx+1,w,g)   = P_gt(index_k,index_w,index_g) - P_gt(index_k_prev,index_w,index_g) <= par.gt_RR  * (4*Ts/60);
                    rampDownPowGTCnstr(prdIndx+1,w,g) = P_gt(index_k,index_w,index_g) - P_gt(index_k_prev,index_w,index_g) >= -par.gt_RR * (4*Ts/60);
                    % GT state constraints
                    statesGTCnstr(prdIndx+1,w,g) =  bin_gt(index_k,index_w,index_g) == bin_gt(index_k_prev,index_w,index_g) + bin_strUP_gt(index_k,w,g)...
                        - bin_shtDOWN_gt(index_k,w,g);
                end
                
                % GT power constraints
                maxPowGTCnstr(prdIndx+1,w,g) = P_gt(index_k,index_w,index_g) <= bin_gt(index_k,index_w,index_g) * par.P_gt_max;
                minPowGTCnstr(prdIndx+1,w,g) = P_gt(index_k,index_w,index_g) >= bin_gt(index_k,index_w,index_g) * par.P_gt_min;
            end
            %----------------------------- DEGRADATION --------------------------------
            % Sum of Linear weights constraint
            sumWeigthsDegCnstr(prdIndx+1,w) = sum(pwl_deg_w(index_k,index_w,:)) == 1;
            % Linear weights constraints
            contiguityDegCnstr(prdIndx+1,w,1) = pwl_deg_w(index_k,index_w,append('point_',int2str(1))) <= ...
                pwl_deg_bin(index_k,index_w,append('point_',int2str(1))) ;
            for p = 2 : N_pwl-1
                index_p      = append('point_',int2str(p));
                index_p_prev = append('point_',int2str(p-1));
                contiguityDegCnstr(prdIndx+1,w,p) = pwl_deg_w(index_k,index_w,index_p) <= ...
                    pwl_deg_bin(index_k,index_w,index_p_prev) + pwl_deg_bin(index_k,index_w,index_p);
            end
            contiguityDegCnstr(prdIndx+1,w,N_pwl) = pwl_deg_w(index_k,index_w,append('point_',int2str(N_pwl))) <= ...
                pwl_deg_bin(index_k,index_w,append('point_',int2str(N_pwl-1))) ;
            % Sum of Binary indicators constraint
            binIndicatorsDegCnstr(prdIndx+1,w) = sum(pwl_deg_bin(index_k,index_w,1:end-1)) == 1;
            
            % Sum of PWA degradation points constraints (approximate Y)
            tSum3 = 0;
            for p = 1 : N_pwl
                index_p = append('point_',int2str(p));
                tSum3 = tSum3 + par.rho_data(p)*pwl_deg_w(index_k,index_w,index_p);
            end
            degradCnstr(prdIndx+1,w) = deg(index_k,index_w) == tSum3;
            
            % Sum of PWA DOD points constraints (approximate X)
            tSum4 = 0;
            for p = 1 : N_pwl
                index_p = append('point_',int2str(p));
                tSum4 = tSum4 + par.DoD_data(p)*pwl_deg_w(index_k,index_w,index_p);
            end
            DoDCnstr(prdIndx+1,w) = DOD(index_k,index_w) == tSum4;
            
            if prdIndx>=1
                % Dummy degradation constraints (absolute value implementation)
                absCyclesPosCnstr(prdIndx+1,w) = deg_cyc(index_k,index_w) >= 0.5*(deg(index_k,index_w) - deg(index_k_prev,index_w));
                absCyclesNegCnstr(prdIndx+1,w) = deg_cyc(index_k,index_w) >= 0.5*(-deg(index_k,index_w) + deg(index_k_prev,index_w));
            end
            %-------------------------------- BESS ------------------------------------
            % Power box constraint
            batBoxChCnstr(prdIndx+1,w)  = P_dis(index_k,index_w) <= par.P_bat_max * bin_dis(index_k,index_w);
            batBoxDisCnstr(prdIndx+1,w) = P_ch(index_k,index_w)  <= par.P_bat_max * (1-bin_dis(index_k,index_w));
            
        end
        
        
        
        % Total cyclic degradation constraint
        TotCycDegradCnstr(w) = DP_cyc(w) == sum(deg_cyc(:,index_w));
        % Total calendar degradation constraint
        %             TotCalDegradCnstr(w) = DP_cal(w) == 1 / (par.batLifetime*2) / par.daysOfYear / par.hoursOfday / par.qrtrOfHour * N_prd;
        % Max degradation constraint (calendar or cyclic) - 1
        maxCycDegradCnstr(w) = DP(w) >= DP_cyc(w);
        % Max degradation constraint (calendar or cyclic) - 2
        %             maxCalDegradCnstr(w) = DP(w) >= DP_cal(w);
        % Total degradation constraint (both Calendar & Cyclic)
        %     prob.Constraints.maxDegradCnstr = DP <= 1/Lifetime/daysOfYear;
        
        % Final state of charge penalization
        %             absSoCDevCnstr1(w) = soc_dev_abs(index_w)  == soc_dev_p(index_w) + soc_dev_n(index_w);
        %             absSoCDevCnstr2(w) =  1 - DOD(index_k,index_w) - par.SoC_ref == soc_dev_p(index_w) - soc_dev_n(index_w);
    end
    
    for prdIndx = 0 : N_prd-1
        index_k = append('k+',int2str(prdIndx));
        powBalanceCnstr(prdIndx+1,:) = P_gt(index_k,:,'GT_1') + P_gt(index_k,:,'GT_2') + P_gt(index_k,:,'GT_3') + P_gt(index_k,:,'GT_4') -...
            P_ch(index_k,:) + P_dis(index_k,:) - P_d(index_k,:) ==...
            (xi.L(prdIndx+1,:) * par.spinRes - xi.W(prdIndx+1,:)) ;
    end
    
    % Battery capacity constraints
    maxSOCCnstrBig = E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis) <= par.socUPlim   * par.E_bat_max;
    minSOCCnstrBig = E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis) >= par.socDOWNlim * par.E_bat_max;
    % Battery DoD updates constraints
    DoDUpdateCnstrBig = 1 - ((E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis)) ./ par.E_bat_max) ==...
        DOD_vec;
    
    %         absSoCDevCnstr1 = soc_dev_abs(:)  == soc_dev_p(:) + soc_dev_n(:);
    %         absSoCDevCnstr2 =  1 - DOD_vec(N_prd:N_prd:N_prd*N_scn,:) - par.SoC_ref*ones(N_scn,1) == soc_dev_p(:) - soc_dev_n(:);
    
    absSoCDevCnstr1 = soc_dev_abs(:)  == soc_dev_p(:) + soc_dev_n(:);
    absSoCDevCnstr2 =  1 - DOD_vec(1:N_prd:N_prd*N_scn,:) - par.SoC_ref*ones(N_scn,1) == soc_dev_p(:) - soc_dev_n(:);
    
    % Possible additional contraints for different stochastic policies
    % 2)Same control accross scenarios
    %{
        chargePowAccrosWCnstr    = optimconstr(N_prd,N_scn^2);
        dischargePowAccrosWCnstr = optimconstr(N_prd,N_scn^2);
        strtUPindicAccrosWCnstr  = optimconstr(N_prd,N_scn^2);
        shutOFFindicAccrosWCnstr = optimconstr(N_prd,N_scn^2);
        
        count_w_s = 0;
        for w = 1 : N_scn
            index_w = append('scen_',int2str(w));
            for prdIndx = 0 : N_prd-1
                index_k = append('k+',int2str(prdIndx));
                for s = 1 : N_scn
                    count_w_s = count_w_s +1;
                    index_s = append('scen_',int2str(s));
                    chargePowAccrosWCnstr(prdIndx+1,count_w_s)    = P_ch(index_k,index_w)  == P_ch(index_k,index_s);
                    dischargePowAccrosWCnstr(prdIndx+1,count_w_s) = P_dis(index_k,index_w) == P_dis(index_k,index_s);
                    for g = 1:N_gt
                        index_g = append('GT_',int2str(g));
                        strtUPindicAccrosWCnstr(prdIndx+1,count_w_s,g) = bin_strUP_gt(index_k,index_w,index_g) == bin_strUP_gt(index_k,index_s,index_g);
                        shutOFFindicAccrosWCnstr(prdIndx+1,count_w_s,g) = bin_shtDOWN_gt(index_k,index_w,index_g) == bin_shtDOWN_gt(index_k,index_s,index_g);
                    end
                end
            end
        end
        probMPC.Constraints.chargePowAccrosWCnstr    = chargePowAccrosWCnstr;
        probMPC.Constraints.dischargePowAccrosWCnstr = dischargePowAccrosWCnstr;
        probMPC.Constraints.strtUPindicAccrosWCnstr  = strtUPindicAccrosWCnstr;
        probMPC.Constraints.shutOFFindicAccrosWCnstr = shutOFFindicAccrosWCnstr;
    %}
    
    % 3)Same control accross scenarios JUST FOR u_0 - V_1
    %{
        chargePowAccrosW1Cnstr    = optimconstr(N_scn-1);
        dischargePowAccrosW1Cnstr = optimconstr(N_scn-1);
        disIndindicAccrosW1Cnstr  = optimconstr(N_scn-1);
        strtUPindicAccrosW1Cnstr  = optimconstr(N_scn-1,N_gt);
        shutOFFindicAccrosW1Cnstr = optimconstr(N_scn-1,N_gt);
        gtPwrAccrosW1Cnstr        = optimconstr(N_scn-1,N_gt);
    
        for w = 1 : N_scn - 1
            index_w = append('scen_',int2str(w));
            index_k = append('k+',int2str(0));
            index_w1 = append('scen_',int2str(w+1));
            chargePowAccrosW1Cnstr(w)    = P_ch(index_k,index_w)  == P_ch(index_k,index_w1);
            dischargePowAccrosW1Cnstr(w) = P_dis(index_k,index_w) == P_dis(index_k,index_w1);
            disIndindicAccrosW1Cnstr(w)  = bin_dis(index_k,index_w)== bin_dis(index_k,index_w1);
            for g = 1 : N_gt
                index_g = append('GT_',int2str(g));
                strtUPindicAccrosW1Cnstr(w,g)  = bin_strUP_gt(index_k,index_w,index_g)   == bin_strUP_gt(index_k,index_w1,index_g);
                shutOFFindicAccrosW1Cnstr(w,g) = bin_shtDOWN_gt(index_k,index_w,index_g) == bin_shtDOWN_gt(index_k,index_w1,index_g);
                gtPwrAccrosW1Cnstr(w,g)        = P_gt(index_k,index_w,index_g) == P_gt(index_k,index_w1,index_g);
            end
        end
        probMPC.Constraints.chargePowAccrosW1Cnstr    = chargePowAccrosW1Cnstr;
        probMPC.Constraints.dischargePowAccrosW1Cnstr = dischargePowAccrosW1Cnstr;
        probMPC.Constraints.strtUPindicAccrosW1Cnstr  = strtUPindicAccrosW1Cnstr;
        probMPC.Constraints.shutOFFindicAccrosW1Cnstr = shutOFFindicAccrosW1Cnstr;
        probMPC.Constraints.gtPwrAccrosW1Cnstr        = gtPwrAccrosW1Cnstr;
        probMPC.Constraints.disIndindicAccrosW1Cnstr  = disIndindicAccrosW1Cnstr;

    %}
    
    % 4)Same control accross scenarios JUST FOR u_0 - V_2
    %
    chargePowAccrosK0Cnstr    = optimconstr(N_scn);
    dischargePowAccrosK0Cnstr = optimconstr(N_scn);
    disIndindicAccrosK0Cnstr  = optimconstr(N_scn);
    strtUPindicAccrosK0Cnstr  = optimconstr(N_scn,N_gt);
    shutOFFindicAccrosK0Cnstr = optimconstr(N_scn,N_gt);
    gtPwrAccrosK0Cnstr        = optimconstr(N_scn,N_gt);
    
    index_k = append('k+',int2str(0));
    for w = 1 : N_scn
        index_w = append('scen_',int2str(w));
        chargePowAccrosK0Cnstr(w)    = P_ch(index_k,index_w)  == P_ch_k0;
        dischargePowAccrosK0Cnstr(w) = P_dis(index_k,index_w) == P_dis_k0;
        %             disIndindicAccrosK0Cnstr(w)  = bin_dis(index_k,index_w)== bin_dis_k0;
        for g = 1 : N_gt
            index_g = append('GT_',int2str(g));
            %                 strtUPindicAccrosK0Cnstr(w,g)  = bin_strUP_gt(index_k,index_w,index_g)   == bin_strUP_gt_k0(index_g);
            %                 shutOFFindicAccrosK0Cnstr(w,g) = bin_shtDOWN_gt(index_k,index_w,index_g) == bin_shtDOWN_gt_k0(index_g);
            gtPwrAccrosK0Cnstr(w,g)        = P_gt(index_k,index_w,index_g) == P_gt_k0(index_g);
        end
    end
    probMPC.Constraints.chargePowAccrosK0Cnstr    = chargePowAccrosK0Cnstr;
    probMPC.Constraints.dischargePowAccrosK0Cnstr = dischargePowAccrosK0Cnstr;
    %         probMPC.Constraints.strtUPindicAccrosK0Cnstr  = strtUPindicAccrosK0Cnstr;
    %         probMPC.Constraints.shutOFFindicAccrosK0Cnstr = shutOFFindicAccrosK0Cnstr;
    probMPC.Constraints.gtPwrAccrosK0Cnstr        = gtPwrAccrosK0Cnstr;
    %         probMPC.Constraints.disIndindicAccrosK0Cnstr  = disIndindicAccrosK0Cnstr;
    %}
    
    
    probMPC.Constraints.sumWeigthsFuelCnstr    = sumWeigthsFuelCnstr;
    probMPC.Constraints.contiguityFuelCnstr    = contiguityFuelCnstr;
    probMPC.Constraints.binIndicatorsFuelCnstr = binIndicatorsFuelCnstr;
    probMPC.Constraints.strtUPCnstr            = strtUPCnstr;
    probMPC.Constraints.shtDOWNCnstr           = shtDOWNCnstr;
    probMPC.Constraints.statesGTCnstr          = statesGTCnstr;
    probMPC.Constraints.maxPowGTCnstr          = maxPowGTCnstr;
    probMPC.Constraints.minPowGTCnstr          = minPowGTCnstr;
    probMPC.Constraints.rampUpPowGTCnstr       = rampUpPowGTCnstr;
    probMPC.Constraints.rampDownPowGTCnstr     = rampDownPowGTCnstr;
    probMPC.Constraints.sumWeigthsDegCnstr     = sumWeigthsDegCnstr;
    probMPC.Constraints.contiguityDegCnstr     = contiguityDegCnstr;
    probMPC.Constraints.binIndicatorsDegCnstr  = binIndicatorsDegCnstr;
    probMPC.Constraints.degradCnstr            = degradCnstr;
    probMPC.Constraints.DoDCnstr               = DoDCnstr;
    probMPC.Constraints.absCyclesPosCnstr      = absCyclesPosCnstr;
    probMPC.Constraints.absCyclesNegCnstr      = absCyclesNegCnstr;
    probMPC.Constraints.batBoxChCnstr          = batBoxChCnstr;
    probMPC.Constraints.batBoxDisCnstr         = batBoxDisCnstr;
    probMPC.Constraints.absSoCDevCnstr1        = absSoCDevCnstr1;
    probMPC.Constraints.absSoCDevCnstr2        = absSoCDevCnstr2;
    probMPC.Constraints.powBalanceCnstr        = powBalanceCnstr;
    probMPC.Constraints.TotCycDegradCnstr      = TotCycDegradCnstr;
    %         probMPC.Constraints.TotCalDegradCnstr      = TotCalDegradCnstr;
    probMPC.Constraints.maxCycDegradCnstr      = maxCycDegradCnstr;
    %         probMPC.Constraints.maxCalDegradCnstr      = maxCalDegradCnstr;
    probMPC.Constraints.PgtCnstr               = PgtCnstr;
    probMPC.Constraints.shtDOWNCnstr2          = shtDOWNCnstr2;
    
    probMPC.Constraints.maxSOCCnstrBig          = maxSOCCnstrBig;
    probMPC.Constraints.minSOCCnstrBig          = minSOCCnstrBig;
    probMPC.Constraints.DoDUpdateCnstrBig       = DoDUpdateCnstrBig;
    
    toc
else
    %
    tic;
    
    for prdIndx = 0 : N_prd-1
        index_k = append('k+',int2str(prdIndx));
        if prdIndx >= 1
            index_k_prev = append('k+',int2str(prdIndx-1));
        end
        powBalanceCnstr(prdIndx+1,:) = P_gt(index_k,:,'GT_1') + P_gt(index_k,:,'GT_2') + P_gt(index_k,:,'GT_3') + P_gt(index_k,:,'GT_4') -...
            P_ch(index_k,:) + P_dis(index_k,:) - P_d(index_k,:) ==...
            (xi.L(prdIndx+1,:) * par.spinRes - xi.W(prdIndx+1,:)) ;
        
        for g = 1 : N_gt
            index_g = append('GT_',int2str(g));
            
            if prdIndx == 0
                % StartUP constraints
                strtUPCnstr(prdIndx+1,:,g)  = bin_gt(index_k,:,index_g) - x_gt_0(g) <= bin_strUP_gt(index_k,:,index_g);
                % ShutDOWN constraints
                shtDOWNCnstr(prdIndx+1,:,g)  = x_gt_0(g) - bin_gt(index_k,:,index_g) <= bin_shtDOWN_gt(index_k,:,index_g);
                shtDOWNCnstr2(prdIndx+1,:,g) = bin_strUP_gt(index_k,:,index_g) + bin_shtDOWN_gt(index_k,:,index_g) <= 1;
                % GT state constraints
                statesGTCnstr(prdIndx+1,:,g) =  bin_gt(index_k,:,index_g) == x_gt_0(g) + bin_strUP_gt(1,:,g)...
                    - bin_shtDOWN_gt(1,:,g);
            end
            
        end
    end
    
    % Battery capacity constraints
    maxSOCCnstrBig = E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis) <= par.socUPlim   * par.E_bat_max;
    minSOCCnstrBig = E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis) >= par.socDOWNlim * par.E_bat_max;
    % Battery DoD updates constraints
    DoDUpdateCnstrBig = 1 - ((E_s_0*ones(N_scn*N_prd,1) + (Ts/60) * (par.eta_ch * nrgUpdtMtrxBig * P_ch_vec  - nrgUpdtMtrxBig * P_dis_vec/ par.eta_dis)) ./ par.E_bat_max) ==...
        DOD_vec;
    
    % Final state of charge penalization
    %         absSoCDevCnstr1(w) = soc_dev_abs(index_w)  == soc_dev_p(index_w) + soc_dev_n(index_w);
    %         absSoCDevCnstr2(w) =  1 - DOD(append('k+',int2str(N_prd-1)),index_w) - par.SoC_ref == soc_dev_p(index_w) - soc_dev_n(index_w);
    
    absSoCDevCnstr1 = soc_dev_abs(:)  == soc_dev_p(:) + soc_dev_n(:);
    %         absSoCDevCnstr2 =  1 - DOD_vec(N_prd:N_prd:N_prd*N_scn,:) - par.SoC_ref*ones(N_scn,1) == soc_dev_p(:) - soc_dev_n(:);
    absSoCDevCnstr2 =  1 - DOD_vec(1:N_prd:N_prd*N_scn,:) - par.SoC_ref*ones(N_scn,1) == soc_dev_p(:) - soc_dev_n(:);
    
    
    probMPC.Constraints.powBalanceCnstr        = powBalanceCnstr;
    probMPC.Constraints.statesGTCnstr          = statesGTCnstr;
    probMPC.Constraints.strtUPCnstr            = strtUPCnstr;
    probMPC.Constraints.shtDOWNCnstr           = shtDOWNCnstr;
    probMPC.Constraints.shtDOWNCnstr2          = shtDOWNCnstr2;
    
    probMPC.Constraints.maxSOCCnstrBig         = maxSOCCnstrBig;
    probMPC.Constraints.minSOCCnstrBig         = minSOCCnstrBig;
    probMPC.Constraints.DoDUpdateCnstrBig      = DoDUpdateCnstrBig;
    
    probMPC.Constraints.absSoCDevCnstr1        = absSoCDevCnstr1;
    probMPC.Constraints.absSoCDevCnstr2        = absSoCDevCnstr2;
    
    toc
    %}
end