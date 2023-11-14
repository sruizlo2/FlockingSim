addpath(genpath('../matlab'))
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')
LATEX_DEF = {'Interpreter', 'latex'};
LINE_WIDTH = 1.5;

%% Test analytical gradient, 1D case (trivial gradient)
% This case is for two particles, one static at x_j the other at different x_i
% Parameters
Ca = 1.5e-7;
Cr = 1.5;
lr = 0.05;
% Number of distances
N = 10000;
% Reference distance
xi = 10;
% Other distances
xj = linspace(-50, 50, N);
% Distances between pairs
dxi = xj(2) - xj(1);
% Potential
potential1D = @(dr) (Cr * exp(-abs(dr) / lr)) + (Ca * abs(dr) .^ 3);
% Analytical force
force = @(dr) -sign(dr) .* ( (Cr / lr * exp(-abs(dr) / lr)) - (3 * Ca * abs(dr) .^ 2) );
% Finite differences force
force_finiteDiff = -[diff(potential1D(xj - xi)) 0] / dxi;
% Plot potential
figure2(1), plot(xj, potential1D(xj - xi), 'k-'),
title('Potential between two birds'), xlabel('$x_j$ [m]'), ylabel('Potential $\varphi$ [a.u.]'), grid on
% Plot Foces
figure2(2), plot(xj, force(xj - xi), 'k-'), hold on
figure2(2), plot(xj, force_finiteDiff, 'r--'), hold off
title('Force = - Grad of potential'), xlabel('$x_j$ [m]'), ylabel('-$\nabla\varphi$ [a.u.]'), grid on
legend('Analytical', 'Finite differences')

