function [x, r_norms] = tgcr_MatrixFree(eval_f,xf,pf,uf,b,tolrGCR,MaxItersGCR,epsMF,verbosity)
% Generalized conjugate residual method for solving [df/dx] x = b 
% using a matrix-free (i.e. matrix-implicit) technique
% INPUTS
% eval_f     : name of the function that evaluates f(xf,pf,uf)
% xf         : state vector where to evaluate the Jacobian [df/dx]
% pf         : structure containing parameters used by eval_f
% uf         : input needed by eval_f
% b          : right hand side of the linear system to be solved
% tolrGCR    : convergence tolerance, terminate on norm(b - Ax) / norm(b) < tolrGCR
% MaxItersGCR: maximum number of iterations before giving up
% epsMF      : finite difference perturbation for Matrix Free directional derivative
% OUTPUTS
% x          : computed solution, returns null if no convergence
% r_norms    : vector containing ||r_k||/||r_0|| for each iteration k
%
% EXAMPLE:
% [x, r_norms] = tgcr_MatrixFree(eval_f,x0,b,tolrGCR,MaxItersGCR,epsMF)

if ~exist('verbosity', 'var') || isempty(verbosity)
  verbosity = true;
end

if verbosity > 1
  fprintf('GCR Iter (of %d): ', MaxItersGCR)
end
% Generate the initial guess for x at itearation k=0
x = zeros(size(b));

% Set the initial residual to b - Ax^0 = b
r = b;
r_norms(1) = norm(r,2);

k = 0;

while (r_norms(k+1)/r_norms(1) > tolrGCR) & (k <= MaxItersGCR)
  if verbosity > 1
    fprintf('%d, ', k)
  end
   k=k+1;
   % Use the residual as the first guess for the ne search direction 
   % and computer its image
   p(:,k) = r;
   
   %The following three lines are an approximation for Ap(:, k) = A * p(:,k);
   %------- START MATRIX-FREE MODIFICATION ----------------------------------
   %Usually best to normalize to ||x|| and ||p|| the given value epsMF:
   %epsilon=                       epsMF;                 %not working well!!!
   %epsilon=                       epsMF/norm(p(:,k),inf);%already ok
   %epsilon=  epsMF*    (1+norm(xf,inf))/norm(p(:,k),inf);%great
    epsilon=2*epsMF*sqrt(1+norm(xf,inf))/norm(p(:,k),inf);%NITSOL normal. great<--
   %Can also try to pick a value automatically:
   %epsilon=                      pf.dxFD/norm(p(:,k),inf);% an ok idea
   %epsilon=2*sqrt(eps)*(1+norm(xf,inf)) /norm(p(:,k),inf); % ok
   %epsilon=2*sqrt(eps *(1+norm(xf,inf)))/norm(p(:,k),inf);% NITSOL value (ok)
   
   fepsMF  = feval(eval_f,xf+epsilon*p(:,k),pf,uf);
   f       = feval(eval_f,xf,             pf,uf);
   Ap(:,k) = (fepsMF - f ) / epsilon; 
   %--------- END MATRIX-FREE MODIFICATION ----------------------------------
   
  % Make the new Ap vector orthogonal to the previous Ap vectors,
  % and the p vectors A^TA orthogonal to the previous p vectors.
  % Notice that if you know A is symmetric
  % you can save computation by limiting the for loop to just j=k-1
  % however if you need relative accuracy better than  1e-10
  % it might be safer to keep full orthogonalization even for symmetric A
  if k >1
     for j = 1:k-1
       beta    = Ap(:,k)' * Ap(:,j);
       p(:,k)  =  p(:,k) - beta *  p(:,j);
       Ap(:,k) = Ap(:,k) - beta * Ap(:,j);
     end;
  end
     
  % Make the orthogonal Ap vector of unit length, and scale the
  % p vector so that A * p  is of unit length
  norm_Ap = norm(Ap(:,k),2);
  Ap(:,k) = Ap(:,k)/norm_Ap;
   p(:,k) =  p(:,k)/norm_Ap;

  % Determine the optimal amount to change x in the p direction
  % by projecting r onto Ap
  alpha = r' * Ap(:,k);

  % Update x and r
  x = x + alpha *  p(:,k);
  r = r - alpha * Ap(:,k);

  % Save the norm of r
  r_norms(k+1) = norm(r,2);

  % Print the norm during the iteration
  % fprintf('||r||=%g i=%d\n', norms(k+1), k+1);
end

% Notify user of convergence
if verbosity
  if r_norms(k+1) > (tolrGCR * r_norms(1))
    fprintf(1, 'GCR did NOT converge! Maximum Number of Iterations reached\n');
    x = [];
  else
    fprintf(1, 'GCR converged in %d iterations\n', k);
  end
end
% Scale the r_norms with respect to the initial residual norm
r_norms = r_norms / r_norms(1);
