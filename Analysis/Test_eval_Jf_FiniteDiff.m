% Add path with functions
addpath(genpath('../matlab'))

%% PARAMETERS
% Number of birds
n_birds = 10;
% Number of informed birds (not used yet)
n_informed_birds = 0;
% Add informed birds
add_informed_birds = false;
% Informed direction bias
informed_dir = -pi / 4;
% Indices of informed birds
informed_birds = randperm(n_birds, n_informed_birds);
% Constant speed value
v_init = 1; % m/s
% Radius of interation
interaction_radius = 10; % m
% Range for uniformly distributed random orientation fluctuations
dir_fluc_range = 0.0; % rad
% Use random orientations or fixed
random_orientations = false;
% Initial position and orientations (randomly defined)
if random_orientations
  x_0 = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
    2*pi * (rand(n_birds, 1) - 0.5));
else
  x_0 = cat(1, 1 * zeros(2 * n_birds, 1),...
    linspace(0, 2 * pi, n_birds)');
end
% Name of function to evaluate f()
eval_f = 'eval_f';
% Time step
timestep = 0.1;
% Struct with parameters
params = struct('interaction_radius', interaction_radius,...
  'dir_fluc_range', dir_fluc_range, 'n_birds', n_birds,...
  'timestep', timestep, 'v_init', v_init,...
  'add_inform_birds', add_informed_birds,...
  'informed_birds', informed_birds, 'informed_dir', informed_dir);
% Add parameter to compute Jacobian with finite differences
useFixedEps = false;
if useFixedEps
  params.epsilon = sqrt(eps);
  params.dxFD = sqrt(eps);
else
  params.epsilon = 2 * sqrt(eps) * max(1, norm(x_0, inf));
  params.dxFD = 2 * sqrt(eps) * max(1, norm(x_0, inf));
end
% Fixed random fluctuation so the Jacobians are comparable
params.seed = 'default';
% Input
input = 0;
% Jacobian with finite differences
Jacobian = eval_Jf_FiniteDiff(eval_f, x_0, params, input);
% Reference Jacobian
JacobianRef = eval_Jf_FiniteDifference('eval_f', x_0, params, input);
figure(1), imagesc(Jacobian'), axis image, colorbar
figure(2), imagesc(JacobianRef'), axis image, colorbar
figure(3), imagesc(Jacobian' - JacobianRef'), axis image, colorbar
% Prinf mean differences +- standard deviation
fprintf('Diference between Jacobians: %.3e +- %.3e\n',...
  mean(Jacobian - JacobianRef, 'all'), std(Jacobian - JacobianRef, [], 'all'))
