function SetAsDefault(objData)
    % Example:
    % WP1.WindValue = ErickWindSpeedPrepro;
    
    objData.Umin   = 3;
    objData.Umax   = 25;
    objData.Un     = 12;
    objData.Pn     = 8;  % Nominal = 8 MW   for the wind turbine
    objData.WT_nmr = 5; % Nominal = 5 wind turbines
    %
end % function

