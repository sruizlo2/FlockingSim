function parms = InitializeVisualizeFlock(parms)
% Set defult parameters
if ~isfield(parms, 'background_color')
  parms.background_color = [1 1 1];
end

if ~isfield(parms, 'flock_color')
  parms.flock_color = [1 0.0784 0.1373];
end

if ~isfield(parms, 'birds_color')
  parms.birds_color = [0 0 0];
end

if ~isfield(parms, 'markersize')
  parms.markersize = 5;
end

if ~isfield(parms, 'markersize')
  parms.linewidth = 0.15;
end

if ~isfield(parms, 'plotFPS')
  parms.plotFPS = [];
end

if ~isfield(parms, 'subtitlename')
  parms.subtitlename = '';
end
