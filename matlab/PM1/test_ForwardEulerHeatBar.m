clear all;
close all;
format compact
%clc
disp(' '); disp(' ');

disp('**************** test_ForwardEulerHeatBar.m *************')

disp('Running: test_ForwardEulerHearBar.m')
disp('tests 1D linear diffusion on a heat conducting bar')
disp('showing time domain simulation as debugging tool')

%select input evaluation functions
eval_u = 'eval_u_step';
%eval_u = 'something else...';

% Heat Conducting Bar Example
[p,x_start,t_start,t_stop,max_dt_FE] = getParam_HeatBar(10);
eval_f = 'eval_f_LinearSystem';

% test FE function
visualize=1;
[X,t] = ForwardEuler(eval_f,x_start,p,eval_u,t_start,t_stop*.99/10,max_dt_FE,visualize);