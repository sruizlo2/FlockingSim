clear all;
close all;
format compact
%clc
disp(' '); disp(' ');

disp('******** test_ForwardEulerSquareDiag.m **************')

disp('Running: test_ForwardEulerSquareDiag.m')
disp('tests state space model with nonlinear (i.e. squared diagonal) vector field')
disp('showing time domain simulation as debugging tool')

%select input evaluation functions
eval_u = 'eval_u_step';
%eval_u = 'something else...';

% Example with two state linear system plus squared diagonal nonlinearity
[p,x_start,t_start,t_stop,max_dt_FE] = getParam_SquaredDiagonal;
eval_f = 'eval_f_SquaredDiagonal';

% test FE function
figure(1)
visualize=1;
[X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop,max_dt_FE,visualize);