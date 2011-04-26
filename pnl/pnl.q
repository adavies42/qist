#!/usr/bin/env q

system"cd ",1_string first` vs hsym .z.f
xn:("DSFFF";enlist",")0:`:xn.csv

yp:{"F"${(1+x?"")_x}` vs`:http://download.finance.yahoo.com"GET /d/quotes.csv?s=",
 (","sv string x,:()),"&f=l1 http/1.0\r\nhost:download.finance.yahoo.com\r\n\r\n"}

\l willbe.q

f:1#.q
f.price:"yp sym"
f.mkt:"price*shares"
f.gain:"mkt-basis"
f.gainp:"100*gain%basis"
f:1_f

g:1#.q
g.price:0b
g.mkt:0b
g.gain:0b
g.gainp:0b
g:1_g

p::willbe[select shares:sum size,basis:sum commission+price*size by sym from xn;f;g]
t::enlist willbe[`basis`mkt#sum p;`gain`gainp#f;`gain`gainp#g]

show p;

-1"";

show t;

if[.z.q;exit 0]
