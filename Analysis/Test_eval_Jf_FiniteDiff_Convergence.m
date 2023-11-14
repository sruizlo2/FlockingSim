%% Convergence of Jacobian norm for real case
% Normalization constants
ls = 1;       % Length scale
ts = 0.1;     % Time scale
vs = ls / ts; % Speed scale
test_indx = 2;
useGPU = true;

% Parameters
Ca = 1.5e-7;    % Effective distance of the attraction
Cr = 1.5;       % Strength of the short-range repulsion
lr = 0.05;      % Effective distance of the repulsion
v0 = 1;         % Terminal speed
alpha_ = 0.2;   % Strenght of drag force
Kv = 0.1;       % Interaction strength of velocity matching
Ka = 0.12;      % Interaction strength of acceleration matching
kappa = 800;    % Maximum time delay for acceleration matching
r0 = 0.6;       % Minimum distance to compuate variance in local order computation
c0 = 10;        % Scale factor for variance
lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
% Initial past accelerations matching
am0 = 0;

% Number of birds
n_birds = 1e3;
% Initial position and orientations. For positions, let's place birds
% randombly within a circle. For orientations, let's fix a global
% orientation and add random orientation for each bird
% Initialize random positions within a circle
cirle_angle = 2 * pi * rand(n_birds, 1);
circle_radius = 10 * sqrt(rand(n_birds, 1));
% Initial positions and velocities
x_start = cat(1, circle_radius .* cos(cirle_angle),...
  circle_radius .* sin(cirle_angle),...
  vs * v0 * (0.0 + 0.5 * (rand(2 * n_birds, 1) - 0.5)));
% Initial accelerations, constant for all birds and time steps
a_start = am0 * ones(2 * n_birds, kappa + 1);
% Input
u = 0;
% Options for plotting
fov = 20;
markersize = 3;
linewidth = 0.25;
plotStep = 4;

% Struct with parameters
parms = struct('n_birds', n_birds, 'Ca', Ca, 'Cr', Cr, 'lr', lr,...
  'v0', v0, 'alpha_', alpha_, 'Kv', Kv, 'Ka', Ka, 'kappa', kappa,...
  'r0', r0, 'c0', c0, 'lo_method', lo_method,...
  'fov', fov, 'markersize', markersize, 'linewidth', linewidth, 'a', a_start, ...
  'ls', ls, 'ts', ts, 'vs', vs, 'plotStep', plotStep,...
  'vid_filename', []); % Ploting options
parms.JfVerbosity = false;
k = 0;
epsVect = -12:.1:-4;
clear JacobianFDNorm JacobianFD
for thisEps = epsVect
   k = k + 1;
  parms.epsilon = 10 ^ thisEps;
  JacobianFD(:, :, k) = eval_Jf_FiniteDiff('eval_f_CSModelWDelay', x_start, parms, u);
  if k > 2
    JacobianFDNorm(k-1) = norm(JacobianFD(:, :, k) - JacobianFD(:, :, k-1), 1);
  end
  fprintf('this dx = %.4e\n', parms.epsilon)
end
figure(9), loglog(10 .^ epsVect(2:end), JacobianFDNorm, 'k', 'LineWidth', 2), grid on, grid minor
title('Norm of the Jacobian versus $\varepsilon$')
ylabel('$|| J_f ||$'), xlabel('$\varepsilon$'), axis tight
xline(1e-7, 'r', 'LineWidth', 2)
