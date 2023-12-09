function [C, Csp] = CorrelationFunction(drnorm, vxy, parms)

% Velocity fluctuation around the mean value
uxy = vxy - mean(vxy, 1);
% Speed fluctuation around the mean value
phi = sqrt(sum(vxy .^ 2, 2));
phi = phi - mean(phi, 1);
% Create vector of distances r to evaluate correlation
rvect = linspace(parms.r0, parms.maxRCorr, parms.NCorr);
% Cluster the observed distances drnorm into rvect
[~, rindxs] = max((drnorm - rvect) <= 0, [], 2);
indxs = 1:parms.NCorr;
% 
rindxs(drnorm > parms.maxRCorr) = parms.NCorr + 1;
% Matrix delta with 1's in the corresponding index
deltaMat = rindxs == indxs;
deltaMatSum = sum(deltaMat, [1 3]);
% Velocity correlation function
C = sum(permute(pagemtimes(uxy, uxy'), [1 3 2]) .* deltaMat, [1 3])...
  ./ deltaMatSum;
% Normalize so that C(0) = 1
C = C ./ C(1);
% Speed correlation function
Csp = sum(permute(phi .* phi', [1 3 2]) .* deltaMat, [1 3])...
  ./ deltaMatSum;
% Normalize so that C(0) = 1
Csp = Csp ./ Csp(1);
if parms.useGPU
  C = gather(C);
  Csp = gather(Csp);
end
% figure(1), plot(rvect, C, 'r'), hold on
% plot(rvect, Csp, 'k--'), hold off, ylim([-1 1]), xlim([0 parms.maxRCorr])