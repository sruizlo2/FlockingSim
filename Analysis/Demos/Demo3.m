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
Trap1 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo3_dt_1e-01.mat'));
X1 = Trap1.Trap.XTrap;
Y1 = Trap1.Trap.YTrap;

Trap2 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo4_dt_1e-01.mat'));
X2 = Trap2.Trap.XTrap;
Y2 = Trap2.Trap.YTrap;

Trap3 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo5_dt_1e-01.mat'));
X3 = Trap3.Trap.XTrap;
Y3 = Trap3.Trap.YTrap;

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
vis.axesoff = true;
vis.drawnowOn = false;
vis.legendOn = false;
vis1 = vis;
color1 = [0 0 0];
color2 = [255 204 0] / 255;
color3 = [85 212 0] / 255;
vis1.titlename = 'Baseline';
vis1.birds_color = color1;
vis2 = vis;
vis2.titlename = 'Larger $K_a$ (Stronger coupling)';
vis2.birds_color = color2;
vis3 = vis;
vis3.titlename = 'Smaller $\kappa$ (Faster reponse)';
vis3.birds_color = color3;
nFig = 4;
hFig = figure(nFig);
hFig.WindowState = 'maximized';

visnan1 = vis1;
visnan1.legendOn = true;
visnan1.titlename = '';
visnan1.background_color = [1 1 1]; % Color of plot background
visnan2 = vis2;
visnan2.legendOn = true;
visnan2.titlename = '';
visnan2.background_color = [1 1 1]; % Color of plot background
visnan3 = vis3;
visnan3.legendOn = true;
visnan3.titlename = '';
visnan3.background_color = [1 1 1]; % Color of plot background

set(gcf,'color','w');

figure(nFig), subplot(6,3, [13 18]), plot(nan, nan), hold on
figure(nFig), subplot(12,9, [57 64]), 
VisualizeFlock(1, nan, [nan 0 0 1 nan 1 1], visnan1, nFig, [], false);
hold off, axis off
figure(nFig), subplot(12,9, [60 68]), 
VisualizeFlock(1, nan, [nan 0 0 1 nan 1 1], visnan2, nFig, [], false);
hold off, axis off
figure(nFig), subplot(12,9, [62 72]), 
VisualizeFlock(1, nan, [nan 0 0 1 nan 1 1], visnan3, nFig, [], false);
hold off, axis off

frames = [];
tic
t = linspace(0, 100, 100 / 0.1 + 1);
kstart = 20 / 0.1 + 1;
kend = 100 / 0.1 + 1;
for k = kstart:5:kend
  if mod(k-1, 1) == 0
    subplot(4,3, [1 4]),
    VisualizeFlock(t(k), X1(:, k), Y1(:, k), vis1, nFig, [], false);
    subplot(4,3, [2 5])
    VisualizeFlock(t(k), X2(:, k), Y2(:, k), vis2, nFig, [], false);
    subplot(4,3, [3 6])
    VisualizeFlock(t(k), X3(:, k), Y3(:, k), vis3, nFig, [], false);
  end
  subplot(6,3, [13 18]),
  plt1 = plot(t(k), Y1(1, k), '.', 'color', color1, 'MarkerSize', 10);
  plt2 = plot(t(k), Y2(1, k), '.', 'color', color2, 'MarkerSize', 10);
  plt3 = plot(t(k), Y3(1, k), '.', 'color', color3, 'MarkerSize', 10);
  ylim([0.65 1]), xlim([t(kstart) t(kend)])
  %title('Group order'),
  xlabel('time [s]'), ylabel('Group order $R$'), grid on,
  legend([plt1, plt2, plt3], '$K_a = 0.12,\ \kappa = 80$ (Baseline)', ...
    '$K_a = 0.36,\ \kappa = 80$ (Stronger coupling)', ...
    '$K_a = 0.12,\ \kappa = 16$ (Faster response)',...
    'interpreter', 'latex', 'location', 'southwest')
%   if mod(k-1, 10) == 0
%     frames = cat(1, frames, getframe(gcf));
%   end
drawnow
end
subplot(6,3, [13 18]), hold off
toc
% WriteFlockVisualization(frames, 3, fullfile(outputFolder, 'Demo3_Vary_Dynamics.avi'))
