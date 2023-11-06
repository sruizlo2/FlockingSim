function parms = NormalizeParameters(parms, ls, ts)
parms.Ca = parms.Ca * (ls * ts ^ 2);
parms.Cr = parms.Cr * (ls ^ 2 / ts ^ 2);
parms.lr = parms.lr * ls;
parms.v0 = parms.v0 * (ls / ts);
parms.alpha_ = parms.alpha_ * (ts / ls ^ 2);
parms.Kv = parms.Kv * (ls ^ 4 / ts);
parms.Ka = parms.Ka * (ls ^ 4);