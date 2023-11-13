function Jacobian = eval_Jf_FiniteDiff(eval_f, x_0, parms, u)
% Defualt epsilon
if ~isfield(parms, 'epsilon')
  dx = sqrt(eps);
else
  dx = parms.epsilon;
end
% Length of x0
N = length(x_0);
% Unitary vectors e
x_unit_all = eye(N);
% Function at x0
fx0 = feval(eval_f, x_0, parms, u);
% Iterate over columns
for i = 1:N
  % Unitary vector dx*e for current row
  x_unit = x_unit_all(:, i);
  % Function at x0 + dx*e
  fx = feval(eval_f, x_0 + (dx * x_unit), parms, u);
  % Jacobian
  Jacobian(:, i) = 1 / dx * (fx - fx0);
end

%changed all 'p's to 'parms'