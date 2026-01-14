%%  Warthunder flight data Logger

%{
    README - how to run
- start warthunder game/test flight
- pause > options > bottom left blue text "open map in browser"
- wait for webpage to load and start displaying data
- run datalogger script
- complete mission in warthunder
- press stop logging button
- note csv files name
- open flight path reconstruction script
- make sure indicated csv file has the correct name
- run flight path reconstruction script

%}

clear; clc;

%% end flight button
disp('Logging started. Press the STOP button to end.');

fig = uifigure('Name','War Thunder Logger','Position',[100 100 300 100]);
btn = uibutton(fig,'Text','STOP LOGGING','Position',[50 30 200 40]);
btn.ButtonPushedFcn = @(src,event) setappdata(fig,'stop',true);

setappdata(fig,'stop',false);

%% storage variables
timeLog   = [];
altLog    = [];
rollLog   = [];
pitchLog  = [];
yawLog    = [];
speedLog  = [];
aoaLog    = [];
aosLog    = [];

% safe field accessor
getf = @(s,f) (isfield(s,f) * s.(f)) + (~isfield(s,f) * NaN);

% Main logging loop

while true

    % check for button press
    if getappdata(fig,'stop')
        break
    end

    try
        state = webread('http://localhost:8111/state');
        ind   = webread('http://localhost:8111/indicators');

        t = posixtime(datetime('now'));

        % sselect parameters (can add/remove as required)
        alt   = getfield(state, 'H_M');
        roll  = getfield(ind, 'aviahorizon_roll');
        pitch = getfield(ind, 'aviahorizon_pitch');
        yaw   = getfield(ind, 'compass');
        speed = getfield(state, 'TAS_Km_h');

        AOA = getfield(ind, 'aviahorizon_pitch');
        AOS = getfield(ind, 'aviahorizon_roll');

        % append to datalog
        timeLog(end+1)  = t;
        altLog(end+1)   = alt;
        rollLog(end+1)  = roll;
        pitchLog(end+1) = pitch;
        yawLog(end+1)   = yaw;
        speedLog(end+1) = speed;
        aoaLog(end+1)   = AOA;
        aosLog(end+1)   = AOS;

        fprintf('ALT: %.1f m | ROLL: %.1f deg | PITCH: %1.f | YAW: %1.f | SPEED: %1.f | AOA: %1.f | AOS: %1.f |\n', alt, roll, pitch, yaw, speed, AOA, AOS);

    catch
        % fuck errors who cares
    end

    %pause(0.0001); % ~20 Hz
end

disp('Logging stopped.');

%% Convert to MATLAB table

flightLog = table( ...
    timeLog', altLog', rollLog', pitchLog', yawLog', ...
    speedLog', aoaLog', aosLog', ...
    'VariableNames', {'time','alt','roll','pitch','yaw','speed','AOA','AOS'} ...
);

disp('Flight log stored in variable: flightLog');

% Save the flight log to a CSV file
% NOTE: IF FILE WITH THIS NAME ALREADY EXISTS, TERMINAL ERROR PREVENTS CSV
% FROM BEING WRITTEN.  THE DATA WILL STILL EXIST IN MATLAB TABLE FILE.
writetable(flightLog, 'slow_plane.csv');
disp('Flight log saved to flight_log.csv');
