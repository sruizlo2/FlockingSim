function [fOut, parms] = eval_f_CSModelWDelay(x, parms, u)

% Unpack options
StructToVars(parms)

% Input x is [rx, ry vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds, end);
% Current velocity [vx vy]
v = x(2 * n_birds + 1:4 * n_birds, end);
% Past accelerations matching terms [amxt amyt]
aMatching = parms.a(:, end-kappa:end);
% [drx, dry] and |dr|
[~, dr, drnorm] = ReshapeAndPairWiseDifferences(r);
% [dvx, dvy]
[vxy, dv] = ReshapeAndPairWiseDifferences(v);

% Time delay for each bird
delays = TimeDelay(drnorm, vxy, parms);
% Linear indexes for each bird for their corresponding time delay
linearIndxs = ((delays) * n_birds * 2 + [0 n_birds]); % add offsets [0 n_birds] to get x and y components
linearIndxs = linearIndxs + (1:n_birds)';
% Time-delayed acceleration matching for each bird
PastAccelerationMatching = aMatching(linearIndxs);

% Current acceleration [ax ay] to update dv/dt = f
a = VelocityMatching(drnorm, dv, parms) +...% First term: self-propulsion response to velocity matching
    PastAccelerationMatching(:) +...% Second term: self-propulsion response to acceleration matching
    TerminalVelocity(v, parms) +... & Third term: drag force
    1 / parms.ls * MorseWallForceAnalytical(parms.ls * dr, parms.ls * drnorm, parms, u) +...% Force due to attractive and repulsive potentials
    u; % Constant acceleration
% [ax, axy]
axy = ReshapeAndPairWiseDifferences(a);
% Current weighted-averange of accelerations, need to keep this in history
CurrAccelerationMatching = AccelerationMatching(drnorm, axy, parms);
% Update acceleration matching
parms.a = cat(2, parms.a, CurrAccelerationMatching); 

% Output value of f, scale with appropiate characteristic scales
fOut = cat(1, v / parms.vs, a * parms.ts);
