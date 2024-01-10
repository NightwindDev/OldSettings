TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = Preferences


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OldSettings

OldSettings_FILES = Tweak.x
OldSettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
