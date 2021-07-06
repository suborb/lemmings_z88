

SRCFILES = game.asm levelcode.asm copyscreenROM.asm game_keys.asm misc_oz.asm oz_interface.asm printany.asm udg2.asm apphdr.asm romhdr.asm
OFILES = $(SRCFILES:.asm=.o)

# Binaries that we create
BINARIES = lem_code.bin wavplay.bin lemload.bin music.bin

all: lem.epr

lem_code.bin: $(OFILES)
	z88dk-z80asm -b -olem.bin $^

music.bin: music/music.o assets/tune.bin
	z88dk-z80asm -b -o$@ $<

lemload.bin: loader/lemload.o loader/inflate2.o
	z88dk-z80asm -b -o$@ $^

wavplay.bin: wavplay.asm
	z88dk-z80asm -b -o$@ $^

%.o: %.asm
	zcc +z88 -c $^

lem.epr: util/rompacker $(BINARIES)
	util/rompacker $@ 32768 lem_code.bin:36750 assets/gamedata.bin:51930 music.bin:34083 assets/title.bin:35673 wavplay.bin:62850 lem_ROMDOR.bin:65472 lemload.bin:32768

util/rompacker:
	$(MAKE) -C util

clean:
	$(RM) -f *.o lem.epr lem.app 
	$(RM) -f */*.o
	$(RM) -f $(BINARIES) lem_code.bin lem_ROMDOR.bin
	$(MAKE) -C util clean
	
