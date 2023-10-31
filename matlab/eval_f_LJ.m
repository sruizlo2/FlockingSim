function fOut = eval_f_LJ(X, params, u)
% Seed for random fluctuation generation
if isfield(params, 'seed')
  rng(params.seed)
end
% Unpack options
StructToVars(params)
% Split state vectors X = [x, y]
% [x, y]
XY = cat(2, X(1:n_birds), X(n_birds + 1:n_birds * 2))';
% % [a_x, a_y]
% A = cat(2, X(n_birds * 2 + 1:n_birds * 3), X(n_birds * 3 + 1:n_birds * 4))';
% Compute delta x_ij = x_i - x_j and delta y_ij = y_i - y_j
% and store in a 2xNxN matrix
delta_X = XY - permute(XY, [1 3 2]);
% Relative orientation bewteen each pair of birds
theta = squeeze(atan2(delta_X(2, :, :), delta_X(1, :, :)));
% Compute distance d between each pair of birds
distances = squeeze(sqrt(sum(delta_X .^ 2, 1)));
% Force magnitude (-dV/dr)
F_mag = -24 * rest_potential / zero_potential_r *...
  ((zero_potential_r ./ distances) .^ 7 -...
  (2 * (zero_potential_r ./ distances) .^ 13)) + ...
  coulomb_force ./ distances .^ 1;
% Force vector in cartesian coordinates
F = cat(3, F_mag .* cos(theta), F_mag .* sin(theta));
% Net force is the sum of forces. Omit self-force (NaN)
F_net = squeeze(sum(F, 2, 'omitnan'))' + u;
F_net = cat(2, F_net(1, :), F_net(2, :))';
% Velocity
V = X(2 * n_birds + 1:4 * n_birds);
% Acceleration
A = F_net / mass;
% Saturate acceleration
A = min(A, max_A) .* (A >= 0) + max(A, -max_A) .* (A < 0);
% Add flucutations
% A = A + (max_A / 5 * (rand(size(A)) - 0.5));
if strcmp(update, 'pos')
  % Output functions
  f1 = cat(1, V, zeros(n_birds * 2, 1));
  f2 = cat(1, A / 2, zeros(n_birds * 2, 1));
elseif strcmp(update, 'vel')
  % Instant velocity change
  V = 1 / 2 * (A + accel);
  % Output functions
  f1 = cat(1, zeros(n_birds * 2, 1), V);
  f2 = zeros(n_birds * 4, 1);
end
% Output
fOut = cat(2, f1, f2);
end
