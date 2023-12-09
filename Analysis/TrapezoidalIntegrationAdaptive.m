function [X, t, Y, p, corrF, corrR] = TrapezoidalIntegrationAdaptive(eval_f, x_start, p,eval_u,...
  t_start, t_stop, timestep, method, eval_y, visualize, keepHist, verbosity)
% uses Forward Euler with delay to simulate states model dx/dt=f(x,x'(t-tau),p,u)
% startin from state vector x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a text string defining the name of the function that evaluates f(x,x'(t-tau),p,u)
% eval_u is a text string defining the name of the funciton that evaluates u(t)
% visualize ~= 0 is an optional parameter triggering the generation of intermediate plots of the state
% 
% EXAMPLE
% [X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize);

if verbosity > 1
  verbosityNewton = 1;
  if verbosity > 2
    verbosityNewton = 2;
  end
  if verbosity > 3
    verbosityNewton = 3;
  end
else
  verbosityNewton = 0;
end

% Use Finite Differences Jacobian:
if strcmp(method, 'FD')
  eval_Jf_Trap = [];
  FiniteDifference = true;
end

% Default 1 frame per second
if isempty(p.vis.plotFPS)
  plotStep = ceil(1 / (1 * timestep(1)));
else
  plotStep = ceil(1 / (p.vis.plotFPS * timestep(1)));
end

% Initialize solution, output and time
X(:,1) = x_start;
[Y(:,1), corrF(:, :, 1), corrR(:, 1)] = feval(eval_y, X(:,1), p, true);
t(1)   = t_start;
% Initialize video
frames = [];

% Convert kappa from time to integer
% p.kappa = p.kappa / timestep;
% Initial accelerations, constant for all birds and time steps
% p.a = zeros(2 * p.n_birds, p.kappa + 1);

% Show initial flock
if visualize
  frames = VisualizeFlock(t(1), X(:, 1), Y, p.vis, visualize, frames, true);
end
% Initialize percentage to show progress
if ~isfield(p, 'progstep') || isempty(p.progstep)
  p.progstep = 10;
end
percent = p.progstep;

update_a_rate = 1 / timestep(1);
compute_corr_rate = 1 / timestep(1);
p.update_a = false;

% Initial dt
dt = timestep(1);
n = 0;
oldXNorm = norm(x_start, inf);
while t(end) <= t_stop
  n = n + 1;
  % If keeping history in workspace
  % Input u(t)
  u           = feval(eval_u, t(end), p);
  % Evaluate function at current t and X
  [f, p]      = feval(eval_f, X(:,end), p, u);
  % Initialize FTrap to be solved with Newton
  X0          = X(:,end) + dt * f;
  gamma_      = X(:,end) + dt / 2 * f;
  eval_f_Trap = @(x_, p_, u_) x_ - dt / 2 * feval(eval_f, x_, p_, u_) - gamma_;
  % Use Closed-form Jacobian
  if strcmp(method, 'CF') 
    eval_Jf_Trap = @(x_, p_, u_) eye(size(X, 1)) - dt / 2 * feval(p.eval_Jf, x_, p_, u_);
    FiniteDifference = false;
  end
  % Solve for X(n+1) with newton
  if strcmp(method, 'FD') || strcmp(method, 'CF')  % Use Newton with Jacobian Matrix
    X_newton = NewtonNd(eval_f_Trap, X0, p, u, p.Newton.errF,...
      p.Newton.errDeltax, p.NewtonrelDeltax, p.Newton.MaxIter,...
      false, FiniteDifference, eval_Jf_Trap, verbosityNewton);
  elseif strcmp(method, 'MF') % Use Newton without Jacobian matrix
    X_newton = NewtonGCR(eval_f_Trap, X0, p, u, p.Newton.errF,...
      p.Newton.errDeltax,  p.Newton.relDeltax, p.Newton.MaxIter,...
      false, false, [], verbosityNewton, p.Newton.tolrGCR, p.Newton.epsMF);
  else
    error(spintf('Method %s is not a valid method, please use FD, CF or MF', 'method'))
  end
  % Adapt delta t
  relDeltaX = abs(oldXNorm - norm(X_newton, inf));
  oldXNorm = norm(X_newton, inf);
  dt = timestep(1) + (timestep(2) - timestep(1)) * exp(-relDeltaX)

  % Update acceleration matching
  %   p.a = cat(2, p.a(:, end-p.kappa+1:end), p.currentAM);
%   p = UpdateAccelerationHistory(f, p);
  if keepHist
    X(:,n+1) = X_newton;
    t(n+1)   = t(n) + dt;
    t(n+1)
  else
    X        = X_newton;
    t        = t + dt;
  end
  if mod(n, compute_corr_rate) == 0
    [Y(:,n+1), corrF(:, :, n+1), corrR(:, (n / compute_corr_rate) + 1)] =...
    feval(eval_y, X(:,end), p, true);
  else
    Y(:,n+1) = feval(eval_y, X(:,end), p, false);
  end
  % Visualize flock
  if visualize && mod(n, plotStep) == 0
    frames = VisualizeFlock(t(end), X(:, end), Y(:, end), p.vis, visualize, frames, false);
  end

  % Print progress
  if verbosity
    if t(end) / (t_stop-t_start) >= (percent / 100)
      fprintf('%d%s, ', percent, '%')
      percent = percent + p.progstep;
    end
  end
end
if visualize
  if ~isempty(p.vis.vid_filename)
    % Play speed 10 fps
    framerate = length(frames) / t_stop * 6;
    WriteFlockVisualization(frames, framerate, ...
      sprintf('%s_dt_%.0e.avi', p.vis.vid_filename, timestep))
  end
end
