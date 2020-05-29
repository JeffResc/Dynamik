PACKAGE_VERSION = 1.0.1
DEBUG = 0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = Dynamik
Dynamik_FILES = Dynamik.xm
Dynamik_CFLAGS = -fobjc-arc
Dynamik_PRIVATE_FRAMEWORKS = PersistentConnection AppSupport
Dynamik_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += dynamikprefs dynamikcli
include $(THEOS_MAKE_PATH)/aggregate.mk
