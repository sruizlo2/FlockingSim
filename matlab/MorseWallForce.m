function forces = MorseWallForce(potential_func, parms, x_0, u)
% Inputs:
%   potential_func : Function to evaluate potential (either string name or function handler)
%   parms          : Struct with parameters needed for potential_func
%   x_0            : Where to evaluate the Jacobian at
%   u              : Input
%
% Ouput:
%   forces         : Finite differences approximation to the force
%

% Compuate minus Jacobian of the potential  to get the force
forces = -Finite_Differences_Jacobian(potential_func, x_0, parms, u);
N = size(forces, 1);
% And extract the gradient from the Jacobian
forces = cat(1, diag(forces(1:N, 1:N)), diag(forces(1:N, N + (1:N))));