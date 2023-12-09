function [corrR, corrRsp] = CorrelationDistance(C, Csp, parms)
C(isnan(C)) = 0;
Csp(isnan(Csp)) = 0;
C = interpft(C, parms.NCorr * 10);
Csp = interpft(Csp, parms.NCorr * 10);
% Create vector of distances r to evaluate correlation
rvect = linspace(parms.r0, parms.maxRCorr, parms.NCorr * 10);
% Correlation distances for velocity fluctuations
[~, corrR] = max(C <= 0);
corrR = rvect(corrR - 1);
% Correlation distances for speed fluctuations
[~, corrRsp] = max(Csp <= 0);
corrRsp = rvect(corrRsp - 1);
% figure(1), xline(corrR, 'r'), xline(corrRsp, 'k'), drawnow
