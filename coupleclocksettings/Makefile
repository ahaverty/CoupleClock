ARCHS = armv7 arm64
include ../theos/makefiles/common.mk

BUNDLE_NAME = CoupleClockSettings
CoupleClockSettings_FILES = CoupleClockSettings.mm
CoupleClockSettings_INSTALL_PATH = /Library/PreferenceBundles
CoupleClockSettings_FRAMEWORKS = UIKit
CoupleClockSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CoupleClockSettings.plist$(ECHO_END)
