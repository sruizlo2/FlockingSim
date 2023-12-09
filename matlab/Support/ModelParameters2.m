function parms = ModelParameters2()

% Model parameters
parms.Ca = 3.0e-7;    % Effective distance of the attraction
parms.Cr = 0.5;       % Strength of the short-range repulsion
parms.lr = 0.15;      % Effective distance of the repulsion
parms.v0 = 1.00;      % Terminal speed
parms.alpha_ = 0.2;   % Strenght of drag force
parms.Kv = 0.1;       % Interaction strength of velocity matching
parms.Ka = 0.12;      % Interaction strength of acceleration matching
parms.kappa = 800;    % Maximum time delay for acceleration matching (in 1/10 seconds)
parms.r0 = 0.6;       % Minimum distance to compuate variance in local order computation
parms.c0 = 10;        % Scale factor for variance
parms.lo_method = 'var'; % Method to compute local order. 'var' for variance, 'pol' for polarization
% Parameters for computer correlation function
parms.NCorr = 50; % Length of correlation fuction
parms.maxRCorr = 25; % Maximum distance to compute correlation