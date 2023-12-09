function [localOrder, parms] = LocalOrder(drnorm, v, parms)

% Matrix of local neirgborhood (1 in inside, NaN if outside)
neighborhood = single(drnorm <= parms.r0);
parms.n_neighborhood = cat(1, parms.n_neighborhood, mean(sum(neighborhood, 1, 'omitnan')));
neighborhood(~neighborhood) = NaN;
switch parms.lo_method
  case 'var'
    % Velocity magnitude
    vnorm = sqrt( sum( v .^ 2, 2 ) );
    % Variance of v for local neirgborhood
%     sigma = sum((vnorm - (sum(vnorm .* neighborhood, 1) ./ n_neighborhood)) .^ 2 .*...
%       neighborhood, 1) ./ (n_neighborhood);
    sigma = var(vnorm .* neighborhood, [], 1, 'omitnan');
    localOrder = parms.c0 * sigma;
  case 'pol'
    % Poalrization of v for local neirgborhood (or full flock if parms.r0 = inf)
    localOrder = 1 ./ (parms.c0 * vecnorm( mean(v .* neighborhood, 1, 'omitnan'), 2));
end
% Local order
localOrder = 1 ./ (1 + localOrder(:));
