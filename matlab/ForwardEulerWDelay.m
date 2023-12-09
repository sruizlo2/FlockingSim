function [Xout, tout, Y, corrF, corrR, p] = ForwardEulerWDelay(eval_f, x_start, p,eval_u,...
  t_start, t_stop, timestep, visualize, keepHist, verbosity)
% uses Forward Euler with delay to simulate states model dx/dt=f(x,x'(t-tau),p,u)
% startin from state vector x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a text string defining the name of the function that evaluates f(x,x'(t-tau),p,u)
% eval_u is a text string defining the name of the funciton that evaluates u(t)
% visualize ~= 0 is an optional parameter triggering the generation of intermediate plots of the state
% 
% EXAMPLE
% [X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize);

% Default 1 frame per second
if isempty(p.vis.plotFPS)
  plotStep = ceil(1 / (1 * timestep));
else
  plotStep = ceil(1 / (p.vis.plotFPS * timestep));
end
% Initialize solution, output and time
X(:,1) = x_start;
p.n_neighborhood = [];
p.timedelays = [];
[Y(:,1), corrF(:, :, 1), corrR(:, 1)] = ComputeOutputs(X(:,1), p, true);
t(1)   = t_start;
% Number of birds
N = p.n_birds;
% Initialize video
frames = [];

% Show initial flock
if visualize
  VisualizeFlock(t(1), X(1:4*N, 1), Y, p.vis, visualize, frames, true);
end
% Initialize percentage to show progress
if ~isfield(p, 'progstep') || isempty(p.progstep)
  p.progstep = 10;
end
percent = p.progstep;

% Rate to update acceleration history and compute outputs
update_a_rate   = round(0.1 / timestep);
compute_XY_rate = round(0.1 / timestep);
p.update_a = true;

for n = 1 : ceil((t_stop-t_start)/timestep)
  % Current index for history of state vectors and outputs
  m = n / compute_XY_rate;
  % Update acceleration matching and delays
  if mod(n, update_a_rate) == 0
    p.update_a = true;
  end
  % Forward euler
  dt         = min(timestep, (t_stop-t(end)));
  u          = feval(eval_u, X(:,end), t(end), p);
  [f, p]     = feval(eval_f, X(:,end), p, u);
  X          = X + dt * f;
  t          = t + dt;
  p.update_a = false;
  % If keeping history in workspace
  if keepHist && mod(n, compute_XY_rate) == 0
    Xout(:,m+1) = X;
    tout(m+1)  = t;
  end

  if mod(n, compute_XY_rate) == 0
    [Y(:,m+1), corrF(:, :, m+1), corrR(:, m+1)] =...
      ComputeOutputs(X, p, true);
  end

  if visualize && mod(n, plotStep) == 0
    frames = VisualizeFlock(t, X, Y(:, end), p.vis, visualize, frames, false);
  end

  % Print progress
  if verbosity
    if (t(end) - t_start) / (t_stop-t_start) >= (percent / 100)
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
  X = gather(X);
end

if visualize && ~isempty(p.vis.vid_filename)
  % Play speed 10 fps
  framerate = length(frames) / t_stop * 10;
  WriteFlockVisualization(frames, framerate, ...
    sprintf('%s_dt_%.0e.avi', p.vis.vid_filename, timestep))
end
