function [X,t] = ForwardEulerWDelay(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize)
% uses Forward Euler with delay to simulate states model dx/dt=f(x,x'(t-tau),p,u)
% startin from state vector x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a text string defining the name of the function that evaluates f(x,x'(t-tau),p,u)
% eval_u is a text string defining the name of the funciton that evaluates u(t)
% visualize ~= 0 is an optional parameter triggering the generation of intermediate plots of the state
% 
% EXAMPLE
% [X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize);

max_delay = p.kappa;
X(:,1:max_delay+1) = x_start;
t(max_delay+1)   = t_start;
N = p.n_birds;
if visualize
%    VisualizeState(t,X,1,'.b');
end
for n = max_delay + (1 : ceil((t_stop-t_start)/timestep)),
   dt       = min(timestep, (t_stop-t(n)));
   t(n+1)   = t(n) + dt;
   u        = feval(eval_u, t(n));
   f        = feval(eval_f, X(:,n-max_delay:n), p, u);
   X(1:4*N,n+1) = X(1:4*N,n) +  dt * f(1:4*N);
   X(4*N+1:end,n+1) = f(4*N+1:end);
   if visualize && mod(n, 4) == 0
%      VisualizeState(t,X,n+1,'.b');
     VisualizeFlockLJ(t(n+1), X(1:4*N, n+1), p, 2);
   end
end