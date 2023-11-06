function drag_force = TerminalVelocity(v, parms)
% Inputs:
%   v          : 2Nx1 vector of speeds
%   parms      : Struct with parameters, alpha_ and v0
%
% Ouput:
%   drag_force : Analytical acceleration due to drag force
%

% Force v to be a column vector
v = v(:);
% Number of elements (half of length of v because we have vx and vy concatenated)
N = length(v) / 2;
% [vx, vy]
vxy = cat(2, v(1:N), v(N + 1:end));
% Terminal velocity due to drag
drag_force = repmat(parms.alpha_ * (parms.v0 ^ 2 - vecnorm(vxy, 2, 2) .^ 2), [2, 1]) .* v;