% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output/MFTrapNoAM';
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
parms.useGPU = true;
% Model parameters
parms.Ca = 1.5e-7;    % Effective distance of the attraction 3
parms.Cr = 1.5;       % Strength of the short-range repulsion 0.5
parms.lr = 0.05;      % Effective distance of the repulsion 0.15
parms.v0 = 1.00;      % Terminal speed
parms.alpha_ = 0.2;   % Strenght of drag force
parms.Kv = 0.1;       % Interaction strength of velocity matching
parms.Ka = 0.00;      % Interaction strength of acceleration matching
parms.kappa = 0;      % Maximum time delay for acceleration matching (in 1/10 seconds)
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
filenameSufix = 'Trap_p1';
parms.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s',...
  filenamePrefix, filenameSufix));
% Name of the output .mat file
outputFilename = fullfile(outputFolder, sprintf('%s_%s_1',...
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
parms.visOut.showcorr = false;           % Whether to show correlation distances plots
parms.visOut = InitializeVisualizeOutputs(parms.visOut); % Set unset parameters to default values

%% Run trapezoidal
% options for Newton and GCR
parms.Newton.errF = 1e-4;
parms.Newton.errDeltax = 1e-4;
parms.Newton.relDeltax = 1e-4;
parms.Newton.MaxIter = 10;
parms.Newton.tolrGCR = 1e-4;
parms.Newton.epsMF = 1e-6;
% Options for trapezoidal
t_start = 0;        % Starting time
t_stop = 50;        % Ending time
timestep = 0.1;     % Time step
keepHist = true;    % Keep history or only last solution and output?
vebosity = 2;       % Print information: 0 for nothing, 1 for Trap info only, 2 for Trap and Newton info
parms.progstep = 1; % Percentange of progress of FE to show

% Trapezoidal integration
tic
[XTrap, tTrap, YTrap] = TrapezoidalIntegrationWDelay(eval_f_delay,...
  x_start, parms, eval_u, t_start, t_stop, timestep,...
  'MF', eval_y, VisualizeFlockFigNum, keepHist, vebosity);
TrapTime = toc;
fprintf('Total time: %.3f min\n', TrapTime / 60)
VisualizeOutputs(YTrap, [], parms.visOut, t_start, t_stop, 300, sprintf('%s_dt_%.0e',...
  parms.vis.vid_filename, timestep));
Trap.XTrap = XTrap;
Trap.YTrap = YTrap;
Trap.tTrap = [tTrap(1) tTrap(end)];
save(sprintf('%s_dt_%.0e.mat', outputFilename, timestep), 'Trap', 'TrapTime', '-v7.3')

%% Trapezoidal integration with adaptive delta t
% [XTrap, tTrap, YTrap] = TrapezoidalIntegrationAdaptive(eval_f,...
%   x_start, parms, eval_u, t_start, t_stop, [0.1 1],...
%   'MF', eval_y, VisualizeFlockFigNum, keepHist, vebosity);
