clear all;
close all;
format compact
%clc
disp(' '); disp(' ');

disp('****** Running: test_Jf_HeatBar.m *********')
disp('tests Heat Conducting Bar analytical Jacobian funciton')
disp('showing difference from finite difference Jacobian as debugging tool')


% Heat Conducting Bar Example
[p,x,t_start] = getParam_HeatBar(10);
eval_f  = 'eval_f_LinearSystem';
eval_Jf = 'eval_Jf_LinearSystem';


%%select input evaluation functions
eval_u = 'eval_u_step';
%eval_u = 'something else...';
u = feval(eval_u, t_start);


% test Analitycal Jacobian function vs general Finite Difference Jacobian
Jf_Analytical       = feval(eval_Jf,x,p,u)

dxFD   = 0.1  % the function is linear so you can make this quite large
p.dxFD = dxFD;  
Jf_FiniteDifference = eval_Jf_FiniteDifference(eval_f,x,p,u)
% Jf_FiniteDifference = eval_Jf_FiniteDiff(eval_f,x,p,u)
difference_J_an_FD  = max(max(abs(Jf_Analytical - Jf_FiniteDifference)))

figure(1)
% plot to study error on Finite Difference Jacobian for different dx
k = 1;
for n = -17:.01:5,
   dx(k)  = 10^(n);
   p.dxFD = dx(k);
   Jf_FiniteDifference = eval_Jf_FiniteDifference(eval_f,x,p,u);
%    Jf_FiniteDifference = eval_Jf_FiniteDiff(eval_f,x,p,u);
   error(k) = max(max(abs(Jf_Analytical - Jf_FiniteDifference)));
   k = k+1;
end
loglog(dx,error)

hold on
grid
xlabel('dxFD')
a = axis;
line([dxFD dxFD],[a(3) a(4)],'Color','g');
legend('|| J_{FD}-J_{an} ||','dxFD')
title('Difference between Analytic & Finite Difference Jacobians')