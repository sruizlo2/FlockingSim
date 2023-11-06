function local_order = LocalOrder(dr, v, parms)

% Matrix of local neirgborhood (1 in inside, NaN if outside)
neighborhood = single(dr <= parms.r0);
neighborhood(~neighborhood) = NaN;

switch parms.lo_method
  case 'var'
    % Velocity magnitude
    vnorm = sqrt( sum( v .^ 2, 2 ) );
    % Variance of v for local neirgborhood
    local_order = parms.c0 * var(vnorm .* neighborhood, [], 1, 'omitnan');
  case 'pol'
    % Poalrization of v for local neirgborhood (or full flock if parms.r0 = inf)
    local_order = 1 ./ (parms.c0 * vecnorm( mean(v .* neighborhood, 1, 'omitnan'), 2));
end
% Local order
local_order = 1 ./ squeeze(1 + local_order);
