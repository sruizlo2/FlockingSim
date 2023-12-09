function [x, f, converged, errf_k, errDeltax_k, relDeltax_k, iterations, X] =...
  NewtonGCR(eval_f, x0, p, u, errf, errDeltax, relDeltax, MaxIter,...
  visualize, FiniteDifference, eval_Jf, verbosity, tolrGCR, epsMF)
% uses Newton Method to solve the VECTOR nonlinear system f(x)=0
% uses GCR to solve the linearized system at each iteration
% x0         is the initial guess for Newton iteration
% p          is a structure containing all parameters needed to evaluate f( )
% u          contains values of inputs 
% eval_f     is a text string with name of function evaluating f for a given x 
% eval_Jf    is a text string with name of function evaluating Jacobian of f at x (i.e. derivative in 1D)
% FiniteDifference = 1 forces the use of Finite Difference Jacobian instead of given eval_Jf
% errF       = absolute equation error: how close do you want f to zero?
% errDeltax  = absolute output error:   how close do you want x?
% relDeltax  = relative output error:   how close do you want x in perentage?
% note: 		 declares convergence if ALL three criteria are satisfied 
% MaxItersGCR= maximum number of iterations allowed
% visualize  = 1 shows intermediate results
% tolrGCR   = residual tolerance target for GCR
% epsMF     (OPTIONAL) perturbation for directional derivative for matrix-free Newton-GCR
%
% EXAMPLES:
% [x,converged,errf_k,errDeltax_k,relDeltax_k,iterations] = NewtonNd(eval_f,x0,p,u,errf,errDeltax,relDeltax,MaxIter,visualize,FiniteDifference,eval_Jf,tolrGCR)
% [x,converged,errf_k,errDeltax_k,relDeltax_k,iterations] = NewtonNd(eval_f,x0,p,u,errf,errDeltax,relDeltax,MaxIter,visualize,FiniteDifference,eval_Jf,tolrGCR,epsMF)

if ~exist('verbosity', 'var') || isempty(verbosity)
  verbosity = true;
end

if verbosity > 1
  vebosityGCR = 1;
  if verbosity > 2
    vebosityGCR = 2;
  end
else
  vebosityGCR = 0;
end

N           = length(x0);
%MaxItersGCR = max(N,round(N*0.2));     
MaxItersGCR = N*1.1; 

k           = 1;                         % Newton iteration index
X(:,k)      = x0;                        % X stores intermetiade solutions as columns

f           = feval(eval_f,X(:,k),p,u);
errf_k 	   = norm(f,inf);


errDeltax_k = Inf;
relDeltax_k = Inf;

if visualize
   VisualizeState(1,X,1,'.b');
end

while k<=MaxIter & (errf_k>errf | errDeltax_k>errDeltax | relDeltax_k>relDeltax),
   
   if exist('epsMF','var')
      Deltax = tgcr_MatrixFree(eval_f,X(:,k),p,u,-f,tolrGCR,MaxItersGCR,epsMF,vebosityGCR); % uses matrix-free
   else
      if FiniteDifference
         Jf = eval_Jf_FiniteDifference(eval_f,X(:,k),p,u);
      else 
         Jf = feval(eval_Jf,X(:,k),p,u);
      end
      Deltax = tgcr(Jf,-f,tolrGCR,MaxItersGCR); % gcr WITHOUT matrix-free
   end

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

x = X(:,k);    % returning only the very last solution

% returning the number of iterations with ACTUAL computation
% i.e. exclusing the given initial guess
iterations = k-1; 

if verbosity
  if errf_k<=errf & errDeltax_k<=errDeltax & relDeltax_k<=relDeltax
    converged = 1;
    fprintf(1, 'Newton converged in %d iterations\n', iterations);
  else
    converged=0;
    fprintf(1, 'Newton did NOT converge! Maximum Number of Iterations reached\n');
  end
  fprintf('ferror = %.1e | dxerror = %.1e | rdxerror = %.1e\n',...
    errf_k, errDeltax_k, relDeltax_k)
end
