
function GenerateFEReference(nVect, filename, eval_f, eval_u, parms, FEparms)
StructToVars(FEparms)
% FE Solution
XFERef = struct();
for n = nVect
  timestep = 1; for k = 1:n; timestep = timestep / 10; end
  fprintf('FE dt = %.0e: ', timestep)
  % Forward Euler integration
  tic
  [XFE,t, YFE, corrF, corrR, parmsOut] = ForwardEulerWDelay(eval_f, x_start, parms, eval_u,...
    t_start, t_stop, timestep, visualize + n, keepHist, verbsoity);
  FEtime(n) = toc;
  fprintf('Run time %.3f s \n', FEtime(n))  
  if parms.useGPU
    XFE = gather(XFE);
  end
  % Add X to struct
  XFERef.XFE{n} = XFE;
  % Add Y to struct
  XFERef.YFE{n} = YFE;
  % Add corrF to struct
  XFERef.corrF{n} = corrF;
  % Add corrR to struct
  XFERef.corrR{n} = corrR;
  % Add t to struct
  if keepHist
    XFERef.t{n} = t;
  else
    XFERef.t{n} = t(end);
  end
  % Reference confidence
  if n > nVect(1)
    XFERef.refConf(n) = max(abs(XFERef.XFE{n}(:, end) - XFERef.XFE{n-1}(:, end)));
  end
  VisualizeOutputs(YFE, corrR, parms.visOut, t_start, t_stop, 200 + n, sprintf('%s_dt_%.0e',...
    filename, timestep));
  nNeighsFE = parmsOut.n_neighborhood;
  timedelaysFE = (parms.kappa - parmsOut.timedelays) * timestep;
  save(sprintf('%s.mat', filename), 'XFERef', 'FEtime', 'nNeighsFE', 'timedelaysFE', '-v7.3')
end
