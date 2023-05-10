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
// read0, but compatible with non-seekable files (fifos, /proc, etc.).
// @param x file symbol
// @return A list of strings containing the contents of the file.
// @see read0
.finos.util.read0f:{r:{y,read0 x}[h:hopen`$":fifo://",1_string x]over();hclose h;r}

///
// read1, but compatible with non-seekable files (fifos, /proc, etc.).
// @param x file symbol
// @return A byte vector containing the contents of the file.
// @see read1
.finos.util.read1f:{r:{y,read1 x}[h:hopen`$":fifo://",1_string x]over();hclose h;r}

.finos.util.compose:('[;])/

// create a list. e.g. list(`a;1) -> (`a;1)
.finos.util.list:{$[104h=type x;1_-1_get x;x]}

// create a dictionary. e.g. dict (1;2;3;4) -> 1 3!2 4
.finos.util.dict:{(!) . flip 2 cut .finos.util.list x}

// create a table. e.g. table[`x`y;(1;2;3;4)] -> ([]x:1 3;y:2 4)
.finos.util.table:{flip x!flip(count x)cut .finos.util.list y}

// log stubs
.finos.log.critical:{-1"CRITICAL: ",x;}
.finos.log.error   :{-1"ERROR: "   ,x;}
.finos.log.warning :{-1"WARNING: " ,x;}
.finos.log.info    :{-1"INFO: "    ,x;}
.finos.log.debug   :{-1"DEBUG: "   ,x;}

.finos.util.rs  :{0b sv x xprev 0b vs y}     / right shift
.finos.util.xor :{0b sv (<>/)   0b vs'(x;y)} / XOR
.finos.util.land:{0b sv (&).    0b vs'(x;y)} / AND
.finos.util.lnot:{0b sv not     0b vs x}     / NOT

.finos.util.crc32:{.finos.util.lnot(.finos.util.lnot"i"$x){.finos.util.xor[.finos.util.rs[8]y]x .finos.util.xor[.finos.util.land[y]255i]0x0 sv 0x000000,"x"$z}[{8{$[x mod 2i;.finos.util.xor -306674912i;::].finos.util.rs[1]x}/x}each"i"$til 256]/y}

// Parse byte(s) into a "number" (i.e. byte, short, int, or long, depending on the length).
// @param x byte or bytes
// @return byte, short, int, or long
.finos.unzip.priv.parseNum:.finos.util.compose({$[1=count x;first;0x00 sv]x};reverse);

// Parse byte(s) into bits; N.B. output is reversed to make flag dicts more natural.
// @param x byte or bytes
// @return bool vector
.finos.unzip.priv.parseBits:.finos.util.compose(reverse;0b vs;.finos.unzip.priv.parseNum);

// Format a "number" (i.e. byte, short, int, or long) into bytes(s).
// @param x byte, short, int, or long
// @return byte or bytes
.finos.unzip.priv.fmtNum:{$[-4h=type x;::;0x00 vs]x};

/
///
// compress data with the DEFLATE algorithm
// N.B. currently only implements the "store" method, i.e. no compression
// @param x chars or bytes
// @return bytes
.finos.png.priv.deflate:{
  if[10h=type x;
    x:"x"$x;
    ];

  if[4h<>type x;
    '`type;
    ];

  if[65535<count x;
    '`nyi;
    ];

  / size
  s:reverse 0x0 vs"h"$count x;

  / complement of size
  S:0b sv'not each 0b vs's;

  / zip header (last block, store, padding)
  h:0b sv reverse 1b,00b,00000b;

  h,s,S,x}
\

///
// compress data with the DEFLATE algorithm
// uses .Q.gz and removes gzip wrapper
// @param x chars or bytes
// @return bytes
.finos.png.priv.deflate:{
    if[not(type x)in 4 10h;
        'type;
        ];

    / compress
    r:"x"$.Q.gz(2;"c"$x);

    / strip gzip header
    r:10_r;

    / strip gzip footer
    r:-8_r;

    r}

///
// compress data in gzip format
// @param x chars or bytes
// @return bytes
.finos.png.priv.gzip:{
  / gzip header (magic, deflate, no flags, no timestamp, fastest algo, unix)
  h:0x1f8b,0x08,0x00,0x00000000,0x04,0x03;

  / crc
  c:reverse 0x0 vs .finos.util.crc32[0]x;

  / size mod 2^32
  s:reverse 0x00 vs"i"$(count x)mod prd 32#2;

  h,(deflate x),c,s}

.finos.png.priv.until:{x+til 1+y-x}

.finos.png.priv.saferaze:{$[(count x:raze x)=sum count each x;x;'`unsafe]}

///
// decode data according to the "fixed" Huffman codes defined in RFC 1951
// N.B. this is a cheap hack based on just testing each known width,
//  not the proper tree-traversal method
// TODO handle extra bits in length codes>=265
// @param x booleans data
// @return ints values
.finos.png.priv.huffman_decode_fixed:{
  f:{((neg x)#'0b vs'(until). y)!(until). z};

  / build a dict of the huffman codes of each possible width
  / derived directly from the table in RFC 1951 3.2.6
  h:saferaze f'[
            8                     9                       7                   8;
    2 sv''((00110000b;10111111b);(110010000b;111111111b);(0000000b;0010111b);(11000000b;11000111b));
           (0         143;        144        255;         256      279;       280       287       )];

  / deocde one symbol, transfering it from input to output
  g:{
    / if the leading z bits of y are a known code, return that code,
    /  otherwise null
    f:{$[(c:z sublist y)in key x;x c;0N]};

    o:y 0;
    i:y 1;

    r:$[
      256=last o; / end-of-block
        y;
      [
        / possible widths
        w:distinct count each key x;

        / try each possible width
        W:first where not null r:w!f[x;i]each w;

        / check
        if[null W;
          '`parse];

        / add symbol to output, remove code from input
        (o,r W;W _i)]];

    r};

  / wrap, decode, unwrap, remove end-of-block
  -1_first g[h]over(`long$();x)}

///
// compute the Adler-32 checksum of data
// ported from <https://en.wikipedia.org/wiki/Adler-32#Example_implementation>
// @param x data
// @return bytes checksum
/
  uint32_t a = 1, b = 0;
  size_t index;

  / Process each byte of the data in order
  for (index = 0; index < len; ++index)
  {
    a = (a + data[index]) % MOD_ADLER;
    b = (b + a) % MOD_ADLER;
  }

  return (b << 16) | a;
\
/
  m:65521i;
  a:1i;
  b:0i;
  i:0;
  while[i<count x;
    a:(a+x i)mod m;
    b:(b+a)mod m;
    i+:1;
    ];
  0x0 vs a+b*65536i
\
.finos.png.priv.adler32:{raze reverse 0x0 vs'"h"$1 0i{(a;((x 1)+a:((x 0)+y)mod m)mod m:65521i)}/"x"$x}

/ test adler32
if[not 0x11E60398~.finos.png.priv.adler32"i"$"Wikipedia";break]

.finos.png.priv.zlib_flag_byte:{[c;d;l]
  0b sv l,d,-5#0b vs"x"$31-(0x0 sv c,0b sv l,d,00000b)mod 31}

///
// compress data in zlib format
// @param x chars or bytes
// @return bytes
.finos.png.priv.zlib:{
  / compression method and flags (32kB sliding window, deflate)
  c:0b sv 0111b,1000b;

  / flags (default algo, no DICT, check bits)
  f:.finos.png.priv.zlib_flag_byte[c;0b;10b];

  / check check bits
  if[(0x0 sv c,f)mod 31;
    '`break;
    ];

  / headers, compressed data, checksum
  c,f,(.finos.png.priv.deflate x),.finos.png.priv.adler32 x}

/ test check bits algo
.finos.png.priv.zlib_test_flag_byte:{[m;w;l;d]
  M:-4#0b vs"x"$m;
  W:-4#0b vs"x"$w;
  c:0b sv W,M;

  L:-2#0b vs"x"$l;
  D:-1#0b vs"x"$d;

  f:.finos.png.priv.zlib_flag_byte[c;D;L];

  not(0x0 sv c,f)mod 31}

{[m;w;l;d]
  if[not .finos.png.priv.zlib_test_flag_byte[m;w;l;d];
    break]}'[8]'[til 8]'[til 4]'[til 2];

.finos.png.priv.huffman_decode:{
  / convert to bits
  d:raze reverse each 0b vs'x;

  / if[...

  / remove header
  d:3_d;

  / decode
  .finos.png.priv.huffman_decode_fixed d}

.finos.png.priv.zlib_decode:{
  // TODO
  / ...

  / remove header
  x:1_x;

  // TODO
  / ...

  / remove header
  x:1_x;

  // TODO
  / ...

  / remove checksum
  x:-4_x;

  / decode
  .finos.png.priv.huffman_decode x}

///
// prepend a directory to a path
// @param x sym path name (e.g. `PATH)
// @param y string directory
// @return sym path name
.finos.png.priv.path_prepend:{x setenv":"sv(enlist y),$[count e:getenv x;":"vs e;()];x}

///
// append a directory to a path
// @param x sym path name (e.g. `PATH)
// @param y string directory
// @return sym path name
.finos.png.priv.path_append:{x setenv":"sv$[count e:getenv x;":"vs e;()],(enlist y);x}

///
// remove all occurences of a directory from a path
// @param x sym path name (e.g. `PATH)
// @param y string directory
// @return sym path name
.finos.png.priv.path_delete:{x setenv":"sv(":"vs getenv x)except enlist y;x}

/ test zlib
.finos.png.priv.zlib_test:{
  e:get"0x",first system"printf ",x,"|pigz -z2b32|xxd -p";
  a:.finos.png.priv.zlib x;
  e~a}

.finos.png.priv.path_prepend[`PATH]"/ms/dist/fsf/PROJ/pigz/2.1.6/bin";
if[not .finos.png.priv.zlib_test"...";
  break;
  ]

.finos.png.priv.m.IHDR.ct:.finos.util.table[`v`n`d](
  0x00;`greyscale           ;1 2 4 8 16i;
  0x02;`truecolor           ;      8 16i;
  0x03;`indexed_color       ;1 2 4 8i   ;
  0x04;`greyscale_with_alpha;      8 16i;
  0x06;`truecolor_with_alpha;      8 16i;
  )

.finos.png.priv.m.IHDR.im:.finos.util.dict(
  0x00;`none;
  0x01;`Adam7;
  )

.finos.png.priv.m.IHDR.f:.finos.util.table[`n`w`f`c`F](
  `width             ;4;.finos.util.compose(                                        .finos.unzip.priv.parseNum;reverse);{$[not x;               '`domain;x]};                    .finos.unzip.priv.fmtNum               ;
  `height            ;4;.finos.util.compose(                                        .finos.unzip.priv.parseNum;reverse);{$[not x;               '`domain;x]};                    .finos.unzip.priv.fmtNum               ;
  `bit_depth         ;1;.finos.util.compose("i"$;                                   .finos.unzip.priv.parseNum;reverse);{$[not x in 1 2 4 8 16i;'`domain;x]};.finos.util.compose(.finos.unzip.priv.fmtNum;"x"$)         ;
  `color_type        ;1;.finos.util.compose(exec v!n from .finos.png.priv.m.IHDR.ct;.finos.unzip.priv.parseNum;reverse);{$[null x;              '`domain;x]};                    exec n!v from .finos.png.priv.m.IHDR.ct;
  `compression_method;1;.finos.util.compose("i"$;                                   .finos.unzip.priv.parseNum;reverse);{$[x;                   '`domain;x]};.finos.util.compose(.finos.unzip.priv.fmtNum;"x"$)         ;
  `filter_method     ;1;.finos.util.compose("i"$;                                   .finos.unzip.priv.parseNum;reverse);{$[x;                   '`domain;x]};.finos.util.compose(.finos.unzip.priv.fmtNum;"x"$)         ;
  `interlace_method  ;1;.finos.util.compose(.finos.png.priv.m.IHDR.im;              .finos.unzip.priv.parseNum;reverse);{$[null x;              '`domain;x]};                    .finos.png.priv.m.IHDR.im?             ;
  )

