% Add path with functions
addpath(genpath('../matlab'))

%% PARAMETERS
% Number of informed birds (not used yet)
n_informed_birds = 1e2;
% Add informed birds
add_informed_birds = false;
% Informed direction bias
informed_dir = -pi / 4;
% Constant speed value
v_init = 10; % m/s
% Radius of interation
interaction_radius = 100; % m
% Use random orientations or fixed
% Field of view: Angle each bird can see (in rads)
fov =  2 * (pi / 8);
test_indx = 2;
switch test_indx
  case 1 % Constat positions, constant orientations
    % Number of birds
    n_birds = 10;
    % Initial position and orientations
    x_start = zeros(2 * n_birds, 1);
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.0; % rad
  case 2 % Random positions, constant orientations
    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations. For positions, let's place birds
    % randombly within a circle. For orientations, let's fix a global
    % orientation and add random orientation for each bird
    cirle_angle = 2 * pi * rand(n_birds, 1);
    circle_radius = 20 * rand(n_birds, 1);
    global_dir = 2 * pi * rand();
    local_dir_range = pi / 10;
    x_start = cat(1, cat(1, circle_radius .* cos(cirle_angle), circle_radius .* sin(cirle_angle)),...
      global_dir + local_dir_range * rand(n_birds, 1));
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.1; % rad
  case 3 % Random positions, Random orientations
    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations
    x_start = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
      -pi / 4 * rand(n_birds, 1));
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.5; % rad
  case 4
    n_birds = 2;
%     x_start = [-1  1     1 -1     pi/4 pi/4];%
%         x_start = [-1 1     -1  1     3 * pi / 4 3 * pi / 4];%
%         x_start = [-1 1      1 -1     5 * pi / 4 5 * pi / 4];%
        x_start = [-1 1     -1  1     7 * pi / 4 7 * pi / 4];%
    dir_fluc_range = 0;
  case 5
    n_birds = 5;
    x_start = [-1 -1 1 1 0    -1 1 -1 1 0    pi/2+0.2 pi/2 pi/2 pi/2 pi/2];%
    dir_fluc_range = 0.1; % rad
end

% Indices of informed birds
informed_birds = randperm(n_birds, min(n_birds, n_informed_birds));
% Name of function to evaluate f()
eval_f = 'eval_f_PM2';
% Name of function to evaluate u()
eval_u = 'eval_u';
% Response time parameter
Gamma1 = 10;
Gamma2 = 10;
% Time step
timestep = .5;
% Number of time points, initial and final time point
t_points = 1000;
t_start = 0;
t_stop = timestep * t_points;
% Struct with parameters
params = struct('interaction_radius', interaction_radius,...
  'dir_fluc_range', dir_fluc_range, 'n_birds', n_birds,...
  'Gamma1', Gamma1, 'Gamma2', Gamma2, 'v_init', v_init, 'fov', fov,...
  'add_inform_birds', add_informed_birds,...
  'informed_birds', informed_birds, 'informed_dir', informed_dir);
% Evaluate functions with Forward Euler method
[X, t] = ForwardEuler(eval_f, x_start, params, eval_u, t_start,...
  t_stop, timestep, true);
