function VisualizeOutputs(Y, C, parms, t_start, t_stop, figN, filename)
StructToVars(parms)
% Group ourder
groupOrder = Y(1, :);
% Group velocity
% groupVelocity = [Y(2, :) Y(3, :)];
% Group speed
groupSpeed = Y(4, :);
% Group size
groupSize = Y(5, :);
% Center of mass
com = [Y(6, :); Y(7, :)];

% Time vect
t = linspace(t_start, t_stop, size(Y, 2));
% dt = t(2) - t(1);
nCorStart = min(100, size(C, 2));
nCorStep = 10;
nCorTimeVect = nCorStart:nCorStep:size(C, 2);
if showcorr
  subp = [2, 3];
  subpord = [1 2 4 5 3 6];
  % Correlation distances
  corrR = C(1, nCorTimeVect);
  corrRsp = C(2, nCorTimeVect);
else
  subp = [2, 2];
  subpord = [1 2 3 4];
end

% Plot outputs
hFig = figure(figN);
hFig.WindowState = 'maximized';
pause(0.5)
subplot(subp(1), subp(2), subpord(1)), plot(t, groupOrder,...
  'color', linecolor, 'linewidth', linewidth, 'linestyle', linestyle,...
  'marker', linemarker, 'markersize', linemarkersize),
title('Group order'), xlabel('time [s]'), ylabel('$R$'), grid on, grid minor
xlim(order_limsX), ylim(order_limsY), 

subplot(subp(1), subp(2), subpord(2)), plot(t, groupSpeed,...
  'color', linecolor, 'linewidth', linewidth, 'linestyle', linestyle,...
  'marker', linemarker, 'markersize', linemarkersize),
title('Group speed'), xlabel('time [s]'), ylabel('$U$ [m/s]'), grid on, grid minor
xlim(speed_limsX), ylim(speed_limsY), 

subplot(subp(1), subp(2), subpord(3)), plot(t, groupSize,...
  'color', linecolor, 'linewidth', linewidth, 'linestyle', linestyle,...
  'marker', linemarker, 'markersize', linemarkersize),
title('Group size'), xlabel('time [s]'), ylabel('$G$ [m]'), grid on, grid minor
xlim(size_limsX), ylim(size_limsY), 

subplot(subp(1), subp(2), subpord(4)), plot(com(1, :), com(2, :),...
  'color', linecolor, 'linewidth', linewidth, 'linestyle', linestyle,...
  'marker', linemarker, 'markersize', linemarkersize),
title('Flock trayectory'), xlabel('$x$ [m]'), ylabel('$y$ [m]'), grid on, grid minor
xlim(com_limsX), ylim(com_limsY), 

if showcorr
  %% Downsample groupsize to match size of correlation distances
  groupSizeCor = groupSize(nCorTimeVect);
  groupSizeCorLineal = linspace(min(groupSizeCor), max(groupSizeCor), 10);

  subplot(subp(1), subp(2), subpord(5)), plot(groupSizeCor, corrR, 'k.', 'markersize', corr_markersize)
  title('Correlation distance'), xlabel('$G$ [m]'), ylabel('$\xi$ [m]'), grid on, grid minor
  ylim(corrV_limsX), xlim(size_limsY), hold on
  % Linear fit of group size and velocity correlation distance
  corrRFit = polyfit(groupSizeCor, corrR, 1);
  plt1 = plot(groupSizeCorLineal, corrRFit(2) + corrRFit(1) * groupSizeCorLineal,...
    'r', 'linewidth', 2 * linewidth); hold off
  % Pearson-correlation test
  [RcoefV, pvalV] = corrcoef(groupSizeCor, corrR);
  % R-squared and significant (p-value)
  RcoefV = RcoefV(1, size(RcoefV , 1));
  pvalV = pvalV(1, size(pvalV , 1));
  legend(plt1, sprintf('$R = %.2f$, $p$ = %.0e', RcoefV, pvalV),...
    'interpreter', 'latex', 'location', 'southeast')

  subplot(subp(1), subp(2), subpord(6)), plot(groupSizeCor, corrRsp, 'k.', 'markersize', corr_markersize)
  title('Correlation distance'), xlabel('$G$ [m]'), ylabel('$\xi_{sp}$ [m]'), grid on, grid minor
  ylim(corrSp_limsY), xlim(size_limsY), hold on
  % Linear fit of group size and speed correlation distance
  corrRspFit = polyfit(groupSizeCor, corrRsp, 1);
  plt2 = plot(groupSizeCorLineal, corrRspFit(2) + corrRspFit(1) * groupSizeCorLineal,...
    'r', 'linewidth', 3); hold off
  % Pearson-correlation test
  [RcoefSp, pvalSp] = corrcoef(groupSizeCor, corrRsp);
  % R-squared and significant (p-value)
  RcoefSp = RcoefSp(1, size(RcoefSp , 1));
  pvalSp = pvalSp(1, size(pvalSp , 1));
  legend(plt2, sprintf('$R = %.2f$, $p$ = %.0e', RcoefSp, pvalSp),...
    'interpreter', 'latex', 'location', 'southeast')
end

drawnow

if filename
  if ~isempty(filename)
    saveas(hFig, sprintf('%s.png', filename))
    saveas(hFig, sprintf('%s.fig', filename))
  end
end