close all, clear all, clc
% Add path with functions
addpath(genpath('../../matlab'))
outputFolder = '../../Output/Demos';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 18)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')
set(0,'defaultfigurecolor',[1 1 1])

%%
TrapSol = load(fullfile(outputFolder, 'Murmuration_Trap_Demo2Full_dt_1e-01.mat'));
X = TrapSol.Trap.XTrap;
Y = TrapSol.Trap.YTrap;

%% Visualize final flock distribution
vis = struct();
vis.fov = 25;             % Maximum FOV in X and Y
vis.markersize = 5;       % Size of the dots that represent birds
vis.linewidth = 0.15;     % Linewidth of the bird velocity arror
vis.plotFPS     = [];     % Number of visualization (frames) per second (default is 1 fps)
vis.background_color = [0.7 0.9 0.95]; % Color of plot background
vis.flock_color = [1 0.0784 0.1373];   % Color or visualization of flock outputs
vis.birds_color = [0 0 0];             % Color or birds arrors
vis = InitializeVisualizeFlock(vis); % Set unset parameters to default values

% tic
nFig = 2;
t = linspace(0, 100, 100 / 0.1 + 1);
kstart = 0 / 0.1 + 1;
kend = 100 / 0.1 + 1;
VisualizeFlock(t(1), X(:, kstart), Y(:, kstart), vis, nFig, [], true);
for k = kstart:10:kend
  if mod(k-1, 1) == 0
    VisualizeFlock(t(k), X(:, k), Y(:, k), vis, nFig, [], false);
  end
end
% toc
