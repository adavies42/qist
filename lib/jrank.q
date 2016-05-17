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
/ api jrank shape take

///
// About: jrank.q
// J's rank and shape functions, and a version of take (#) that works with more than two dimensions.
///

///
// dimensionality of data
// inspired by the rank concept from APL & J
// @invariant {jrank[x]=count shape x}
// @param x data
// @return the number of dimensions in x
// @see take
// @see shape
// @see http://jsoftware.com/help/dictionary/intro20.htm
jrank:{count shape x}

///
// dimensions of data
// inspired by the shape operator from APL & J
// @invariant {x~shape[x]take raze over x}
// @param x data
// @return dimensions of x (vector)
// @see take
// @see jrank
// @see http://jsoftware.com/help/dictionary/intro20.htm
shape:{$[x~();x;0>type x;key 0;(count x),.z.s first x]}

///
// a version of # that accepts more than 2 dimensions
// e.g.
//  q)-3!2 4 3 take til 24
//  "((0 1 2;3 4 5;6 7 8;9 10 11);(12 13 14;15 16 17;18 19 20;21 22 23))"
//  q)
// @invariant {x~shape[x]take raze over x}
// @param x expected shape
// @param y data
// @return y reshaped as a multi-dimensional array with shape x
// @see shape
// @see jrank
take:{y{y cut x}/reverse 1_x}

\

q)r:2 4 3 take til 24
q)unshow(shape;count;jrank)@\:r
(2 4 3;2;3)
q)
