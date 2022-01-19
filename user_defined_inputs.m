%-----USER DEFINED VALUES-----
%%
input.startingDay  = 100;
input.durationDays = 0;
input.giveStartingTime = 1;           % {0, 1}
inut.startingTime  = 7649;
input.doAnimation  = 0;
input.animationVar = 'load';          % {'load', 'wind'}

input.randomSeed   = 24;

input.method       = 'scn_frcst';     % {'point_frcst', 'scn_frcst'}
input.degradWeight = 'noWeight';      % {'noWeight','none', 'normal', 'low', 'medium', 'high'}


if ~xor(strcmp(input.method,'point_frcst')==1, strcmp(input.method,'scn_frcst')==1)
    error(['Non valid argument for input.method.' newline...
           'Insert: point_frcst OR scn_frcst']);
end

if input.durationDays == 1
    input.simulPeriodName = ['day_',int2str(input.startingDay)];
    input.N_steps = 4*24*input.durationDays;
    t_current   = 4*24*(input.startingDay-1);    

elseif input.durationDays > 1
    input.simulPeriodName = ['days_',int2str(input.startingDay),'_',int2str(input.startingDay + input.durationDays)];
    input.N_steps = 4*24*input.durationDays;
    t_current   = 4*24*(input.startingDay-1);    

elseif input.durationDays == 0
    input.N_steps = 300;    % number of timesteps to simulate 576 (nice period)
    if input.giveStartingTime == 0
        input.simulPeriodName = ['day_',int2str(input.startingDay),'_steps_',int2str(input.N_steps)];
        t_current   = 4*24*(input.startingDay-1);
    else
        input.simulPeriodName = ['t_',int2str(inut.startingTime),'_steps_',int2str(input.N_steps)];
        t_current   = inut.startingTime;
    end
end

input.N_prd = 6;    % {6, 12}
input.lgdLocationDstrb = 'southwest';
input.lgdLocationIgtOn = 'southeast';
input.lgdLocationSoC   = 'southeast';