function fOut = eval_f_CSModel(x, parms, u)
% Unpack options
StructToVars(parms)

% Input x is [x, y vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds);
% Current velocity [vx vy]
v = x(2 * n_birds + 1:4 * n_birds);

% [drx, dry] and |dr|
[~, dr, drnorm] = ReshapeAndPairWiseDifferences(r);
% [dvx, dvy]
[~, dv] = ReshapeAndPairWiseDifferences(v);

% Current acceleration [ax ay] to update dv/dt = f
a = VelocityMatching(drnorm, dv, parms) +...% First term: self-propulsion response to velocity matching
    TerminalVelocity(v, parms) +... & Third term: drag force
    MorseWallForceAnalytical(dr, drnorm, parms, u); % Force due to attractive and repulsive potentials % Morse_Wall_Force(potential_func, parms, r, u)
fOut = cat(1, v, a);
