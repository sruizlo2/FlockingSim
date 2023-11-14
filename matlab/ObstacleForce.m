function a = ObstacleForce(x, t, parms)
% Inputs:
%   drxy      : Nx2xN matrix with pair-wise differences in x and y components
%   drxynorm  : Nx1xN matrix with pair-wise distances (the norm of drxy)
%   parms     : Struct with parameters, Ca, Cr, and lr
%
% Ouput:
%   a         : Analytical acceleration due to obstacles
%

theta = parms.wo * t;
% ro = parms.ro + parms.vo * t;
ro = parms.vr .* cat(2, cos(theta), sin(theta)) + parms.ro;
% Current positions [rx ry]
r = x(1:2 * parms.n_birds);
r = cat(2, r(1:end/2), r(end/2 + 1:end));
% Distance from each bird to the obstacle center
drxy = r - ro;
% Norm of pair-wise differences
drxynorm = sqrt( sum( drxy .^ 2, 2 ) );
% Relative orientation bewteen each pair of birds
theta = atan2( drxy(:, 2, :), drxy(:, 1, :) );
% Accleration due to potential force (-dV/dr)
a = parms.beta * parms.Co ./ parms.lo * (drxynorm / parms.lo) .^ (parms.beta - 1) .*...
  exp(- (drxynorm / parms.lo) .^ parms.beta);
% Acceleration vector [ax, ay]
a = a .* cat(2, cos(theta), sin(theta));
a = a(:);