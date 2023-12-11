function frame = VisualizeFlock(t, X, Y, parms, hFig, frame, init)
% Unpack options
StructToVars(parms)

% Speed, use to normalize vectors length in the plot
norm = sqrt(X(end / 2 + 1:3 * end / 4) .^ 2 + X(3 * end / 4 + 1:end) .^ 2);
% Polarization vector
% polVectAngle = [mean(X(end / 2 + 1:3 * end / 4)), mean(X(3 * end / 4 + 1:end))];

% Group velocity
groupVelocity = [Y(2) Y(3)];
% Group speed
groupSpeed = Y(4);
% Group size
groupSize = Y(5);
% Center of mass
com = [Y(6), Y(7)];

% Plot velocity vectors at each bird location
figure2(hFig), quiver(X(1:end / 4), X(end / 4 + 1: end / 2),...
  X(end / 2 + 1:3 * end / 4) ./ norm, X(3 * end / 4 + 1:end) ./ norm,...
  'off', 'Color', birds_color, 'Marker', '.', 'Markersize', markersize,...
  'linewidth', linewidth, 'ShowArrowHead', 'on'); hold on
quiver(com(1), com(2), groupVelocity(1) / groupSpeed, groupVelocity(2) / groupSpeed,...
  2.5, 'Color', flock_color, 'Marker', '.', 'Markersize', markersize,...
  'linewidth', 10 * linewidth, 'ShowArrowHead', 'on')
plot(NaN, NaN, 'ro', 'Markersize', 20, 'linewidth', 2);
viscircles(com, groupSize, 'color', flock_color); hold off
% xlim([-fov fov] + sign(com(1)) * floor(abs(com(1)) / (fov/3)) * (fov/3)),
% ylim([-fov fov] + sign(com(2)) * floor(abs(com(2)) / (fov/3)) * (fov/3)),
xlim([-fov fov] + com(1)),
ylim([-fov fov] + com(2)),
axis square, 
if axesoff
  xticks([]), yticks([])
else
  ylabel('$z$ [m]'), xlabel('$y$ [m]'),
end
set(gca,'Color', background_color)
if ~exist('titlename', 'var')
  titlename = sprintf('Flock at time %.1f s', t);
end
title(titlename, subtitlename),
if legendOn
  legend('Bird velocity vectors', 'Group velocity vector $\mathbf{U}$', 'Group size $G$',...
  'interpreter', 'latex', 'location', 'northeast')
end
  
% hold on,  quiver(com(1), com(2), polVectAngle(1), polVectAngle(2),...
%   'Color', 'r', 'linewidth', 2), hold off
if drawnowOn
  drawnow
end

if init
  h = figure(hFig);
  h.WindowState = 'maximized';
  set(gcf,'color','w');
  pause(0.5)
  h.Position = h.Position ./ [1 1 2 1];
  pause(0.5)
end

% figure2(3), plot(com(1), com(2), 'r.'), hold on
if nargout > 0
  if isempty(frame)
    frame = getframe(gcf);
  else
    frame = cat(1, frame, getframe(gcf));
  end
end