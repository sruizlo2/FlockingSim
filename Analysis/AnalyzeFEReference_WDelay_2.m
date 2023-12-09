% Add path with functions
addpath(genpath('../matlab'))
outputFolder = '../Output/FEConvergencewAM';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')

% Load file with data
filename = 'Murmuration_FEConvergence_Reference.mat'; % Original parms
% filename = 'Murmuration_FEConvergence2_Reference.mat'; % Modified parms
[~, basefilename] = fileparts(filename);
load(fullfile(outputFolder, filename))
StructToVars(XFERef)
nMax = length(XFE);
% Plot confidence vs dt
nFig = 1;
figure2(nFig), subplot(121), loglog(10 .^ -(2:nMax), refConf(2:nMax), 'k.', 'markersize', 20),
grid on, grid minor,
xlabel('$\Delta t$'), ylabel('Confidence')
clear *errorFE
for k = 1:nMax-1
  XerrorFE(k) = norm(XFE{k} - XFE{end}, inf);
  RerrorFE(k) = norm(YFE{k}(1, end) - YFE{end}(1, end), inf);
  UerrorFE(k) = norm(YFE{k}(4, end) - YFE{end}(4, end), inf);
  GerrorFE(k) = norm(YFE{k}(5, end) - YFE{end}(5, end), inf);
end
figure2(nFig), subplot(221), loglog(10 .^ -(1:nMax-1), XerrorFE, 'k.', 'markersize', 20),
grid on, grid minor, yline(refConf(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $X$')
figure2(nFig), subplot(222), loglog(10 .^ -(1:nMax-1), RerrorFE, 'k.', 'markersize', 20),
grid on, grid minor, yline(RerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $R$')
figure2(nFig), subplot(223), loglog(10 .^ -(1:nMax-1), UerrorFE, 'k.', 'markersize', 20),
grid on, grid minor, yline(UerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $U$')
figure2(nFig), subplot(224), loglog(10 .^ -(1:nMax-1), GerrorFE, 'k.', 'markersize', 20),
grid on, grid minor, yline(GerrorFE(end), 'r--', 'LineWidth', 2)
xlabel('$\Delta t$'), ylabel('Error in $G$')
% Error in state vector
fprintf('dt = %1.0e\t', 10 .^ -(1:nMax-1)), fprintf('\n')
fprintf('dX = %1.3e\t', XerrorFE), fprintf('\n')
% Error in outputs
fprintf('dR = %1.3e\t', RerrorFE), fprintf('\n')
fprintf('dU = %1.3e\t', UerrorFE), fprintf('\n')
fprintf('dG = %1.3e\t', GerrorFE), fprintf('\n')

%% Compare outputs
% OPTIONS FOR VISUALIZATION OF THE OUTPUTS
visOut.linewidth = 1;              % Line width for plots
visOut.order_limsX = [-inf inf];   % X limits for group order
visOut.order_limsY = [0.6 1.05];   % Y limits for group order
visOut.speed_limsX = [-inf inf];   % X limits for group speed
visOut.speed_limsY = [0 1.4];      % Y limits for group speed
visOut.size_limsX = [-inf inf];    % X limits for group size
visOut.size_limsY = [2 14];      % Y limits for group size
visOut.com_limsX = [-5 40];       % X limits for group center of mass
visOut.com_limsY = [-5 40];       % Y limits for group center of mass
visOut.showcorr = false;           % Whether to show correlation distances plots
visOut = InitializeVisualizeOutputs(visOut); % Set unset parameters to default values
% Color for the plots
colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
% Filename to save plot
filename = false; fullfile(outputFolder, sprintf('%s_All', basefilename));
nFig = 2;
for k = 1:nMax
  % Current Delta t
  visOut.linecolor = colors(k, :);
  VisualizeOutputs(YFE{k}, corrR{k}, visOut, 0, t{1}, nFig, []),
  for j = 1:4; subplot(2,2,j); hold on; end
  labels{k} = sprintf('$%s t = %.0e$', '\Delta', 10^(-k));
end
for j = 1:4 subplot(2,2,j); hold off; end
subplot(221), legend(labels{:}, 'interpreter', 'latex', 'location', 'southeast')
if filename
  if ~isempty(filename)
    nFig = figure(nFig);
    saveas(nFig, sprintf('%s.png', filename))
    saveas(nFig, sprintf('%s.fig', filename))
  end
end

%% Make individual figures
visOut.showcorr = true; % Whether to show correlation distances plots
% Filename to save plot
nFig = 10;
visOut.linewidth = 2;              % Line width for plots
for k = 1:4
  % Current Delta t
  filename = fullfile(outputFolder, sprintf('%s_dt_%.0e', basefilename, 10^(-k)));
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
