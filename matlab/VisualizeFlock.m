function VisualizeFlock(t, X, f, hFig)
% Speed, use to normalize vectors length in the plot
speed = sqrt(f(1) .^ 2 + f(end / 3 + 1) .^ 2);
com = [mean(X(1:end / 3)), mean(X(end / 3 + 1: 2 * end / 3))];
% Plot velocity vectors at each bird location
figure2(hFig), quiver(X(1:end / 3), X(end / 3 + 1: 2 * end / 3),...
  f(1:end / 3) / speed, f(end / 3 + 1: 2 * end / 3) / speed,...
  'AutoScale', 'off', 'Color', 'k')
  title(sprintf('Flock at time %.1f', t)),
%    xlim([-50 50] + sign(com(1)) * floor(abs(com(1)) / 25) * 25),
%    ylim([-50 50] + sign(com(2)) * floor(abs(com(2)) / 25) * 25),
   xlim([-50 50] + com(1)),
   ylim([-50 50] + com(2)),
  axis square, ylabel('Y [m]'), xlabel('X [m]'), grid on, grid minor, drawnow