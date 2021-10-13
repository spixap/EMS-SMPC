classdef WindFarm < handle
    properties
        WindValue   % Load Wind Speed data
        Umin        % Minimum Wind Speed
        Umax        % Maximum wind speed
        Un          % Nominal Wind Speed
        Pn          % Nominal Wind Turbine Power
        WT_nmr      % Number of Wind Turbines
        WindPower   % Calculated or Loaded Wind Power
    end
    methods
        % standard constructor
        function objData = WindFarm()
            % Example:
            % WF1 = WindFarm(); (This is the object of the Wind Farm created)
            % WF1.WindValue = ErickWindSpeedPrepro; (load wind speed data to this object)
            
            objData.SetAsDefault();
            objData.WindPower = [];
            
            %
        end % standard constructor
        
        
        % ---Method 1:
        function WPG=DoWindPower(objData)
            % Calculate the wind power generation from given wind speed
            % dataset and wind turbine characteristics
            % Example:
            % WF1.DoWindPower; OR WindPower1 = DoWindPower(WF1);
            
            WPG = zeros(length(objData.WindValue),1);
            for i=1:length(objData.WindValue)
                if objData.WindValue(i) < objData.Umin
                    WP = 0;
                elseif (objData.Umin <= objData.WindValue(i))&&(objData.WindValue(i)<objData.Un)
                    WP =objData.WT_nmr*objData.Pn*(objData.WindValue(i)/objData.Un)^3;
                elseif (objData.WindValue(i)>= objData.Un)&&(objData.WindValue(i)<objData.Umax)
                    WP =objData.WT_nmr*objData.Pn;
                else
                    WP = 0;
                end
                WPG(i)=WP;
            end
            objData.WindPower = WPG;
        end
    end
end