function VisualizeObstacle(t, u, parms, hFig)
% Unpack options
StructToVars(parms)
theta = wo * t;
ro = vr .* cat(2, cos(theta), sin(theta)) + ro;
% Plot location of obstacle
figure2(hFig),
plot(ro(1), ro(2), 'r.', 'Markersize', markersize),
hold on,
