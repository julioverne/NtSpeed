include theos/makefiles/common.mk

TWEAK_NAME = NtSpeed
NtSpeed_FILES = /mnt/d/codes/ntspeed/ntspeedhooks/Tweak.xm
NtSpeed_FRAMEWORKS = CydiaSubstrate Foundation UIKit CoreGraphics
#NtSpeed_CFLAGS = -fobjc-arc
NtSpeed_LDFLAGS = -Wl,-segalign,4000

NtSpeed_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
	
all::
	