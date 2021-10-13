# EMS-SMPC # 
 This repository contains the scripts used for the EMS-SMPC paper :blush:. The main tasks are described below:
 1. ### PARAMETERS ###
    1. `preamble.m` assigns the follwoing important parameters for the `main.m` : 
        * __Prediction Horizon__  : `par.N_prd`  _default value:_ 12 (6 to run MPC, 12 for CRPS calculation)
        * __Prediction Method__   : `par.method` _default value:_ 'scn_frcst'
        * __Number of Scenarios__ : `par.N_scn`  _default value:_ 10 (automatic check to assign 1 for point forecast method)
       
 2. ### RANDOM FORESTS ###
    1. - [ ]  `train_RF.m` used for training 
    
 4. ### GENERATE SCENARIOS functions ###
    1. - [ ]  `funScenGenQRF1.m` generate scenarios 1 step ahead 
    2. - [ ]  `funScenGenQRF.m` generate scenarios used in  `main.m` for MPC


 5. ### GENERATE RESULTS ###
    1. - [ ]  `funPltCtrlRslt.m` plot the control vriables results 
