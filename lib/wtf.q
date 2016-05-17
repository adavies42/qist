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
/ require util.q metax.q(metax)
/ api fdp wtf callers breaks

///
// About: wtf.q
// "What the function", a debugging suite.
// Attempts to solve the "I'm at an error prompt, but I don't
//  know what function I'm in!" problem.
///

///
// function dictionary pairs
// runs a function on each pair of keys and values in a dictionary,
//  transforming result back into a dictionary
// N.B. capable of returning a dictionary of more or less elements
//  than given
// @param x function
// @param y dictionary
// @return result of running x on each key-value pair in y
fdp:{(!). flip raze x .'flip(key y;get y)}; / function dictionary pairs

///
// reduce any object to a list containing no list/vector elements
// N.B. not very reliable (drops empties, does weird things w/tables/dicts, etc.)
// alternate implementation: {$[type[x];x;first r:.[,;(1;min[2,count x]#x);0];(r;.z.s 2_x;x]}
// @param x data
// @return x flattened
xflatten:{({.[,;(x;y);(x;y)]}over)over x}

///
// gives indices to use with dot to retrieve each element from a nested list
// @param x data
// @return list of depth indices for each element of x
indices:{{$[type[y]within 0 97h;raze(x,/:til count y).z.s'y;enlist x]}[`int$()]x}

///
// catalog of names of all objects in workspace
// includes deep names (.foo.bar.baz)
// `. is after `.? so "each", etc. match properly
// test:
//  q)f:{{'break}each x}
//  q)f[]
//  {'break}
//  'break
//  q))'
//  k){x'y}
//  '
//  @
//  {'break}'
//  q.q))wtf .z.s
//  `.q.each
// `..f.lambda.1 is an error
// @param x workspace, or (any) null for all
// @return catalog of all names in workspace
wtfcat:{
 $[$[null x;1b;(x like"..?*")&(last` vs x)in views`.;0b;
     99=type get x;(`.~x)|((1#.q)~1#get x)&11h~type key x;0b];
   2 raze/.z.s each'x .Q.dd''key each x:$[null x;``.;x];x]}

///
// return a dictionary of all known lambdas defined in the workspace, appropriately labeled
// currently capable of finding:
//  global functions
//   plain (100h) (name)
//   part of a projection (104h) (name.arg.n)
//   part of a composition (105h) (name.comp.n)
//   modified by an adverb [106 111h] (name)
//   any combination of the above
//  local functions (name.lambda.n)
//  functions in a view (name.view.parse.n.m...)
// tests:
//  view:
//   q)b::{'break}'[1 2]
//   q)b[]
//   {'break}
//   'break
//   q))wtf .z.s
//   `..b.view.parse.0.1
//   q)).z.s~parse[view`b]. 0 1
//   1b
// TODO consolidate lambda processing into converge?
// @return dictionary of all lambdas
wtffd:{[]
 vf:{$[(v:last` vs x)in views`.;parse view v;get x]}each; / view/function

 v:{$[(last` vs x)in views`.;[flip((x,`view`parse).Q.dd/:indices y;xflatten y)];enlist(x;y)]}; / view

 apcl:fdp[{ / adverb/projection/composition/list
  $[(t:type y)within 106 111h;enlist(x;get y); / handle adverbs
    t in 104 105h;flip(((x,`arg`comp 105h=t).Q.dd/:til count p);@[p;where(::)~'p:get y;:;::]); / break up projections/compositions
    not t;flip((x,`item).Q.dd/:til count y;y); / list items
    enlist(x;y)]}]; / don't change others

 fc:{(t=100h)|(t:type each x)within 104 111h}; / function constraint

 l:{enlist[(x;y)],raze .z.s'[(x,`lambda).Q.dd/:til count p;p@:where 100h=type each p:get y]}; / lambda
 / if[$[`debug in key`.;get`..debug;0b];'break];
 fdp[l]dfilter[fc]apcl over fdp[v]mapd[vf]wtfcat[]}

///
// look up the name of a function
// usually called as "wtf .z.s" from inside an error prompt
// @param x function
// @return name of the function, if found; null sym, otherwise
wtf:{wtffd[]?x}

///
// find callers of a function
// @param x function, by name
// @return names of callers of x
callers:{where x{x in get[y]3}'wtffd[]}

///
// functions with breakpoints
// @return names of functions with breakpoints
breaks:{[]where(any like[;"*break*"]@)each(metax each wtffd[])[;`g]}

\

///
// two-level-only workspace catalog
// skips names like .foo.bar.baz
// k impl: k){[]f:{x .Q.dd''!:'x};,/f'`.,f`}
// @return catalog
q){[]f:{x .Q.dd''key each x};raze f each`.,f`}

///
// arbitrary-depth workspace catalog
// includes names like .foo.bar.baz
// k impl: k){$[$[^x;1;99=@.:x;`~*!x;0b]|`.~x;,//.z.s''x .Q.dd''!:'x:$[^x;`.`;x];x]}
// @param x workspace, or (any) null for all
// @return catalog
q){$[$[null x;1;99h=type get x;`~first key x;0b]|`.~x;(raze/).z.s each'x .Q.dd''key each x:$[null x;`.`;x];x]}
