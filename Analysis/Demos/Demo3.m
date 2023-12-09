clear all, clc
% Add path with functions
addpath(genpath('../../matlab'))
outputFolder = '../../Output/Demos';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 16)
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
vis.fov = 30;             % Maximum FOV in X and Y
vis.markersize = 5;       % Size of the dots that represent birds
vis.linewidth = 0.15;     % Linewidth of the bird velocity arror
vis.plotFPS     = [];     % Number of visualization (frames) per second (default is 1 fps)
vis.background_color = [0.7 0.9 0.95]; % Color of plot background
vis.flock_color = [1 0.0784 0.1373];   % Color or visualization of flock outputs
vis.birds_color = [0 0 0];             % Color or birds arrors
vis = InitializeVisualizeFlock(vis); % Set unset parameters to default values
vis1 = vis;
vis1.subtitlename = 'Baseline';
vis2 = vis;
vis2.subtitlename = 'Stronger coupling';
vis3 = vis;
vis3.subtitlename = 'Faster reponse';

nFig = 4;
figure(nFig), subplot(2,1,2), plot(nan, nan), hold on
hFig = figure(nFig);
hFig.WindowState = 'maximized';
set(gcf,'color','w');
pause(0.5)

frames = [];

t = linspace(0, 100, 100 / 0.1 + 1);
kstart = 15 / 0.1 + 1;
kend = 75 / 0.1 + 1;
for k = kstart:kend
  if mod(k-1, 10) == 0
    subplot(2,3,1),
    VisualizeFlock(t(k), X1(:, k), Y1(:, k), vis1, nFig, [], false);
    subplot(2,3,2)
    VisualizeFlock(t(k), X2(:, k), Y2(:, k), vis2, nFig, [], false);
    subplot(2,3,3)
    VisualizeFlock(t(k), X3(:, k), Y3(:, k), vis3, nFig, [], false);
  end
  subplot(2,1,2),
  plot(t(k), Y1(1, k), 'k.', 'MarkerSize', 10),
  plot(t(k), Y2(1, k), 'r.', 'MarkerSize', 10),
  plot(t(k), Y3(1, k), 'g.', 'MarkerSize', 10),
  ylim([0.8 1]), xlim([t(kstart) t(kend)])
  title('Group order'), xlabel('time [s]'), ylabel('$R$'), grid on, grid minor
%   if mod(k-1, 10) == 0
%     frames = cat(1, frames, getframe(gcf));
%   end
end
subplot(2,1,2), hold off

% WriteFlockVisualization(frames, 10, fullfile(outputFolder, 'Demo3_Vary_Dynamics.avi'))
