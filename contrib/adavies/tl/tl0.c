#define KXVER 3
#include <stdio.h>
#include "k.h"
ZV d(I i,S n,K x){O("line %d: %s: xr: %d; xt: %3hhd; xn: %lld\n",i,n,xr,xt,xn);}
K1(tl0){
 d(__LINE__,"x",x);
 K l=knk(0);
 d(__LINE__,"l",l);
 K m;
 DO(xn,m=kK(x)[i];d(__LINE__,"m",m);jk(&l,m));
 d(__LINE__,"l",l);
 r1(l);
 d(__LINE__,"l",l);
 R l;
}

K2(tl00){
 d(__LINE__,"x",x);
 d(__LINE__,"y",y);
 K l=k(0,"{flip x!y}",r1(x),r1(y),(K)0);
 d(__LINE__,"l",l);
 R r1(l);
}

K2(tl1){R r1(k(0,"{flip x!y}",r1(x),r1(y),(K)0));}

K1(tl){R r1(k(0,"{([]x:x)}",r1(x),(K)0));}

K1(n){R r1(ki(xn));}
