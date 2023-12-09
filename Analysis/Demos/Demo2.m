clear all, clc
% Add path with functions
addpath(genpath('../../matlab'))
outputFolder = '../../Output/Demos';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')
set(0,'defaultfigurecolor',[1 1 1])

%% FUNCTIONS
% Name of function to evaluate f()
eval_f_delay = 'eval_f_CSModelWDelay';
eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Name of function to evaluate y()
eval_y = 'ComputeOutputs';

%% PARAMETERS AND SEED
load(fullfile(outputFolder, 'Murmuration_Trap_Demo2Seed_dt_1e-01.mat'))
useGPU = true;

if useGPU
  XTrap = gpuArray(Trap.XTrap(:, end));
else
  XTrap = Trap.XTrap(:, end);
end

% Video file name
filenamePrefix = 'Murmuration';
filenameSufix = 'Trap';
parmsOut.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s_Demo2',...
  filenamePrefix, filenameSufix));
parmsOut.vis.subtitlename = '';
parmsOut.vis.fov = 25;

%% Integrate via Matrix-free trapezoidal
% options for Newton and GCR
parms.Newton.errF = 1e-4;
parms.Newton.errDeltax = 1e-4;
parms.Newton.relDeltax = 1e-4;
parms.Newton.MaxIter = 10;
parms.Newton.tolrGCR = 1e-4;
parms.Newton.epsMF = 1e-6;
% Options for trapezoidal
t_start = 15;       % Starting time
t_stop = 100;        % Ending time
timestep = 0.1;     % Time step
keepHist = true;    % Keep history or only last solution and output?
vebosity = 1;       % Print information: 0 for nothing, 1 for Trap info only, 2 for Trap and Newton info
parmsOut.progstep = 10; % Percentange of progress of FE to show
visualize = 2;
% Name of the output .mat file
outputFilename = fullfile(outputFolder, sprintf('%s_%s_Demo2',...
  filenamePrefix, filenameSufix));
% Trapezoidal integration
tic
[XTrap, tTrap, YTrap, parmsOut, corrFTrap, corrRTrap] = TrapezoidalIntegrationWDelay(eval_f_delay,...
  XTrap, parmsOut, eval_u, t_start, t_stop, timestep,...
  'MF', eval_y, visualize, keepHist, vebosity);
toc
timedelaysTrap = (parmsOut.kappa - parmsOut.timedelays) * timestep;
% VisualizeOutputs(YTrap, corrRTrap, parms.visOut, t_start, t_stop, 300, sprintf('%s_dt_%.0e',...
%   parms.vis.vid_filename, timestep));
Trap.XTrap = XTrap;
Trap.YTrap = YTrap;
Trap.tTrap = [tTrap(1) tTrap(end)];
figure(4), subplot(121), histogram(timedelaysTrap), title('Time delays')
figure(4), subplot(122), histogram(parmsOut.n_neighborhood), title('Number of Neighboors')
% Save file
% save(sprintf('%s_dt_%.0e.mat', outputFilename, timestep), 'Trap', 'parmsOut', '-v7.3')
