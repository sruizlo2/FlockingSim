function [X, t, Y] = TrapezoidalIntegration(eval_f, x_start, p, eval_u,...
  t_start, t_stop, timestep, visualize, method, eval_Jf, verbosity)
% uses Trapezoidal rule to simulate states model dx/dt=f(x,x'(t-tau),p,u)
% startin from state vector x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a text string defining the name of the function that evaluates f(x,x'(t-tau),p,u)
% eval_u is a text string defining the name of the funciton that evaluates u(t)
% visualize ~= 0 is an optional parameter triggering the generation of intermediate plots of the state
% 
% EXAMPLE
% [X,t] = TrapezoidalIntegration(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize);

if verbosity > 1
  verbosityNewton = 1;
else
  verbosityNewton = 0;
end

X(:,1) = x_start;
t(1)   = t_start;
if visualize
  VisualizeState(t,X,1,{'.b'});
end
percent = 10;
for n = 1 : ceil((t_stop-t_start)/timestep),
  dt       = min(timestep, (t_stop-t(n)));
  t(n+1)   = t(n) + dt;
  u        = feval(eval_u, t(n));
  f        = feval(eval_f, X(:,n), p, u);
  X0       = X(:,n);% + dt * f;
  gamma_   = X0 + dt / 2 * f;
  eval_f_Trap   = @(x_, p_, u_) x_ - dt / 2 * feval(eval_f, x_, p_, u_) - gamma_;

  if strcmp(method, 'FD')
    eval_Jf_Trap = [];
    FiniteDifference = true;
  elseif strcmp(method, 'CF')
    eval_Jf_Trap = @(x_, p_, u_) eye(size(X, 1)) - dt / 2 * feval(eval_Jf, x_, p_, u_);
    FiniteDifference = false;
  end
  if strcmp(method, 'FD') || strcmp(method, 'CF')
    X(:,n+1) = NewtonNd(eval_f_Trap, X0, p, u, p.errF, p.errDeltax,...
      p.relDeltax, p.MaxIter, visualize, FiniteDifference, eval_Jf_Trap, verbosityNewton);
  elseif strcmp(method, 'MF')
    FiniteDifference = false;
    X(:,n+1) = NewtonGCR(eval_f_Trap, X0, p, u, p.errF, p.errDeltax,...
      p.relDeltax, p.MaxIter, visualize, FiniteDifference, [],...
      verbosityNewton, p.tolrGCR, p.epsMF);
  else
    error(srpintf('Method %s is not a valid method, please use FD, CF or MF', 'method'))
  end
  if visualize
    VisualizeState(t,X,n+1, {'.b'});
  end
  if verbosity
    if t(n+1) / (t_stop-t_start) >= (percent / 100)
      fprintf('%d%s, ', percent, '%')
      percent = percent + 10;
    end
  end
end
if verbosity
  fprintf(' Done!\n')
end