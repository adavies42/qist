show part1:sum over{(count x)cut{(any all each(((0,0 1+y 0)cut x[;y 1])_1)<x . y)|any all each(((0,0 1+y 1)cut x y 0)_1)<x . y}["J"$''x]each{x cross x}til count x}read0`:input
show part2:max{{prd raze({$[all not x;count x;1+(count x)^first where x]}each((reverse;::)@'(((0,0 1+y 0)cut x[;y 1])_1))>=x . y;{$[all not x;count x;1+(count x)^first where x]}each((reverse;::)@'(((0,0 1+y 1)cut x y 0)_1))>=x . y)}["J"$''x]each{x cross x}til count x}read0`:input