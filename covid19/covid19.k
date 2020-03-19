/ k9 2020.03.15

Qft:{$[`A=@y;x y;xkey[#key y]x unkey y]}

fill:{@[y;&y=*0#y;:;x]}
xkey:{(x#'y)!x_'y}
unkey:{(,').. x}
unpiv:{xkey[1+#key y]@,/({y,/+x!. z}[x]').. y} / is the 1+ universally valid?

dos2unix:{(~"\r"=)#/x}

tfc:{[t;f;c]+(i#+t),((,c)!,f(+t)c),(1+i:(!+t)?c)_+t} / single-column update with function

dl:{$[(,"200")~r:."\\curl -s -w '%{http_code}\\n' -o ",(f:"/tmp/",*|"/"\:x)," ",x;f;1+`a]} / download

qc:{i:&(~(~=)\y="\"")&x=y;I:?0,i+1;w:@[({@[-':x;0;:;*x]}i,#y)-1;0;+;1];o:I+'!'w;y o} / quote cut (partial excel parser)

pd:{"D"$"20","-"/:"0"fill'-2$'("/"\:$x)2 0 1} / parse (some) dates

l:{`j$''xkey[4]{+(`$*x)!+1_x}","qc'dos2unix@0:dl x} / load

/ download & load
c1:{y!x y}[{l"https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-",($x),".csv"}']`Confirmed`Deaths`Recovered

/ sum by date of all series
t1:{(!).(x;:)@'. y}[+(,`Date)!,pd';+(+/'+*|.)'c1]

/ unpivot & convert column names to proper dates
/c2:Qft[tfc[;pd';`Date]]'(`Date,'!c1)unpiv'c1 / projection & v f'd are nyi?
c2:Qft[{tfc[x;pd';`Date]}]'{(!y)!x .. y}[{(`Date,'x)unpiv'y}]c1

/ keyed uj / apparently multi-column sort is nyi; assume all key sets match up to order
c3:{,'/(!*x)#/x}c2

/ sum by date of all series (should match t1)
t2:{[t;b;a],'/{[t;b;a]xkey[1]@+(b,a)!.+/'((+t)a)@=(+t)b}[unkey t;b]'a}[c3;`Date;!+*|. c3]
