function parms = NormalizeParameters(parms, ls, ts, dir)
switch dir
  case 'fw'
    parms.Ca = parms.Ca / (ls * ts ^ 2);
    parms.Cr = parms.Cr / (ts ^ 2 / ls ^ 2);
    parms.lr = parms.lr / (1 / ls);
    parms.v0 = parms.v0 / (ts / ls);
    parms.alpha_ = parms.alpha_ / (ls ^ 2 / ts);
    parms.Kv = parms.Kv / (ts / ls ^ 4);
    parms.Ka = parms.Ka / (1 / ls ^ 4);
  case 'bw'
    parms.Ca = parms.Ca * (ls * ts ^ 2);
    parms.Cr = parms.Cr * (ts ^ 2 / ls ^ 2);
    parms.lr = parms.lr * (1 / ls);
    parms.v0 = parms.v0 * (ts / ls);
    parms.alpha_ = parms.alpha_ * (ls ^ 2 / ts);
    parms.Kv = parms.Kv * (ts / ls ^ 4);
    parms.Ka = parms.Ka * (1 / ls ^ 4);
end
