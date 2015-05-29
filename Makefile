GO_EASY_ON_ME = 1
TARGET=iphone:clang:latest:4.0
ADDITIONAL_CFLAGS = -fobjc-arc
ARCHS = armv7 arm64
MODULES = nahm8
THEOS_BUILD_DIR = debs
include theos/makefiles/common.mk

TWEAK_NAME = AntiEffective
AntiEffective_FILES = Tweak.xm
AntiEffective_FRAMEWORKS = Foundation CoreText UIKit
AntiEffective_LIBRARIES = substrate
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
