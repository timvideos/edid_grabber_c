CURL_BUILD = $(PWD)/curl-7.32.0
CURL_PREFIX = $(CURL_BUILD)/build
CURL_CONFIG = $(CURL_PREFIX)/bin/curl-config

# What to call the final executable
TARGET = bin/edid-grabber

# Which object files that the executable consists of
OBJS = grabber.o uploader.o src/edid-grabber.c

# What compiler to use
CC = $(CROSS_PREFIX)gcc

# Compiler flags, -g for debug, -c to make an object file, -Wall for warnings
CFLAGS = -c -g -Wall -Isrc `$(CURL_CONFIG) --cflags` $(CFLAGS_EXTRA)

LDFLAGS = `$(CURL_CONFIG) --static-libs` $(LDFLAGS_EXTRA)

# Link the target with all objects and libraries
$(TARGET): libcurl $(OBJS)
	test -d bin || mkdir bin
	$(CC) -o $(TARGET) $(OBJS) $(LDFLAGS)

# Compile the source files into object files
grabber.o: src/grabber/$(PLATFORM).c
	$(CC) -o $@ $(CFLAGS) $<

uploader.o: src/uploader.c
	$(CC) -o $@ $(CFLAGS) $<

clean:
	@-rm *.o $(TARGET); rm -r $(CURL_BUILD)

libcurl:
	test -f curl-7.32.0.tar.gz || wget http://curl.haxx.se/download/curl-7.32.0.tar.gz
	tar xzf curl-7.32.0.tar.gz
	unset CFLAGS; \
        cd $(CURL_BUILD); \
        ./configure --prefix=$(CURL_PREFIX) $(CURL_FLAGS) --disable-shared \
        --disable-thread --disable-ftp --disable-file --disable-ldap \
        --disable-ldaps --disable-rtsp --disable-proxy --disable-dict \
        --disable-telnet --disable-tftp --disable-pop3 --disable-imap \
        --disable-smtp --disable-gopher --disable-ipv6 --without-winssl \
        --without-darwinssl --without-ssl --without-libmetalink \
        --without-libssh2 --without-librtmp --without-libidn
	make -C $(CURL_BUILD)
	make -C $(CURL_BUILD) install

linux:
	unset CC; \
        export PLATFORM=linux; \
        $(MAKE) -e

windows:
	unset CC; \
        export PLATFORM=windows; \
        export CROSS_PREFIX="i686-w64-mingw32-"; \
        export CFLAGS_EXTRA="-m32"; \
        export LDFLAGS_EXTRA="-lsetupapi"; \
        export CURL_FLAGS="--host=i686-w64-mingw32"; \
        export TARGET="$(TARGET).exe"; \
        $(MAKE) -e
