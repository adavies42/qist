// Copyright 2016 Morgan Stanley
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// THIS PROGRAM IS SUBJECT TO THE TERMS OF THE APACHE LICENSE, VERSION 2.0.
//
// IN ADDITION, THE FOLLOWING DISCLAIMER APPLIES IN CONNECTION WITH THIS
// PROGRAM:
//
// THIS SOFTWARE IS LICENSED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE AND ANY WARRANTY OF NON-INFRINGEMENT, ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE. THIS SOFTWARE MAY BE REDISTRIBUTED TO OTHERS
// ONLY BY EFFECTIVELY USING THIS OR ANOTHER EQUIVALENT DISCLAIMER IN
// ADDITION TO ANY OTHER REQUIRED LICENSE TERMS.

if[type key`.lib.d;.lib.d[]]
/ require q.q(.lib.dd)
/ api *

///
// About: util.q
// A collection of miscellaneous utility functions.
///

///
// print in k (q 2.3) style
// useful where standard q output is ambiguous
// @param x object
// @return void
//
// Examples:
//
//  empty list:
//  q)()
//  q)unshow()
//  ()
//
//  one-row matrix:
//  q)enlist 1 2
//  1 2
//  q)unshow enlist 1 2
//  ,1 2
unshow:{-1@-3!x;}

///
// print elements of a dictionary in "show" style
// N.B. buggy!
// @param x dictionary
// @return void
//
// Example:
//
//  dictionary containing tables:
//  q)dshow`a`b!2#enlist([]1 2 3)
//  a| x
//   | -
//   | 1
//   | 2
//   | 3
//  b| x
//   | -
//   | 1
//   | 2
//   | 3
dshow:{$[all 1=count each x:` vs'{$[x~(::);-3!;.Q.s]x}each x;show x;
 -1@'"| "sv/:flip(max each count each'(k;r))$(@[0#'r;get 0^prev sums count each x;:;k:string key x];r:raze x)];}

///
// print multiple lists/vectors side-by-side in "show" style
// @param x list of objects to print
// @return void
// @see paste0
//
// Example:
//
//  two tables:
//  q)paste 2#enlist([]1 2 3)
//  x       x
//  -       -
//  1       1
//  2       2
//  3       3
/paste:{1` sv"\t"sv/:flip{x,'(max[c]-c:count each x)#\:enlist""}` vs' .Q.s each x;}
/paste:{1` sv"\t"sv/:{((max count each)each x)$x}flip{x,'(max[c]-c:count each x)#\:enlist""}` vs' .Q.s each x;}
paste:{1` sv"\t"sv/:flip{((max count each)each x)$x}flip{((max count each)each x)$x}flip{x,'(max[c]-c:count each x)#\:enlist""}` vs' .Q.s each x;}

///
// print multiple lists/vectors side-by-side in "show" style
// an alternate implementation for objects already the same length
// k impl: k)paste0:{if[~1=#?#:'x;'`length];1@`/:"\t"/:'+`\:'.Q.s'x;}
// @param x list of objects to print
// @return void
// @throws length if all objects are not of the same length
// @see paste
//
// Example:
//
//  two tables:
//  q)paste0 2#enlist([]1 2 3)
//  x       x
//  -       -
//  1       1
//  2       2
//  3       3
paste0:{if[1<>count distinct count each x;'`length];1` sv"\t"sv'flip` vs'.Q.s each x;}

///
// print text
// @param x string or list of string
// @return void
//
// Example:
//
//  hello world:
//  q)print"Hello, world!"
//  Hello, world!
print:{-1 x;}

///
// return elements of a list where some predicate is true
// @param x test function
// @param y list
// @return elements of y where x y is true
//
// Example:
//
//  simple integer comparison:
//  q)filter[1<]1 2 3
//  2 3
filter:{y where x y,:()}

///
// return elements of a dictionary where some predicate is true of its values
// @param x test function
// @param y dictionary
// @return entries in y where x y is true
//
// Example:
//
//  simple integer comparison:
//  q)dfilter[1<]`a`b`c!1 2 3
//  b| 2
//  c| 3
/dfilter:{where[x y]#y}
dfilter:{w:where x y;$[99=type y;w#y;y w]}

///
// return elements of a dictionary where some predicate is true of its keys
// @param x test function
// @param y dictionary
// @return entries in y where x key y is true
//
// Example:
//
//
//  simple integer comparison:
//  q)kfilter[1<]1 2 3!`a`b`c
//  2| b
//  3| c
kfilter:{(filter[x]key y)#y}

///
// return columns of a table where some predicate is true of the column names
// @param x test function
// @param y table
//
// Example:
//
//
//  string comparison:
//  q)cfilter[like[;"a*"]]([]a1:1 2;a2:3 4;b:5 6)
//  a1 a2
//  -----
//  1  3 
//  2  4 
cfilter:{.Q.ftx[{(filter[x]cols y)#y}x]y}

///
// sort a dictionary by its keys, ascending
// @param x dictionary
// @return x sorted by its keys, ascending
//
// Example:
//
//  q)dasc`b`a!2 1
//  a| 1
//  b| 2
dasc:{k!x k:asc key x}

///
// sort a dictionary by its keys, descending
// @param x dictionary
// @return x sorted by its keys, descending
//
// Example:
//
//  q)ddesc`a`b!1 2
//  b| 2
//  a| 1
ddesc:{k!x k:desc key x}

///
// sort a table by frequency of some column(s), ascending
// @param x column(s)
// @param y table
// @return y sorted s.t. least common values of x appear first
//
// Example:
//
//  q)fasc[`x]([]x:2 1 1 1 2;y:1 2 3 4 5)
//  x y
//  ---
//  2 1
//  2 5
//  1 2
//  1 3
//  1 4
//  q)
fasc :{y raze i  iasc count each i:?[y;();x;`i]} / frequency sort TODO keyed tables

///
// sort a table by frequency of some column(s), descending
// @param x column(s)
// @param y table
// @return y sorted s.t. most common values of x appear first
//
// Example:
//
//  q)fdesc[`x]([]x:1 2 2 2 1;y:1 2 3 4 5)
//  x y
//  ---
//  2 2
//  2 3
//  2 4
//  1 1
//  1 5
//  q)
fdesc:{y raze i idesc count each i:?[y;();x;`i]} / "

///
// clear the screen
// identical to Ctrl+L, but doesn't require rlwrap
// string is ANSI for move cursor to top left of screen,
//  clear from cursor to bottom right of screen"
// @return void
// @see https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes
clear:{[]1"\033[H\033[J";}

///
// set \c appropriately for current terminal size
// N.B. uses resize utility, which can sometime be slow enough
//  that you can type while it's running, which generally confuses it
//  and often leaves gibberish typed on the input line
// @return void
resize:{[]system"c "," "sv -1_'last each"="vs'system["resize"]1 0}

///
// convert list into dictionary of entries and function results
// @param x function
// @param y list
// @return dictionary with y as keys and x y as values
//
// Examples:
//
//  see countt
mapd:{y!x y,:()}

///
// convert list into table of entries and function results
// @param x tuple of (column names;function)
// @param y list
// @return keyed table with y as keys, x[1]y as values, and x[0] as column names
//
// Examples:
//
//  see counttt
mapt:{first[x]xcol([y]last[x]y,:())}

///
// get dictionary of table names and counts
// @param x workspace
// @return dictionary of table names and counts
// @see mapd
//
// Example:
//
//  q)t:([]1 2 3)
//  q)t2:([]1 2 3 4)
//  q)countt[]
//  t | 3
//  t2| 4
countt:mapd[count each get each]tables@

///
// get table of table names and counts
// @param x workspace
// @return table of table names and counts
// @see mapt
//
// Example:
//
//  q)t:([]1 2 3)
//  q)t2:([]1 2 3 4)
//  q)counttt[]
//  table| rows
//  -----| ----
//  t    | 3   
//  t2   | 4   
counttt:mapt[(`table`rows;count each get each)]tables@

///
// get meta of all tables
// column "n" with table name is added
// @param x workspace
// @return table containing meta of all tables in x
//
// Example:
//
//  q)t:([]1 2 3)
//  q)t2:([]1 2 3 4)
//  q)mmeta[]
//  n  c| t f a
//  ----| -----
//  t  x| i    
//  t2 x| i    
mmeta:{raze{`n`c xkey update n:x from meta x}each tables x}

///
// get saferazed meta of all tables
// N.B. will fail if any table has duplicate columns
// column "n" with table name is added
// @param x workspace
// @return table containing meta of all tables in x
//
// Examples:
//
//  q)t:([]x:1 2 3)
//  q)t2:([]x:1 2 3 4;y:1 2 3 4)
//  q)mmetas[]
//  n  c| t f a
//  ----| -----
//  t  x| i    
//  t2 x| i    
//  t2 y| i    
//  q)t2:`x`x xcol t2
//  q)mmetas[]
//  {saferaze{`n`c xkey update n:x from meta x}each tables x}
//  'unsafe
//  @
//  {$[(count x:raze x)=sum count each x;x;'`unsafe]}
//  ((+`n`c!(,`t;,`x))!+`t`f`a!(,"i";,`;,`);(+`n`c!(`t2`t2;`x`x))!+`t`f`a!("ii";``;``))
//  q.q))
mmetas:{saferaze{`n`c xkey update n:x from meta x}each tables x}

///
// return closed interval from x to y
// only implemented for x and y of same type
// not implemented for guid, real, float, symbol, or datetime
// unwinds type conversions to guarantee result is of the same type as arguments
// @invariant {isrange until[x]y}
// @param x interval start
// @param x interval end
// @return all elements in closed interval [x y]
// @see isrange
//
// Examples:
//
//  ints:
//  q)until[5]10
//  5 6 7 8 9 10
//
//  chars:
//  q)until["f"]"m"
//  "fghijklm"
//
//  minutes:
//  q)until[09:30]09:45
//  09:30 09:31 09:32 09:33 09:34 09:35 09:36 09:37 09:38 09:39 09:40 09:41 09:42 09:43 09:44 09:45
until:{if[type[x]<>type y;'`type];u:("bxhijcpmdnuvt"!"hxhijxjiijiii")t:.Q.t abs type x;t$u$(u$x)+key 1+(-). u$(y;x)}

///
// is x a consecutive list?
// test
//  all{mapd[{$[first r:@[(1;)y .;x$v:1000 1010];((x$v)in\:last r)~(x$v)within\:x$v;last r]}[;x]each]extant[.Q.t]except"sefz"}(until)
// @param x list
// @return true if x is consecutive
// @see until
//
// Example:
//
//  validating "until" on ints:
//  q)isrange until[5]10
//  1b
isrange:{x~(until).(first;last)@\:x}

///
// is x a subset of y?
// @param x list
// @param y list
// @return true iff x has no elements not in y
//
// Examples:
//
//  q)subset[1 2]1 2 3
//  1b
//  q)subset[1 2]1 2
//  1b
subset:{0=count x except y}

///
// is x a strict subset of y?
// @param x list
// @param y list
// @return true iff x is as subset of y and y is not a subset of x
//
// Examples:
//
//  q)ssubset[1 2]1 2 3
//  1b
//  q)ssubset[1 2]1 2
//  0b
ssubset:{(.lib.dd[`subset][x]y)&not .lib.dd[`subset][y]x}

///
// is x a superset of y?
// @param x list
// @param y list
// @return true iff y has no elements not in x
//
// Examples:
//
//  q)superset[1 2 3]1 2
//  1b
//  q)superset[1 2 3]1 2 3
//  1b
//  q)
superset:{0=count y except x}

///
// is x a strict superset of y?
// @param x list
// @param y list
// @return true iff y is a superset of x and x is not a superset of y
//
// Examples:
//
//  q)ssuperset[1 2 3]1 2
//  1b
//  q)ssuperset[1 2 3]1 2 3
//  0b
ssuperset:{(.lib.dd[`superset][x]y)&not .lib.dd[`superset][y]x}

/ ///
/ // protected execution version of \l, with error reporting
/ //  on error, prints file and error message, then returns
/ // @param x file to load, as hsym
/ // @return void
/ safel:{@[system;"l ",1_string x;{-2@string[last` vs x],": \"",y,"\"";}x]}

///
// if x is an enum type, de-enumerate it
// @param x data
// @return if x is an enum, the underlying value; otherwise x
//
// Example:
//
//  q)sym:`a`b`c
//  q)type denum`sym$`a`b
//  11h
denum:{$[type[x]within 20 77;get each x;x]}

///
// retrieve an object from a handle and store it locally
// @param x handle
// @param y object name
// @return y
//
// Example:
//
//  q)t
//  't
//  q)h:hopen 5050
//  q)h"t:([]1 2 3)"
//  q)hget[h]`t;
//  q)t
//  x
//  -
//  1
//  2
//  3
hget:{y set x y}

///
// send an object over a handle and store it remotely
// @param x handle
// @param y object name
// @return y
//
// Example:
//
//  q)h:hopen 5050
//  q)h`t
//  't
//  q)t:([]1 2 3)
//  q)hset[h]`t;
//  q)h`t
//  x
//  -
//  1
//  2
//  3
hset:{x(set;y;get y)}

///
// all .z.p?
// shows any of the .z.p? handlers which are set
// @return dictionary of .z.p? handler names and functions
//
// Example:
//
//  q)azp[]
//  .z.pg| {get 0N!x}
//  .z.ph| k){x:uh$[@x;x;*x];$[~#x;hy[`htm]fram[$.z.f;x]("?";"?",*x@<x:$(."\\v"),..
azp:{[]dfilter[not null each]x!@[get;;`]each x:` sv'`.z,'`ac`bm`exit`pc`pg`pd`ph`pi`po`pp`ps`pw`ts`vs`ws}

///
// variant on vs splitting on multiple delimiters
// @param x delimiters
// @param y thing to split
// @return y split on all occurrences of any x
//
// Example:
//
//  url-format username, hostname, & port
//  q)mvs["@:"]"user@localhost:5050"
//  "user"
//  "localhost"
//  "5050"
mvs:{{raze y vs'x}/[enlist y;x]}

///
// set-theoretic XOR: all elements of two sets not in common to them
// N.B. if x or y contain duplicates, the result may too
// @param x list
// @param y list
// @return list of elements not shared by both lists
//
// Example:
//
//  q)setxor[1 1 2]2 3
//  1 1 3
setxor:{(x except y),y except x}

///
// canonical xasc: sort a table by all its columns
// if two tables are identical up to order, their cxasc's should match (~)
// @param x table
// @return x sorted by all its columns, ascending
//
// Example:
//
//  q)cxasc([]x:2 1 2;y:3 1 2)
//  x y
//  ---
//  1 1
//  2 2
//  2 3
cxasc:{cols[x]xasc x}

///
// non-null elements of a list
// @param list
// @return non-null elements of x
//
// Example:
//
//  q)extant 1 0N 2
//  1 2
extant:{x where not null x}

///
// group of keyed table as a group, not a crosstab
// @param x table
// @return if x is a keyed table, x xgrouped by all its value columns, otherwise x
//
// Example:
//
//  q)tgroup([k:1 2 3]v:1 1 2)
//  v| k  
//  -| ---
//  1| 1 2
//  2| ,3 
tgroup:{$[(.Q.qtx x)&99h=type x;cols[get x]xgroup x;x]}

///
// directory vs
// breaks up an hsym into all its components,
//  not just dirname and basename (like vs)
// alt slightly slower
// {{$[x=`:;;`\:]x}[*x],1_x,:()}
// {(`\:;::)[`:=a][a:*x],1_x,:()}
// k impl: k)dvs:{$[a=`:;;`\:][a:*x],1_x,:()}/
// @invariant {x~dsv dvs x}
// @param x path hsym
// @return list of path components in x
// @see dsv
//
// Example:
//
//  q)` vs hsym`$getenv`HOME
//  `:/Users`adavies
//  q)dvs hsym`$getenv`HOME
//  `:`Users`adavies
//  q)
dvs:{$[a=`:;;` vs][a:first x],1_x,:()}/

///
// directory sv
// identical to ` sv
// k impl: k)dsv:`/:
// @invariant {x~dvs dsv x}
// @param x list of path components
// @return x joined together
// @see dvs
dsv:` sv

///
// eval multi-line input
// execute, paste code into terminal, then type Ctrl+D
// @return whatever the code returns
//
// Example:
//
//  q)f
//  'f
//  q)getpaste[]
//  f:{
//   1+2}
//  ^D
//  q)f
//  {1+2}
getpaste:{[]get` sv system"cat"}

///
// eval clipboard
// N.B. only implemented for Mac
// @return whatever the code returns
// @see getpaste
//
// Examples:
//
//  see getpaste
getpastex:{[]if[not .z.o like"m*";'`nyi];get` sv system"pbpaste"}

///
// like .q.views[], but for \B
// k impl: k)dirty:{."\\B ",$$[^x;`;x]}
// @param x workspace
// @param invalidated views in x
//
// Example:
//
//  q)v::1+2
//  q)dirty[]
//  ,`v
//  q)v;
//  q)dirty[]
//  `symbol$()
dirty:{system"B ",string$[null x;`;x]}

///
// like .q.tables[], but for \f
// k impl: k)functions:{."\\f ",$$[^x;`;x]}
// @param x workspace
// @return functions in x
//
// Example:
//
//  q)f:{x+y}
//  q)functions[]
//  ,`f
functions:{system"f ",string$[null x;`;x]}

///
// like .q.tables[], but for \v
// k impl: k)variables:{."\\v ",$$[^x;`;x]}
// @param x workspace
// @return variables in x
//
// Example:
//
//  q)a:1
//  q)variables[]
//  ,`a
variables:{system"v ",string$[null x;`;x]}

///
// variables in the root of an hdb that do not come from the hdb's data
// basically, everything except the partition vector (date/month/whatever),
//  the partitioned tables, and any objects found in the hdb directory
//  (splayed and serialized tables, symfiles, etc.)
// @return variables not representing hdb data
variablesx:{[]key[`.]except$[`pf in key`.Q;.Q.pf,.Q.pt,key[`:.]except`$string get .Q.pf;()]}

///
// get normally-distributed random numbers
// the cos half of the Box–Muller transform
// @param x number of values to get
// @return x normal randoms (avg 0, dev 1)
//
// Example:
//
//  q)(avg;dev)@\:norm 10000
//  -0.0009247813 1.007683
norm:{(sqrt -2*log x?1.)*cos 2*(acos -1)*x?1.}

///
// natural join: join on common columns
// @param x table
// @param y table
// @return x and y equi-joined on their common columns
//
// Example:
//
//  see https://en.wikipedia.org/w/index.php?title=Relational_algebra&oldid=709297998#Natural_join_.28.E2.8B.88.29
//  q)e:([]name:`harry`sally`george`harriet;id:3415 2241 3401 2202;dept:`finance`sales`finance`sales)
//  q)d:([]dept:`finance`sales`production;manager:`george`harriet`charles)
//  q)nj[e]d
//  dept   | name    id   manager
//  -------| --------------------
//  finance| harry   3415 george 
//  sales  | sally   2241 harriet
//  finance| george  3401 george 
//  sales  | harriet 2202 harriet
//  q)
nj:{k xkey ej[k:cols[x]inter cols y;x;y]}

///
// are the values of x unique?
// faster than trying to apply `u#
// @param x data
// @return true iff no value in x is repeated
//
// Examples:
//
//  q)uniq 1 2
//  1b
//  q)uniq 1 2 2
//  0b
//  q)\ts `u#til 1000000
//  80 20971744j
//  q)\ts uniq til 1000000
//  12 9437360j
//  q)\ts @[`u#;(til 1000000),0;::]
//  74 20972016j
//  q)\ts uniq(til 1000000),0
//  7 9437472j
uniq:{x~distinct x}

///
// is the key of x unique?
// useful for validating keyed tables
// @param x data
// @return true iff not value in the key of x is repeated
// @see uniq
//
// Examples:
//
//  q)unik([k:1 2]v:3 4)
//  1b
//  q)unik([k:1 1]v:3 4)
//  0b
unik:('[uniq;key])

///
// raze iff result is same size as inputs
// meant for razing keyed tables with expected disjoint key sets
// k)saferaze:{$[(#x:,/x)=+/#:'x;x;'`unsafe]}
// @param x data
// @return raze x if result is of the same size as arguments
// @throws unsafe if result would be of different size
//
// Examples:
//
//  q)saferaze(([k:1 2]v:3 4);([k:3 4]v:5 6))
//  k| v
//  -| -
//  1| 3
//  2| 4
//  3| 5
//  4| 6
//  q)saferaze(([k:1 2]v:3 4);([k:2 3]v:5 6))
//  'unsafe
saferaze:{$[(count x:raze x)=sum count each x;x;'`unsafe]}

///
// format numbers with commas
// N.B. only implemented for shorts, ints, and longs
// @param x number
// @return x as a comma-formatted string
//
// Example:
//
//  q)comma 1234567
//  "1,234,567"
comma:{$[(type x)in -5 -6 -7h;$[x<0;"-";""],reverse","sv 3 cut reverse string abs x;'`nyi]}'

///
// parallel xasc
// see http://www.q-ist.com/2013/05/parallel-xasc.html
// @param x sort keys
// @param y table
// k)pxasc :{(#.q.keys y)!+{y x}[<(,/x)#0!y]':+0!y}
pxasc :{(count keys y)!flip{y x}[ iasc(raze x)#0!y]peach flip 0!y}

///
// parallel xdesc
// see http://www.q-ist.com/2013/05/parallel-xasc.html
// @param x sort keys
// @param y table
// k)pxdesc:{(#.q.keys y)!+{y x}[>(,/x)#0!y]':+0!y}
pxdesc:{(count keys y)!flip{y x}[idesc(raze x)#0!y]peach flip 0!y}

///
// xcols w/support for keyed tables
// ignores key side/key cols in x
// alt impl: {k xkey(k,(raze x)except k:keys y)xcols 0!y}
// k impl: k){(#k)!xcols[k,x@&~x in k:keys y]0!y}
// @param x cols
// @param y table
// @return y with cols x moved to the left & keys unchanged
// @see .Q.ftx
//
// Example:
//
//  q)xcolsx[`z`y]([x:1 2 3]y:4 5 6;z:7 8 9)
//  x| z y
//  -| ---
//  1| 7 4
//  2| 8 5
//  3| 9 6
xcolsx:{{.Q.ftx[x xcols]y}}

///
// y except x
// for when you'd rather change the function name than cut
//  and paste the args again
// @param x x
// @param y y
// @return y except x
// @see except
//
// Example:
//
//  q)2 3 4 rexcept 1 2 3
//  ,1
rexcept:{y except x}

///
// shuffle
// @param x x
// @return x, randomly shuffled
// k)shuf:{(-#x)?x}
//
// Example:
//
//  q)shuf til 10
//  6 3 4 9 2 0 8 1 5 7
shuf:{(neg count x)?x}

\d .help

///
// remote help
// fetches and prints help.q-type help text over a handle
// supports listing available topics
// @param x handle
// @param y topic
// @return void
//
// Example:
//
//  q)h:hopen 5050
//  q)h".help.TXT[`foo]:`foo"
//  q)h".help.TXT[`foo]:enlist\"foo\""
//  q)rhelp[h]`foo
//  foo
.q.rhelp:{1 x({if[not 10h=abs type x;x:string x];$[1=count i:where(key DIR)like x,"*";` sv TXT[(key DIR)[first i]];.Q.s DIR]};y);}

\d .Q

///
// alternate version of .Q.qt
// doesn't consider crosstabs tables
// @param x data
// @return true iff x is a table or keyed table (but not a crosstab)
//
// Example:
//
//  q).Q.qt`a`b!([]1 2)
//  1b
//  q).Q.qtx`a`b!([]1 2)
//  0b
k)qtx:{$[99h=@x;(98h=@!x)&98h=@. x;98h=@x]}

///
// alternate version of .Q.ft
// if y is a keyed table, runs x on its value portion,
//  then reapplies the keys and returns the result
// otherwise just runs x on y
// useful when you want to handle the value side separately
//  (.Q.ft handles the unkeyed version of the table)
// @param x function
// @param y table
// @return y as modified by x
//
// Example:
//
//  see xcolsx
k)ftx:{$[$[99h=@t:v y;98h=@. t;0];(!y)!x@. y;x y]}
