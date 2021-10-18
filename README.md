# EMS-SMPC # 
 This repository contains the scripts :scroll: used for the EMS-SMPC paper :page_facing_up:.
 ## INPUTS :clipboard: :floppy_disk: ##
 1. - [ ]  __QRF TRAINING__
    * __Prediction Horizon__  : `par.N_prd`  {_MPC simulation_, _CRPS calculation_} = {6, 12}
 2. - [ ]  __MPC SYSTEM SIMULATION__  
    * __Method__  : `input.method`  _default value:_ 12 (6 to run MPC, 12 for CRPS calculation)

    <details>
     <summary> Default Values :1234:</summary>

     * `par.N_prd = 10`
     * `par.N_prd = 10`

   </details>
   



 The main tasks are described below :arrow_down:
 1. ### PARAMETERS :bar_chart: ###
    1. `preamble.m` assigns :paperclip: important parameters for the `main.m` : 
        * __Prediction Horizon__  : `par.N_prd`  _default value:_ 12 (6 to run MPC, 12 for CRPS calculation)
        * __Prediction Method__   : `par.method` _default value:_ 'scn_frcst'
        * __Number of Scenarios__ : `par.N_scn`  _default value:_ 10 (automatic check to assign 1 for point forecast method)
        * __Number of Simulation Steps__ : `par.N_steps`  _default value:_ 4 * 24 * num_of_days
        * __Current time that simulation starts__ : `t_current`  _default value:_ 4 * 24 * (simulation_day - 1)
       
 2. ### RANDOM FORESTS :deciduous_tree: ### 
    1. - [ ]  `train_RF.m` used for training 
    
 3. ### GENERATE SCENARIOS :crystal_ball: ###
    1. - [ ]  `funScenGenQRF1.m` generate scenarios 1 step ahead 
    2. - [ ]  `funScenGenQRF.m` generate scenarios used in  `main.m` for MPC


 4. ### GENERATE RESULTS :bulb: ###
    1. - [ ]  `funPltCtrlRslt.m` plot the control vriables results 


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

</details>

## DATA FILES :open_file_folder: ##
