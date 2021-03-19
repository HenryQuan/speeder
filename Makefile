export THEOS_DEVICE_IP = 192.168.1.34

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = speeder

speeder_FILES = Tweak.x
speeder_CFLAGS = -fobjc-arc
speeder_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
