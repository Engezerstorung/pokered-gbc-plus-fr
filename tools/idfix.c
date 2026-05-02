// credits to Narishma-gb
#define PROGRAM_NAME "idfix"
#define USAGE_OPTS "[-h|--help] in._metatiles.bin in._attributes.bin out._metatiles.bst"

#include "common.h"

void parse_args(int argc, char *argv[]) {
    struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {0}
    };
    for (int opt; (opt = getopt_long(argc, argv, "h", long_options)) != -1;) {
        switch (opt) {
        case 'h':
            usage_exit(0);
            break;
        default:
            usage_exit(1);
        }
    }
}

int main(int argc, char *argv[]) {
    parse_args(argc, argv);

    argc -= optind;
    argv += optind;
    if (argc != 3) {
        usage_exit(1);
    }

    long filesize;
    long attrfilesize;
    uint8_t *data = read_u8(argv[0], &filesize);
    uint8_t *attrdata = read_u8(argv[1], &attrfilesize);

    if (filesize != attrfilesize) {
        usage_exit(1);
    }

    for (long i = 0; i < filesize; i++) {
        if (attrdata[i] & 8) {
            data[i] |= 0x80;
        }
    }

    write_u8(argv[2], data, (size_t)filesize);

    free(data);
    free(attrdata);
    return 0;
}
