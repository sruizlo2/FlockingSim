function VisualizeState(t,X,n,plottype);
% Visualizes state components. It can be used to visualize: 
% 1) the time domain evolution of the state during ODE integration
% 2) or the itermediate progress of a Newton iteration
%
% INPUTS:
% t 	     vector containing time stamps 
%		     (or iteration indeces when used to visualize itermediate Newton iterations)
% X	     contains intermediate solutions as columns
% n	     index of the current data to be added to the plot
% plottype specifies color and markers e.g. 'b.'
%
% EXAMPLES:
% VisualizeState(t,X,n,plottype);       % to visualize time domain evolution
% VisualizeState([1:1:k,X,k,plottype);  % to visualize Newton iteration progress

N = size(X,1); %number of components in the solution/state

if N>1
   % top part shows the intermediate progress of all solution components vs iteration index
   subplot(2,1,1)
end
plot(t(n),X(:,n),plottype); 
hold on
xlabel('time or (iteration index)')
ylabel('x')
   
if N>1
   % bottom part shows all component values of the last solution
   subplot(2,1,2)
   plot(X(:,n),plottype);
   minX = min(min(X));
   maxX = max(max(X));
   if maxX == minX
      if maxX == 0
         minX = -1;
         maxX = 1;
      else
         minX = min(minX*0.9, minX*1.1);
         maxX = max(minX*0.9, minX*1.1);
      end
   end
   maxh = size(X,1);
   if maxh == 1,
      maxh = 2;
   end
   axis([1 maxh minX maxX])
   xlabel('state components index')
   ylabel('x')
end

drawnow
