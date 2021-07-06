// Generate a .epr file and a OZ5 installable app

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

static unsigned char memory[65536];
static char *program_name;

static void write_app5(char *filen, int pages);
static void insert_binary(char *filename, int address);
static void suffix_change(char *name, const char *suffix);

/* lz49.c */
extern unsigned char *LZ49_encode(unsigned char *data, int length, int *retlength);
extern void LZ49_decode(unsigned char *data, unsigned char *odata);



static void exit_log(int code, char *fmt, ...)
{
    va_list  ap;

    va_start(ap, fmt);
    if ( fmt != NULL ) {
        if ( program_name ) {
            fprintf(stderr, "%s: ", program_name);
        }

        vfprintf(stderr, fmt, ap);
    }

    va_end(ap);
    exit(code);
}

int main(int argc, char **argv)
{
    int romsize,i;
    FILE *fp;

    program_name = argv[0];

    if ( argc < 3 ) {
        exit_log(1,"Usage [outfile] [romsize] {[binary]:[address]}\n");
    }

    romsize = strtol(argv[2],NULL, 0);

    if ( romsize == 0 ) {
        exit_log(1,"Cannot parse rom size %s\n",argv[2]);
    }
   

    for ( i = 3; i < argc; i++ ) {
         char *ptr = strchr(argv[i], ':');
         long  addr;

         if ( ptr == NULL ) {
             exit_log(1,"Cannot parse argument %s\n",argv[i]);
         }
         if ( (addr = strtol(ptr+1, NULL, 0)) == 0 ) {
             exit_log(1,"Cannot parse argument %s\n",argv[i]);
         }
         *ptr++ = 0;

         insert_binary(argv[i], addr);
    }

    if ( (fp = fopen(argv[1],"wb")) != NULL ) {
        if (fwrite(memory + 65536 - romsize, 1, romsize, fp) != romsize ) {
            exit_log(1,"Could not write assembled ROM\n");
        }
        fclose(fp);
    }

    write_app5(argv[1], (romsize / 16384));


    exit(0);
}


static void write_app5(char *filen, int pages)
{
    unsigned char *app;
    size_t         app_size = 40;
    char  filename[FILENAME_MAX+1];
    FILE *fp;
    unsigned char *ptr;
    int   i;

    strcpy(filename, filen);

    suffix_change(filename, ".app");

    app = calloc(40, sizeof(char));
    ptr = app;
    ptr[0] = 0xa5;
    ptr[1] = 0x5a;
    ptr[2] = pages;
    ptr[3] = 0xff;

    ptr = app + 10;
    for ( i = 0 ; i < pages; i++ ) {
        *ptr++ = 0x00;
        *ptr++ = 0x40;
        ptr += 2;
    }

    for ( i = 0 ; i < pages; i++) {
        int blocklen;
        unsigned char *comp = LZ49_encode(memory + ( 49152 - i*16384), 16384, &blocklen);

        // Adjust the header so it contains the length of the compressed block
        app[10 + (i * 4) + 0] = blocklen % 256;
        app[10 + (i * 4) + 1] = blocklen / 256;

        // Reallocate and add the compressed page to the end
        app = realloc(app, app_size + blocklen);
        memcpy(app + app_size, comp, blocklen);
        app_size += blocklen;
        free(comp);
    }

    if ( (fp = fopen(filename, "wb")) == NULL ) {
        exit_log(1,"Cannot open file <%s> for writing\n",filename);
    }

    if ( fwrite(app, 1, app_size, fp) != app_size) {
        exit_log(1,"Couldn't write application to file\n");
    }
    fclose(fp);
}


static int zcc_strrcspn(char *s, char *reject)
{
    int index, i;

    index = 0;

    for (i = 1; *s; ++i) {
        if (strchr(reject, *s++))
            index = i;
    }

    return index;
}


static void suffix_change(char *name, const char *suffix)
{
    int index;

    if ((index = zcc_strrcspn(name, "./\\")) && (name[index - 1] == '.'))
        name[index - 1] = 0;

    strcat(name, suffix);
}

static void insert_binary(char *filename, int address)
{
     FILE *fp;
     long  filesize;

     if ( (fp = fopen(filename, "rb") ) != NULL ) {
         if (fseek(fp, 0, SEEK_END)) {
             fclose(fp);
             exit_log(1,"Couldn't determine the size of the file %s\n",filename);
         }

         filesize = ftell(fp);
         if (filesize+address > 65536L) {
             fclose(fp);
             exit_log(1,"The file %s would overflow the rom\n",filename);
         }

         fseek(fp, 0, SEEK_SET);
         if (fread(memory+address, 1, filesize, fp) != filesize ) {
             exit_log(1,"Didn't read enough data from file %s\n",filename);
         }
         fclose(fp);
     } else {
         exit_log(1,"Couldn't open file %s\n",filename);
     }

}

