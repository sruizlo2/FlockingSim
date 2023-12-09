function parms = InitializeVisualizeOutputs(parms)
% Set defult parameters
if ~isfield(parms, 'linewidth')
  parms.linewidth = 2;
end

% Set defult parameters
if ~isfield(parms, 'linestyle')
  parms.linestyle = '-';
end

% Set defult parameters
if ~isfield(parms, 'linemarker')
  parms.linemarker = 'none';
end

% Set defult parameters
if ~isfield(parms, 'linemarkersize')
  parms.linemarkersize = 1;
end

if ~isfield(parms, 'linecolor')
  parms.linecolor = [0 0 0];
end

if ~isfield(parms, 'order_limsX')
  parms.order_limsX = [-inf inf];
end

if ~isfield(parms, 'order_limsY')
  parms.order_limsY = [-inf inf];
end

if ~isfield(parms, 'speed_limsX')
  parms.speed_limsX = [-inf inf];
end

if ~isfield(parms, 'speed_limsY')
  parms.speed_limsY = [-inf inf];
end

if ~isfield(parms, 'size_limsX')
  parms.size_limsX = [-inf inf];
end

if ~isfield(parms, 'size_limsY')
  parms.size_limsY = [-inf inf];
end

if ~isfield(parms, 'com_limsX')
  parms.com_limsX = [-inf inf];
end

if ~isfield(parms, 'com_limsY')
  parms.com_limsY = [-inf inf];
end

if ~isfield(parms, 'showcorr')
  parms.showcorr = false;
end

if ~isfield(parms, 'corr_markersize')
  parms.corr_markersize = 8;
end

if ~isfield(parms, 'corrV_limsX')
  parms.corrV_limsX = [-inf inf];
end

if ~isfield(parms, 'corrSp_limsY')
  parms.corrSp_limsY = [-inf inf];
end

