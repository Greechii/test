
include ../inc/default.mk

TARGET_NAME = bluekey
TARGET		= $(TARGET_NAME)
INSTALL_DIR	= ../app/

ifeq ($(CONFIG_DEBUG),y)
OBJECT_DIR 		= ../build/debug/$(TARGET_NAME)/
TARGET_DIR		= ../bin/debug/
LIB_DIR			= ../bin/debug/lib/
DEFINES			+= -DDEBUG
CFLAGS			+= -g 
CXXFLAGS		+= -g
COMPILE_CFG		+= Debug Compiling
else
OBJECT_DIR 		= ../build/release/$(TARGET_NAME)/
TARGET_DIR		= ../bin/release/
LIB_DIR			= ../bin/release/lib/
DEFINES			+= -DNDEBUG
CFLAGS			+= -O2
CXXFLAGS		+= -O2
COMPILE_CFG		+= Release Compiling
endif

CC				= $(CROSS_COMPILE)gcc
CXX				= $(CROSS_COMPILE)g++
LINK			= $(CROSS_COMPILE)g++
AR				= $(CROSS_COMPILE)ar cqs
LD				= $(CROSS_COMPILE)ld
CFLAGS			+= -pipe -D_REENTRANT -Wall -W -Wno-ignored-qualifiers $(DEFINES)
CXXFLAGS		+= -pipe -D_REENTRANT -Wall -W -Wno-ignored-qualifiers $(DEFINES)
LEXFLAGS		=
YACCFLAGS		= -d

DEFINES			+= -DLINUX

INCPATH			+= -I../inc
INCPATH			+= -I/usr/local/include #for wiriing pi
#INCPATH		+= -Iinc -Iinc/bui -Iapp/resource/include/
#INCPATH		+= -Ibasiclibs/bclib
#INCPATH		+= -Ibasiclibs/iniparser
#INCPATH		+= -I../lib/
#INCPATH		+= -Ilibs/common

### changes
#LFLAGS			= -Wl
LIBS			= -L$(LIB_DIR) -lpthread -ldl -lm
#LIBS			= -llibbluekeyserialmodule
LIBS			+= -L/usr/local/lib -lwiringPi #for wiring pi

RANLIB			=
COPY			= cp -f
INSTALL_PROGRAM	= install -m 755 -p
DEL_FILE		= rm -f
SYMLINK			= ln -sf
DEL_DIR			= rmdir
MOVE			= mv -f
CHK_DIR_EXISTS	= test -d
MKDIR			= mkdir -p


OBJECTS = \
		  $(OBJECT_DIR)bluekey.o \
		  $(OBJECT_DIR)../libbluekeyserialmodule/bluekeyserial.o \

first: makedir all

### Implicit rules
.SUFFIXES: .o .c .cpp .cc .cxx .C

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o "$@" "$<"

.c.o:
	$(CC) -c $(CLFAGS) $(INCPATH) -o "$@" "$<"

### Build rules
makedir:
	@echo "[$(COMPILE_CFG) => $(CC)]"
	@$(CHK_DIR_EXISTS) $(OBJECT_DIR) || $(MKDIR) $(OBJECT_DIR)
	@$(CHK_DIR_EXISTS) $(TARGET_DIR) || $(MKDIR) $(TARGET_DIR)

all: $(TARGET_DIR)$(TARGET_NAME)

$(TARGET_DIR)$(TARGET): $(OBJECTS)
	@echo "Linking.........[$(TARGET)] [$(LIBS)]"
	@echo "DEFINES.........[$(DEFINES)]"
	@echo "CFLAGS..........[$(CFLAGS)]"
	@$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(LIBS)
	@$(MOVE) $(TARGET) $(TARGET_DIR)

yaccclean:
lexclean:
clean:
	-$(DEL_FILE) $(OBJECTS)
	-$(DEL_FILE) *~ core *.core

$(OBJECT_DIR)bluekey.o: bluekey.c
	@echo "Compiling......[$<]"
	@$(CC) -c $(CFLAGS) $(INCPATH) -o $@ $<

### Install
install_target: first FORCE
	@echo "Installing......[$(INSTALL_DIR)$(TARGET)]"
	@$(CHK_DIR_EXISTS) $(INSTALL_DIR) || $(MKDIR) $(INSTALL_DIR)
	@$(INSTALL_PROGRAM) "$(TARGET_DIR)$(TARGET)" "$(INSTALL_DIR)$(TARGET)"
ifneq ($(CONFIG_DVR_DEBUG),y)
	@$(CROSS_COMPILE)strip --strip-unneeded "$(INSTALL_DIR)$(TARGET)"
endif

uninstall_target: FORCE
	@echo "Uninstalling......[$(INSTALL_DIR)$(TARGET)]"
	@$(DEL_FILE) "$(INSTALL_DIR)$(TARGET)"

install: install_target FORCE
uninstall: uninstall_target FORCE

FORCE:
