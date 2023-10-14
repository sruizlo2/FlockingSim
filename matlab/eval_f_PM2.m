function fOut = eval_f(X, params, u)
% Seed for random fluctuation generation
if isfield(params, 'seed')
  rng(params.seed)
end
% Unpack options
StructToVars(params)
% Split state vectors X = [x, y, theta]
% [x, y]
cur_pos = cat(2, X(1:n_birds), X(n_birds + 1:n_birds * 2))';
% th\eta
cur_dir = X(2 * n_birds + 1:end);
% Update velocities
vel = vecnorm(v_init, 2, 1) .* [cos(cur_dir); sin(cur_dir)];
% Compute y_i - y_j and x_i - x_j and store in a 2xNxN matrix
cur_pos_diff = cur_pos - permute(cur_pos, [1 3 2]);
% Relative orientation bewteen each pair of birds. Subtract each birds'
% orientation
cur_rel_dir = squeeze(atan2(cur_pos_diff(2, :, :), cur_pos_diff(1, :, :))) - cur_dir';
cur_rel_dir = angle(exp(1i * cur_rel_dir));
% Use this to make self orientation zero.
% cur_rel_dir = cur_rel_dir .* (1 - eye(size(cur_rel_dir)));
% Compute distance (squared) d^2 between each pair of birds
distances2 = squeeze(sum(cur_pos_diff .^ 2, 1));
% Only birds within the field of view of each bird influence
interations = double(abs(cur_rel_dir) <= fov / 2);
interations(~interations) = nan;
% Remove central bird from the averaging (make it NaN)
interationsDiag = eye(size(interations));
interationsDiag(interationsDiag == 1) = nan;
interations = interations + interationsDiag;
% Compute weights based on euclidean distance, and normalize such that sum
% is equal to 1
weights = exp(-distances2 / 1);
weights = weights ./ sum(weights, 1);
% Average direction of vectors connecting each pair of birds
average_dir = angle(sum(exp(1i * cur_rel_dir .* interations) .* weights, 1, 'omitnan'));
% Generate random fluctuations
dir_fluc = 2 * dir_fluc_range * (rand(1, n_birds) - 0.5);
angle_change = (average_dir / Gamma + dir_fluc)';
% Generate output function [f_1 f_2 f_3]
fOut = cat(1, vel, angle_change);
end
