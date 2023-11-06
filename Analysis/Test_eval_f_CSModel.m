% Add path with functions
addpath(genpath('../matlab'))

%% PARAMETERS
% Normalization constants
ls = 1; % Length scale
ts = 0.1; % Time slace

% Parameters
Ca = 1.5e-7;  % Effective distance of the attraction
Cr = 1.5;     % Strength of the short-range repulsion
lr = 0.05;    % Effective distance of the repulsion
v0 = 1;       % Terminal speed
alpha_ = 0.2; % Strenght of drag force
Kv = 0.1;     % Interaction strength of velocity matching
Ka = 0.0;     % Interaction strength of acceleration matching

potential_func = 'Morse_Wall_Potential';
test_indx = 1;
switch test_indx
  case 1
    % Number of birds
    n_birds = 4;
    % Initial position and orientations
    x_start = [-1, -1,  1,  1,... x
               -1,  1, -1,  1,... y
               v0, v0,  -v0,  -v0,... v_x
               v0,  -v0, v0,  -v0,... v_y
               ]';
    % Options for plotting
    fov = 10;
    markersize = 20;
  case 2
    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations. For positions, let's place birds
    % randombly within a circle. For orientations, let's fix a global
    % orientation and add random orientation for each bird
    cirle_angle = 2 * pi * rand(n_birds, 1);
    circle_radius = 50 * rand(n_birds, 1);
    local_dir_range = pi / 10;
    % Initial position and orientations.
    x_start = cat(1, circle_radius .* cos(cirle_angle),...
      circle_radius .* sin(cirle_angle),...
      v0 * ones(2 * n_birds, 1))';
    % Options for plotting
    fov = 50;
    markersize = 5;
end
% Name of function to evaluate f()
eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Time step
timestep = .01;
% Number of time points, initial and final time point
t_points = 100;
t_start = 0;
t_stop = timestep * t_points;
% Video file name
vid_filename = fullfile('../Output/StarlingMurmuration');
% Struct with parameters
parms = struct('n_birds', n_birds, 'Ca', Ca, 'Cr', Cr, 'lr', lr,...
  'v0', v0, 'alpha_', alpha_, 'Kv', Kv, 'Ka', Ka,...
  'potential_func', potential_func,...
  'fov', fov, 'markersize', markersize); % Ploting options
parms = NormalizeParameters(parms, ls, ts);
% Evaluate functions with Forward Euler method
[X, t] = ForwardEuler(eval_f, x_start, parms, eval_u, t_start,...
  t_stop, timestep, true);
