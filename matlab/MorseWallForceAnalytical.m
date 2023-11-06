function a = MorseWallForceAnalytical(drxy, drxynorm, parms, u)
% Inputs:
%   drxy      : Nx2xN matrix with pair-wise differences in x and y components
%   drxynorm  : Nx1xN matrix with pair-wise distances (the norm of drxy)
%   parms     : Struct with parameters, Ca, Cr, and lr
%   u         : Input, not used yet but could be helpful for external perturbations
%
% Ouput:
%   a         : Analytical acceleration due to Morse and Wall potential
%

% Relative orientation bewteen each pair of birds
theta = atan2( drxy(:, 2, :), drxy(:, 1, :) );
% Accleration due to potential force (-dV/dr)
a = parms.Cr / parms.lr * exp(- drxynorm / parms.lr) ... % Attractive
  - (3 * parms.Ca * drxynorm .^ 2); % Repulsive
% Omit self-interations
a(1:size(a, 1) + 1:end) = nan;
% Acceleration vector [ax, ay]
a = a .* cat(2, cos(theta), sin(theta));
% Net acceleration is the sum of acceleration.
a = sum(a, 3, 'omitnan') + u;
a = a(:);
