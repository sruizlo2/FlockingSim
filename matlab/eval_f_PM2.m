function fOut = eval_f(X, params, u)
% Seed for random fluctuation generation
if isfield(params, 'seed')
  rng(params.seed)
end
% Unpack options
StructToVars(params)
% Split state vectors
cur_pos = cat(2, X(1:n_birds), X(n_birds + 1:n_birds * 2))';
%cur_dir = X(2 * n_birds + 1:end);
cur_
% Update velocities
vel = vecnorm(v_init, 2, 1) .* [cos(cur_dir); sin(cur_dir)];
% Create mask with closest neighbors
distances = sum((cur_pos - permute(cur_pos, [1 3 2])) .^ 2, 1);
interations = double(squeeze(distances <= interaction_radius ^ 2));
interations(~interations) = nan;
% Average direction of neighborhoods
average_dir = angle(sum(exp(1i * cur_dir .* interations), 1, 'omitnan'));
% Generate random fluctuations
dir_fluc = 2 * dir_fluc_range * (rand(1, n_birds) - 0.5);
dir = (average_dir + dir_fluc)' / Gamma;
dir(1)
% Generate output function [f_1 f_2 f_3]
fOut = cat(1, vel, dir);
end
