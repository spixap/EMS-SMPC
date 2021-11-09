# EMS-SMPC # 
 This repository contains the scripts :scroll: used for the EMS-SMPC paper :page_facing_up:.
 
 ## RANDOM FORESTS :deciduous_tree: ## 
  1. - __Random Forests (RF) TRAINING__
       * Load timeseries: GFA_15_min (load data), RES (wind speed data)
       * `train_RF.m` : train RF models
       * Output: RF models Mdl_ld (load), Mdl_wp (wind power)

  2. - __FIGURES__  
       * `figures_section_2_2.m` : describe plots [ ]
       * `figures_section_4_1_2.m` : describe plots [ ]
 
 ## INPUTS :clipboard: :floppy_disk: ##
 1. - __USER DEFINED INPUTS__
    * `user_defined_inputs.m` : define the input structure
    * __Method__  : `input.method`  _default value:_ 12 (6 to run MPC, 12 for CRPS calculation)
    * - [ ]  describe the rest of input structure

 2. - __SYSTEM SIMULATION (DMPC/SMPC)__  
    * `main.m` : simulate system with DMPC/SMPC
    * `optProb.m` : formulate the MILP optimization rpoblem for DMPC/SMPC

    <details>
     <summary> Default Values :1234:</summary>

     * `input.method = 'scn_frcst`
     * `input.degradWeight = 'noWeight'`

   </details>
   



 The main tasks are described below :arrow_down:
 1. ### PARAMETERS :bar_chart: ###
    1. `preamble.m` assigns :paperclip: important parameters for the `main.m` : 
        * __Prediction Horizon__  : `par.N_prd`  _default value:_ 12 {_MPC simulation_, _CRPS calculation_} = {6, 12}
        * __Prediction Method__   : `par.method` _default value:_ 'scn_frcst'
        * __Number of Scenarios__ : `par.N_scn`  _default value:_ 10 (automatic check to assign 1 for point forecast method)
        * __Number of Simulation Steps__ : `par.N_steps`  _default value:_ 4 * 24 * num_of_days
        * __Current time that simulation starts__ : `t_current`  _default value:_ 4 * 24 * (simulation_day - 1)


    <details>
     <summary> Default Values :1234:</summary>

     * `par.N_prd = 6`
     * `par.N_scn = 10`

   </details>
       
    
 2. ### GENERATE SCENARIOS :crystal_ball: ###
    1. - [ ]  `funScenGenQRF1.m` generate scenarios 1 step ahead 
    2. - [ ]  `funGetCtrlRslt.m` gives you the kpi based on the result in RSLT
               example use (mean case): `funGetCtrlRslt(par, RSLT.ESS_mean.x, RSLT.ESS_mean.u_0  , RSLT.ESS_mean.rslt);`


 3. ### GENERATE RESULTS :bulb: ###
    1. - [ ]  `funPltCtrlRslt.m` plot the control vriables results 
    2. - [ ]  `funPltCtrlRslt.m` plot the control vriables results 


## SIMULATION CASE STUDIES :hourglass: ##

<details>
  <summary>Cases :date:</summary>
  
  * Day 100: 10 April
  * Day 104: 14 April
  * Day 105: 15 April
  * Day 107: 17 April
  * Day 109: 19 April

</details>

<details>
  <summary>Cases with opex savings :date:</summary>
  
  * Day 100: 10 April 
  * Day 107: 17 April
  * Day 112: 21 April
  * Day 118: 27 April
  * Day 126: 06 May
  * Day 226: 14 August
  * Day 237: 25 August
  * Day 61:  02 March
  * Day 166: 15 June
  * Day 290: 17 October
  * Day 160: 09 June
  * Day 192: 11 July

</details>

<details>
  <summary>Cases with higher opex :date:</summary>
  
  * Day 238:  
  * Day 301: 

</details>

<details>
  <summary>Steps :date:</summary>
  
 
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
