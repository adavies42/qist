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
write:{x 1:$[e like"p?m";spnm;::](. e:*|"."\:*|"/"\:$x)y}                       / sort of like .q.save (but with data on y)
ce:{"/"/:@[y;(#y:"/"\:$$[|/"/"=$y;y;"./",$y])-1;{"."/:(-1_"."\:x),,y};$x]}      / change extension


/ graphics formats

/ pbm
pbm:{("P1";" "/:$#:'(+:;::)@\:x)," "/:'$x}                                      / PBM renderer: header, data

/ pgm
N:{(x-n)%(|//x)-n:&//x}                                                         / normalize to [0 1]
pgm:{("P2";" "/:$#:'(+:;::)@\:x;"255")," "/:'(-|//#:''x)$x:$_255*N x}           / PGM renderer: header, data

/ ppm
ppm:{("P3";" "/:$#:'(+:;::)@\:x;"255")," "/:'" "/:''(-|//#:'''x)$x:$_255*N x}   / PPM renderer: header, data

/ bmp
le:{`i$|(((`h`i`j!2 4 8)@@x)#256)\:x}                                           / to little-endian
fh:{(`i$0x424d,le[14+#x],0x0000000022000000),x}                                 / bitmap file header
dh:{(,/le'`i`h`h`h`h$12,x,y,1 1),z}                                             / DIB header (OS/2 v1)
ct:{255 255 255 0 0 0 0 0,x}                                                    / color table (white, black)
pad:{x,\:((32*-_-w%32)-w:#+x)#0}                                                / pad rows out to 4 bytes
pack:{,/2/:''(8*!`i$(#*x)%8)_/:x}                                               / boolean matrix to packed byte vector
bmp:{`c$fh dh[#*x;#x]ct pack pad@|x}                                            / BMP renderer: wrapper


/ building the rendering plane
a:{y+(!x)*(z-y)%x-1}                                                            / axis of x steps from y to z
S:{++:'(*:;*|:)@\:/:/:(,\:/:). x}                                               / 2 vectors -> pairs matrix -> 2 matrices
g:{S(::;|:)@'a'[z;*:'(x;y);(*|:)'(x;y)]}                                        / grid


/ complex math
u:{(-;+).'(x*y;x*(|y))}                                                         / complex multiply
s:{(((x*x)-y*y);2*x*y)}.                                                        / complex square
n:{sqrt(x*x)+y*y}.                                                              / complex norm


/ misc
l:{if[~.*|$x;` 0:,$x]}                                                          / log
mux:{(y*\:x)+z*\:~x}                                                            / matrix ternary
signum:{(x>0)-x<0}                                                              / from q
ltrim:{( +/&\" "= x)_x}                                                         / ditto
rtrim:{(-+/&\" "=|x)_x}                                                         / ditto
modx:{(x*y<0)+(signum y)*x mod abs y}                                           / workaround for mod of negative float
spnm:{"\n"/:@[`m@x;0 1 2;rtrim],,""}                                            / string from pgm/ppm



/ algos


/ escape-time algo
e:{l i+:1;mux[2<n x;y;(,1+*y),x+:s -2#y]}                                       / evolve
E:{."i:0";*150 e[x]/(,+z#0),x:g[x;y;z]}                                         / escape time

/ distance-estimator algo
db:{y[`i]&x<n y`Z}                                                              / escaped
dd:{mux[x;y`d]1+2*u[y`Z]y`d}                                                    / next dz
dZ:{mux[x;y`Z]y[`c]+s y`Z}                                                      / next z
dc:{`d`Z`i!(dd[x]y;dZ[x]y;1+y`i)}                                               / update
dl:{if[~.*|$x`i;` 0:,$x`i];x}                                                   / log
de:{dl y,dc[db[x]y]y}                                                           / evolve
da:{(Z*log Z:n x`Z)%n x`d}                                                      / post-proc
dy:{`c`Z`d`i!(x;x;0&0|x;0)}                                                     / make arg
D:{da 150 de[2.0]/dy g[x;y;z]}                                                  / distance estimator



/ color manipulation
hsv:{+:'+(modx[360](modx[360]360*0|2 log x)+20*modx[2]x;1;N y)}                 / iterations, distance

rgbhsv:{[x;y;z]c:z*y;hp:x%60;x:c*(1-abs(modx[2]hp)-1)                           / http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
 (z-c)+(+:'+(c;x;0))@''((!6)!(0 1 2;1 0 2;2 0 1;2 1 0;1 2 0;0 2 1))@_hp}        /  cont'd

c:{rgbhsv .++:'hsv[E[x;y;z];D[x;y;z]]}                                          / colorize (N.B. caller of algos)



/ entry points

/ general
/  p: output filename
/  x: x coordinate
/  y: y coordinate
/  z: canvas size (scaled)
run4:{[p;x;y;z]                                                                 / driver
 f:`ppm`pgm`pbm`bmp!(::;avg'';{x>avg/x}@avg'';{x>avg/x}@avg'')                  /  converters
 r:c[x;y;z]                                                                     /  run
 r:{$[y in!x;x[y]z;domain]}[f;`$*|"."\:*|"/"\:p]r                               /  convert
 write[p]r                                                                      /  save
 ` 0:,p}                                                                        /  print file

/ convenience:
/  d: destination directory
/  f: filename base
/  e: file extension/format
/  x: x coordinate
/  y: y coordinate
/  z: canvas size
/  s: scale factor
run:{[d;f;e;x;y;z;s]run4["/"/:(d;"."/:("_"/:$f,z;$e));x;y;z*:s]}                / convenience




/ more fun with fractals
sier1:{$[&/~0<x,y;1;&/1=3 mod x,y;0;sier1 .`i$(x,y)%3]};sier:sier1 .''{x,/:\:x}@!: / sierpinski carpet

\

/ some example runs

/ common params
dst:"/Users/adavies/Downloads/k7/out"
fmt:`ppm
scale:1

/ the whole bug
\t run[dst;`mandel  ;fmt;-2 1                     ;-1 1                    ;80 60]scale

/ the north radical <http://mrob.com/pub/muency/r213a.html>
\t run[dst;`mu2d1o3 ;fmt;-0.12256116628477+-1 1*.3;0.74486176791682+-1 1*.3;60 60]scale

/ ~center ninth of the north radical
\t run[dst;`mu2d1o3c;fmt;-0.2225612 -0.02256117   ;0.6448618 0.8448618     ;60 60]scale

/ https://commons.wikimedia.org/wiki/File:Mandel_zoom_06_double_hook.jpg
\t run[dst;`wiki    ;fmt;-0.7436997 -0.743582     ;0.1317881 0.1318666     ;80 60]scale
