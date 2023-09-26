 function [pos, vel, dir, informSubjs] = UpdatePosition(curPos, curVel, curDir,...
  timeStep, neighRadius, dirFlucRange, informSubjs, informDir, addInformSub)

 % Number of subject
 nSubjects = size(curPos, 2);

 % Matrix with current directions
% curDirMat = squeeze(repmat(curDir, [1, 1, size(curDir)]));

% Create mask with closest neighbors
distances = sum((curPos - permute(curPos, [1 3 2])) .^ 2, 1);
closestNeigh = single(squeeze(distances < neighRadius ^ 2));
closestNeigh(~closestNeigh) = nan;
% figure2(30), imagescnan(sqrt(squeeze(distances)), [-pi pi]),
% figure2(31), imagescnan(closestNeigh, [-pi pi]),
% colormap(cmap('c3')), colorbar
% figure2(3), imagescnan(squeeze(curDir) .* closestNeigh, [-pi pi]),
% colormap(cmap('c3')), colorbar

% Average direction of neighborhoods
aveDir = angle(sum(exp(1i * squeeze(curDir) .* closestNeigh), 2, 'omitnan'))';
% figure2(4), imagescnan(aveDir, [-pi pi]), colormap(cmap('c3')), colorbar

% Compute new direction
dirFluctuation = 2 * dirFlucRange * (rand(1, nSubjects) - 0.5);

% Update orientations
dir = aveDir + dirFluctuation;
% Add informed subjects
if addInformSub
%   informSubjs = randperm(nSubjects, nInformSub);
  dir(informSubjs) = dir(informSubjs) + informDir;
end
% Update velocities
vel = vecnorm(curVel, 2, 1) .* [cos(dir); sin(dir)];
% Update position
pos = curPos + vel * timeStep;
