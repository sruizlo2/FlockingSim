function p = UpdateAccelerationHistory(x, p)
if p.update_a
  n_birds = p.n_birds;
  % Input x is [rx, ry vx, vy]
  % Current positions [rx ry]
  r = x(1:2 * n_birds, end);
  % [drx, dry] and |dr|
  [~, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
  % Current velocity [vx vy]
  v = x(2 * n_birds + 1:4 * n_birds, end);
  % [dvx, dvy]
  vxy = ReshapeAndPairWiseDifferences(v);

  % Time delay for each bird
  delays = TimeDelay(drnorm, vxy, p);
  % Linear indexes for each bird for their corresponding time delay
  linearIndxs = ((delays) * n_birds * 2 + [0 n_birds]); % add offsets [0 n_birds] to get x and y components
  linearIndxs = linearIndxs + (1:n_birds)';
  % Update delays indexes
  p.linearIndxs = linearIndxs;
% end

% if p.update_a
  % Current accelerations [ax, ay]
  axy = ReshapeAndPairWiseDifferences(p.curA);
  % Update acceleration matching
  p.a = cat(2, p.a(:, 2:end), AccelerationMatching(drnorm, axy, p));
end