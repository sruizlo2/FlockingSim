% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output/FEConvergencewAMLong';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

%% FUNCTIONS
% Name of function to evaluate f()
eval_f_delay = 'eval_f_CSModelWDelay';
eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Name of function to evaluate y()
eval_y = 'ComputeOutputs';

%% PARAMETERS
parms = struct();

% Use GPU?
parms.useGPU = false;
% Model parameters
parms.Ca = 3.0e-7;    % Effective distance of the attraction 3
parms.Cr = 0.5;       % Strength of the short-range repulsion 0.5
parms.lr = 0.15;      % Effective distance of the repulsion 0.15
parms.v0 = 1.00;      % Terminal speed
parms.alpha_ = 0.2;   % Strenght of drag force
parms.Kv = 0.1;       % Interaction strength of velocity matching
parms.Ka = 0.12;      % Interaction strength of acceleration matching
parms.kappa = 800;    % Maximum time delay for acceleration matching (in 1/10 seconds)
parms.r0 = 0.6;       % Minimum distance to compuate variance in local order computation
parms.c0 = 10;        % Scale factor for variance
parms.lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
% Parameters for computer correlation function
parms.NCorr = 50; % Length of correlation fuction
parms.maxRCorr = 25; % Maximum distance to compute correlation

% Number of birds
n_birds = 1e3;
parms.n_birds = n_birds;
% Initial position and velocities.
% For positions, let's place birds randombly within a circle
rng('default');
cirle_angle = 2 * pi * rand(n_birds, 1);
circle_radius = 10 * sqrt(rand(n_birds, 1));
% Initial positions and velocities
x_start = cat(1, circle_radius .* cos(cirle_angle),...
  circle_radius .* sin(cirle_angle),...
  parms.v0 * 2 * (rand(2 * n_birds, 1) - 0.5));
% Initial accelerations, constant for all birds and time steps
am0 = 0; % Initial past accelerations matching
a_start = am0 * ones(2 * n_birds, parms.kappa + 1);
parms.a = a_start;

% Move to GPU if needed
if parms.useGPU
  x_start = gpuArray(x_start);
end

%% OPTIONS FOR VISUALIZATION OF THE FLOCK
parms.vis.fov = 40;             % Maximum FOV in X and Y
parms.vis.markersize = 5;       % Size of the dots that represent birds
parms.vis.linewidth = 0.15;     % Linewidth of the bird velocity arror
parms.vis.plotFPS     = [];     % Number of visualization (frames) per second (default is 1 fps)
parms.vis.background_color = [0.7 0.9 0.95]; % Color of plot background
parms.vis.flock_color = [1 0.0784 0.1373];   % Color or visualization of flock outputs
parms.vis.birds_color = [0 0 0];             % Color or birds arrors
parms.vis = InitializeVisualizeFlock(parms.vis); % Set unset parameters to default values

% Video file name
filenamePrefix = 'Murmuration';
filenameSufix = 'FEConvergence2';
parms.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s',...
  filenamePrefix, filenameSufix));
VisualizeFlockFigNum = 2; % False for not plotting flock

%% OPTIONS FOR VISUALIZATION OF THE OUTPUTS
parms.visOut.linewidth = 2;              % Line width for plots
parms.visOut.order_limsX = [-inf inf];   % X limits for group order
parms.visOut.order_limsY = [0.6 1.05];   % Y limits for group order
parms.visOut.speed_limsX = [-inf inf];   % X limits for group speed
parms.visOut.speed_limsY = [0 1.1];      % Y limits for group speed
parms.visOut.size_limsX = [-inf inf];    % X limits for group size
parms.visOut.size_limsY = [2 10.5];      % Y limits for group size
parms.visOut.com_limsX = [-10 80];       % X limits for group center of mass
parms.visOut.com_limsY = [-10 80];       % Y limits for group center of mass
parms.visOut.showcorr = true;           % Whether to show correlation distances plots
parms.visOut = InitializeVisualizeOutputs(parms.visOut); % Set unset parameters to default values

%% Measure f_eval time with tic toc
parms.update_a = true;
t = 0;
nevals = 1000;
tic
for k = 1:nevals
  u = feval(eval_u, x_start, t, parms);
end 
time = toc;
timePerU = time / nevals;
fprintf('u_eval average time: %.3f us\n', timePerU * 1e6)

u = feval(eval_u, x_start, t, parms);
tic
for k = 1:nevals
  [f, parms] = feval(eval_f_delay, x_start, parms, u);
end
time = toc;
timePerF = time / nevals;
fprintf('f_eval average time: %.3f ms\n', timePerF * 1e3) % 22.4 ms

%% Example of total simulation for Forward Euler
dt = 1e-2;
t_stop = 50;
total_time = t_stop / dt * timePerF / 3600;
fprintf('For dt = %1.0e, total time of eval_f = %.3f hours\n', dt, total_time)

%% Profile
nevals = 20;
profile on
for k = 1:nevals
  [f, parms] = feval(eval_f_delay, x_start, parms, u); % var() for LocalOrder() is the most expensive 
end
profile off
profreport

%% Time numerical Jacobian
u = feval(eval_u, x_start, t, parms);
nevals = 1;
tic
for k = 1:nevals
[Jf, dxFD] = eval_Jf_FiniteDifference(eval_f_delay, x_start, parms, u);
end
time = toc;
timePerJf = time / nevals;
fprintf('f_eval average time: %.3f s\n', timePerJf) % 86.3 s

%% Example of total simulation time for Trapezoidal integration
dt = 0.1;
t_stop = 50;
maxNewtonIter = 10;
total_time = t_stop / dt * maxNewtonIter * timePerJf / 3600;
fprintf('For dt = %1.0e, total time of eval_f = %.3f hours\n', dt, total_time)

%% Example of total simulation time for Trapezoidal integration with Matrix-free GCR
dt = 0.1;
t_stop = 50;
maxNewtonIter = 10;
maxGCRIter = 100;
total_time = t_stop / dt * maxNewtonIter * maxGCRIter * timePerF / 3600;
fprintf('For dt = %1.0e, total time of eval_f = %.3f hours\n', dt, total_time)



