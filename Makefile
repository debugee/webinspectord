THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
DEBUG = 1
ARCHS = arm64
TARGET=iphone:latest:11.0
INSTALL_TARGET_PROCESSES = Aweme
TARGET_LIPO = 

ifeq ($(DEBUG),0)
TARGET_CODESIGN = jtool
TARGET_CODESIGN_FLAGS = --sign --inplace 
else
TARGET_CODESIGN = codesign
TARGET_CODESIGN_FLAGS = -f -s 'Apple Development: Wen Cheng (Y9UU5S8ZW7)'
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zzz

zzz_FILES = zzz.m
zzz_CFLAGS = -Wno-unused-variable -fvisibility=hidden -I/Users/admin/Desktop/tweaks/third_party/substitute/out/usr/include
zzz_LDFLAGS = -L/Users/admin/Desktop/tweaks/third_party/substitute/out -lsubstitute
zzz_FRAMEWORKS = Foundation Security
zzz_LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk



#after-package::
#	./patcher $(_THEOS_DEB_PACKAGE_FILENAME) sss
#after-install::
#	install.exec "killall -9 zzz"