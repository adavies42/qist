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
/ require util.q
/ api histo histobar histobar2

///
// About: histo.q
// Two functions for generating ASCII histograms.
///

///
// count data by buckets
// e.g.
//  q)histobar[2]1 2 3
//  0| 1
//  2| 2
//  q)
// result can be passed to histo[] for rendering
// e.g.
//  q)histo histobar[2]1 2 3
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//                                         |***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ***************************************|***************************************
//  ---------------------------------------+---------------------------------------
//  0                                      |2
//  q)
// @param x bucket size
// @param y data, as vector or dictionary (but not table)
// @return dictionary of buckets!counts
histobar:{{0^k!count[k:distinct x xbar(until).(min;max)@\:key y]#0#get y}[x;d],d:count each group x xbar y}

///
// generate histogram (v1)
// TODO print keys vertically if necessary
// @param x data (as vector, dictionary, or (optionally keyed) 2-column table)
// @return histogram of data (as list of strings)
histo1:{
 x:$[not count x;'`domain;
     (not .Q.qt x)&99h=t:type x;x;
     t within 1 19h;(til count x)!x;
     .Q.qt x;[if[not 2=count cols x;'`type];(!/)get flip 0!x];
     '`type];
 if[11h=type get x;'`type];
 if[any 0>x;'`nyi];
 ("|"sv'flip get(flip w#enlist neg[h]$)each(0^ceiling x*(h:-4+first c)%max x)#'"*"),
 "+|"sv'flip flip each"-",''($[w:-1+last[c:system"c"]div count x;w;'`wide])$string key x}

///
// generate histogram (v2)
// @param x data (as vector, dictionary, or (optionally keyed) 2-column table)
// @return histogram of data (as list of strings)
histo2:{
 x:$[not count x;'`domain;
     (not .Q.qt x)&99h=t:type x;x;
     t within 1 19h;(til count x)!x;
     .Q.qt x;[if[not 2=count cols x;'`type];(!/)get flip 0!x];
     '`type];
 if[11h=type get x;'`type];
 if[any 0>x;'`nyi];
 $[0<w:-1+last[c:system"c"]div count x;w;'`wide];
 x1:"+|"sv'flip flip each"-",''w$string key x;
 x2:("+",m#"|")sv'string flip"-",'(neg m:max count each s)$s:string key x;
 b:("|"sv'flip get(flip w#enlist neg[h]$)each(0^ceiling x*(h:-4+first c:system"c")%max x)#'"*");
 b,$[m>w;x2;x1]}
/ ("+",m#"|")sv'string flip"-",'(m:max count each s)$s:string key x}
/ "+|"sv'flip flip each"-",''$[w:-1+last[c:system"c"]div count x;w;'`wide]$string key x}

///
// print histogram
// @param x data (as vector, dictionary, or (optionally keyed) 2-column table)
// @return void
// @see histo1
/histo:{-1 x;}histo1@
histo:{-1 x;}histo2@

///
// rack a single-keyed table by an increment (xbar arg)
// @param x increment
// @param y table with exactly one key column
// @return y with key entries for all buckets from 0 to max y, including empty ones
histobar21:{
 if[99<>type y;'`type];
 if[(98=type k)&1<>count cols k:key y;'`nyi];
 ?[k;();0b;{y!x each y}[{(x;y)}{$[any null y;(y 0N),;]x*(.lib.dd`until). (type y)$floor (0;1+max y)%x}x]cols k]#y}

///
// histobar with rack
// result can be passed to histo[] for rendering
// select count i by x xbar c from y, for one-column y, with rack
// @param x xbar
// @param y vector or one-column table
// @return count of x-width buckets of y, including empty buckets
// @see histobar21
// @see histobar
// @see histo
histobar2:{
 y:$[(t:type y)within 1 19;([]y);98=t;y;'`type];
 if[1<>count cols y;'`nyi];
 0^histobar21[x]?[y;();{y!x each y}[{(x;y)}{(xbar;x)}x]cols y;(enlist`x)!enlist(count;`i)]}
