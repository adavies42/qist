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
/ require
/ api ungroupx1 ungroupx2

///
// About: ungroupx.q
// Alternate versions of ungroup.
// ungroupx1: a version of ungroup that can be run under "over".
// ungroupx2: a version of ungroup that works on keyed tables with string columns
///

///
// alternate version of ungroup that returns table unmodified if not nested
//  safe for "over" to fully flatten multiply-nested table
//  e.g. ungroupx1 over([]x:((1 2;3 4);(5 6;7 8)))
// @param x table
// @return x ungrouped if it was grouped, otherwise x unmodified
ungroupx1:{$[(any not type each flip x)&count x:0!x;raze flip each x;x]}

///
// alternate version of ungroup that works on keyed tables with string columns
//  in the key section
//  e.g. ungroupx2([k:("foo";"quux")]v:(1 2;3 4 5))
// @param x keyed table
// @return x ungrouped, with any strings in the key section copied down properly
ungroupx2:{
 if[$[99<>type x;1;any 98<>type each(key x;get x)];'`type];
 ungroup![x;();0b;{y!x{((';#);x;((';,:);y))}/:y}[count each first flip get x]keys x]}
