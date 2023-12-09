% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output/FEConvergence';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

% Load file with data 
filename = 'Murmuration_FEConvergence3_Reference3.mat';
% filename = 'Murmuration_FEConvergence2_Reference2.mat';
% filename = 'Murmuration_FEConvergence2_Reference.mat';
load(fullfile(outputFolder, filename))
StructToVars(XFERef)
nMax = length(XFE);
% Plot confidence vs dt
figure2(1), subplot(121), loglog(10 .^ -(2:nMax), refConf(2:nMax), 'k.', 'markersize', 20),
grid on, grid minor,
xlabel('$\Delta t$'), ylabel('Confidence')
clear errorFE
for k = 1:nMax-1
  errorFE(k) = norm(XFE{k} - XFE{end}, inf);
end
figure2(1), subplot(122), loglog(10 .^ -(1:nMax-1), errorFE, 'k.', 'markersize', 20),
grid on, grid minor,
yline(refConf(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error')

% Compare outputs
% OPTIONS FOR VISUALIZATION OF THE OUTPUTS
visOut.linewidth = 1;              % Line width for plots
visOut.order_limsX = [-inf inf];   % X limits for group order
% visOut.order_limsY = [0.6 1.05];   % Y limits for group order
visOut.speed_limsX = [-inf inf];   % X limits for group speed
% visOut.speed_limsY = [0 1.1];      % Y limits for group speed
visOut.size_limsX = [-inf inf];    % X limits for group size
% visOut.size_limsY = [2 10.5];      % Y limits for group size
% visOut.com_limsX = [-10 80];       % X limits for group center of mass
% visOut.com_limsY = [-10 80];       % Y limits for group center of mass
visOut.showcorr = false;           % Whether to show correlation distances plots
visOut = InitializeVisualizeOutputs(visOut); % Set unset parameters to default values

colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
for k = 1:nMax
  % Current Delta t
  visOut.linecolor = colors(k, :);
  VisualizeOutputs(YFE{k}, [], visOut, 0, 50, 2, []),
  for j = 1:4; subplot(2,2,j); hold on; end
  labels{k} = sprintf('$%s t = %.0e$', '\Delta', 10^(-k));
end
for k = 1:4; subplot(2,2,k); hold off; end
subplot(221), legend(labels{:}, 'interpreter', 'latex', 'location', 'southeast')

