addpath(genpath('../matlab'))
rest_potential = 1;
zero_potential_r = 0.7;

X = [0, 2 ^ (1/6) * zero_potential_r, -zero_potential_r, 0, 0, 0]';
X = [0 1 1 0 0 1]';
n_birds = length(X) / 2;

X_vect = cat(2, X(1:n_birds), X(n_birds + 1:n_birds * 2))';
delta_X = X_vect - permute(X_vect, [1 3 2]);

dist = squeeze(sqrt(sum(delta_X .^ 2, 1)));

theta = squeeze(atan2(delta_X(2, :, :), delta_X(1, :, :)));

force_mag = -24 * rest_potential / zero_potential_r *...
  ((zero_potential_r ./ dist) .^ 7 - (2 * (zero_potential_r ./ dist) .^ 13));
force = cat(3, force_mag .* cos(theta), force_mag .* sin(theta));
net_force = squeeze(sum(force, 2, 'omitnan'))';
potential = 4 * rest_potential *...
  ((zero_potential_r ./ dist) .^ 12 - (zero_potential_r ./ dist) .^ 6);

figure2(1), quiver(X_vect(1, :), X_vect(2, :), net_force(1, :), net_force(2, :), 'off', 'Color', 'r')
hold on, plot(X_vect(1, :), X_vect(2, :), 'b.', 'Markersize', 20), hold off
axis square, xlim([-3 3]), ylim([-3 3])

r = 1;
force_mag = 24 * rest_potential / zero_potential_r *...
  ((zero_potential_r ./ r) .^ 7 - (2 * (zero_potential_r ./ r) .^ 13))
figure2(2), plot(r, force_mag)