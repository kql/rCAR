% ===========================================================================
% Author:				Kyle Q. Lepage
% Copyright:		30.10.2009	to	06.01.2010
% ===========================================================================
function col = make_col( vec )
  [ N M ] = size( vec );
  if( M > N )
    col = transpose( vec );
  else
    col = vec;
  end
end
