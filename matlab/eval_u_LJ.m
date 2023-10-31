function fOut = eval_u(u, t)
F_mag = 2e2;
F_dir = angle(exp(1i * (atan2(u(2), u(1)) +...
  ((rand() < 0.1) * 2 * pi * (rand() - 0.5)))));
fOut = (F_mag * [cos(F_dir); sin(F_dir)]);