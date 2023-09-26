function [Jf,dxFD] = eval_Jf_FiniteDifference(eval_f,x0,p,u)
% evaluates the Jacobian of the vector field f( ) at state x0
% p is a structure containing all model parameters
% u is the value of the imput at the curren time
% uses a finite difference approach computing one column k at the time
% as difference of function evaluations perturbed by scalar p.dxFD 
% Jf(:,k) = (f(x0+p.dxFD) - f(x0)) / p.dxFD
% if p.dxFD is NOT specified, 
%    uses NITSOL value p.dxFD = 2*sqrt(eps)*max(1,norm(x))
%
% EXAMPLES:
% Jf        = eval_Jf_FiniteDifference(eval_f,x0,p,u);
% [Jf,dxFD] = eval_Jf_FiniteDifference(eval_f,x0,p,u);


N  = length(x0);
f_x0 = feval(eval_f,x0,p,u);

if isfield(p,'dxFD')
   dxFD = p.dxFD;                     %if user specified it: use that
else
   %dxFD=sqrt(eps);                   %works ok in general if ||x0|| not huge
   %dxFD=2*sqrt(eps)*(1+norm(x0,inf));    %correction for ||x0|| very large (works best)
   %dxFD=2*sqrt(eps)*max(1,norm(x0,inf)); %similar correctly for large ||x0|| 
   dxFD=2*sqrt(eps)*sqrt(1+norm(x0,inf));     % used in NITSOL solver
   %dxFD=2*sqrt(eps)*sqrt(max(1,norm(x0,inf)));% similar to NITSOL
   disp(['dxFD not specified: using 2*sqrt(eps)*sqrt(1+||x||) = ' num2str(dxFD)])
end

for k = 1:N,                        % for each column of the Jacobian
   xk      = x0;
   xk(k)   = x0(k) + dxFD; 
   f_xk    = feval(eval_f,xk,p,u);
   Jf(:,k) = (f_xk - f_x0)/dxFD;
end



