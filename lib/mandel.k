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

///
// About: mandel.k
// A collection of mandelbrot generators and related utilities.
///

///
// the main generator is the standard escape-time algorithm as described at
//  <https://en.wikipedia.org/wiki/Mandelbrot_set#Escape_time_algorithm>;
//
// the second one is a distance-estimator similar to the ones described in
//  <https://en.wikipedia.org/wiki/Mandelbrot_set#Distance_estimates>

///
// the rest of the file is some basic implementations of a few graphics file
//  formats, some complex math functions, and other utility functions

///
// the intended entry point is the "run" function

///
// N.B. this is at least as much as an exercise in developing a coherent k
//  coding style (with inspiration from <http://nsl.com/>) as it is an
//  exercise in math


/ utility functions


/ files
write:{$[4h=t:@p;1:;(~t)&&/10h=@:'p;0:;'`type][x]p:(p 1)@.*p:`\:*|`\:-1!x}      / binary-capable version of .q.save
ce:{`/:(::;`/:)@'@[(::;`\:)@'`\:y;1;|x,1_|:]}                                   / change extension


/ graphics formats

/ pbm
pbm:{("P1";" "/:$#:'(+:;::)@\:x)," "/:'$x}                                      / PBM renderer: header, data

/ pgm
N:{(x-n)%(|//x)-n:&//x}                                                         / normalize to [0 1]
pgm:{("P2";" "/:$#:'(+:;::)@\:x;"255")," "/:'(-|//#:''x)$x:$_255*N x}           / PGM renderer: header, data

/ ppm
ppm:{("P3";" "/:$#:'(+:;::)@\:x;"255")," "/:'" "/:''(-|//#:'''x)$x:$_255*N x}   / PPM renderer: header, data

/ bmp
le:|0x0\:                                                                       / to little-endian
fh:{0x424d,le[6h$14+#x],0x0000000022000000,x}                                   / bitmap file header
dh:{(,/le'"ihhhh"$12,x,y,1 1),z}                                                / DIB header (OS/2 v1)
ct:{0xffffff0000000000,x}                                                       / color table (white, black)
pad:{x,\:((32*-_-w%32)-w:#+x)#0b}                                               / pad rows out to 4 bytes
/pack:{,/0b/:''8 0N#/:x}                                                         / boolean matrix to packed byte matrix
pack:{,/0b/:''0N 8#/:x}                                                         / boolean matrix to packed byte matrix
bmp:{fh dh[#*x;#x]ct pack pad@|x}                                               / BMP renderer: wrapper


/ building the rendering plane
a:{y+(!x)*(z-y)%x-1}                                                            / axis of x steps from y to z
S:{++:'(*:;*|:)@\:/:/:(,\:/:). x}                                               / 2 vectors -> pairs matrix -> 2 matrices
g:{S(::;|:)@'a'[z;*:'(x;y);(*|:)'(x;y)]}                                        / grid


/ complex math
u:{(-;+).'(x*y;x*|y)}                                                           / complex multiply
s:{(((x*x)-y*y);2*x*y)}.                                                        / complex square
n:{sqrt(x*x)+y*y}.                                                              / complex norm


/ misc
l:{if[~.*|$x;0N!x]}                                                             / log
mux:{(y*\:x)+z*\:~x}                                                            / matrix ternary



/ algos


/ escape-time algo
e:{l i+:1;mux[2<n x;y;(,1+*y),x+:s -2#y]}                                       / evolve
E:{i::0;*150 e[x]/(,+z#0),x:g[x;y;z]}                                           / escape time

/ distance-estimator algo
db:{y[`i]&x<n y`Z}                                                              / escaped
dd:{mux[x;y`d]1+2*u[y`Z]y`d}                                                    / next dz
dZ:{mux[x;y`Z]y[`c]+s y`Z}                                                      / next z
dc:{`d`Z`i!(dd[x]y;dZ[x]y;1+y`i)}                                               / update
dl:{if[~.*|$x`i;0N!x`i];x}                                                      / log
de:{dl y,dc[db[x]y]y}                                                           / evolve
da:{(Z*log Z:n x`Z)%n x`d}                                                      / post-proc
dy:{`c`Z`d`i!(x;x;0&0|x;0)}                                                     / make arg
D:{da 150 de[2.0]/dy g[x;y;z]}                                                  / distance estimator



/ color manipulation
hsv:{+:'+(.q.mod[(.q.mod[360*0|.q.xlog[2]x]360)+20*.q.mod[x]2]360;1;N y)}       / iterations, distance

rgbhsv:{c:z*y;hp:x%60;x:c*(1-abs .q.mod[hp;2]-1)                                / http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
 (z-c)+(+:'+(c;x;0))@''((!6)!(0 1 2;1 0 2;2 0 1;2 1 0;1 2 0;0 2 1))@_hp}        /  cont'd

c:{rgbhsv .++:'hsv[E[x;y;z];D[x;y;z]]}                                          / colorize (N.B. caller of algos)



/ entry points

/ general
/  p: output filename
/  x: x coordinate
/  y: y coordinate
/  z: canvas size (scaled)
run4:{[p;x;y;z]                                                                 / driver
 .q.set[g:*`\:*|`\:p]r:c[x;y;z]                                                 /  set global
 write p                                                                        /  save temp
 ![`.;();0b;,g]                                                                 /  drop global
 -1@1_$p}                                                                       /  print file

/ convenience:
/  d: destination directory
/  f: filename base
/  e: file extension/format
/  x: x coordinate
/  y: y coordinate
/  z: canvas size
/  s: scale factor
run:{[d;f;e;x;y;z;s]run4[.Q.dd[d].Q.dd[`$"_"/:$f,z]e;x;y;z*:s]}                 / convenience




/ more fun with fractals
q)sier:{{while[(x>0)|y>0;$[(1=x mod 3)&1=y mod 3;:0b;[x:x div 3;y:y div 3]]];1b}.''{x,/:\:x}til x} / sierpinski carpet

\

/ some example runs

/ common params
dst:`:/u/m/spgrisk/daviaaro/mandel3
fmt:`ppm
scale:1

/ the whole bug
\ts run[dst;`mandel  ;fmt;-2 1                     ;-1 1                    ;80 60]scale

/ the north radical <http://mrob.com/pub/muency/r213a.html>
\ts run[dst;`mu2d1o3 ;fmt;-0.12256116628477+-1 1*.3;0.74486176791682+-1 1*.3;60 60]scale

/ ~center ninth of the north radical
\ts run[dst;`mu2d1o3c;fmt;-0.2225612 -0.02256117   ;0.6448618 0.8448618     ;60 60]scale

/ https://commons.wikimedia.org/wiki/File:Mandel_zoom_06_double_hook.jpg
\ts run[dst;`wiki    ;fmt;-0.7436997 -0.743582     ;0.1317881 0.1318666     ;80 60]scale
