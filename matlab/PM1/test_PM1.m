clear all
close all
format compact
% clc
disp(' '); disp(' ');

% this scripts tests all functions distributed with PM1

test_VisualizeNetwork;			disp('press a key to continue'); pause
test_ForwardEulerSquaredDiag;	disp('press a key to continue'); pause
test_ForwardEulerHeatBar;		disp('press a key to continue'); pause
test_Jf_SquaredDiagonal;		disp('press a key to continue'); pause
test_Jf_HeatBar;					disp('press a key to continue'); pause
