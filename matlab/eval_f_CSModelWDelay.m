function [fOut, parms] = eval_f_CSModelWDelay(x, parms, u)

% Unpack options
n_birds = parms.n_birds;

% Input x is [rx, ry vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds, end);
% Current velocity [vx vy]
v = x(2 * n_birds + 1:4 * n_birds, end);
% [drx, dry] and |dr|
[~, dr, drnorm] = ReshapeAndPairWiseDifferences(r);
% [dvx, dvy]
[vxy, dv] = ReshapeAndPairWiseDifferences(v);

if parms.update_a
  % Time delay for each bird
  [delays, parms] = TimeDelay(drnorm, vxy, parms);
  % Linear indexes for each bird for their corresponding time delay
  linearIndxs = ((delays) * n_birds * 2 + [0 n_birds]); % add offsets [0 n_birds] to get x and y components
  linearIndxs = linearIndxs + (1:n_birds)';
  parms.linearIndxs = linearIndxs;
end
% Time-delayed acceleration matching for each bird
PastAccelerationMatching = parms.a(parms.linearIndxs);

% Current acceleration [ax ay] to update dv/dt = f
a = VelocityMatching(drnorm, dv, parms) +...% First term: self-propulsion response to velocity matching
    PastAccelerationMatching(:) +...% Second term: self-propulsion response to acceleration matching
    TerminalVelocity(v, parms) +... & Third term: drag force
    MorseWallForceAnalytical(dr, drnorm, parms, u) +...% Force due to attractive and repulsive potentials
    u; % Constant acceleration
if parms.update_a
  % [ax, axy]
  axy = ReshapeAndPairWiseDifferences(a);
  % Current weighted-averange of accelerations, need to keep this in history
  CurrAccelerationMatching = AccelerationMatching(drnorm, axy, parms);
  % % Update acceleration matching
  parms.a = cat(2, parms.a(:, end-parms.kappa+1:end), CurrAccelerationMatching);
end
% Output value of f, scale with appropiate characteristic scales
% parms.curA = a;
fOut = cat(1, v, a);
