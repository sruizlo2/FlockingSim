addpath(genpath('../matlab'))

%% Test analytical gradient, 1D case (trivial gradient)
% This case is for two particles, one static at x_j the other at different x_i
% Parameters
Ca = 1.5e-7;
Cr = 1.5;
lr = 0.05;
% Number of distances
N = 10000;
% Reference distance
xj = 10;
% Other distances
xi = linspace(-100, 100, N);
% Distances between pairs
dxi = xi(2) - xi(1);
% Potential
potential1D = @(dr) (Cr * exp(-abs(dr) / lr)) + (Ca * abs(dr) .^ 3);
% Analytical force
force = @(dr) -sign(dr) .* ( (Cr / lr * exp(-abs(dr) / lr)) - (3 * Ca * abs(dr) .^ 2) );
% Finite differences force
force_finiteDiff = -[diff(potential1D(xj - xi)) 0] / dxi;
% Plot potential
figure2(1), plot(xi, potential1D(xj - xi), 'k-'),
title('Potential'), xlabel('xi [m]'), ylabel('Potential [a.u.]'), grid on
% Plot Foces
figure2(2), plot(xi, force(xj - xi), 'k-'), hold on
figure2(2), plot(xi, force_finiteDiff, 'r--'), hold off
title('Force = - Grad of potential'), xlabel('xj [m]'), ylabel('Force [a.u.]'), grid on
legend('Analytical', 'Finite differences')

%% Test finite differences gradient, 2D case (non-trivial gradient)
% This case is for N particles in 2D
% Parameters
Ca = 1.5e-2; 
Cr = 1.5;
lr = 1;
parms = struct('Ca', Ca, 'Cr', Cr', 'lr', lr);
% Bird positions
r =  1 * [-1 -1  1 1 2 -1  1 -1  1 0]';
[~, drxy, drxynorm] = ReshapeAndPairWiseDifferences(r);

N = length(r) / 2;
% Input, not used yet but could be helpful for external perturbations
u = 0;
% Forces via finite differences
forces = MorseWallForce('MorseWallPotential', parms, r, u);
% Forces vias analytical gradient
forces_analytic = MorseWallForceAnalytical(drxy, drxynorm, parms, u);
% Norm to normalize vectors in plot (sometimes just 1's is enough)
forces_mag = 1;
% Plor force vectors
figure2(3), quiver(r(1:N), r(N + 1: end),...
  forces(1:N) ./ forces_mag, forces(N + 1:end) ./ forces_mag,...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Forces'), axis image, grid on, xlabel('x'), ylabel('y'), hold on
% Plor analytical force vectors
figure2(3), quiver(r(1:N), r(N + 1: end),...
  forces_analytic(1:N) ./ forces_mag, forces_analytic(N + 1:end) ./ forces_mag,...
  'AutoScale', 'off', 'Color', 'b', 'Marker', '.', 'Markersize', 20)
title('Forces'), axis image, grid on, xlabel('x'), ylabel('y'), hold off

%% Test terminal velocity function
% This case is 1D, fixed terminal velcity and varying speed
% Parameters
alpha_ = 0.2;
terminal_speed = 10;
parms = struct('alpha_', alpha_, 'v0', terminal_speed);
% Speed
v = cat(2, linspace(-15, 15, 100), zeros(1, 100));
N = length(v) / 2;
% Drag force
drag_force = TerminalVelocity(v, parms);
% Plot Drag force versus speed. F_d has the same sign as v when |v| < v_0,
% otherwise F_d opposes to v
figure2(4), plot(v(1:N), drag_force(1:N), 'r-'), hold on
plot(v(N + (1:N)), drag_force(N + (1:N)), 'k-'), hold off
xline([-10 10]), grid on

%% Test velocity matching force (self-propulsion mechanism)
% This case is for N particles in 2D
% Parameters
Kv = 1; 0.1;
Ka = 1; 0.12;
parms = struct('Kv', Kv, 'Ka', Ka);
% Bird positions
r =  .1 * [-1 -1  1  1 -1  1 -1  1]';
[~, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
N = length(r) / 2;
% Bird velocities
v =  [1  2  1  1  0 0  0 0]';
[~, dv] = ReshapeAndPairWiseDifferences(v);
% Bird accelerations
a =  [1  10  1  1  0 0  0 0]';
a_vect = ReshapeAndPairWiseDifferences(a);
forces_mag = 1;

% Plot self_propulsion_force
self_Propulsion_VM = VelocityMatching(drnorm, dv, parms) +...
  AccelerationMatching(drnorm, a_vect, parms);
% plot velocities
figure2(5), subplot(131), quiver(r(1:N), r(N + 1: end),...
  v(1:N), v(N + 1:end),...
  'AutoScale', 'on', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Velocities'), axis image, grid on, xlabel('x'), ylabel('y')
% plot accelerations
figure2(5), subplot(132), quiver(r(1:N), r(N + 1: end),...
  a(1:N), a(N + 1:end),...
  'AutoScale', 'on', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Accelerations'), axis image, grid on, xlabel('x'), ylabel('y')
% Plot self-propulsion forces
figure2(5), subplot(133), quiver(r(1:N), r(N + 1: end),...
  self_Propulsion_VM(1:N) ./ forces_mag, self_Propulsion_VM(N + 1:end) ./ forces_mag,...
  'AutoScale', 'on', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Self-propulsion forces'), axis image, grid on, xlabel('x'), ylabel('y')

%% Local order
r0 = .2; % minimum distance to compuate variance in local order computation
c0 = 10; % Scale factor for variance
kappa = 10; % Max time-delay
% Bird positions
r =  .1 * [-1 -1  1  1 -1  1 -1  1]';
[~, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
N = length(r) / 2;
% Bird velocities
v =  [1 2 1 1 0 0 0 0]';
[vxy, dv] = ReshapeAndPairWiseDifferences(v);
parms = struct('r0', r0, 'c0', c0, 'kappa', kappa);
% Local order
local_order = LocalOrder(drnorm, vxy, parms);
% Time delay
delay = TimeDelay(drnorm, vxy, parms);
