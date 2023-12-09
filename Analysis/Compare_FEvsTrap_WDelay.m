% Add path with functions
addpath(genpath('../matlab'))
outputFolder1 = '../Output/FEConvergencewAM-vf';
outputFolder2 = '../Output/MFTrapwAM-vf';
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

% Load file with data from FE
% filename1 = 'Murmuration_FEConvergence_Reference.mat'; % Original parms
filename1 = 'Murmuration_FEConvergence_p1_Reference.mat'; % Modified parms
[~, basefilename1] = fileparts(filename1);
load(fullfile(outputFolder1, filename1))
StructToVars(XFERef)
nMax = length(XFE);
% Load file with data from Trap
% filename2 = 'Murmuration_Trap_p1_1_dt_1e-01.mat'; % Original parms
filename2 = 'Murmuration_Trap_p1_1_dt_1e-01.mat'; % Modified parms
load(fullfile(outputFolder2, filename2))
[~, basefilename2] = fileparts(filename2);
StructToVars(Trap)
TrapTimestep = 0.1;
% Plot confidence vs dt
nFig = 103;
figure2(nFig), subplot(121), loglog(10 .^ -(2:nMax), refConf(2:nMax), 'k.', 'markersize', 20),
grid on, grid minor,
xlabel('$\Delta t$'), ylabel('Confidence')
clear *error* comErrorFE
for k = 1:nMax-1
  XerrorFE(k) = norm((XFE{k}(:) - XFE{end}(:)), inf);
  RerrorFE(k) = norm(YFE{k}(1, :) - YFE{end}(1, :), inf);
  UerrorFE(k) = norm(YFE{k}(4, :) - YFE{end}(4, :), inf);
  GerrorFE(k) = norm(YFE{k}(5, :) - YFE{end}(5, :), inf);
  comErrorFE(k) = norm(sqrt(sum(((YFE{k}(6:7, :) - YFE{end}(6:7, :))) .^ 2, 1)), inf);
end
% Trapezoidal error
XerrorTrap = norm((XTrap(:) - XFE{end}(:)), inf);
RerrorTrap = norm(YTrap(1, :) - YFE{end}(1, :), inf);
UerrorTrap = norm(YTrap(4, :) - YFE{end}(4, :), inf);
GerrorTrap = norm(YTrap(5, :) - YFE{end}(5, :), inf);
comErrorTrap = norm(sqrt(sum(((YTrap(6:7, :) - YFE{end}(6:7, :)) ).^ 2, 1)), inf);