.finos.png.priv.p.IHDR:{
  r:exec c@'f@'n!(0^prev sums w)cut x from .finos.png.priv.m.IHDR.f;

  if[not(r`bit_depth)in(exec n!d from .finos.png.priv.m.IHDR.ct)r`color_type;
    '`domain;
    ];

  r}

.finos.png.priv.p.sRGB:{(enlist`rendering_intent)!x}
.finos.png.priv.p.gAMA:{(enlist`gamma_value)!enlist(.finos.unzip.priv.parseNum reverse x)%100000}

.finos.png.priv.p.pHYs:{
  u:.finos.util.dict(
    0;`unknown;
    1;`meter;
    );

  f:.finos.util.table[`n`w`f`c](
    `ppux;4;.finos.util.compose(       .finos.unzip.priv.parseNum;reverse);::                    ;
    `ppuy;4;.finos.util.compose(       .finos.unzip.priv.parseNum;reverse);::                    ;
    `u   ;1;.finos.util.compose(u;"i"$;.finos.unzip.priv.parseNum;reverse);{$[null x;'`domain;x]};
    );

  r:(f`c)@'(f`f)@'(f`n)!(0^prev sums f`w)cut x;

  r}

.finos.png.priv.zpipec:{
  f0:hsym`$first system"mktemp";
  f0 1:x;
  f1:hsym`$first system"mktemp";
  system"(zpipe    <",(1_string f0)," >",(1_string f1),")";
  r:read1 f1;
  hdel each f0,f1;
  r}

