#include "k.h"
extern S*environ;
K1(env){
 K l=knk(0);for(S*e=environ;*e;++e)jk(&l,kp(*e));
 R k(0,"{1_'(!).\"S*\"$flip(0,'x?'\"=\")cut'x}",l,(K)0);}
