% Add path with functions
addpath(genpath('../matlab'))
outputFolder1 = '../Output/FEConvergenceNoAM';
outputFolder2 = '../Output/MFTrapNoAM';
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

% Load file with data from FE
% filename1 = 'Murmuration_FEConvergence2_Reference.mat'; % Original parms
filename1 = 'Murmuration_FEConvergence3_Reference.mat'; % Modified parms
[~, basefilename1] = fileparts(filename1);
load(fullfile(outputFolder1, filename1))
StructToVars(XFERef)
nMax = length(XFE);
% Load file with data from Trap
% filename2 = 'Murmuration_Trap_p1_1_dt_1e-01.mat'; % Original parms
filename2 = 'Murmuration_Trap_p2_1_dt_1e-01.mat'; % Modified parms
load(fullfile(outputFolder2, filename2))
[~, basefilename2] = fileparts(filename2);
StructToVars(Trap)
TrapTimestep = 0.1;
% Plot confidence vs dt
nFig = 3;
figure2(nFig), subplot(111), loglog(10 .^ -(2:nMax), refConf(2:nMax), 'k.', 'markersize', 20),
grid on, grid minor,
xlabel('$\Delta t$'), ylabel('Confidence')
clear *errorFE
for k = 1:nMax-1
  XerrorFE(k) = norm(XFE{k} - XFE{end}, inf);
  RerrorFE(k) = norm(YFE{k}(1, end) - YFE{end}(1, end), inf);
  UerrorFE(k) = norm(YFE{k}(4, end) - YFE{end}(4, end), inf);
  GerrorFE(k) = norm(YFE{k}(5, end) - YFE{end}(5, end), inf);
end
% Trapezoidal error
XerrorTrap = norm(XTrap(:, end) - XFE{end}, inf);
RerrorTrap = norm(YTrap(1, end) - YFE{end}(1, end), inf);
UerrorTrap = norm(YTrap(4, end) - YFE{end}(4, end), inf);
GerrorTrap = norm(YTrap(5, end) - YFE{end}(5, end), inf);

figure2(nFig+1), subplot(221), loglog(10 .^ -(1:nMax-1), XerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, XerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(refConf(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $X$')
subplot(222), loglog(10 .^ -(1:nMax-1), RerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, RerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(RerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $R$')
subplot(223), loglog(10 .^ -(1:nMax-1), UerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, UerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(UerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $U$')
subplot(224), loglog(10 .^ -(1:nMax-1), GerrorFE, 'k.', 'markersize', 20),
hold on, loglog(TrapTimestep, GerrorTrap, 'r.', 'markersize', 20), hold off
grid on, grid minor, yline(GerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $G$')
% FE Error in state vector
fprintf('dt = %1.0e\t', 10 .^ -(1:nMax-1)), fprintf('\n Forward Euler Errors:\n')
fprintf('dX = %1.3e\t', XerrorFE), fprintf('\n')
% FE Error in outputs
fprintf('dR = %1.3e\t', RerrorFE), fprintf('\n')
fprintf('dU = %1.3e\t', UerrorFE), fprintf('\n')
fprintf('dG = %1.3e\t', GerrorFE), fprintf('\n')
% Trap Error in state vector
fprintf('Trapezoidal erros\n')
fprintf('dX = %1.3e\t', XerrorTrap), fprintf('\n')
% Trap Error in outputs
fprintf('dR = %1.3e\t', RerrorTrap), fprintf('\n')
fprintf('dU = %1.3e\t', UerrorTrap), fprintf('\n')
fprintf('dG = %1.3e\t', GerrorTrap), fprintf('\n')

%% Compare outputs
% OPTIONS FOR VISUALIZATION OF THE OUTPUTS
visOut.linewidth = 2;              % Line width for plots
visOut.order_limsX = [-inf inf];   % X limits for group order
visOut.order_limsY = [0.6 1.05];   % Y limits for group order
visOut.speed_limsX = [-inf inf];   % X limits for group speed
visOut.speed_limsY = [0 1.1];      % Y limits for group speed
visOut.size_limsX = [-inf inf];    % X limits for group size
visOut.size_limsY = [2 8];      % Y limits for group size
visOut.com_limsX = [-5 30];       % X limits for group center of mass
visOut.com_limsY = [-5 30];       % Y limits for group center of mass
visOut.showcorr = false;           % Whether to show correlation distances plots
visOut = InitializeVisualizeOutputs(visOut); % Set unset parameters to default values
% Color for the plots
colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
% Filename to save plot
filename = false; fullfile(outputFolder1, sprintf('%s_All', basefilename1));
nFig = 5;
% Plot Trap outputs
visOutTrap = visOut;
visOutTrap.linecolor = [1 0 1];
VisualizeOutputs(YTrap, [], visOutTrap, 0, 50, nFig, []),
labels{1} = sprintf('Trap: $%s t = %.0e$', '\Delta', TrapTimestep);
for j = 1:4; subplot(2,2,j); hold on; end

% Plot FE outputs
for k = 1:nMax
  % Current Delta t
  visOut.linecolor = colors(k, :);
  VisualizeOutputs(YFE{k}, [], visOut, 0, t{1}, nFig, []),
  labels{k+1} = sprintf('FE: $%s t = %.0e$', '\Delta', 10^(-k));
end

for k = 1:4; subplot(2,2,k); hold off; end
subplot(221), legend(labels{:}, 'interpreter', 'latex', 'location', 'southeast')
if filename
  if ~isempty(filename)
    hFig = figure(nFig);
    saveas(hFig, sprintf('%s.png', filename))
    saveas(hFig, sprintf('%s.fig', filename))
  end
end

%% Make individual figures
% Save FE plots
nFig = 10;
visOut.linewidth = 2; % Line width for plots
for k = 1:4
  % Current Delta t
  filename = fullfile(outputFolder1, sprintf('%s_dt_%.0e', basefilename1, 10^(-k)));
  visOut.linecolor = [0 0 0];
  VisualizeOutputs(YFE{k}, corrR{k}, visOut, 0, t{1}, nFig + k - 1, []),
  if filename
    if ~isempty(filename)
      hFig = figure(nFig+ k - 1);
      saveas(hFig, sprintf('%s.png', filename))
      saveas(hFig, sprintf('%s.fig', filename))
    end
  end
end
if 0
% Save Trap plot
filename = fullfile(outputFolder2, sprintf('%s_dt_%.0e', basefilename2, 10^(-k)));
visOut.linecolor = [0 0 0];
VisualizeOutputs(YTrap, corrR, visOut, 0, tTrap(2), nFig + 4, []),
if filename
  if ~isempty(filename)
    hFig = figure(nFig+ k - 1);
    saveas(hFig, sprintf('%s.png', filename))
    saveas(hFig, sprintf('%s.fig', filename))
  end
end
end