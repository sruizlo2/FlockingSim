function localOrder = LocalOrder(drnorm, v, parms)

% Matrix of local neirgborhood (1 in inside, NaN if outside)
neighborhood = single(drnorm <= parms.r0);
neighborhood(~neighborhood) = NaN;
mean(sum(neighborhood, 3, 'omitnan'), 'all');
switch parms.lo_method
  case 'var'
    % Velocity magnitude
    vnorm = sqrt( sum( v .^ 2, 2 ) );
    % Variance of v for local neirgborhood
    localOrder = parms.c0 * var(vnorm .* neighborhood, [], 1, 'omitnan');
  case 'pol'
    % Poalrization of v for local neirgborhood (or full flock if parms.r0 = inf)
    localOrder = 1 ./ (parms.c0 * vecnorm( mean(v .* neighborhood, 1, 'omitnan'), 2));
end
% Local order
localOrder = 1 ./ squeeze(1 + localOrder);
