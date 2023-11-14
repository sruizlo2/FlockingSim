function fOut = eval_f_CSModel_Newton(x, parms, u)
% Unpack options
StructToVars(parms)

% Input x is [x, y vx, vy]
% Current positions [rx ry]
r = x(1:2 * n_birds);
% % Current velocity [vx vy]
% v = zeros((4 * n_birds)-(2 * n_birds),1);
% disp('v')
% disp(v)
% size(v)
% 
% % [drx, dry] and |dr|
[~, dr, drnorm] = ReshapeAndPairWiseDifferences(r);
% 

% Current acceleration [ax ay] to update dv/dt = f
a = MorseWallForceAnalytical(dr, drnorm, parms, u); % Force due to attractive and repulsive potentials % Morse_Wall_Force(potential_func, parms, r, u)
%fOut = cat(1, v, a);
fOut = a;
