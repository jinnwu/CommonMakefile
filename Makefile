## name of main executable to build
TARGET	= test

## commands
CC	= gcc
AR	=
WARN	= -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow \
	  -Wconversion
CFLAGS	= -g3 -O1 $(WARN)
LDLIBS	=

## extension for c files, or c plus plus files
EXT	= c

### directory
## project directory
DIR	= .
## the place where final binary file will be placed
BIN_DIR	= $(HOME)/usr/local/bin
LIB_DIR	= $(DIR)/lib
## the location of the common source directory
SRC_DIR	= $(DIR)/src
INC_DIR	= $(DIR)/include
OBJ_DIR	= $(DIR)/.objs
DEP_DIR	= $(DIR)/.deps

# SRCDIRS = . src util
# SRCS = $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))
CFILES	= $(wildcard $(SRC_DIR)/*.$(EXT))
OFILES	= $(patsubst $(SRC_DIR)/%.$(EXT), $(OBJ_DIR)/%.o, $(CFILES))
DFILES	= $(patsubst $(SRC_DIR)/%.$(EXT), $(DEP_DIR)/%.d, $(CFILES))

## the places to look for include files (in order)
INCLUDES= -I$(INC_DIR)
LIBS	= -L$(LIB_DIR)

all: $(TARGET)
#	ctags *.c

$(TARGET): $(OFILES)
	@echo "Creating $@..."
	$(CC) -o $@ $(OFILES) $(LIBS) $(addprefix -l,$(LDLIBS))

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.$(EXT)
	$(shell if [ ! -d $(OBJ_DIR) ]; then mkdir $(OBJ_DIR); fi)
	@echo Compiling $<...
	$(CC) -o $@ -c $(CFLAGS) $< $(INCLUDES)

$(DEP_DIR)/%.d: $(SRC_DIR)/%.$(EXT)
	$(shell if [ ! -d $(DEP_DIR) ]; then mkdir $(DEP_DIR); fi)
	@echo Building $<...
	@$(CC) -MM $(CPPFLAGS) $< $(INCLUDES) > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; rm $@.$$$$

ifneq ($(MAKECMDGOALS), clean)
-include $(DFILES)
endif

.PHONY: clean package bz2

clean:
	$(RM) $(TARGET) $(OBJ_DIR)/* $(DEP_DIR)/* core tags *.bz2
	rm -rf $(OBJ_DIR) $(DEP_DIR)

package:
	make bz2

## require the TARGET value equal to the root directory name of the project
bz2:
	make clean
	cd ..; rm -rf $(TARGET)/$(TARGET).tar.bz2
	cd ..; tar jcv ./$(TARGET) > $(TARGET).tar.bz2
	mv ../$(TARGET).tar.bz2 .
