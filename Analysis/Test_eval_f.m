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
v_init = 1; % m/s
% Radius of interation
interaction_radius = 1; % m
% Use random orientations or fixed
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
    % Initial position and orientations
    x_start = 20 * (rand(2 * n_birds, 1) - 0.5);
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.0; % rad
  case 3 % Random positions, Random orientations
    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations
    x_start = 20 * (rand(2 * n_birds, 1) - 0.5);
    % Range for uniformly distributed random orientation fluctuations
    dir_fluc_range = 0.0; % rad
end

% Indices of informed birds
informed_birds = randperm(n_birds, min(n_birds, n_informed_birds));
% Name of function to evaluate f()
eval_f = 'eval_f_PM2';
% Name of function to evaluate u()
eval_u = 'eval_u';
% Response time parameter
Gamma = 1;
% Time step
timestep = 0.1;
% Number of time points, initial and final time point
t_points = 500;
t_start = 0;
t_stop = timestep * t_points;
% Struct with parameters
params = struct('interaction_radius', interaction_radius,...
  'dir_fluc_range', dir_fluc_range, 'n_birds', n_birds,...
  'Gamma', Gamma, 'v_init', v_init,...
  'add_inform_birds', add_informed_birds,...
  'informed_birds', informed_birds, 'informed_dir', informed_dir);
% params = struct('interaction_radius', interaction_radius,...
%   'dir_fluc_range', dir_fluc_range, 'n_birds', n_birds,...
%   'timestep', .1, 'v_init', v_init,...
%   'add_inform_birds', add_informed_birds,...
%   'informed_birds', informed_birds, 'informed_dir', informed_dir);

% Evaluate functions with Forward Euler method
[X, t] = ForwardEuler(eval_f, x_start, params, eval_u, t_start,...
  t_stop, timestep, true);
