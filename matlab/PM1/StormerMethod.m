function [X,t] = StormerMethod(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize, vid_filename)
% uses Forward Euler to simulate states model dx/dt=f(x,p,u)
% startin from state vector x_start at time t_start
% until time t_stop, with time intervals timestep
% eval_f is a text string defining the name of the function that evaluates f(x,p,u)
% eval_u is a text string defining the name of the funciton that evaluates u(t)
% visualize ~= 0 is an optional parameter triggering the generation of intermediate plots of the state
%
% EXAMPLE
% [X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop,timestep,visualize);


X(:,1) = x_start;
t(1)   = t_start;
u = [0; 0];
if vid_filename ~= 0
  % Initialize video
  videoWriter = VideoWriter(vid_filename); %open video file
  videoWriter.FrameRate = 1 / timestep;  %can adjust this, 5 - 10 works well for me
  open(videoWriter)
end
for n = 1 : ceil((t_stop-t_start)/timestep)
  dt       = min(timestep, (t_stop-t(n)));
  t(n+1)   = t(n) + dt;
  u        = feval(eval_u, u, t(n));
  % Update position
  p.update = 'pos';
  f        = feval(eval_f, X(:,n), p, u); 

  X(:,n+1) = X(:,n) + (f(:, 1) * dt) + (f(:, 2) * dt ^ 2);
  % Store acceleration
  p.accel = 2 * f(1:end/2, 2);
  % Update velocity
  p.update = 'vel';
  f        = feval(eval_f, X(:,n+1), p, u);
  X(:,n+1) = X(:,n+1) + f(:, 1) * dt;
  % Saturate velocity
  X(end/2+1:end,n+1) = min(X(end/2+1:end,n+1), p.max_V) .* (X(end/2+1:end,n+1) >= 0)...
    + max(X(end/2+1:end,n+1), -p.max_V) .* (X(end/2+1:end,n+1) < 0);
  if visualize
    frame = VisualizeFlockLJ(t(n+1), X(:, n), f, 2);
    if vid_filename ~= 0
      writeVideo(videoWriter, frame);
    end
  end
end
if vid_filename ~= 0
  close(videoWriter)
end
