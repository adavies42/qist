UNAME=$(shell uname)

BITS=64

CFLAGS=-std=gnu99 -W -Wall -Werror -Wno-unused-parameter -m$(BITS)
CPPFLAGS=-I../../../kx/kdb+/c/c
LDFLAGS=-shared

ifeq ($(UNAME),Linux)
	TARGET_ARCH=-fPIC
else ifeq ($(UNAME),Darwin)
	TARGET_ARCH=-undefined suppress -flat_namespace
else
$(error Unsupported architecture `$(UNAME)')
endif

%.so: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH) $(OUTPUT_OPTION) $<

SO=env.so

all: $(SO)

clean:
	rm -f $(SO)
