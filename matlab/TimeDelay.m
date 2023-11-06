function delay = TimeDelay(dr, v, parms)
% Time delay (could be changed to a non-linear function
delay = min(parms.kappa, round(parms.kappa * (1 - LocalOrder(dr, v, parms))));
% Adjust to linear indexes fromm 0 to kappa
delay = parms.kappa - delay;