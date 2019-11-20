# -C = Case sensitive labels
# -B = automatic bxx *+3 jmpo $xxxx

LIBRARIES = D:\\OneDrive\\X16Dev\\source\\lib
INCLUDE = D:\\OneDrive\\X16Dev\\source\\header

FILES=\
	vera.s


vera.lib: $(FILES)
	ca65 -t cx16 vera.s
	ar65 r vera.lib vera.o

	-copy *.lib $(LIBRARIES)
	-copy *.h $(INCLUDE)
	-echo y | del *.o
	-echo y | del *.lib