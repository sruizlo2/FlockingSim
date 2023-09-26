function fOut = eval_f(X, params, u)
% Unpack options
StructToVars(params)
% Split state vectors
curDir = X(2 * n_birds + 1:end);
curR = cat(2, X(1:n_birds), X(n_birds + 1:n_birds * 2))';
% Create mask with closest neighbors
distances = sum((curR - permute(curR, [1 3 2])) .^ 2, 1);
closestNeigh = double(squeeze(distances < neighRadius ^ 2));
closestNeigh(~closestNeigh) = nan;
% Average direction of neighborhoods
aveDir = angle(sum(exp(1i * curDir .* closestNeigh), 1, 'omitnan'));
% Compute new direction
dirFluctuation = 2 * dirFlucRange * (rand(1, n_birds) - 0.5);
% Update orientations
dir = aveDir + dirFluctuation;
% Update velocities
vel = vecnorm(v_init, 2, 1) .* [cos(dir), sin(dir)];
dir = dir - curDir';
fOut = cat(2, vel, dir / timestep)';
end
