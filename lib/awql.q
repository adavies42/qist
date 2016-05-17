#!/usr/bin/env q

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
// About: awq.q & awql.q
// A script for using q as a unix filter (like awk).
// Expects a q expression as first command-line argument.
// If invoked with a name ending in "l", or if environment variable AWQ
//  contains "l", runs expression on each line of input separately;
//  otherwise runs it on all input once, after input finishes.
// Additional command-line arguments are available to the expression,
//  but otherwise ignored.
// Note that the null expression is valid.
// "--help" as the first argument will produce a help message.
//
// Examples:
//
//  # total disk space by user in the current subtree, sorted by size descending
//  find -printf '%s\t%u\n'|awq '{select[>size]sum size by user from flip`size`user!("JS";"\t")0:x}'
//
//  # average time between first and last entries in a directory of timestamped logs
//  for x in *.log
//  do
//      grep -Po '^\d{4}.\d{2}.\d{2}.\d{2}:\d{2}:\d{2}' "$x"|sed -n '1p;$p'|tac
//  done|awq '{avgx(-). flip 2 cut"P"$x}'

if["--help"~first .z.x;-1"Usage: ",(string last` vs hsym .z.f)," ['expression' [...]]";exit 0]

/ compile the expression as q code
f:"q"q:first .z.x,""

/ format for output: if a string or a general list with a string as  its first
/  item, do nothing; otherwise use .Q.s, but split back to list of string
o:{$[$[type x;10=type x;10=type first x];;` vs .Q.s@]x}

/ whether to run in single-line mode
l:("l"in getenv`AWQ)|(first` vs last` vs hsym .z.f)like"*l"

/ extract a plain string from a single line of .z.pi input
e:{first` vs x}

/ in single-line mode, set .z.pi to extract, process, format, and print each
/  line as it arrives
/ in multi-line mode, set .z.pi to accumulate lines, then set .z.exit to
/  extract, process, format, and print the whole text once input finishes
$[l;[.z.pi:{-1 o f e x}                       ];
    [.z.pi:{t,:x}      ;.z.exit:{-1 o f` vs t}]];
