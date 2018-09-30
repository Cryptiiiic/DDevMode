export ARCHS = armv7 arm64
export TARGET = iphone:clang:11.1:9.2
DEBUG = 1
FINALPACKAGE = 0
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DDevMode
$(TWEAK_NAME)_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Discord"