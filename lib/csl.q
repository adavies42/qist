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
/ api csl

///
// About: csl.q
// A function for pretty-printing data as comma-separated lists.
//
// Examples:
//
//  empty list:
//  q)csl`$()
//  ""
//
//  one item:
//  q)csl`foo
//  "foo"
//
//  two items:
//  q)csl`foo`quux
//  "foo and quux"
//
//  three items:
//  q)csl`foo`bar`quux
//  "foo, bar, and quux"
//
// Test:
//
//  q)tests:(`$();();`foo;"foo";`foo`quux;("foo";"quux");`foo`bar`quux;("foo";"bar";"quux");`;"")
//  q)expected:(("";"foo";"foo and quux";"foo, bar, and quux")!(0 1 8 9;2 3;4 5;6 7))
//  q)expected~group csl each tests
//  1b
///

///
// comma-separated list
// formats data as comma-separated string
// meant for reporting, logging, etc.
// @param x data to format (list or atom, any type)
// @return x as a comma-separated string
csl:{$[0=c:count x:raze each string$[type[x]in -11 10h;enlist;]x;"";
       1=c;"c"$raze x;
       2=c;" and "sv x;
           ", and "sv(", "sv -1_x;last x)]}
