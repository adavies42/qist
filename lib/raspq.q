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

/ The built-in s-ops

tokens:{x}
indices:{til count x}
length:{c#c:count x}

tokens"hi"
indices"hi"
length"hi"

/ Elementwise combination

1+indices"hi"
{(length x)=1+indices x}"hi"
{?[0=(indices x)mod 2;tokens x;"-"]}"hello"

/ Select and aggregate
Select:{x z\:/:y}
aggregate:{0^avg each y where each x}

Select[0 1 2;1 2 3;<]
aggregate[Select[0 1 2;1 2 3;<];10 20 30]

a:{Select[indices x;indices x;<]}
a"hey"
{aggregate[a x;1+indices x]}"hey"

/ Simple select-aggregate examples
Flip:{Select[indices x;(length x)-1+indices x;=]}
Reverse:{aggregate[Flip x;tokens x]}

Flip"hey"
"c"$Reverse"hey"

select_all:{Select[(count x)#1;(count x)#1;=]}
frac_as:{aggregate[select_all x;{?["a"=tokens x;1;0]}x]}

frac_as"aabbb"

load1:{Select[indices x;1;=]}
{load1[x]|Flip[x]}"hey"

selector_width:{sum each x y}

same_token:{Select[tokens x;tokens x;=]}
histo:{(selector_width same_token)x}

histo"hello"

sort:{
    smaller:{Select[y;y;<]|Select[y;y;=]&Select[indices x;indices x;<]}[;y];
    target_pos:(selector_width smaller)x;
    sel_new:Select[target_pos;indices x;=];
    aggregate[sel_new;x]}
sort_input:{sort[tokens x;tokens x]}
