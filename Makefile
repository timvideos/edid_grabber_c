# What to call the final executable
TARGET = edid-grabber

# Which object files that the executable consists of
OBJS = grabber.o uploader.o edid-grabber.c

# What compiler to use
CC = gcc

# Compiler flags, -g for debug, -c to make an object file, -Wall for warnings
CFLAGS = -c -g -Wall -iquote .

# This should point to a directory that holds libcurl, if it isn't
# in the system's standard lib dir
# We also set a -L to include the directory where we have the openssl
# libraries
LDFLAGS = `curl-config --libs`
# -L/usr/local/ssl/lib

# We need -lcurl for the curl stuff
# We need -lsocket and -lnsl when on Solaris
# We need -lssl and -lcrypto when using libcurl with SSL support
# We need -lpthread for the pthread example
LIBS = -lcurl

# Link the target with all objects and libraries
$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

# Compile the source files into object files
grabber.o: linux/grabber.c grabber.h
	$(CC) $(CFLAGS) $<

uploader.o: uploader.c uploader.h
	$(CC) $(CFLAGS) $<

clean:
	-rm *.o $(TARGET)
