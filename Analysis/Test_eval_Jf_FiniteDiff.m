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
test_indx = 2;
switch test_indx
  case 1 % Random positions, fixed orientations
    x_0 = cat(1, 10 * rand(2 * n_birds, 1),...
      pi / 4 * ones(n_birds, 1));
  case 2 %  position and orientations (randomly defined)
    x_0 = cat(1, zeros(2 * n_birds, 1),...
      linspace(0, 2 * pi, n_birds)');
  case 3 % Random position and orientations
    x_0 = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
      2*pi * (rand(n_birds, 1) - 0.5));
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
%% Jacobian with finite differences
Jacobian = eval_Jf_FiniteDiff(eval_f, x_0, params, input);
% Reference Jacobian
JacobianRef = eval_Jf_FiniteDifference('eval_f', x_0, params, input);
figure(1), imagesc(Jacobian), axis image, colorbar
ylabel('f_i'), xlabel('x_i'), 
figure(2), imagesc(JacobianRef), axis image, colorbar
ylabel('f_i'), xlabel('x_i'), 
figure(3), imagesc(Jacobian - JacobianRef), axis image, colorbar
ylabel('f_i'), xlabel('x_i'), 
% Prinf mean differences +- standard deviation
fprintf('Diference between Jacobians: %.3e +- %.3e\n',...
  mean(Jacobian - JacobianRef, 'all'), std(Jacobian - JacobianRef, [], 'all'))

if 0
  %% Analyze error on FD Jacobian for different dx
  k = 1;
  clear dx error
  for n = -30:.1:15
    dx(k)  = 10^(n);
    params.dxFD = dx(k);
    params.epsilon = dx(k);
    Jf_FiniteDifference = eval_Jf_FiniteDiff(eval_f, x_0, params, input);
    Jf_FiniteDifferenceRef = eval_Jf_FiniteDifference(eval_f, x_0, params, input);
    error(k) = max(max(abs(Jf_FiniteDifference - Jf_FiniteDifferenceRef)));
    k = k+1;
  end
  figure(4), loglog(dx,error, 'b-', 'markersize', 20),
  grid on, grid minor, xlabel('dxFD')
  legend('|| J_{FD}-J_{an} ||'),
  title('Difference between custom and reference FD Jacobians')
end