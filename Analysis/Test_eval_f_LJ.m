% Add path with functions
addpath(genpath('../matlab'))

%% PARAMETERS
% Potential at rest (maximum negative potential)
rest_potential = 1;
% Distance at which the potential is zero
zero_potential_r = 2;
zero_potential_r * 2 ^ (1/6);
% Birds' mass
mass = .75;
% Initial speed value
v_init = 10; % m/s
% Maximum acceleration
max_A = 20;
% Maximum velocity
max_V = 20;
% Long range attraction force
coulomb_force = -20; -.3;
test_indx = 2;
switch test_indx
  case 1
    % Number of birds
    n_birds = 4;
    % Initial position and orientations
    x_start = [-1, -1,  1,  1,... x
               -1,  1, -1,  1,... y
                0,  0,  0,  0,... v_x
                0,  0,  0,  0,... v_y
               ];
    x_start = gpuArray(x_start);
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.1; % rad
  case 2
    % Number of birds
    n_birds = 1e3;
     % Initial position and orientations. For positions, let's place birds
    % randombly within a circle. For orientations, let's fix a global
    % orientation and add random orientation for each bird
    cirle_angle = 2 * pi * rand(n_birds, 1);
    circle_radius = 50 * rand(n_birds, 1);
    global_dir = 2 * pi * rand();
    local_dir_range = pi / 10;
    % Initial position and orientations.
    x_start = cat(1, circle_radius .* cos(cirle_angle),...
      circle_radius .* sin(cirle_angle),...
      20 * zeros(2 * n_birds, 1))';
    x_start = gpuArray(x_start);
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.1; % rad
end
% Name of function to evaluate f()
eval_f = 'eval_f_LJ';
% Name of function to evaluate u()
eval_u = 'eval_u_LJ';
% Response time parameter
Gamma1 = 10;
Gamma2 = 10;
% Time step
timestep = .1;
% Number of time points, initial and final time point
t_points = 10000;
t_start = 0;
t_stop = timestep * t_points;
% Video file name
vid_filename = fullfile('../Output/StarlingMurmuration');
% Struct with parameters
params = struct('n_birds', n_birds, 'rest_potential', rest_potential,...
  'zero_potential_r', zero_potential_r, 'v_init', v_init, 'mass', mass,...
  'max_V', max_V, 'max_A', max_A, 'coulomb_force', coulomb_force,...
  'Gamma1', Gamma1, 'Gamma2', Gamma2);
% Evaluate functions with Forward Euler method
[X, t] = StormerMethod(eval_f, x_start, params, eval_u, t_start,...
  t_stop, timestep, true, 0 * vid_filename);
