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
/ require util.q metax.q
/ api locals params globals limits free state

///
// About: debug.q
// More experimental debugging utilities.
///

///
// Locals of the current function and their values.
// N.B. only works at error prompt
// alternate implementation
//  "tacit"/point-free, may work in slightly different contexts
//  locals:('[mapd[eval each]@[;`l]metax eval first@;(`.z.s;)]) / local version
// e.g.
//  q){a:1;break}[]
//  {a:1;break}
//  'break
//  q))show locals[]
//  a| 1
//  q))
// @return dictionary of local variables of the current function and their values
locals:{[]mapd[eval each]metax[eval`.z.s]`l} / nested scopes are visible to eval!?!? (but only from an error prompt...?)

///
// Parameters of the current function and their values.
// N.B. only works at error prompt
// e.g.
//  q){break}2
//  {break}
//  'break
//  q))show params[]
//  x| 2
//  q))
// @return dictionary of parameters of the current function and their values
params:{[]mapd[eval each]metax[eval`.z.s]`p} / params too!

///
// Globals used by the current function and their values.
// N.B. only works at error prompt
// e.g.
//  q)a:3
//  q)f:{break;a}
//  q)f[]
//  {break;a}
//  'break
//  q))show globals[]
//  break| "break"
//  a    | 3
//  q))
// @return dictionary of global variables used by the current function and their values
globals:{[]mapd[@[eval;;::]each]1_metax[eval`.z.s]`g} / and globals of course

///
// Info about how close a function is to the compiler limits.
// Returns a table giving the number used and number remaining for each of the four
//  compiler limits for functions (params/locals/globals/constants).
// @param x function
// @return table of x's usage of compiler-limited resources
limits:{([limit:`params`locals`globals`constants]used:c;avail:8 23 31 96-c:count each 0 0 1 0_'metax[x]`p`l`g`c)}

///
// Is a variable name available to use in a function?
// Checks that a name is not a reserved word, a built-in function, or already used
//  as a parameter, local, or global in a function.
// @param x function
// @param y name
// @return 1b if x is available to use in y; 0b otherwise
free:{not y in .Q.res,key[`.q],raze metax[x]`p`l`g}

///
// A general debugging tool. Attempts to present a unified view of all interesting
//  information available at a debug prompt.
// No return value--all information is printed to console.
// Currently includes:
//  .z.s, optionally canonicalized
//  globals
//  parameters
//  locals
//  (guessed) function name
//  (guessed) line in function
//  (guessed) source file
// N.B. HIGHLY EXPERIMENTAL
//  possibleLocation, in particular, is not at all reliable
// @param x canonicalize code?
// @return void
/state:{
/ -1{(neg"\n"=last x)_x}over` sv enlist[$[@["b"$;x;0];canon;string][eval`.z.s],"\n"],
/   (`globals`params`locals`wtf`possibleLocation`wheretf{(string[x],":\n"),.Q.s .lib.dd . x,y}'eval`.z.s);}

state:{
 -1{(neg"\n"=last x)_x}over` sv enlist[` sv(enlist"source:"),numberedList` vs$[@["b"$;x;0];canon;string][eval`.z.s],"\n"],
   (`globals`params`locals`wtf`possibleMaxCurrentLineNumber`possibleLocation`wheretf{(string[x],":\n"),.Q.s .lib.dd . x,y}'eval`.z.s);}

///
// Possibly uninitalized local variables.
// All locals set to general empty list.
// N.B. It is of course possible to set a variable to this explicitly.
// @return names of (possibly) uninitialized local variables
ul:{[]where()~/:locals[]}

///
// Which lines of x "match" (in the ss sense) y.
// @param x list of string
// @param y pattern
// @return indices of lines of x where x ss\:y finds any matches
xss:{where 0<count each x ss\:y}

///
// Which lines of the current function are assignments to a local variable.
// N.B. only works at error prompt
// @param x variable
// @return indices of lines of the current function where x is assigned to
la:{xss[` vs string eval`.z.s]string[x],":"}

///
// Which lines of the current file are assignments to a global variable.
// N.B. only useful when .z.f is set
// @param x variable
// @return indices of lines of .z.f where x is assigned to
ga:{$[null .z.f;0#0;xss[read0 .z.f]string[x],":"]}

///
// Guess max current line.
//  A very rough guess at the max possible current line of the function.
//  Looks for the first assignment to the first uninitialized local variable.
// N.B. HIGHLY EXPERIMENTAL
// N.B. only works at error prompt
// @return a guess at the max possible line number of the current function
//  that could have been executed before entering the debug prompt
possibleMaxCurrentLineNumber:gmcl:{[]first[la first ul[]]}

///
// Guess function line in file.
//  A very rough guess at the line of .z.f where .z.s is defined.
// N.B. HIGHLY EXPERIMENTAL
// N.B. only works at error prompt
// @return a guess at the (first) line of .z.f where .z.s is defined
gflf:{[]first ga last` vs wtf eval`.z.s}

///
// Guess line in .z.f where execution might have stopped before
//  entering the debug prompt.
// Among many other problems, only works on functions defined in .z.f.
// N.B. HIGHLY EXPERIMENTAL
// N.B. only works at error prompt
// @return `filename:line, where filename is a source file and line
//  is a guess at a line number where the debug prompt was entered
possibleLocation:gs:{[]`$":"sv string(.z.f;1+gflf[]+gmcl[]-1)}

///
// Right-justify text.
// @param x list of string
// @return x padded on the left with spaces as necessary to rectangularize
rightJustify:{(neg max count each x)$x}

///
// Number the lines of a list.
// @param x list of string
// @return x with line numbers added
numberedList:{" "sv'flip(rightJustify string til count x;x)}
