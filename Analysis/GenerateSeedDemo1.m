clear all, clc
% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '..//Output/Demos';
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
parms = ModelParameters;
parms.NCorr = 50;
parms.Ka = 0;
parms.kappa = 0;
% Use GPU?
parms.useGPU = true;

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
parms.vis.fov = 30;             % Maximum FOV in X and Y
parms.vis.markersize = 5;       % Size of the dots that represent birds
parms.vis.linewidth = 0.15;     % Linewidth of the bird velocity arror
parms.vis.plotFPS     = [];     % Number of visualization (frames) per second (default is 1 fps)
parms.vis.background_color = [0.7 0.9 0.95]; % Color of plot background
parms.vis.flock_color = [1 0.0784 0.1373];   % Color or visualization of flock outputs
parms.vis.birds_color = [0 0 0];             % Color or birds arrors
parms.vis = InitializeVisualizeFlock(parms.vis); % Set unset parameters to default values
parms.vis.fps = 3;

% Video file name
filenamePrefix = 'Murmuration';
filenameSufix = 'FE';
parms.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s_Demo1Seed',...
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

%% Integrate via Forward Euler seed
% Options for Forward Euler
t_start = 0;        % Starting time
t_stop = 10;        % Ending time
keepHist = false;   % Keep history or only last solution and output?
visualize = 1;      % Number of figure to visualize plot (false for not plotting)
verbsoity = false;  % Print progress of FE?
progstep = 10;      % Percentange of progress of FE to show
timestep = 0.1;     % Time step
% Name of the output .mat file
outputFilename = fullfile(outputFolder, sprintf('%s_%s_Demo1Seed',...
  filenamePrefix, filenameSufix));
% GenerateFEReference(nVect, outputFilename, eval_f_delay, eval_u, parms, FEparms);
% Forward Euler
[XFE, t, YFE, corrF, corrR, parmsOut] = ForwardEulerWDelay(eval_f_delay,...
  x_start, parms, eval_u, t_start, t_stop, timestep, visualize, keepHist, verbsoity);
% Save initial conditions
save(sprintf('%s_dt_%.0e.mat', outputFilename, timestep), 'XFE', 'parmsOut', '-v7.3')

%% Integrate via Forward Euler seed
% Options for Forward Euler
t_start = 0;        % Starting time
t_stop = 60;        % Ending time
keepHist = false;   % Keep history or only last solution and output?
visualize = 1;      % Number of figure to visualize plot (false for not plotting)
verbsoity = false;  % Print progress of FE?
progstep = 10;      % Percentange of progress of FE to show
timestep = 0.1;     % Time step
% Name of the output .mat file
parms.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s_Demo1Full',...
  filenamePrefix, filenameSufix));
outputFilename = fullfile(outputFolder, sprintf('%s_%s_Demo1Full',...
  filenamePrefix, filenameSufix));
% GenerateFEReference(nVect, outputFilename, eval_f_delay, eval_u, parms, FEparms);
% Forward Euler
[XFE, t, YFE, corrF, corrR, parmsOut] = ForwardEulerWDelay(eval_f_delay,...
  x_start, parms, eval_u, t_start, t_stop, timestep, visualize, keepHist, verbsoity);
% Save initial conditions
save(sprintf('%s_dt_%.0e.mat', outputFilename, timestep), 'XFE', 'parmsOut', '-v7.3')