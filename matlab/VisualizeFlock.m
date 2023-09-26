function VisualizeFlock(t, X, f, hFig)

figure(hFig), quiver(X(1:end / 3), X(end / 3 + 1: 2 * end / 3),...
  f(1:end / 3), f(end / 3 + 1: 2 * end / 3), 'off', 'Color', 'k')
  title(sprintf('Flock at time %.1f', t)),
  axis square, ylim([-50 50]), xlim([-50 50])
  ylabel('Y [m]'), xlabel('X [m]'), grid on, grid minor, drawnow