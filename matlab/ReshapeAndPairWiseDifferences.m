function [x, dx, dx_norm] = ReshapeAndPairWiseDifferences(x)

% [rx, ry]
x = cat(2, x(1:end/2), x(end/2 + 1:end));
if nargout > 1
  % Return pair-wise differences
  dx = x - permute(x, [3 2 1]);
end
if nargout > 2
  % Return norm of pair-wise differences
  dx_norm = sqrt( sum( dx .^ 2, 2 ) );
end