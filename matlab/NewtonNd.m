function [x,converged,errf_k,errDeltax_k,relDeltax_k,iterations,X] = NewtonNd(eval_f,x0,p,u,errf,errDeltax,relDeltax,MaxIter,visualize,FiniteDifference,eval_Jf)
% uses Newton Method to solve the VECTOR nonlinear system f(x)=0
% x0        is the initial guess for Newton iteration
% p         is a structure containing all parameters needed to evaluate f( )
% u         contains values of inputs 
% eval_f    is a text string with name of function evaluating f for a given x 
% eval_Jf   is a text string with name of function evaluating Jacobian of f at x (i.e. derivative in 1D)
% FiniteDifference = 1 forces the use of Finite Difference Jacobian instead of given eval_Jf
% errF      = absolute equation error: how close do you want f to zero?
% errDeltax = absolute output error:   how close do you want x?
% relDeltax = relative output error:   how close do you want x in perentage?
% note: 		declares convergence if ALL three criteria are satisfied 
% MaxIter   = maximum number of iterations allowed
% visualize = 1 shows intermediate results
%
% OUTPUTS:
% converged   1 if converged, 0 if not converged
% errf_k      ||f(x)||
% errDeltax_k ||X(end) -X(end-1)||
% relDeltax_k ||X(end) -X(end-1)|| / ||X(end)||
% iterations  number of Newton iterations k to get to convergence
%
% EXAMPLE:
% [x,converged,errf_k,errDeltax_k,relDeltax_k,iterations] = NewtonNd(eval_f,x0,p,u,errf,errDeltax,relDeltax,MaxIter,visualize,FiniteDifference,eval_Jf)

k           = 1;                         % Newton iteration index
X(:,k)      = x0;                        % X stores intermetiade solutions as columns

f           = feval(eval_f,X(:,k),p,u);
errf_k      = norm(f,inf);

errDeltax_k = Inf;
relDeltax_k = Inf;

if visualize
   VisualizeState(1,X,1,'.b');
end

while k<=MaxIter & (errf_k>errf | errDeltax_k>errDeltax | relDeltax_k>relDeltax),

   if FiniteDifference
      Jf = eval_Jf_FiniteDifference(eval_f,X(:,k),p,u);
   else 
      Jf = feval(eval_Jf,eval_f,X(:,k),p,u);
   end
   Deltax      = Jf\(-f); %NOTE this is the only difference from 1D to multiD
   X(:,k+1)    = X(:,k) + Deltax;
   k           = k+1;
   f           = feval(eval_f,X(:,k),p,u);
   errf_k      = norm(f,inf);
   errDeltax_k = norm(Deltax,inf);
   relDeltax_k = norm(Deltax,inf)/max(abs(X(:,k)));
   if visualize
      VisualizeState([1:1:k],X,k,'.b');
   end
end

x = X(:,k);    % extracting the very last solution

% returning the number of iterations with ACTUAL computation
% i.e. exclusing the given initial guess
iterations = k-1; 


if errf_k<=errf & errDeltax_k<=errDeltax & relDeltax_k<=relDeltax
   converged = 1;
   if visualize
      fprintf(1, 'Newton converged in %d iterations\n', iterations);
   end
else
   converged = 0;
   fprintf(1, 'Newton did NOT converge! Maximum Number of Iterations reached\n');
end
