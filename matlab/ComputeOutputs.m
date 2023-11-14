function Y = ComputeOutputs(x, parms)

% Input x is [rx, ry vx, vy]
% Current positions [rx ry]
r = x(1:2 * parms.n_birds, end);
% Current velocity [vx vy]
v = x(2 * parms.n_birds + 1:4 * parms.n_birds, end);
% [drx, dry] and |dr|
[rxy, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
% [dvx, dvy]
vxy = ReshapeAndPairWiseDifferences(v);

% Local order
localOrder = LocalOrder(drnorm, vxy, parms);
% Group order
groupOrder = mean(localOrder);
% Group velocity
groupVelocity = sum(vxy, 1) / parms.n_birds;
% Group speed
groupSpeed = vecnorm(groupVelocity);
% Center of mass
com = mean(rxy, 1);
% Group size
groupSize = mean(vecnorm(rxy - com, 2, 2), 1);

% Outputs
Y = cat(1, groupOrder, groupVelocity', groupSpeed, groupSize, com');
