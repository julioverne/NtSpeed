include theos/makefiles/common.mk

TWEAK_NAME = NtSpeed
NtSpeed_FILES = Tweak.xm
NtSpeed_FRAMEWORKS = CydiaSubstrate Foundation UIKit CoreGraphics
NtSpeed_CFLAGS = -fobjc-arc
NtSpeed_LDFLAGS = -Wl,-segalign,4000

NtSpeed_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
	
all::
	@echo "[+] Copying Files..."
	@cp ./obj/obj/debug/NtSpeed.dylib //Library/MobileSubstrate/DynamicLibraries/NtSpeed.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/NtSpeed.dylib
	@echo "DONE"
	#@killall SpringBoard
	