figure(nFig+1), subplot(231), loglog(10 .^ -(1:nMax-1), XerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, XerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(XerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $x$'), axis padded
xticks([flip(10 .^ -(2:nMax)) TrapTimestep]);
legend('FE', 'Trap', 'Confidence', 'location', 'east', 'interpreter', 'latex')

subplot(232), loglog(10 .^ -(1:nMax-1), comErrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, comErrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(comErrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in COM'), axis padded
xticks([flip(10 .^ -(2:nMax)) TrapTimestep]);

subplot(233), loglog(10 .^ -(1:nMax-1), RerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, RerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(RerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $R$'), axis padded
xticks([flip(10 .^ -(2:nMax)) TrapTimestep]);

subplot(234), loglog(10 .^ -(1:nMax-1), UerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, UerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(UerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $U$'), axis padded
xticks([flip(10 .^ -(2:nMax)) TrapTimestep]);

subplot(235), loglog(10 .^ -(1:nMax-1), GerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, GerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(GerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $G$'), axis padded
xticks([flip(10 .^ -(2:nMax)) TrapTimestep]);

% FE Error in state vector
fprintf('dt = %1.0e\t', 10 .^ -(1:nMax-1)), fprintf('\nForward Euler Errors:\n')
fprintf('dX = %1.2e\t', XerrorFE), fprintf('\n')
% FE Error in outputs
fprintf('dR = %1.2e\t', RerrorFE), fprintf('\n')
fprintf('dU = %1.2e\t', UerrorFE), fprintf('\n')
fprintf('dG = %1.2e\t', GerrorFE), fprintf('\n')
fprintf('dCOM = %1.2e\t', comErrorFE), fprintf('\n\n')
% Trap Error in state vector
fprintf('Trapezoidal erros\n')
fprintf('dX = %1.2e\t', XerrorTrap), fprintf('\n')
% Trap Error in outputs
fprintf('dR = %1.2e\t', RerrorTrap), fprintf('\n')
fprintf('dU = %1.2e\t', UerrorTrap), fprintf('\n')
fprintf('dG = %1.2e\t', GerrorTrap), fprintf('\n')
fprintf('dCOM = %1.2e\t', comErrorTrap), fprintf('\n\n')

% Print times
fprintf('dt = %1.0e\t', 10 .^ -(1:nMax)), fprintf('\nForward Euler Times:\n')
fprintf('Time = %.2f\t', FEtime / 60), fprintf('\n')
fprintf('dt = %1.0e\t', TrapTimestep), fprintf('Trapezoidal time\n')
fprintf('Time = %.2f\t', TrapTime / 60), fprintf('\n')

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

for k = 1:nMax
%   VisualizeFlock(t{end}(1), XFE{k}(:, end), YFE{k}(:, end), vis, 1000 + k, [], true);
end


%% Compare outputs
% OPTIONS FOR VISUALIZATION OF THE OUTPUTS
visOut.linewidth = 1;              % Line width for plots
visOut.order_limsX = [-inf inf];   % X limits for group order
visOut.order_limsY = [0.6 1.05];   % Y limits for group order
visOut.speed_limsX = [-inf inf];   % X limits for group speed
visOut.speed_limsY = [0 1.4];      % Y limits for group speed
visOut.size_limsX = [-inf inf];    % X limits for group size
visOut.size_limsY = [2 12];      % Y limits for group size
visOut.com_limsX = [-5 40];       % X limits for group center of mass
visOut.com_limsY = [-5 40];       % Y limits for group center of mass
visOut.corrV_limsX = [2 16];
visOut.corrSp_limsY = [2 12];
visOut.showcorr = false;           % Whether to show correlation distances plots
visOut = InitializeVisualizeOutputs(visOut); % Set unset parameters to default values
% Color for the plots
colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 0 1];
% Filename to save plot
filename = false; fullfile(outputFolder1, sprintf('%s_All', basefilename1));
nFig = 105;
% Plot Trap outputs
visOutTrap = visOut;
visOutTrap.linecolor = [1 0 1];
VisualizeOutputs(YTrap, [], visOutTrap, 0, 50, nFig, []),
labels{1} = sprintf('Trap: $%s t = %.0e$', '\Delta', TrapTimestep);
for j = 1:4; subplot(2,2,j); hold on; end

for k = 1:nMax
  % Current Delta t
  visOut.linecolor = colors(k, :);
  VisualizeOutputs(YFE{k}, corrR{k}, visOut, 0, t{1}(end), nFig, []),
  for j = 1:4; subplot(2,2,j); hold on; end
  labels{k+1} = sprintf('FE: $%s t = %.0e$', '\Delta', 10^(-k));
end
for j = 1:4; subplot(2,2,j); hold off; end
subplot(221), legend(labels{:}, 'interpreter', 'latex', 'location', 'southeast')
if filename
  if ~isempty(filename)
    nFig = figure(nFig);
    saveas(nFig, sprintf('%s.png', filename))
    saveas(nFig, sprintf('%s.fig', filename))
  end
end
if 0
%% Make individual figures
visOut.showcorr = true; % Whether to show correlation distances plots
% Filename to save plot
nFig = 10;
visOut.linewidth = 2;              % Line width for plots
for k = 1:4
  % Current Delta t
  filename = fullfile(outputFolder1, sprintf('%s_dt_%.0e', basefilename1, 10^(-k)));
  visOut.linecolor = [0 0 0];
  VisualizeOutputs(YFE{k}, corrR{k}, visOut, 0, t{1}(end), nFig + k - 1, []),
  if filename
    if ~isempty(filename)
      hFig = figure(nFig+ k - 1);
      saveas(hFig, sprintf('%s.png', filename))
      saveas(hFig, sprintf('%s.fig', filename))
    end
  end
end
end