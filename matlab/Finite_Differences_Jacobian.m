function Jacobian = Finite_Differences_Jacobian(eval_f, x_0, p, u)
% Inputs:
%   eval_f    : Function to evaluate (either string name or function handler)
%   x_0       : Where to evaluate the Jacobian at
%   parms     : Struct with parameter need for potential_func and (optionally) epsilon
%   u         : Input
%
% Ouput:
%   Jacobian  : Finite differences Jacobian
%

% Defualt epsilon
if ~isfield(p, 'epsilon')
%   dx = sqrt(eps);
  dx = 2 * sqrt(eps) * sqrt(1 + norm(x_0, inf)); % used in NITSOL solver
else
  dx = p.epsilon;
end
% Length of x0
N = length(x_0);
% Unitary vectors e
x_unit_all = eye(N);
% Function at x0
fx0 = feval(eval_f, x_0, p, u);
% Iterate over columns
for i = 1:N
  % Unitary vector dx*e for current row
  x_unit = x_unit_all(:, i);
  % Function at x0 + dx*e
  fx = feval(eval_f, x_0 + (dx * x_unit), p, u);
  % Jacobian
  Jacobian(:, i) = 1 / dx * (fx - fx0);
end