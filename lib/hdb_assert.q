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
/ require util.q(filter)
/ api at

///
// About: hdb_assert.q
// Some partioned-table assertions.
//
// Verifies that each partitioned table is consistent across partitions.
//
// Generally, tries to verify that all columns are present, in the same order,
//  and have the same types and attributes, and that no extra files exist.
//
// Entry point is the at[] function, which takes no arguments and returns a
//  boolean indicating whether all tests passed.
//
// example where hdb passes:
//
// q)\l hdb_assert.q
// q)\l db
// q)at[]
// 1b
//
// TODO
// failure details
///

/ base utils
read:{f!x f:x`.d}                                      / stolen from q internals
dirs:{.Q.pd .Q.dd'.Q.pv,'x}                            / partition dirs for x
same:1=count group@                                    / all x match each other
none:all 0=count each                                  / all x are empty

/ more utils
dky:{filter[{not(x=`.d)|x like"*#"}]key x}             / splay files that should be in .d
extra  :{(dky x)except x `.d}                          / files in splay not in .d
missing:{(x `.d)except key x}                          / files in .d not in splay

/ test types
asr:{all x{same x{x read y}'dirs y}'.Q.pt}             / all same read
an:{all x{none x each dirs y}'.Q.pt}                   / all none

/ run tests
ag:{[]all asr each(attr';type';.Q.ty';key;meta flip@)} / all good (attributes, types, meta types, cols, meta)
nb:{[]all an each(extra;missing)}                      / none bad (.d/directory consistency)
at:{[]ag[]&nb[]}                                       / all test
