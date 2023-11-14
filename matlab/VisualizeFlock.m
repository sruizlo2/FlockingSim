function frame = VisualizeFlock(t, X, Y, parms, hFig, frame)
% Unpack options
StructToVars(parms)
% Speed, use to normalize vectors length in the plot
norm = sqrt(X(end / 2 + 1:3 * end / 4) .^ 2 + X(3 * end / 4 + 1:end) .^ 2);
% Polarization vector
% polVectAngle = [mean(X(end / 2 + 1:3 * end / 4)), mean(X(3 * end / 4 + 1:end))];

% Group velocity
groupVelocity = [Y(2, end) Y(3, end)];
% Group speed
groupSpeed = Y(4, end);
% Group size
groupSize = Y(5, end);
% Center of mass
com = [Y(end-1, end), Y(end, end)];

% Plot velocity vectors at each bird location
markersize = 7;
figure2(hFig), quiver(X(1:end / 4), X(end / 4 + 1: end / 2),...
  X(end / 2 + 1:3 * end / 4) ./ norm, X(3 * end / 4 + 1:end) ./ norm,...
  0, 'Color', 'k', 'Marker', '.', 'Markersize', markersize,...
  'linewidth', linewidth, 'ShowArrowHead', 'on'), hold on
quiver(com(1), com(2), groupVelocity(1) / groupSpeed, groupVelocity(2) / groupSpeed,...
  0, 'Color', 'r', 'Marker', '.', 'Markersize', 2*markersize,...
  'linewidth', 10*linewidth, 'ShowArrowHead', 'on')
title(sprintf('Flock at time %.1f', t)),
viscircles(com, groupSize, 'color', 'r'); hold off
%    xlim([-50 50] + sign(com(1)) * floor(abs(com(1)) / 25) * 25),
%    ylim([-50 50] + sign(com(2)) * floor(abs(com(2)) / 25) * 25),
% fov = 1;
xlim([-fov fov] + com(1)),
ylim([-fov fov] + com(2)),
axis square, ylabel('Y [m]'), xlabel('X [m]')

% hold on,  quiver(com(1), com(2), polVectAngle(1), polVectAngle(2),...
%   'Color', 'r', 'linewidth', 2), hold off
drawnow
% figure2(3), plot(com(1), com(2), 'r.'), hold on
% drawnow
if nargout > 0
  if isempty(frame)
    frame = getframe(gcf);
  else
    frame = cat(1, frame, getframe(gcf));
  end
end