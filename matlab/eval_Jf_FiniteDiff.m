function Jacobian = eval_Jf_FiniteDiff(eval_f, x_0, p, u)
% Defualt epsilon
if ~isfield(p, 'epsilon')
  dx = sqrt(eps);
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