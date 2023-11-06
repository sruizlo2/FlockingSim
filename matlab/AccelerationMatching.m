function self_prop = AccelerationMatching(drnorm, a, parms)
% Inputs:
%   drnorm    : Nx1xN matrix with pair-wise distances
%   a         : Nx2xN matrix with acceleration in x and y components
%   parms     : Struct with parameters, Ca, Cr, and lr
%
% Ouput:
%   self_prop : Acceleration due to velocity matching
%

% Weights
weights = 1 ./ (1 + drnorm .^ 2) .^ 2;
% Acceleration interations
I = parms.Ka * weights;
% Self-propulsion: Average velocity difference + Average aceleration
self_prop = squeeze(sum( I .* a, 1))';
self_prop = self_prop(:);
