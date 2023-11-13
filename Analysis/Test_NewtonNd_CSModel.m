% Add path with functions
addpath(genpath('../matlab'))

%% PARAMETERS
% Normalization constants
ls = 1; % Length scale
ts = 0.1; % Time slace

% Parameters
Ca = 5; %1.5e-7 % Effective distance of the attraction
Cr = 5; %1.5    % Strength of the short-range repulsion
lr = 0.25;%0.05 % Effective distance of the repulsion
v0 = 1;         % Terminal speed
alpha_ = 0.2;   % Strenght of drag force
Kv = 0.1;       % Interaction strength of velocity matching
Ka = 0.12;      % Interaction strength of acceleration matching
kappa = 100;    % Maximum time delay for acceleration matching
r0 = 10;        % Minimum distance to compuate variance in local order computation
c0 = 10;        % Scale factor for variance
lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
epsilon = 1e-14;
potential_func = 'MorseWallForceAnalytical';
test_indx = 1;
switch test_indx
  case 1
    % Number of birds
    n_birds = 4;
    % Initial accelerations
    a0 = 0;
    % Initial past accelerations matching
    am0 = 0;
    % Initial position and orientations
    x_start = [-1, -1,  1,  1,... x
               -1,  1, -1,  1];... y
%                v0, v0,  -v0,  -v0,... v_x
%                v0,  -v0, v0,  -v0];... v_y
    a_start = am0 * ones(2 * n_birds, kappa + 1);
    % Options for plotting
    fov = 5;
    markersize = 20;
  case 2
    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations. For positions, let's place birds
    % randombly within a circle. For orientations, let's fix a global
    % orientation and add random orientation for each bird
    cirle_angle = 2 * pi * rand(n_birds, 1);
    circle_radius = 25 * rand(n_birds, 1);
    local_dir_range = pi / 10;
    % Initial positions and velocities
    x_start = cat(1, circle_radius .* cos(cirle_angle),...
      circle_radius .* sin(cirle_angle),...
      v0 *(1 + 0.5 * (rand(2 * n_birds, 1) - 0.5)));
    % Initial accelerations, constant for all birds and time steps
    a_start = am0 * ones(2 * n_birds, kappa + 1);
    % Options for plotting
    fov = 50;
    markersize = 5;
end
% Name of function to evaluate f()
eval_f = 'eval_f_CSModel_Newton';
eval_Jf = 'eval_Jf_FiniteDiff';

%eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Video file name
vid_filename = fullfile('../Output/StarlingMurmuration');
% Struct with parameters
parms = struct('n_birds', n_birds, 'Ca', Ca, 'Cr', Cr, 'lr', lr,...
  'v0', v0, 'alpha_', alpha_, 'Kv', Kv, 'Ka', Ka, 'kappa', kappa,...
  'r0', r0, 'c0', c0, 'lo_method', lo_method, 'potential_func', potential_func,...
  'fov', fov, 'markersize', markersize, 'a', a_start, 'epsilon', epsilon); % Ploting options
parms = NormalizeParameters(parms, ls, ts);
% Newton termination criteria feel free to adjust as needed
errf      = 1e-12;		
errDeltax = 1e-12;
relDeltax = 1e-12;
MaxIter   = 200;	
FiniteDifference = 0;
visualize=1;
% Evaluate functions with Newton solver
[X_state,converged,errf_k,errDeltax_k,relDeltax_k,iterations,X] = NewtonNd(eval_f,x_start,parms,eval_u_CSModel,errf,errDeltax,relDeltax,MaxIter,visualize,FiniteDifference,eval_Jf);
% Evaluate functions with Forward Euler method
% [X, t] = ForwardEuler(eval_f, x_start(1:4*n_birds, end), parms, eval_u, t_start,...
%   t_stop, timestep, true);
