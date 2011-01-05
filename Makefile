include theos/makefiles/common.mk
TWEAK_NAME = MyCamera
MyCamera_FILES = Tweak.xm
MyCamera_LDFLAGS = -lactivator
MyCamera_FRAMEWORKS = UIKit QuartzCore
MyCamera_PRIVATE_FRAMEWORKS = GraphicsServices
include $(THEOS_MAKE_PATH)/tweak.mk
