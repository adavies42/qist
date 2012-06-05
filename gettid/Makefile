BITS=64
CPPFLAGS=-I../../../kx/kdb+/c/c
CFLAGS=-W -Wall -Wno-unused-parameter -m$(BITS)

%.so: %.c
	$(CC) $(CPPFLAGS) -shared -fPIC $(CFLAGS) $(OUTPUT_OPTION) $<

SO=gettid.so

all: $(SO)

clean:
	rm -f $(SO)
