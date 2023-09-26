function Jacobian = eval_Jf_FiniteDiff(eval_f, x_null, p, u)

if ~isfield(p, 'epsilon')
  dx = sqrt(eps);
else
  dx = p.epsilon;
end

N = length(x_null);
x_unit_all = eye(N);
fx0 = feval(eval_f, x_null, p, u);

for i = 1:N
  x_unit = x_unit_all(:, i); 
  fx = feval(eval_f, x_null + dx * x_unit, p, u);
  Jacobian(:, i) = 1 / dx * (fx - fx0);
end