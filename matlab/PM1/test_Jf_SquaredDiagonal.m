clear all;
close all;
format compact
%clc
disp(' '); disp(' ');

disp('****** Running: test_Jf_SquaredDiagonal.m *******')
disp('tests Squared Diagonal analytical Jacobian funciton')
disp('showing difference from finite difference Jacobian as debugging tool')


% Example with two state linear system plus squared diagonal nonlinearity
[p,x,t_start] = getParam_SquaredDiagonal;
eval_f = 'eval_f_SquaredDiagonal';
eval_Jf = 'eval_Jf_SquaredDiagonal';

%%select input evaluation functions
eval_u = 'eval_u_step';
%eval_u = 'something else...';
u = feval(eval_u, t_start);


% test Analitycal Jacobian function vs general Finite Difference Jacobian
Jf_Analytical = feval(eval_Jf,x,p,u)


dxFDeps = sqrt(eps)   
%p.dxFD=dxFDeps       % a good choice if machine precision not known
%p.dxFD=1e-7;         % a conservative choice for double precision machines
%if p.dxFD is not specified, eval_Jf_FiniteDifference will default 
%to a potentially better value proposed in the solver NITSOL 	
[Jf_FiniteDifference,dxFDnitsol] = eval_Jf_FiniteDifference(eval_f,x,p,u)

difference_J_an_FD = max(max(abs(Jf_Analytical - Jf_FiniteDifference)))


figure
% plot to study error on Finite Difference Jacobian for different dx
k = 1;
for n = 0:.05:15,
   dx(k)  = 10^-(n);
   p.dxFD = dx(k);
   Jf_FiniteDifference = eval_Jf_FiniteDifference(eval_f,x,p,u);
   error(k) = max(max(abs(Jf_Analytical - Jf_FiniteDifference)));
   k = k+1;
end
loglog(dx,error)

hold on
grid
xlabel('dxFD')
a=axis;
line([dxFDeps dxFDeps],[a(3) a(4)],'Color','k');
line([dxFDnitsol dxFDnitsol],[a(3) a(4)],'Color','g');
legend('|| J_{FD}-J_{an} ||','sqrt(eps)','dxFDnitsol')
title('Difference between Analytic & Finite Difference Jacobians')