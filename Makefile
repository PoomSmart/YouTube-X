TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = YouTube
PACKAGE_VERSION = 1.7.6
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubeX

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