%% Test finite differences gradient and analytical gradient for 2D case (non-trivial gradient)
% This case is for N particles in 2D
% Parameters
Ca = 1.5e-2; 
Cr = 1.5;
lr = 1;
parms = struct('Ca', Ca, 'Cr', Cr', 'lr', lr);
% Bird positions
r_2 =  cat(2, 1 * [-1 -1  1 1 -1  1 -1  1]', .75 * [-1 -1  1 1 -1  1 -1  1]');
for k = 1:2
  r = r_2(:, k);
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
  % Plot force vectors
  figure2(3), subplot(1,2,k), quiver(r(1:N), r(N + 1: end),...
    forces(1:N) ./ forces_mag, forces(N + 1:end) ./ forces_mag,...
    'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20, 'LineWidth', 2)
  title('Forces due to Morse-Wall Potential'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'), hold on
  % Plor analytical force vectors
  figure2(3), subplot(1,2,k), quiver(r(1:N), r(N + 1: end),...
    forces_analytic(1:N) ./ forces_mag, forces_analytic(N + 1:end) ./ forces_mag,...
    'AutoScale', 'off', 'Color', 'r', 'Marker', '.', 'Markersize', 20, 'LineStyle','--', 'LineWidth', 2)
  axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'), hold off
end

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
title('Force due to air drag'), xlabel('$||v||$ [m/s]'), ylabel('$\psi(v)$ [a.u.]')

%% Test velocity matching force (self-propulsion mechanism)
% This case is for N particles in 2D
% Parameters
Kv = 10; 0.1;
Ka = 1; 0.12;
parms = struct('Kv', Kv, 'Ka', Ka, 'ls', 1);
% Bird positions
r =  1 * [-1 -1  1  1 -1  1 -1  1]';
[~, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
N = length(r) / 2;
% Bird velocities
v =  [1  2  1  1  0 0  0 0]';
[~, dv] = ReshapeAndPairWiseDifferences(v);
% Bird accelerations
a =  [1  2  1  1  0 0  0 0]';
a_vect = ReshapeAndPairWiseDifferences(a);
forces_mag = 1;

% Self_propulsion_force
self_Propulsion_VM = VelocityMatching(drnorm, dv, parms);
self_Propulsion_AM = AccelerationMatching(drnorm, a_vect, parms);
lims = [-2.3 2.3];

% plot velocities
figure2(5), subplot(221), quiver(r(1:N), r(N + 1: end),...
  v(1:N), v(N + 1:end),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Velocities'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),
% plot accelerations
figure2(5), subplot(222), quiver(r(1:N), r(N + 1: end),...
  a(1:N), a(N + 1:end),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Accelerations'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),
% Plot self-propulsion forces due to velocity matching
figure2(5), subplot(223), quiver(r(1:N), r(N + 1: end),...
  self_Propulsion_VM(1:N) ./ forces_mag, self_Propulsion_VM(N + 1:end) ./ forces_mag,...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Velocity matching'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]')
xlim(lims), ylim(lims),
% Plot self-propulsion forces due to acceleration matching
figure2(5), subplot(224), quiver(r(1:N), r(N + 1: end),...
  self_Propulsion_AM(1:N) ./ forces_mag, self_Propulsion_AM(N + 1:end) ./ forces_mag,...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Acceleration matching'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]')
xlim(lims), ylim(lims),

%% Local order
r0 = 2.5; % minimum distance to compuate variance in local order computation
c0 = 10; % Scale factor for variance
kappa = 10; % Max time-delay
% Bird positions
r =  1 * [-1 -1  1  1 -1  1 -1  1]';
[~, ~, drnorm] = ReshapeAndPairWiseDifferences(r);
N = length(r) / 2;
% Bird velocities
v =  [1.75 1 1 1 0 0 0 0]';
[vxy, dv] = ReshapeAndPairWiseDifferences(v);
parms = struct('r0', r0, 'c0', c0, 'kappa', kappa, 'lo_method', 'var');
% Local order
local_order = LocalOrder(drnorm, vxy, parms);
% Time delay
delay = parms.kappa - TimeDelay(drnorm, vxy, parms);
% plot velocities
figure2(6), quiver(r(1:N), r(N + 1: end),...
  v(1:N), v(N + 1:end),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Velocities'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
for k = 1:3
  viscircles(r([k k + 4])', r0, 'color', 'k', 'LineWidth', 1, 'LineStyle','--');
end
viscircles(r([4 8])', r0, 'color', 'r', 'LineWidth', 1, 'LineStyle','--');
fprintf('Time delays: [%d, %d, %d, %d]\n', delay)

%% Test input potential (obstacle)
% r0 = 1;
% N = 100000;
% r = linspace(-10, 10, N);
% beta = 10;
% E0 = 10;
% El = 1;
% exter_pot = E0 * exp(- (r - r0) .^ beta / El ^ beta);
% exter_force = - beta * E0 ./ El * ((r - r0) / El) .^ (beta - 1) .* exp(- ((r - r0) / El) .^ beta);
% dr = r(2) - r(1);
% exter_force_diff = [diff(exter_pot) 0] / dr;
% figure2(6), subplot(121), plot(r, exter_pot)
% figure2(6), subplot(122), plot(r, exter_force, 'r'), hold on
% plot(r, exter_force_diff, 'k--'), hold off

%% Example of function evaluation
% PARAMETERS
% Normalization constants
ls = 1;       % Length scale
ts = 1;     % Time scale
vs = ls / ts; % Speed scale

% Parameters
Ca = .001; %1.5e-7 % Effective distance of the attraction
Cr = 3; %1.5    % Strength of the short-range repulsion
lr = .5; %0.05 % Effective distance of the repulsion
v0 = 1;         % Terminal speed
alpha_ = 0.2;   % Strenght of drag force
Kv = 0.1;       % Interaction strength of velocity matching
Ka = 0.12;      % Interaction strength of acceleration matching
kappa = 0;    % Maximum time delay for acceleration matching
r0 = 10;        % Minimum distance to compuate variance in local order computation
c0 = 10;        % Scale factor for variance
lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
a0 = .4;

% Number of birds
n_birds = 5;
% Initial position and orientations. For positions, let's place birds
% randombly within a circle. For orientations, let's fix a global
% orientation and add random orientation for each bird
% Initial positions, velocities and accelerations
r = [0 1 1 0 -1 -1 -1 0 1, 0 0 1 1 1 0 -1 -1 -1 0 ]';
v = .75 * [0 -1 -1 0 1 1 1 0 -1, 0 0 -1 -1 -1 0 1 1 1]';
a = .75 * [0 -1 -1 0 1 1 1 0 -1, 0 0 -1 -1 -1 0 1 1 1]';

r = [0 -1 1 -1 1, 0 -1 -1 1 1]';
v = .75 * [0 1 -1 1 -1, 0 1 1 -1 -1]';
a = .75 * [0 1 -1 1 -1, 0 1 1 -1 -1]';

u = 0;
% Ploting options
fov = 5;
markersize = 3;
linewidth = 0.25;
% Parameters structure
parms = struct('n_birds', n_birds, 'Ca', Ca, 'Cr', Cr, 'lr', lr,...
  'v0', v0, 'alpha_', alpha_, 'Kv', Kv, 'Ka', Ka, 'kappa', kappa,...
  'r0', r0, 'c0', c0, 'lo_method', lo_method,...
  'fov', fov, 'markersize', markersize, 'a', a, 'linewidth', linewidth,....
  'ls', ls, 'ts', ts, 'vs', vs); % Ploting options

% Evaluate function
x = cat(1, r, v);
fOut = eval_f_CSModelWDelay(x, parms, u);

% plot velocities
lims = [-1.75 1.75];
figure2(7), subplot(241), quiver(r(1:n_birds), r(n_birds + 1: end),...
  v(1:n_birds), v(n_birds + 1:end),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Velocities'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),
% plot accelerations
figure2(7), subplot(242), quiver(r(1:n_birds), r(n_birds + 1: end),...
  a(1:n_birds), a(n_birds + 1:end),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('Accelerations'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),

% plot velocities f_1 = v
figure2(7), subplot(245), quiver(r(1:n_birds), r(n_birds + 1: end),...
  fOut(1:n_birds), fOut(n_birds+1:2*n_birds),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('$f_1 = v$'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),
% plot accelerations f_2 = a
figure2(7), subplot(246), quiver(r(1:n_birds), r(n_birds + 1: end),...
  fOut(2*n_birds+1:3*n_birds), fOut(3*n_birds+1:4*n_birds),...
  'AutoScale', 'off', 'Color', 'k', 'Marker', '.', 'Markersize', 20)
title('$f_2 = a$'), axis image, grid on, xlabel('$x$ [m]'), ylabel('$y$ [m]'),
xlim(lims), ylim(lims),

% Example of Jacobian evaluation
JacobianFD = eval_Jf_FiniteDiff('eval_f_CSModelWDelay', x, parms, u);
figure(7), subplot(222),
imagesc(flip(JacobianFD(1:end/2, :), 5), [0 1]), axis image, colormap(gray(256)),
title('Jacobian'), xlabel('[$x$~$y$~$v_x$~$v_y$]'), ylabel('[$v_y$~$v_x$]'), colorbar

figure(7), subplot(224),
imagesc(flip(JacobianFD(end/2+1:end, :), 5), [-2.5 2.5]), axis image, colormap(gray(256)),
title('Jacobian'), xlabel('[$x$~$y$~$v_x$~$v_y$]'), ylabel('[$a_y$~$a_x$]'), colorbar

%% Convergence of Jacobian norm for simple case
k = 0;
epsVect = -16:.01:1;
clear JacobianFDNorm
for thisEps = epsVect
   k = k + 1;
  parms.epsilon = 10 ^ thisEps;
  JacobianFD(:, :, k) = eval_Jf_FiniteDiff('eval_f_CSModelWDelay', x, parms, u);
  if k > 2
    JacobianFDNorm(k-1) = norm(JacobianFD(:, :, k) - JacobianFD(:, :, k-1), 1);
  end
end
figure(8), loglog(10 .^ epsVect(2:end), JacobianFDNorm, 'k', 'LineWidth', 2),
grid on, grid minor
title('Norm of the Jacobian versus $\varepsilon$')
ylabel('$|| J_f ||$'), xlabel('$\varepsilon$'), axis tight

