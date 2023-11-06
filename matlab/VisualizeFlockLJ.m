function frame = VisualizeFlockLJ(t, X, parms, hFig)
% Unpack options
StructToVars(parms)
% Speed, use to normalize vectors length in the plot
norm = sqrt(X(end / 2 + 1:3 * end / 4) .^ 2 + X(3 * end / 4 + 1:end) .^ 2);
% Polarization vector
polVectAngle = [mean(X(end / 2 + 1:3 * end / 4)), mean(X(3 * end / 4 + 1:end))];
% Center of mass
com = [mean(X(1:end / 4)), mean(X(end / 4 + 1: end / 2))];
% Plot velocity vectors at each bird location
figure2(hFig), quiver(X(1:end / 4), X(end / 4 + 1: end / 2),...
  X(end / 2 + 1:3 * end / 4) ./ norm, X(3 * end / 4 + 1:end) ./ norm,...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', markersize)
title(sprintf('Flock at time %.1f', t)),
%    xlim([-50 50] + sign(com(1)) * floor(abs(com(1)) / 25) * 25),
%    ylim([-50 50] + sign(com(2)) * floor(abs(com(2)) / 25) * 25),
% fov = 1;
xlim([-fov fov] + com(1)),
ylim([-fov fov] + com(2)),
axis square, ylabel('Y [m]'), xlabel('X [m]'), grid on, grid minor,

% hold on,  quiver(com(1), com(2), polVectAngle(1), polVectAngle(2),...
%   'Color', 'r', 'linewidth', 2), hold off
drawnow
% figure2(3), plot(com(1), com(2), 'r.'), hold on
% drawnow
frame = getframe(gcf);