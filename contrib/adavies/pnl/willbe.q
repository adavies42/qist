/ http://nsl.com/q/willbe.q, http://nsl.com/q/willbe.txt

/ table willbe definition
willbe:{[t;f;g]
 p:parse each f;		/ parse of expression
 r:refs each p;			/ references
 o:order r;			/ ordered by reference
 col/[t;g o;o map'p o]}		/ create view

flatten:distinct raze over
ref:{$[-11=t:type x;x;t;();.z.s each x]}
refs:flatten ref@
map:{enlist[x]!enlist y}
col:![;();;]
order:{flatten[reverse(flatten x@)scan key x]inter key x}
\
/ example
t:([]e:1 1 2;f:10 20 30;g:40 50 60)
f:`h`j`k`l!("j+k";"f+g";"j*100";"k%sum k")
g:`h`j`k`l!(0b;0b;0b;enlist[`e]!enlist`e)
v::willbe[t;f;g]

show t
show v
t:update g:g+1 from t where f<50
show t
show v
