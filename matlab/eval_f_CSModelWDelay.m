function fOut = eval_f_CSModels(x, parms, u)

% Unpack options
StructToVars(parms)

% Input x is [x, y vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds, end);
% Current velocity [vx vy]
v = x(2 * n_birds + 1:4 * n_birds, end);
% Past accelerations matching terms [amxt amyt]
aMatching = x(4 * n_birds + 1:end, :);
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
    MorseWallForceAnalytical(dr, drnorm, parms, u); % Force due to attractive and repulsive potentials % Morse_Wall_Force(potential_func, parms, r, u)
% [ax, axy]
axy = ReshapeAndPairWiseDifferences(a);
% Current weighted-averange of accelerations, need to keep this in history
CurrAccelerationMatching = AccelerationMatching(drnorm, axy, parms);

fOut = cat(1, v, a, CurrAccelerationMatching);
