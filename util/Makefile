

CFILES = $(wildcard *.c)
OFILES = $(CFILES:.c=.o)

CFLAGS = -Wall -g

all: rompacker

rompacker: $(OFILES)
	$(CC) -o $@  $^

clean:
	$(RM) -f *.o rompacker
	
