close all, clear all, clc
% Add path with functions
addpath(genpath('../../matlab'))
outputFolder = '../../Output/Demos';
[~, ~, ~] = mkdir(outputFolder);
% Pre-defined parameters for plotting
set(groot,'defaultAxesFontSize', 20)
set(groot,'defaulttextInterpreter', 'latex')
set(groot, 'defaultAxesTickLabelInterpreter','latex')
% set(0,'defaultfigurecolor',[1 1 1])
set(groot,'defaultFigureColor','w');

hFig = figure(10);
hFig.Position = hFig.Position .* [1.75 0.25 1 1.75];
eq1 ='Group order $$R = \sum_{i=1}^N R_i$$'; 
annotation(gcf,'textbox',[0,0,1,1],'string',eq1,'interpreter','latex', 'fontsize', 30);

eq2 ='Group Velocity $$\mathbf{U} = \frac1N\sum_{i=1}^N \mathbf{v_i}$$'; 
annotation(gcf,'textbox',[0,0,1,0.75],'string',eq2,'interpreter','latex', 'fontsize', 30);

eq3 ='Group size $$G = \frac1N\sum_{i=1}^N |\mathbf{r_i} - \mathbf{r_0}|$$'; 
annotation(gcf,'textbox',[0,0,1,0.5],'string',eq3,'interpreter','latex', 'fontsize', 30);

eq4 ='Center of mass $$\mathbf{r_0} = \frac1N\sum_{i=1}^N \mathbf{r_i}$$'; 
annotation(gcf,'textbox',[0,0,1,0.25],'string',eq4,'interpreter','latex', 'fontsize', 30);

%% FUNCTIONS
% Name of function to evaluate f()
eval_f_delay = 'eval_f_CSModelWDelay';
eval_f = 'eval_f_CSModel';
% Name of function to evaluate u()
eval_u = 'eval_u_CSModel';
% Name of function to evaluate y()
eval_y = 'ComputeOutputs';

%% PARAMETERS AND SEED
load(fullfile(outputFolder, 'Murmuration_FE_Demo1Seed_dt_1e-01.mat'))
useGPU = true;

if useGPU
  XFE = gpuArray(XFE);
end

% Video file name
filenamePrefix = 'Murmuration';
filenameSufix = 'FE';
parmsOut.vis.vid_filename = fullfile(outputFolder, sprintf('%s_%s_Demo1',...
  filenamePrefix, filenameSufix));
parmsOut.vis.legendOn = true;
parmsOut.vis.drawnowOn = true;
parmsOut.vis.subtitlename = '';
parmsOut.vis.fov = 20;
parmsOut.vis.fps = 3;
parmsOut.vis.plotFPS = 2;
parmsOut.NCorr = 0;

%% Integrate via Forward Euler
% Options for Forward Euler
t_start = 10;       % Starting time
t_stop = 60;        % Ending time
keepHist = false;   % Keep history or only last solution and output?
visualize = 1;      % Number of figure to visualize plot (false for not plotting)
verbsoity = 1;      % Print progress of FE?
progstep = 10;      % Percentange of progress of FE to show
timestep = 0.1;     % Time step
% Name of the output .mat file
outputFilename = fullfile(outputFolder, sprintf('%s_%s_Demo1',...
  filenamePrefix, filenameSufix));
% GenerateFEReference(nVect, outputFilename, eval_f_delay, eval_u, parms, FEparms);
% Forward Euler
tic
[XFE, t, YFE] = ForwardEulerWDelay(eval_f_delay,...
  XFE, parmsOut, eval_u, t_start, t_stop, timestep, visualize, keepHist, verbsoity);
fprintf('\n')
toc
% Save file
% save(sprintf('%s_dt_%.0e.mat', outputFilename, timestep), 'XFE', 'parmsOut', '-v7.3')
