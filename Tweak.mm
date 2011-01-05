/*
 * MyCamera
 * Created by EvilPenguin|
 * Use how you please :)
 *
 *
 *
 *
 *
 */

#include <PhotoLibrary/PLCameraView.h>
#include <PhotoLibrary/PLCameraController.h> 
#include <SpringBoard4.2/VolumeControl.h>
#import <SpringBoard4.2/SBApplication.h>
#import <SpringBoard4.2/SBUIController.h>
#import <SpringBoard4.2/SBApplicationController.h>
#import <SpringBoard4.2/SBAwayController.h>
#import "libactivator.h"
#import <substrate.h>

static void cameraLoader(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	PLCameraView *cameraView = (PLCameraView *)observer;
	[cameraView setCameraMode:0];
	if ([cameraView _canTakePhoto]) { [cameraView _shutterButtonClicked]; }
	else { [NSTimer scheduledTimerWithTimeInterval:2.0f target:cameraView selector:@selector(_shutterButtonClicked) userInfo:nil repeats:NO]; }
}

%class PLCameraController;
static void videoLoader(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	PLCameraView *cameraView = (PLCameraView *)observer;
	PLCameraController *controller = [$PLCameraController sharedInstance];
	[cameraView setCameraMode:1];
	if ([controller canCaptureVideo]) { [cameraView startVideoCapture]; }
	else {  
		[cameraView stopVideoCapture];
		[cameraView _processCapturedVideo];
	}
}

%hook PLCameraView 
- (id)initWithFrame:(CGRect)frame {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
									self, 
									&videoLoader, 
									CFSTR("us.nakedproductions.MyCamera.video"), 
									NULL, 
									CFNotificationSuspensionBehaviorHold);
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
									self, 
									&cameraLoader, 
									CFSTR("us.nakedproductions.MyCamera.camera"), 
									NULL, 
									CFNotificationSuspensionBehaviorHold);
	return %orig;
}

-(id)_shutterButton {
	//[%orig removeFromSuperview];
	return %orig;
}
%end

@interface VideoActivator : NSObject <LAListener> 
@end

@implementation VideoActivator

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(),
													CFSTR("us.nakedproductions.MyCamera.video"),  
													NULL, 
													NULL,
													kCFNotificationDeliverImmediately);
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
}

+ (void)load {
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.mycameravideo"];
}

@end

@interface PhotoActivator : NSObject <LAListener> 
@end

@implementation PhotoActivator

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(),
													CFSTR("us.nakedproductions.MyCamera.camera"),  
													NULL, 
													NULL,
													kCFNotificationDeliverImmediately);
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
}

+ (void)load {
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.mycameraphoto"];
}

@end

@interface CameraAcitvator : NSObject <LAListener> 
@end

@implementation CameraAcitvator

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	SBAwayController *sbAwayController = [%c(SBAwayController) sharedAwayController];
	if (![sbAwayController isPasswordProtected]) { 
		if ([sbAwayController isLocked]) { [sbAwayController unlockWithSound:NO]; }
	}
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.apple.mobileslideshow"];
	[[%c(SBUIController) sharedInstance] activateApplicationFromSwitcher:app];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
}

+ (void)load {
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.mycamera"];
}

@end