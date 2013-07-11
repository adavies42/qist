true:1b
false:0b
quotes:{("\""=x)&"\\"<>prev x}
spans:{x or(<>)scan x}
dict:{(!)."S*"$flip 2 cut x}
struct:{x!x}["c"$til 256],("[{]}:,")!("(";"dict(";")";")";";";";")

toFloat:{$[6=abs t:type x;"f"$x;t in 0 99h;.z.s each x;x]}

escape:{first x ss"\\u"}
unicode:{{$[null i:escape x;x;[p:i#x;s:(i+6)_x;u:"X"$2 cut 2_6#i _x;$[first u;'`nyi;p,("c"$1_u),s]]]}over x}

isInt:{(first[x]in"-0123456789")&all(1_x)in"0123456789"}'
toLongs:{raze@[x;where isInt x:-4!x;,[;"j"]]}

json:$[.z.K<3;
 {.q.null:"";r:toFloat{get toLongs unicode raze over@[enlist each x;where not spans quotes x;struct]}raze over x;.q.null:(^:);r};
 {.q.null:"";r:toFloat{get         unicode raze over@[enlist each x;where not spans quotes x;struct]}raze over x;.q.null:(^:);r}]
