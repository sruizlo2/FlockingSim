addpath(genpath('../matlab'))
nSubjects = 1e3;
nInformSub = 0;

% curPos = cat(2, 5 * ones(2, nSubjects / 2), -5 * ones(2, nSubjects / 2));
curPos = 20 * (rand(2, nSubjects) - 0.5);
speed = ones(2, nSubjects);
% curDir = cat(2, pi/3 * ones(1, nSubjects / 2), pi/5 * ones(1, nSubjects / 2));
% curDir = pi/4 * ones(1, nSubjects);
curDir = 2*pi * (rand(1, nSubjects) - 0.5);

curVel = speed .* [cos(curDir); sin(curDir)];
figure2(1), histogram(curDir), title('Orientation PDF [rad]')
figure2(2), quiver(curPos(1, :), curPos(2, :), curVel(1, :), curVel(2, :))
title('Initial conditions')

% Parameters
neighRadius = 10;
timeStep = 0.5;
dirFlucRange = 0.1;
addInformSub = true;
nTimeSteps = 100;
figure(100)
for curTime = 0:nTimeSteps-1
  if mod(curTime, 10) == 0
    informSubjs = randperm(nSubjects, nInformSub);
  end
  if addInformSub
  [curPos, curVel, curDir, informSubjs] = UpdatePosition(curPos, curVel, curDir,...
    timeStep, neighRadius, dirFlucRange, informSubjs, -3*pi / 4, addInformSub);
  else
  [curPos, curVel, curDir] = UpdatePosition(curPos, curVel, curDir,...
    timeStep, neighRadius, dirFlucRange, informSubjs, -3*pi / 4, addInformSub);
  end
%   addInformSub = false;
  figure2(100), quiver(curPos(1, :), curPos(2, :), curVel(1, :), curVel(2, :), 'off')
  title('Initial conditions'), hold on
  figure2(100), quiver(curPos(1, informSubjs), curPos(2, informSubjs),...
    curVel(1, informSubjs), curVel(2, informSubjs), 'off', 'color', 'r')
  title('Initial conditions'), hold off
  axis square, ylim([-50 50]), xlim([-50 50]),
  drawnow, %pause(0.1)
end

