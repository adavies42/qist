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
/ require ?
/ api ff lines canon break_entry break_all trace_all profile readProfile

///
// About: lines.q
// A collection of functions used for doing automated code modification.
// At the moment, none of these are fully general, in that
//  (at a minimum) they are subject to compiler limits
//  (locals/globals/constants/etc.)
// Future plans include workarounds for the limits and more
//  granular breakpoint creation.
// Partially implemented at this point are:
//  Reformat function code with one statement per line
//  Add a breakpoint at the beginning of a function
//  Add a breakpoint after every statement of a function
//  Add tracing messages to every statement of a function
///

///
// Function from function: run a higher-order function over any functional type.
// If y is: a lambda or primitive, returns the function, modified
//          a projection, returns the function, modified & projected
//          a composition, returns the composition of its two functions, each modified
//          a function with an adverb, returns the function, modified, with the same abverb
//          anything else, throws 'type
// @param x the higher-order function
// @param y the function to run x on
// @return y as modified by x
// @throws type if y is dynamically loaded code or not a function
ff:{
 if[(t:type y)=-11h;t:type y:get y];                        /  get type (& dereference)
 s:{x z get y}[.z.s x;y];                                   /  recurse on part
 a:first parse"f",(raze"'/\\",\:/:("";":"))t-106h;          /  adverb
 $[t within 100 103h;x y;                                   /  lambda or primitive (base case)
   t=104h           ;.[s first;1_get y];                    /   projection
   t=105h           ;'[s first;s last ];                    /   composition
   t within 106 111h;@[a      ;s (::)  ];                   /   adverb
   '`type]}                                                 /   ???

///
// given a boolean list, add 1b's between pairs of 1b's
// i.e., given a list that indicates positions where a
//  property changes from true to false or vice versa,
//  return a list that indicates all areas where it was
//  true (including the toggle points).
// @param x a boolean list
// @return x with pairs of 1b's extended into ranges of 1b's
/if[$[`dd in key`.lib;null .lib.dd `spans;1];`spans set{x or(<>)scan x}] / apparently 'assign is checked at parse time!
spans:{x or(<>)scan x}

///
// split a string like vs, but only on occurances of the split
//  character that align with 0b's in a mask
// i.e. lets you mark certain occurances of the character as
//  not being appropriate for splitting
// e.g. use spans[] to find quoted sections of a string, then
//  split on semi-colons that are not in the quoted sections
// xvs[";";00111111111111111111111110001111000111110000111110b;"x:{[b](foo{}[\"\\\"\\\\\\\"}\"])};a:{;2};b:(1;2);c:f[1;3];"]
// @param x split character
// @param y mask
// @param z string
// @return z split on x's that don't occur on trues in y
xvs:{first each 0N 2#(0,raze 0 1+/:where(z=x)&not y)cut z}

///
// break a function's code into statements
// currently returns exactly one line per technical "statement"
//  i.e. ternaries, nested functions, etc., will not be broken out
// @param x the function or its name
// @return a list of strings of the statements of the functions, including the parameter declaration as the first line
lines:{
 $[not(t:type x:.Q.v x)within 100 111;'`type; /  not a function
   t within 101 103;'`domain;          /    primitive
   t=104;'`nyi;                        /    projection
   t=105;'`nyi;                        /    composition
   t within 106 111;'`nyi;];           /    adverb
 t:string x;                           /  code
 if["k)"~2#t;'`nyi];                   /  k4 later

 t:-1_1_raze` vs t;                    /  remove braces
 if["["=first t;t:(1+t?"]")_t];        /  remove params

 q:spans("\""=t)&"\\"<>prev t;         /  quoted

 f:{[t;s]                              /  skip sub-statements
  pp:"([{"!")]}";                      /   punct pairs
  p:first t where(t in key pp)&not s;  /   first non-skipped paired punct in t
  s|not not(or':)                      /   already skipped or include closing puct of
   sums(-)over(not s)&/:t=\:/:p,pp p}; /    arthur magic for balancing nested ranges

 / f:{y|~~|':+\-/(~y)&/:x=\:/:p,pp p:*x@&(~y)&x in!pp:("([{"!")]}")}; / in k

 p:{"[",x,"]"}";"sv string get[x]1;    /  params
 enlist[p],xvs[";";f[t]over q;t]}      /  split on non-skipped ;'s for lines

///
// make a name absolute
// relative names are considered relative to current workspace
// `.foo.x -> `.foo.x
// `x -> `.dir.x if called from .dir (including root)
// @param x name
// @return name in absolute form
absolute:{$[11h=t:type x;.z.s each x;-11h=t;$[null first` vs x;x;` sv(system"d"),x];x]}

///
// make a name relative iff it's in the root
// `x -> `x
// `.foo.x -> `.foo.x
// `..x -> `x
// @param x name
// @return name without leading dots if it was root-absolute; unchanged otherwise
relativeroot:{$[11h=t:type x;.z.s each x;-11h=t;` sv(2*all null 2#x)_x:` vs x;x]}

///
// canonical name -- relative in root, absolute otherwise
// relative names are considered relative to current workspace
// `.foo.x -> `.foo.x
// `x -> `x if called from root
// `x -> `.dir.x if called from .dir (other than root)
// @param x name or function
// @return relative name of x if x is in the root, absolute name otherwise
// @see relativeroot
// @see absolute
canonname:{relativeroot absolute$[-11=type x;x;wtf x]}

///
// add a prefix to the name of a function
// `y -> `.x.y
// `.y.y -> `.x.y.y
// @param x prefix
// @param y name or function
// @return name of y prefixed by x
prefixname:{` sv x,`$("."=first y)_y:string canonname y}

///
// canonicalize function code
//  whitespace trimmed
//  all but first line indented by one space
//  all but last last semi-colon terminated
//  wrapped in braces
//  as string
// @param x code, as list of string
// @return canonical form of code, as string
canoncode:{"{",(-2_1_` sv" ",'@[;0;-1_](trim x),'";"),"}"}

///
// statement assigning canonical code to canonical name
// @param x function to get name from, as name or function
// @param y code to canonicalize, as list of string
// @return statement assigning canonicalized code to canonicalized name, as string
assigncode:{string[canonname x],":",canoncode y}

///
// statement canonicalizing code
// result is suitable for passing directly to "get" to actually execute assignment
// canon:{string[{` sv(2*null x 1)_x:` vs x}$[-11=type x;{$[null first` vs x;x;` sv``,x]}x;wtf x]],":{",(-2_1_` sv" ",'@[;0;-1_](trim lines x),'";"),"}"}
// canon:{string[canonname x],":",canoncode lines x}
// @invariant bytecode identical ({(first get x)~first get get{(1+x?":")_x}canon x})
// @param x function to canonicalize, as name or function
canon:{assigncode[x]lines x}

///
// add breakpoint on entry of function
// @param x function
// @return void
break_entry:{get assigncode[x](1#l),(enlist"if[`..p `debug;",(string prefixname[`.break]x),"_entry]"),1_l:lines x}

///
// does a function have a return value?
// @param x function
// @return true if x has no return value; false otherwise
void:{not count last$[all 10=type each x;x;lines x]}

///
// add breakpoints before each statment of function
// uses new local variable "r" to hold result, so
//  doesn't work on functions that already use "r"
//  (as param, local, or global)
// TODO better return handling
// TODO abstract as "each line" metaf
// @param x function
// @return void
break_all:{
 / if[`t in key`.;'"t not free in `."];
 n:canonname x;
 if[not free[x]`r;'"r not free in ",string n];
 get assigncode[x]$[void x;::;,[;enlist" r"]@[;c;" r:",]trim@]@[;1+i;,;n{";",string .Q.dd[`]`break,x,y}'1+i:til c:count[l]-1]@[;0;::                                    ]l:lines x}

///
// add logging before each statment of function
// @param x function
// @return void
trace_all:{
 get x assigncode{(1#l),(x{"-2\"trace: ",(string x),":",(string y),"\";"}'til count b),'b:1_l:lines x}canonname x}

///
// add profiling statements around each statment of function
// uses new local variable "r" to hold function result and
//  new global variable "t" to hold profile results, so
//  doesn't work on functions that already use "r" or "t"
//  (as param, local, or global) or if a global "t" already
//  exists
// TODO better return and profile data handling
// @param x function
// @return void
// @see readProfile
profile:{
 if[`t in key`.;'"t not free in `."];
 n:canonname x;
 if[not free[x]`t;'"t not free in ",string n];
 if[not free[x]`r;'"r not free in ",string n];
 get assigncode[x]$[void x;::;,[;enlist" r"]@[;c;" r:",]trim@]@[;1+i;,;n{";","t,:(",string[y],";.z.z)"}'1+i:til c:count[l]-1]@[;0;,[;"`..t set([line:1#0]time:1#.z.z);"]]l:lines x}

///
// read profile data
// can be sorted ascending or descending by elapsed time
// @param x sort order, if any: `a is ascending, `d is descending, anything else is none
// @return profile data with elapsed time ("delta") column addded
// @see profile
readProfile:{
 if[not`t in key`.;'"no data"];
 $[x~`a;`delta xasc;x~`d;`delta xdesc;::]update delta:@[;0;:;0Nt]"t"$"z"$deltas time from`. `t}

\

/ use this to identify named local lambdas in wtf?

$ q
KDB+ 2.8 2013.11.20 Copyright (C) 1993-2013 Kx Systems
l64/ 4()core 15951MB daviaaro vmias15863 10.197.5.22 NONEXPIRE  Morgan Stanley - http://kdb, for support email <kdbhelp> #45646

q).lib.d:{[]system"d .q"}
q)\l util.q
q)\l wtf.q
q)\l lines.q
q)\d .foo
q.foo)f:{(g:{break})[][]}
q.foo)f[]
{break}
'break
q.foo))wtf .z.s
`.foo.f.lambda.0
q.foo)){first 1_p . -1_indices[p](xflatten p:parse each lines x)?y}[f;.z.s]
`g
q.foo))
