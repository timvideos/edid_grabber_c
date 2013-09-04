#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "uploader.h"

#define BUFFER_SIZE 512

int grab_edids() {
    FILE *fp = popen("xrandr --props", "r");
	char *output = NULL;
	int output_len = 0;

	char buffer[BUFFER_SIZE];

    if (fp == NULL) {
        printf("Running XRandR failed.");
    	return EXIT_FAILURE;
    }

	while(fgets(buffer, BUFFER_SIZE, fp) != NULL) {
    	output = (char *) realloc(output, (output_len + BUFFER_SIZE) * sizeof(char));
    	output = strcat(output, buffer);
    	output_len += strlen(buffer);
	}

    pclose(fp);

    upload_text(output, "xrandr");

    free(output);
	return EXIT_SUCCESS;
}