.finos.png.priv.zpiped:{
  f0:hsym`$first system"mktemp";
  f0 1:x;
  f1:hsym`$first system"mktemp";
  system"(zpipe -d <",(1_string f0)," >",(1_string f1),")";
  r:read1 f1;
  hdel each f0,f1;
  r}

.finos.png.priv.p.IDAT:{
  / r:zlib_decode x;

  f0:hsym`$first system"mktemp";
  f0 1:x;
  f1:hsym`$first system"mktemp";
  system"(zpipe -d <",(1_string f0)," >",(1_string f1),")";
  r:read1 f1;
  hdel each f0,f1;

  r}

.finos.png.priv.p.IEND:{x}

.finos.png.priv.w.IHDR:{
  / TODO validations

  raze(exec n!F from .finos.png.priv.m.IHDR.f)@'x}

.finos.png.priv.w.IDAT:{
  / n.b. assumes bit_depth 8
  / TODO validations, other depths, etc.
  .finos.png.priv.zlib raze"x"$0i,'raze each x}

.finos.png.priv.w.IEND:{`byte$()}

///
// parse a PNG file
// @param x sym or bytes filename or data
// @return table parsed PNG structure
.finos.png.parse:{
  / parse one chunk
  f:{
    o:x 0;
    i:x 1;

    r:$[
      count i;
        [
          s:first over(enlist 4;enlist"i")1:4#i;
          d:s#8_i;
          c:4#(8+s)_i;
          t:4#4_i;
          l:(12+s)_i;
          (o,enlist .finos.util.dict(
            `size       ;s;
            `name       ;`$"c"$t;
            `data       ;d;
            `crc        ;c;
            `crc_valid  ;c~0x0 vs .finos.util.crc32[0]t,d;
            `data_parsed;.finos.png.priv.p[`$"c"$t]d;
            );l)
          ];
        x];

    r};

  / accept hsym or bytes
  i:$[
    -11h=t:type x;
      read1 x;
    4h=t;
      x;
    '`type];

  / check header
  if[not 0x89504e470d0a1a0a~8#i;
    '`parse;
    ];

  / remove header
  i:8_i;

  / wrap, decode, unwrap
  r:1_first f over(enlist(::);i);

  / IHDR
  h:(first r)`data_parsed;

  if[`indexed_color=h`color_type;
    '`nyi;
    ];

  if[8<>h`bit_depth;
    '`nyi;
    ];

  / width in bits of one pixel
  w:8*3+(h`color_type)like"*_with_alpha";

  / break data into scanlines & pixels
  r:update(h`height){{(first y;"i"$0b sv''8 cut'x cut raze 0b vs'1_y)}[x]each(y;0Ni)#z}[w]'data_parsed from r where name=`IDAT;

  r}

///
// format a PNG file
// an image is a list of scanlines
// a scanline is a list of pixels
// a pixel is an RGB or RGBA tuple
// e.g. the 2x2 pixel image
//  +---+---+
//  | R | G |
//  +---+---+
//  | B | W |
//  +---+---+
// would be ((255 0 0;0 255 0);(0 0 255;0 0 0))
// @param x dict header
// @param y numbers image
// @return bytes a PNG file
.finos.png.format:{
  / format one chunk
  f:{
    d:.finos.png.priv.w[x]y;
    l:.finos.unzip.priv.fmtNum"i"$count d;
    t:"x"$string x;
    c:0x0 vs .finos.util.crc32[0]t,d;
    l,t,d,c};

  0x89504e470d0a1a0a,raze`IHDR`IDAT`IEND f'(x;y;::)}

\

show .finos.png.parse`:4x1.png
show .finos.png.parse`:1x4.png
show .finos.png.parse`:2x2.png
show .finos.png.parse`:a.png

`:2x2.q.png 1:.finos.png.format[`width`height`bit_depth`color_type`compression_method`filter_method`interlace_method!(2i;2i;8i;`truecolor;0i;0i;`none);((255 0 0i;0 255 0i);(0 0 255i;0 0 0i))]

\

rrggbb color
0   0   0    black   black   0   0   0   0
0   0   255  blue    blue    0   0   0   255
0   255 0    green   green   0   0   255 0
0   255 255  aqua    aqua    0   0   255 255
255 0   0    red     red     0   255 0   0
255 0   255  fuchsia fuchsia 0   255 0   255
255 255 0    yellow  yellow  0   255 255 0
255 255 255  white   white   0   255 255 255
