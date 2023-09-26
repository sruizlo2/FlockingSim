n_birds = 10;
n_inform_birds = 1e2;
timestep = 1;
v_init = 1;
x_null = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
  2*pi * (rand(n_birds, 1) - 0.5));

params = struct('neighRadius', 10, 'dirFlucRange', 0.1,...
  'n_birds', n_birds, 'timestep', timestep, 'v_init', 1,...
  'add_inform_birds', 1);

params.epsilon = sqrt(eps);
params.dxFD = sqrt(eps);

input = 0;

Jacobian = eval_Jf_FiniteDiff('eval_f', x_null, params, input);
figure(1), imagesc(Jacobian), axis image, colorbar
JacobianRef = eval_Jf_FiniteDifference('eval_f', x_null, params, input);
figure(2), imagesc(JacobianRef), axis image, colorbar
figure(3), imagesc(Jacobian - JacobianRef), axis image, colorbar
