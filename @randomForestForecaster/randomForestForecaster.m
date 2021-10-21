classdef randomForestForecaster < handle
    %randomForestForecaster This class issues forecasts, calculates metrics
    %and visualizes the forecastingresults
    %   Detailed explanation goes here
    
    properties

        forecastMethod (1,1) string {mustBeMember(forecastMethod,{'point_frcst','scn_frcst'})}= 'point_frcst'
        forecastModel
        forecastData
        
        forecastIssueTime
        forecastStepsDuration
        forecastStartingDay (1,1) double  {mustBeInRange(forecastStartingDay,1,365)} = 100
        forecastDaysDuration (1,1) double {mustBeInRange(forecastDaysDuration,1,10)} = 1


    end % properties
    
    methods
        % standard constructor
        function obj = randomForestForecaster(timeseriesData)
            % Summary of constructor
            if nargin == 0
                %
                obj.forecastData = [];
            else
                obj.forecastData = timeseriesData;
                
            end
        end % standard constructor
        %
    end % normal methods
    %
    %
    
    methods
        function [period_name,t_current] = setDuration(obj,starting_day,number_of_days)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            if number_of_days == 1
                period_name = ['day_',int2str(starting_day)];
                obj.forecastStepsDuration = 4*24*number_of_days;
                obj.forecastIssueTime   = 4*24*(starting_day-1);
                
            elseif number_of_days > 1
                period_name = ['days_',int2str(starting_day),'_',int2str(starting_day + number_of_days)];
                obj.forecastStepsDuration = 4*24*number_of_days;
                obj.forecastIssueTime   = 4*24*(starting_day-1);
                
            elseif number_of_days == 0
                obj.forecastStepsDuration = 0;
                period_name = ['day_',int2str(starting_day),'_steps_',int2str(obj.forecastStepsDuration)];
                obj.forecastIssueTime   = 4*24*(starting_day-1);
            end
%             obj.Property1 = inputArg1 + inputArg2;
            t_current = obj.forecastIssueTime;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

