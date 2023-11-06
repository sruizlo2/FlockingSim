function potential = MorseWallPotential(r, parms, u)
% Inputs:
%   r         : 2Nx1 vector with x and y positions concatenated
%   parms     : Struct with parameters, Ca, Cr, and lr
%   u         : Input, not used yet but could be helpful for external perturbations
%
% Ouput:
%   potential : Analytical Morse and Wall potential
%

% Force r to be a column vector
r = r(:);
% Number of elements (half of length of r because we have x and y concatenated)
N = length(r) / 2;
% [rx, ry]
rxy = cat(3, r(1:N), r(N + 1:end));
% Compute pair-wise distances in x and y
drxy = rxy - permute(rxy, [2 1 3]);
drxynorm = sqrt( sum( drxy .^ 2, 3 ));
% Morese potential is attractive and wall potential is repulsive
potential = sum( (parms.Cr .* exp(-drxynorm / parms.lr)) +...
  (parms.Ca .* drxynorm .* drxynorm .* drxynorm), 2);

