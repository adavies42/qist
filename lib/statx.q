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
/ api medx avgx wsumx wavgx varx devx

///
// About: statx.q
// A collection of type-consistent stat functions.
// Particularly handy when working with temporals, where
//  many built-in stat functions return floats.
//
// Examples:
//
//  average of times:
//  q)avgx 09:00 09:10
//  09:05
//
//  bell-curve points:
//  q){(avgx x)+-2 0 2*devx x}00:05 00:06 00:10 00:01 03:00 00:15 24:10
//  -12:38 03:58 20:34
///

///
// type-consistent med
// always returns same type as arg
// @param x data
// @return med of x, with same type as x
medx:{(type x)$med x}

///
// type-consistent avg
// always returns same type as arg
// @param x data
// @return avg of x, with same type as x
avgx:{(type x)$avg x}

///
// type-consistent wsum
// always returns same type as data arg
// @param x weights
// @param y data
// @return x wsum y, with same type as y
wsumx:{(type y)$x wsum y}

///
// type-consistent wavg
// always returns same type as data arg
// @param x weights
// @param y data
// @return x wavg y, with same type as y
wavgx:{(type y)$x wavg y}

///
// type-consistent var
// always returns same type as arg
// @param x data
// @return var of x, with same type as x
varx:{(type x)$var x}

///
// type-consistent dev
// always returns same type as arg
// @param x data
// @return dev of x, with same type as x
devx:{(type x)$dev x}
