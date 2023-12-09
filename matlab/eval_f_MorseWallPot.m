function fOut = eval_f_MorseWallPot(x, parms, u)

% Unpack options
StructToVars(parms)

% Input x is [rx, ry vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds, end);
% [drx, dry] and |dr|
[~, dr, drnorm] = ReshapeAndPairWiseDifferences(r);

% function value
% Force due to attractive and repulsive potentials
fOut = 1 / parms.ls * MorseWallForceAnalytical(parms.ls * dr, parms.ls * drnorm, parms, u);