# -C = Case sensitive labels
# -B = automatic bxx *+3 jmpo $xxxx


# Library output directory.  Your C program will have to link the vera.lib file created here into your C program.
LIBRARIES = D:\\OneDrive\\X16Dev\\source\\lib
# Header output directory.  Your C program will have to include the vera.h file that is copied here.
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