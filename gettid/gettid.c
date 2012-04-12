#include <unistd.h>
#include <sys/syscall.h>
#include "k.h"

// return thread id
K1(qgettid){R r1(ki(syscall(__NR_gettid)));}
