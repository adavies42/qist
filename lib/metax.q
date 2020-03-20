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
/ require util.q(saferaze) ../unpublished/Q.k(.Q.ev)
/ api metax mmetax mmetaxs denumt

///
// About: metax.q
// Extensions to meta to provide more information or to work on other data types.
///

///
// Intended entry points are metax, mmetax, mmetaxs, and denumt.
// metax: standard meta with key and enum info for tables, new meta for dictionaries and functions
// mmetax: table of metax on all tables
// mmetaxs: table of metax on all tables, with check for duplicate cols
// denumt: de-enumerate symbols in a table

///
// An extension of meta that includes key and enumeration information.
// k: a flag indicating whether this column is part of the primary key of the table
// e: the name of the enumeration, if any, of symbol columns
// @param x table
// @return meta x, with additional key and enum info
metaa:{([c].Q.ty each t;f:.Q.fk each t;a:attr each t;k:(c:key v)in keys x;e:.Q.ev each t:get v:.Q.V x)}

///
// A version of metaa for dictionaries.
// Returns a crosstab with two rows, one for key and one for value, with metaa-type
//  columns giving type, foreign key, attribute, and enum.
// @param x dictionary
// @return crosstab of metadata about x
metad:{`k`v!flip`t`f`a`e!flip(.Q.ty;.Q.fk;attr;.Q.ev)@\:/:(key x;get x:.Q.v x)}

///
// A version of meta for functions.
// Returns the same information as "get f", but grouped into a dictionary and
//  with the interesting parts labelled.
// b: bytecode
// p: params
// l: locals
// g: globals
// c: constants
// t: text
// @param x function
// @return dictionary of metadata about x
metaf:{`b`p`l`g`c`t!(x til 4),(enlist -1_4_x),enlist last x:get .Q.v x}

///
// A wrapper for the various meta* meta extension functions.
// Runs metaf on lambdas, metad on non-table dictionaries, and metaa
//  on everything else.
// @param x data
// @return metadata about x
metax:{$[100=t:type x;metaf;(99=t)&not .Q.qt x;metad;metaa]x:.Q.v x}

///
// get metax of all tables
// column "n" with table name is added
// @param x workspace
// @return table containing metax of all tables in x
// @see metax
mmetax:{raze{`n`c xkey update n:x from metax x}each tables x}

///
// get saferazed metax of all tables
// N.B. will fail if any table has duplicate columns
// column "n" with table name is added
// @param x workspace
// @return table containing metax of all tables in x
// @see metax
mmetaxs:{saferaze{`n`c xkey update n:x from metax x}each tables x}

///
// de-enumerate any enumerated columns in a table
// N.B. does not affect link columns
// @param x table
// @return x with any enumerated symbol columns de-enumerated
denumt:{![x;();0b;{x!get,'x}exec c from metaa x where not null e,e<>`symbol]}
