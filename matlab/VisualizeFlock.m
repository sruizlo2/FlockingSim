function VisualizeFlock(t, X, f, hFig)

figure(hFig), quiver(X(1:end / 2), X(end / 2 + 1: end),...
  f(1:end / 2), f(end / 2 + 1: end), 'off', 'Color', 'k')
  title(sprintf('Flock at time %.1f', t)),
  axis square, ylim([-50 50]), xlim([-50 50])
  ylabel('Y [m]'), xlabel('X [m]'), grid on, grid minor, drawnow