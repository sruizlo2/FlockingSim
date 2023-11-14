% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output';
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')
LATEX_DEF = {'Interpreter', 'latex'};
LINE_WIDTH = 1.5;

%% PARAMETERS
% Normalization constants
ls = 1;       % Length scale
ts = 0.1;     % Time scale
vs = ls / ts; % Speed scale
test_indx = 2;
useGPU = true;

switch test_indx
  case 1
    % Parameters
    Ca = 5;         % Effective distance of the attraction
    Cr = 5;         % Strength of the short-range repulsion
    lr = 0.25;      % Effective distance of the repulsion
    v0 = 1;         % Terminal speed
    alpha_ = 0.2;   % Strenght of drag force
    Kv = 0.1;       % Interaction strength of velocity matching
    Ka = 0.12;      % Interaction strength of acceleration matching
    kappa = 100;    % Maximum time delay for acceleration matching
    r0 = 10;        % Minimum distance to compuate variance in local order computation
    c0 = 10;        % Scale factor for variance
    lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization

    % Number of birds
    n_birds = 4;
    % Initial past accelerations matching
    am0 = 0;
    % Initial position and orientations
    x_start = [-1, -1,  1,  1,... x
      -1,  1, -1,  1,... y
      v0, v0,  -v0,  -v0,... v_x
      v0,  -v0, v0,  -v0];... v_y
      a_start = am0 * ones(2 * n_birds, kappa + 1);
    % Options for plotting
    fov = 7.5;
    markersize = 20;
  case 2
    % Parameters
    Ca = 1.5e-7;    % Effective distance of the attraction
    Cr = 1.5;       % Strength of the short-range repulsion
    lr = 0.05;      % Effective distance of the repulsion
    v0 = 1;         % Terminal speed
    alpha_ = 0.2;   % Strenght of drag force
    Kv = 0.1;       % Interaction strength of velocity matching
    Ka = 0.12;      % Interaction strength of acceleration matching
    kappa = 800;    % Maximum time delay for acceleration matching
    r0 = 0.6;       % Minimum distance to compuate variance in local order computation
    c0 = 10;        % Scale factor for variance
    lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
    % Initial past accelerations matching
    am0 = 0;

    % Number of birds
    n_birds = 1e3;
    % Initial position and orientations. For positions, let's place birds
    % randombly within a circle. For orientations, let's fix a global
    % orientation and add random orientation for each bird
    % Initialize random positions within a circle
    cirle_angle = 2 * pi * rand(n_birds, 1);
    circle_radius = 10 * sqrt(rand(n_birds, 1));
    % Initial positions and velocities
    x_start = cat(1, circle_radius .* cos(cirle_angle),...
      circle_radius .* sin(cirle_angle),...
      vs * v0 * (0.0 + 0.5 * (rand(2 * n_birds, 1) - 0.5)));
    % Initial accelerations, constant for all birds and time steps
    a_start = am0 * ones(2 * n_birds, kappa + 1);
    % Options for plotting
    fov = 20;
    markersize = 3;
    linewidth = 0.25;
    plotStep = 4;
end
if useGPU
  x_start = gpuArray(x_start);
  ls = gpuArray(ls);
  ts = gpuArray(ts);
  vs = gpuArray(vs);
end
% Name of function to evaluate f()
eval_f_delay = 'eval_f_CSModelWDelay';
eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Time step
timestep = 1;
% Number of time points, initial and final time point
t_points = 1000;
t_start = 0;
t_stop = timestep * t_points;

filenamePrefix = 'StarlingMurmuration';
filenameSufix = 'wAM2';
savefiles = false;
% Video file name
vid_filename = []; fullfile(outputFolder, sprintf('%s_%s', filenamePrefix, filenameSufix));
VisualizeFlockFigNum = 2; % False for not plotting flock
% Struct with parameters
parms = struct('n_birds', n_birds, 'Ca', Ca, 'Cr', Cr, 'lr', lr,...
  'v0', v0, 'alpha_', alpha_, 'Kv', Kv, 'Ka', Ka, 'kappa', kappa,...
  'r0', r0, 'c0', c0, 'lo_method', lo_method,...
  'fov', fov, 'markersize', markersize, 'linewidth', linewidth, 'a', a_start, ...
  'ls', ls, 'ts', ts, 'vs', vs, 'plotStep', plotStep,...
  'vid_filename', vid_filename); % Ploting options
% parms = NormalizeParameters(parms, ls, ts, 'fw');
% Evaluate functions with delayed Forward Euler method
[X, t, Y] = ForwardEulerWDelay(eval_f_delay, x_start, parms, eval_u, t_start,...
  t_stop, timestep, VisualizeFlockFigNum);
if useGPU
  t = gather(t);
  X = gather(X);
  Y = gather(Y);
end
if savefiles
  save(fullfile(outputFolder, sprintf('%s_%s.mat', filenamePrefix, filenameSufix)),...
    'X', 't', 'Y', 'parms', '-v7.3');
end

%% Load data
if savefiles
  data = load(fullfile(outputFolder, sprintf('%s_%s.mat', filenamePrefix, filenameSufix)));
else
  data.Y = Y;
  data.t = t;
  data.parms = parms;
end
% Group ourder
groupOrder = data.Y(1, :);
% Group velocity
groupVelocity = [data.Y(2, :) data.Y(3, :)];
% Group speed
groupSpeed = data.Y(4, :);
% Group size
groupSize = data.Y(5, :);
% Center of mass
com = [data.Y(end-1, :); data.Y(end, :)];

%% Plot outputs
hFig = figure(4); subplot(221), plot(data.t * data.parms.ts, groupOrder, 'k', 'linewidth', 2),
title('Group order'), xlabel('time [s]'), ylabel('$R$'), grid on, grid minor
ylim([-0.1 1.1]), xlim([-10 inf])

subplot(222), plot(data.t * data.parms.ts, groupSpeed, 'k', 'linewidth', 2),
title('Group speed'), xlabel('time [s]'), ylabel('$U$ [m/s]'), grid on, grid minor
ylim([-0.1 1.6]), xlim([-10 inf])

subplot(223), plot(data.t * data.parms.ts, groupSize, 'k', 'linewidth', 2),
title('Group size'), xlabel('time [s]'), ylabel('$G$ [m]'), grid on, grid minor
ylim([0 14]), xlim([-10 inf])

subplot(224), plot(com(1, :), com(2, :), 'k.', 'markersize', 4),
title('Flock trayectory'), xlabel('$x$ [m]'), ylabel('$y$ [m]'), grid on, grid minor

if savefiles
  saveas(hFig, fullfile(outputFolder, sprintf('%sOutputs_%s.png', filenamePrefix, filenameSufix)))
end