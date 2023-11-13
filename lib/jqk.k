#!/usr/bin/env q

// Copyright 2023 Morgan Stanley
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
// About: jqq.q
// A script for using q as a unix filter for json (like jq).
// Expects a q expression as first command-line argument.
// Additional command-line arguments are available to the expression,
//  but otherwise ignored.
// Note that the null expression is valid.
// "--help" as the first argument will produce a help message.
//
// Examples:
//
//  # table of titles of jq issues, sorted
//  curl -L https://api.github.com/repos/stedolan/jq/issues|jqq '{([]issues:asc x[;`title])}'

if["--help"~*.z.x;-1"Usage: ",($*|`\:-1!.z.f)," ['expression' [...]]";exit 0]

/ compile the expression as q code
f:"k"k:*.z.x,""

/ format for output: if a string or a general list with a string as  its first
/  item, do nothing; otherwise use .Q.s, but split back to list of string
o:{$[$[@x;10=@x;&/10=@:'x];;`\:.Q.s@]x}

/ extract a plain string from a single line of .z.pi input
e:{*`\:x}

/ accumulate lines
.z.pi:{t,:x}

/ parse, process, format, and print once input finishes
.z.exit:{-1 o f .j.k t}
