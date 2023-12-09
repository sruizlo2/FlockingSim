function self_prop = AccelerationMatching(drnorm, a, parms)
% Inputs:
%   drnorm    : Nx1xN matrix with pair-wise distances
%   a         : Nx2xN matrix with acceleration in x and y components
%   parms     : Struct with parameters, Ca, Cr, and lr
%
% Ouput:
%   self_prop : Acceleration due to velocity matching
%

if parms.Ka ~= 0
  % Acceleration interations
  J = 1 ./ (1 + drnorm .^ 2) .^ 2;
%   J = exp(-drnorm .^ 2);
%   J = J ./ sum(J(:));
  % Self-propulsion: Average velocity difference + Average aceleration
  self_prop = permute(parms.Ka * sum(J .* a, 1), [3 2 1]);
  self_prop = self_prop(:);
else
  self_prop = zeros(numel(a), 1);
end
