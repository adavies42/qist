show part1:sum{(("XYZ"!1 2 3)y)+$[(x,y)in("AX";"BY";"CZ");3;(x,y)in("AZ";"BX";"CY");0;(x,y)in("CX";"AY";"BZ");6;'`domain]}.'flip("CC";" ")0:`:input
show part2:sum{a:"XYZ"!"ABC"!/:("ZXY";"XYZ";"YZX");m:a[y]x;{(("XYZ"!1 2 3)y)+$[(x,y)in("AX";"BY";"CZ");3;(x,y)in("AZ";"BX";"CY");0;(x,y)in("CX";"AY";"BZ");6;'`domain]}[x]m}.'flip("CC";" ")0:`:input
