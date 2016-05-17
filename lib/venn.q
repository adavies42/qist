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
/ require uniq
/ api venn venn2

///
// About: venn.q
// A function for comparing sets.
///

///
// compare two sets and return the cardinalities of various parts of
//  their venn diagram
// note that set-ness is strictly enforced--the function fails if either
//  is not distinct
//
//                         union
//                           |
//                           |
//     /---------------------+---------------------\
//    /                                             \
//    |/---------- X -------\                       |
//    /            |         \                      |
//    |        ---------     |     ---------        |
//    |    ---/         \---   ---/         \---    |
//    |   /                 \ /                 \   |
//      -/                  -+-                  \-
//     /                   /   \                   \
//     |                   |   |                   |
//    /                   /     \                   \
//    |       left        | in- |     right         |
//    \                   \ ter /                   /
//     |                   |   |                   |
//     \                   \   /                   /
//      -\                  -+-                  /- |
//    |   \                 / \                 /   |
//    |    ---\         /---   ---\         /---    |
//    |        ---------     |     -----+---        |
//    |                   |  \          |           /
//    |                   |   \-------- Y ---------/
//    \                   /
//     \--------+--------/      |                   |
//              |               |                   |
//              |               \                   /
//              |                \---------+-------/
//              |                          |
//              |                          |
//              \                          /
//               \-------- symdiff -------/
//
// @param x the left set
// @param y the right set
// @return a dictionary of the counts of various parts of the venn diagram of the two sets
// @throws "'x: u-fail" if x is not distinct
// @throws "'y: u-fail" if y is not distinct
//
// Example:
//
//  q)l1:1 2 3 4 5 6 7 8 9 10
//  q)l2:7 8 9 10 11 12
//  q)venn[l1]l2
//  union  | 12
//  x      | 10
//  left   | 6
//  inter  | 4
//  right  | 2
//  y      | 6
//  symdiff| 8
/venn:{
/ if[not first t:@[(1;)`u#;x;(0;)];'"x: ",last t];
/ if[not first t:@[(1;)`u#;y;(0;)];'"y: ",last t];
/ r:(0#`)!0#0;
/ r[`union]:count x union y;
/ r[`x]:count x;
/ r[`left]:count x except y;
/ r[`inter]:count x inter y;
/ r[`right]:count y except x;
/ r[`y]:count y;
/ r[`symdiff]:(count x except y)+(count y except x);
/ r}
venn:{
 if[not uniq x;'"x: u-fail"];
 if[not uniq y;'"y: u-fail"];
 o:(0#`)!0#0;
 l:x except y;
 r:y except x;
 i:x inter y;
 o[`union]:sum count each(l;i;r);
 o[`x]:count x;
 o[`left]:count l;
 o[`inter]:count i;
 o[`right]:count r;
 o[`y]:count y;
 o[`symdiff]:sum count each(l;r);
 o}

// @param x the left set
// @param y the right set
// @return a dictionary of the various parts of the venn diagram of the two sets
// @throws "'x: u-fail" if x is not distinct
// @throws "'y: u-fail" if y is not distinct
// @see venn
//
// Example:
//
//  q)l1:1 2 3 4 5 6 7 8 9 10
//  q)l2:7 8 9 10 11 12
//  q)venn2[l1]l2
//  union  | 1 2 3 4 5 6 7 8 9 10 11 12
//  x      | 1 2 3 4 5 6 7 8 9 10
//  left   | 1 2 3 4 5 6
//  inter  | 7 8 9 10
//  right  | 11 12
//  y      | 7 8 9 10 11 12
//  symdiff| 1 2 3 4 5 6 11 12
/venn2:{if[not first t:@[(1;)`u#;x;(0;)];'"x: ",last t];
/ if[not first t:@[(1;)`u#;y;(0;)];'"y: ",last t];
/ r:(enlist`)!enlist(::);
/ r[`union]:x union y;
/ r[`x]:x;
/ r[`left]:x except y;
/ r[`inter]:x inter y;
/ r[`right]:y except x;
/ r[`y]:y;
/ r[`symdiff]:(x except y),(y except x);
/ 1_r}
venn2:{
 if[not uniq x;'"x: u-fail"];
 if[not uniq y;'"y: u-fail"];
 o:(enlist`)!enlist(::);
 l:x except y;
 r:y except x;
 i:x inter y;
 o[`union]:l,i,r;
 o[`x]:x;
 o[`left]:l;
 o[`inter]:i;
 o[`right]:r;
 o[`y]:y;
 o[`symdiff]:l,r;
 1_o}
