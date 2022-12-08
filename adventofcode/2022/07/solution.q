/ fs:``a`b_txt`c_dat`d!(::;``e`f`g`h_lst!(::;``i!(::;584);29116;2557;62596);14848514;8504156;``j`d_log`d_ext`k!(::;4060174;8033020;5626152;7214296))

\l ../../../lib/wtf.q

f:{
    cwd:`;
    r:(enlist`)!enlist(::);
    while[count x;
        a:first x;
        x _:0;
        b:{$[x~enlist`;();x]}`$"/"vs string{`$(sum mins"/"=string x)_string x}cwd;
        $[
            a like"$ cd *";
                [
                    d:`$5_a;
                    cwd:`$"/"sv$[
                        d=`..;
                            -1_"/"vs string cwd;
                        string cwd,d];
                ];
            a~"$ ls";
                ::;
            a like"dir *";
                r:.[r;b;,;(enlist`$4_a)!enlist(enlist`)!enlist(::)];
            r:.[r;b;,;(enlist`$ssr[last" "vs a;".";"_"])!enlist"J"$first" "vs a]];
        ];
    r}

du:{$[any b:-7=type each x;sum x where b;0]+$[any a:99=type each x;sum .z.s each x where a;0]}

fs:f read0`:input

show part1:sum{x where x<=100000}du each get each` sv'distinct -1_'` vs'wtfcat`fs
show part2:min{(where x y)#y}[{x>=30000000-70000000-du fs}]{y!x y}[du each get each]` sv'distinct -1_'` vs'wtfcat`fs
