function self_prop = VelocityMatching(drnorm, dv, parms)
% Inputs:
%   drnorm    : Nx1xN matrix with pair-wise distances
%   dv        : Nx2xN matrix with pair-wise differences in vx and vy components
%   parms     : Struct with parameters, Ca, Cr, and lr
%
% Ouput:
%   self_prop : Acceleration due to velocity matching
%

% Velocity interations
I = 1 ./ (1 + drnorm .^ 2) .^ 2;
% I = exp(-drnorm .^ 2);
% I = I ./ sum(I(:));
% Self-propulsion: Average velocity difference
self_prop = parms.Kv * sum(-I .* dv, 3);
self_prop = self_prop(:);
