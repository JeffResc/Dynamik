# Thank you to Dave van Wijk and QuitAll for providing a beautiful preferences bundle
# https://github.com/vanwijkdave/QuitAll

include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e

BUNDLE_NAME = dynamikprefs
dynamikprefs_FILES = DynamikRootListController.m zodiacs.m
dynamikprefs_INSTALL_PATH = /Library/PreferenceBundles
dynamikprefs_FRAMEWORKS = UIKit
dynamikprefs_PRIVATE_FRAMEWORKS = Preferences
dynamikprefs_CFLAGS = -fobjc-arc
dynamikprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DynamikPrefs.plist$(ECHO_END)
