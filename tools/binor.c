// credits to Sylvie
#define PROGRAM_NAME "binor"
#define USAGE_OPTS "[-h|--help] [-x|--or value] in.bin out.atr"

#include "common.h"

void parse_args(int argc, char *argv[], uint8_t *or_value) {
	struct option long_options[] = {
		{"or", required_argument, 0, 'x'},
		{"help", no_argument, 0, 'h'},
		{0}
	};
	for (int opt; (opt = getopt_long(argc, argv, "x:h", long_options)) != -1;) {
		switch (opt) {
		case 'x':
			*or_value = strtoul(optarg, NULL, 0);
			break;
		case 'h':
			usage_exit(0);
			break;
		default:
			usage_exit(1);
		}
	}
}

int main(int argc, char *argv[]) {
	uint8_t or_value = 0x08; // %00001000
	parse_args(argc, argv, &or_value);

	argc -= optind;
	argv += optind;
	if (argc != 2) {
		usage_exit(1);
	}


	long filesize;
	uint8_t *data = read_u8(argv[0], &filesize);

	for (long i = 0; i < filesize; i++) {
		data[i] |= or_value;
	}

	write_u8(argv[1], data, (size_t)filesize);

	free(data);
	return 0;
}
