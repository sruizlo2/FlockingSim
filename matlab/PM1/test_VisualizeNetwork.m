clear all;
close all;
format compact
%clc
disp(' '); disp(' ');

disp('******* test_VisualizeNetwork.m ***********')


disp('Example showing how to use VisualizeNetwork.m')

NodeCoordinates = [0 0; 3 4; 0 7; 6 4]
NodalValues     = [ 1;  0.5; 1.5;  .3] %use here instead the solution from your simulator

EdgeConnections = [1 2; 2 3; 3 1; 2 4] %you can derive this from your nodal matrix
FlowValues      = [6;   3;   10;  1]   %you can compute this using the consitutite equations

figure
VisualizeNetwork(NodeCoordinates,NodalValues,EdgeConnections,FlowValues);
axis equal %this makes circles look like circles rather than ovals
drawnow    


% if you need to visualize multiple networks at the same time 
% (e.g. electrical, thermal, fluid, etc...)
% you can use a different color and height for each network
% if you do not specify the color the dafault will be 'b' for blue
% if you do not specify the height the default will be 0
% here is an example of how to visualize a second network

NodeCoordinatesNetB = [0 7; 5 8; -3 13]; 
NodalValuesNetB     = [0.5;  1;   0.5];

EdgeConnectionsNetB = [1 2; 1 3];
FlowValuesNetB      = [4;   3]

color  = 'r';
height = 1;

VisualizeNetwork(NodeCoordinatesNetB,NodalValuesNetB,EdgeConnectionsNetB,FlowValuesNetB,color,height);

disp('press a key to continue')
pause

disp('you can also visualize things in 3D view with the command "view"')
view(30,25)
disp('press a key to continue')
pause

disp('and even make them rotate')
for theta=30:1:210
   view(theta,25)
   drawnow
   for w=1:10000, %this is just to introduce some delay if your computer is too fast
      tmp=log(35);
   end
end
disp('press a key to continue')
pause
   



disp('Example showing how to use make animations with VisualizeNetwork.m')

NodeCoordinates = [0 0; 3 4; 0 7]; 
EdgeConnections = [1 2; 2 3; 3 1]; %you can derive this from your nodal matrix

% the values for your animations should really be computed using your simulator
% such as forward euler (and later backward euler or trapezoidal)
% here I am generating some fake signals just to illustrate how to visualize
% the behaviour of your network using VisualizeNetwork in an animation

figure
N=50;
for t=0:2*pi/N:2*pi*2,
   clf;
   NodalValues = [ 1;  0.5; 1.5] * (0.4*cos(t)+1);  
   FlowValues  = [ 8;   5;  15]  * (0.4*sin(t)+0);   
   VisualizeNetwork(NodeCoordinates,NodalValues*(0.4*cos(t)+1.01),EdgeConnections,FlowValues*(0.4*sin(t)+1.01));
   axis equal          %this makes circles look like circles rather than ovals
   axis([-4 5 -3 11]);
   drawnow             %this is critical if you are trying to do animations!!!!!
   for w=1:20000,      %this is just to introduce some delay if your computer is too fast
      tmp=log(35);
   end
end