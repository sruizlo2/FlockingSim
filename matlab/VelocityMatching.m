function self_prop = VelocityMatching(drnorm, dv, parms)
% Inputs:
%   drnorm    : Nx1xN matrix with pair-wise distances
%   dv        : Nx2xN matrix with pair-wise differences in vx and vy components
%   parms     : Struct with parameters, Ca, Cr, and lr
%
% Ouput:
%   self_prop : Acceleration due to velocity matching
%

% Weights
weights = 1 ./ (1 + (parms.ls * drnorm) .^ 2) .^ 2;
% Velocity interations
J = parms.Kv * weights;
% Self-propulsion: Average velocity difference
self_prop = squeeze(sum(- J .* dv, 3));
self_prop = self_prop(:);
