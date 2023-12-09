function [Xout, tout, Y, p, corrF, corrR] = TrapezoidalIntegrationWDelay(eval_f, x_start, p,eval_u,...
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
  plotStep = ceil(1 / (1 * timestep));
else
  plotStep = ceil(1 / (p.vis.plotFPS * timestep));
end

% Initialize solution, output and time
X(:,1) = x_start;
Xout(:,1) = x_start;
p.n_neighborhood = [];
[Y(:,1), corrF(:, :, 1), corrR(:, 1)] = feval(eval_y, Xout(:,1), p, true);
t(1)   = t_start;
% Initialize video
frames = [];

% Convert kappa from time to integer
% p.kappa = p.kappa / timestep;
% Initial accelerations, constant for all birds and time steps
% p.a = zeros(2 * p.n_birds, p.kappa + 1);

% Show initial flock
if visualize
  frames = VisualizeFlock(t(1), Xout(:, 1), Y, p.vis, visualize, frames, true);
end
% Initialize percentage to show progress
if ~isfield(p, 'progstep') || isempty(p.progstep)
  p.progstep = 10;
end
percent = p.progstep;

update_a_rate = round(0.1 / timestep);
compute_XY_rate = round(0.1 / timestep); 
p.update_a = true;
p.curA = p.a(:, end);
p = UpdateAccelerationHistory(x_start, p);

for n = 1 : ceil((t_stop-t_start)/timestep),
  % Current index for history of state vectors and outputs
  m = n / compute_XY_rate;
  % If keeping history in workspace
  % Delta t
  dt          = min(timestep, (t_stop-t(end)));
  % Input u(t)
  u           = feval(eval_u, t(end), p);
  % Evaluate function at current t and X
  [f, p]      = feval(eval_f, Xout(:,end), p, u);
%   p.update_a = false;
  % Initialize FTrap to be solved with Newton
  X0          = X + dt * f;
  gamma_      = X + dt / 2 * f;
  eval_f_Trap = @(x_, p_, u_) x_ - dt / 2 * feval(eval_f, x_, p_, u_) - gamma_;
  % Use Closed-form Jacobian
  if strcmp(method, 'CF') 
    eval_Jf_Trap = @(x_, p_, u_) eye(size(Xout, 1)) - dt / 2 * feval(p.eval_Jf, x_, p_, u_);
    FiniteDifference = false;
  end
  % Solve for X(n+1) with newton
  if strcmp(method, 'FD') || strcmp(method, 'CF')  % Use Newton with Jacobian Matrix
    X = NewtonNd(eval_f_Trap, X0, p, u, p.Newton.errF,...
      p.Newton.errDeltax, p.NewtonrelDeltax, p.Newton.MaxIter,...
      false, FiniteDifference, eval_Jf_Trap, verbosityNewton);
  elseif strcmp(method, 'MF') % Use Newton without Jacobian matrix
    X = NewtonGCR(eval_f_Trap, X0, p, u, p.Newton.errF,...
      p.Newton.errDeltax,  p.Newton.relDeltax, p.Newton.MaxIter,...
      false, false, [], verbosityNewton, p.Newton.tolrGCR, p.Newton.epsMF);
  else
    error(spintf('Method %s is not a valid method, please use FD, CF or MF', 'method'))
  end
  t = t + dt;
  % Update acceleration matching and delays
  if mod(n, update_a_rate) == 0
    p.update_a = true;
  else
    p.update_a = false;
  end
  p = UpdateAccelerationHistory(X, p);
  % Update X and Y
  if keepHist && mod(n, compute_XY_rate) == 0
    Xout(:,m+1) = X;
    tout(m+1)   = t;
  end
  if mod(n, compute_XY_rate) == 0
    [Y(:,m+1), corrF(:, :, m+1), corrR(:, m+1)] =...
    feval(eval_y, X, p, true);
  end
  % Visualize flock
  if visualize && mod(n, plotStep) == 0
    frames = VisualizeFlock(t(end), X, Y(:, end), p.vis, visualize, frames, false);
  end

  % Print progress
  if verbosity
    if t(end) / (t_stop-t_start) >= (percent / 100)
      fprintf('%d%s, ', percent, '%')
      percent = percent + p.progstep;
    end
  end
end
if ~keepHist
  Xout = X;
  tout = t;
end
% Move out of GPU
if p.useGPU
  Xout = gather(Xout);
end

if visualize
  if ~isempty(p.vis.vid_filename)
    % Play speed 10 fps
    framerate = length(frames) / t_stop * 6;
    WriteFlockVisualization(frames, framerate, ...
      sprintf('%s_dt_%.0e.avi', p.vis.vid_filename, timestep))
  end
end
