#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>

void upload_text(char *text, char *text_type) {
    CURL *curl;
    CURLcode res;

    const char *postfields_format = "text=%s&text_type=%s";
    char *postfields = malloc((strlen(text) + strlen(text_type) +
                               strlen(postfields_format)) * sizeof(char));

    sprintf(postfields, postfields_format, text, text_type);

    curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "http://127.0.0.1:8000/api/upload/text");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postfields);

        // Perform the request, res will get the return code
        res = curl_easy_perform(curl);
        // Check for errors
        if(res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
            curl_easy_strerror(res));
        }

        curl_easy_cleanup(curl);
    }
}
