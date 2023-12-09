clear all, clc
% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output/Demos';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 16)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

%%
Trap1 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo3_dt_1e-01.mat'));
Y1 = Trap1.Trap.YTrap;
Trap2 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo4_dt_1e-01.mat'));
Y2 = Trap2.Trap.YTrap;
Trap3 = load(fullfile(outputFolder, 'Murmuration_Trap_Demo5_dt_1e-01.mat'));
Y3 = Trap3.Trap.YTrap;
t = linspace(0, 100, 100 / 0.1 + 1);
figure(3), plot(t, Y1(1, :), 'k', 'linewidth', 2), hold on
plot(t, Y2(1, :), 'r', 'linewidth', 2),
plot(t, Y3(1, :), 'g', 'linewidth', 2), hold off
title('Group order'), xlabel('time [s]'), ylabel('$R$'), grid on, grid minor
legend('$K_a = 0.12,\ \kappa = 80$ (Baseline)', ...
  '$K_a = 0.36,\ \kappa = 80$ (Stronger coupling)', ...
  '$K_a = 0.12,\ \kappa = 16$ (Faster reponse)',...
  'interpreter', 'latex', 'location', 'southeast')
ylim([0.8 1])