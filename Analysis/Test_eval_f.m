addpath(genpath('../matlab'))
n_birds = 1e3;
n_inform_birds = 1e2;
x_start = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
  2*pi * (rand(n_birds, 1) - 0.5));
% x_start = cat(1, 20 * (rand(2 * n_birds, 1) - 0.5),...
%   pi / 4 * ones(n_birds, 1));
eval_f = 'eval_f';
eval_u = 'eval_u';
timestep = 0.5;
t_start = 0;
t_points = 100;
t_stop = timestep * t_points;
inform_birds = randperm(n_birds, n_inform_birds);
params = struct('neighRadius', 10, 'dirFlucRange', 0.1,...
  'n_birds', n_birds, 'timestep', timestep, 'v_init', 1,...
  'add_inform_birds', 1, 'inform_birds', inform_birds, 'inform_dir', 0);
[X,t] = ForwardEuler(eval_f, x_start, params, eval_u, t_start,t_stop,timestep, true);
