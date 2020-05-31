include $(THEOS)/makefiles/common.mk

SUBPROJECTS += ntspeedhooks
SUBPROJECTS += ntspeedsettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
