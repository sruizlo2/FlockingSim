function [delay, parms] = TimeDelay(drnorm, v, parms)
% Time delay (could be changed to a non-linear function
% delay = min(parms.kappa, round( parms.kappa * (1 - LocalOrder(drnorm, v, parms)) ));
[localOrder, parms] = LocalOrder(drnorm, v, parms);
delay = min(parms.kappa, round( parms.kappa * tanh(1 - localOrder .^ 6) / tanh(1) ));
% Adjust to linear indexes fromm 0 to kappa
delay = parms.kappa - delay;
parms.timedelays = cat(1, parms.timedelays, mean(delay));