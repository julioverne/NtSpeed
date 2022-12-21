#import <dlfcn.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <substrate.h>
#import <notify.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <net/if.h>

#define NSLog(...)

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.ntspeed.plist"

static BOOL Enabled;

static BOOL alwaysVisible;
static BOOL isBlackScreen;

static int textColor;

static int kWidth = 40;
static int kHeight = 15;

static int kLocX = 5;
static int kLocY = 20;

static float kAlpha = 0.5f;
static float kAlphaText = 0.9f;
static float kRadius = 6;

static BOOL forceNewLocation;

static float kScreenW;
static float kScreenH;

static __strong NSString* kBs = [[@"%ldB/s" copy] retain];
static __strong NSString* kKs = [[@"%.1fK/s" copy] retain];
static __strong NSString* kMs = [[@"%.2fM/s" copy] retain];
static __strong NSString* kGs = [[@"%.3fG/s" copy] retain];


static __unused NSString *bytesFormat(long long bytes)
{
	//@autoreleasepool {
		if(bytes < 1024) {
			return [NSString stringWithFormat:kBs, bytes];
		} else if(bytes >= 1024 && bytes < 1024 * 1024) {
			return [NSString stringWithFormat:kKs, (double)bytes / 1024];
		} else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
			return [NSString stringWithFormat:kMs, (double)bytes / (1024 * 1024)];
		} else {
			return [NSString stringWithFormat:kGs, (double)bytes / (1024 * 1024 * 1024)];
		}
	//}
}

static long long getBytesTotal() 
{
	@autoreleasepool {
		long long iBytes = 0;
		long long oBytes = 0;
		struct ifaddrs *ifa_list = NULL, *ifa;
		if ((getifaddrs(&ifa_list) < 0) || !ifa_list || ifa_list==0) {
			return 0;
		}
		for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
			if (ifa->ifa_addr == NULL) {
				continue;
			}
			if (AF_LINK != ifa->ifa_addr->sa_family) {
				continue;
			}
			if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) {
				continue;
			}
			if (ifa->ifa_data == NULL || ifa->ifa_data == 0) {
				continue;
			}
			struct if_data *if_data = (struct if_data *)ifa->ifa_data;
			iBytes += if_data->ifi_ibytes;
			oBytes += if_data->ifi_obytes;
		}
		if(ifa_list) {
			freeifaddrs(ifa_list);
		}
		return iBytes + oBytes;
	}
}

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end
@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface NtSpeedWindow : UIWindow
@end
@implementation NtSpeedWindow
- (BOOL)_ignoresHitTest
{
	return YES;
}
+ (BOOL)_isSecure
{
	return YES;
}
- (void)dalloc
{
	return;
}
- (oneway void)release
{
	return;
}
@end

@interface NtSpeed : NSObject
{
	UIWindow* springboardWindow;
	UILabel *label;
	UIView *backView;
	UIView *content;
}
@property (nonatomic, strong) UIWindow* springboardWindow;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *content;
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
+ (void)notifyOrientationChange;
- (void)firstload;
- (void)orientationChanged;
- (void)updateFrame;
@end

static void orientationChanged()
{
	[NtSpeed notifyOrientationChange];
}

static long long oldSpeed = 0;
static UIDeviceOrientation orientationOld;

@implementation NtSpeed
@synthesize springboardWindow, label, backView, content;
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[[self alloc] init] retain];
		[NSTimer scheduledTimerWithTimeInterval:1 target:_sharedObject selector:@selector(update) userInfo:nil repeats:YES];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, (CFNotificationSuspensionBehavior)0);
		CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return [_sharedObject retain];
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
+ (void)notifyOrientationChange
{
	@try {
		if([NtSpeed sharedInstanceExist]) {
			if (NtSpeed* NTShared = [[NtSpeed sharedInstance] retain]) {
				[NTShared orientationChanged];
			}
		}
	} @catch (NSException * e) {
	}
}
- (void)firstload
{
	return;
}
- (void)updateLabelColor
{
	if(label) {
		label.textColor = textColor==0?[UIColor whiteColor]:textColor==1?[UIColor blackColor]:textColor==2?[UIColor redColor]:textColor==3?[UIColor greenColor]:textColor==4?[UIColor blueColor]:[UIColor grayColor];
	}
}
-(id)init
{
	self = [super init];
	if(self != nil) {
		@try {
			kScreenW = [[UIScreen mainScreen] bounds].size.width;
			kScreenH = [[UIScreen mainScreen] bounds].size.height;
			
			springboardWindow = [[[NtSpeedWindow alloc] initWithFrame:CGRectZero] retain];
			springboardWindow.windowLevel = 9999999;
			[springboardWindow setHidden:NO];
			springboardWindow.alpha = 1;
			[springboardWindow _setSecure:YES];
			[springboardWindow setUserInteractionEnabled:NO];
			springboardWindow.layer.cornerRadius = kRadius;
			springboardWindow.layer.masksToBounds = YES;
			springboardWindow.layer.shouldRasterize  = NO;
			
			backView = [UIView new];
			backView.backgroundColor = [UIColor colorWithWhite: 0.50 alpha:1];
			[(UIView *)springboardWindow addSubview:backView];
			
			content = [UIView new];
			label = [[UILabel alloc]initWithFrame:CGRectZero];
			[self update];
			label.numberOfLines = 1;
			[self updateLabelColor];
			label.baselineAdjustment = (UIBaselineAdjustment)YES;
			label.adjustsFontSizeToFitWidth = YES;
			label.adjustsLetterSpacingToFitWidth = YES;
			label.textAlignment = NSTextAlignmentCenter;
			[content addSubview:label];
			[(UIView *)springboardWindow addSubview:content];
			
			[self updateFrame];
			
		} @catch (NSException * e) {
		}
	}
	return self;
}
- (void)updateFrame
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateFrame) object:nil];
	[self performSelector:@selector(_updateFrame) withObject:nil afterDelay:0.3];
}
- (void)_updateFrame
{
	@try {
		backView.alpha = kAlpha;
		content.alpha = kAlphaText;
		[self updateLabelColor];
		springboardWindow.layer.cornerRadius = kRadius;
		springboardWindow.frame = CGRectMake(0, 0, kWidth, kHeight);
		backView.frame = CGRectMake(0, 0, springboardWindow.frame.size.width, springboardWindow.frame.size.height);
		content.frame = CGRectMake(4, 0, springboardWindow.frame.size.width-8, springboardWindow.frame.size.height);
		label.frame = CGRectMake(0, 0, content.frame.size.width, content.frame.size.height);
		forceNewLocation = YES;
		[springboardWindow setHidden:NO];
		[self orientationChanged];
	} @catch (NSException * e) {
	}
}
- (void)update
{
	@try {
		@autoreleasepool {
			if(!Enabled || isBlackScreen) {
				if(springboardWindow && !springboardWindow.hidden) {
					[springboardWindow setHidden:YES];
				}
				return;
			}
			long long nowData = getBytesTotal();
			if(!oldSpeed) {
				oldSpeed = nowData;
			}
			if(label&&springboardWindow) {
				long long speed = nowData-oldSpeed;
				if(speed < 0) {
					speed = 0;
				}
				[springboardWindow setHidden:(!alwaysVisible && speed==0)?YES:NO];
				label.text = bytesFormat(speed);
			}
			oldSpeed = nowData;
		}
	} @catch (NSException * e) {
	}
}
- (void)orientationChanged
{
	@try {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
		if(orientation == orientationOld && !forceNewLocation) {
			return;
		}
		forceNewLocation = NO;
		BOOL isLandscape;
		__block CGAffineTransform newTransform;
		__block int xLoc;
		__block int yLoc;
		#define DegreesToRadians(degrees) (degrees * M_PI / 180)
		switch (orientation) {
		case UIDeviceOrientationLandscapeRight: {			
				isLandscape = YES;
				yLoc = kLocX;
				xLoc = kLocY;
				newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
				break;
			}
		case UIDeviceOrientationLandscapeLeft: {
				isLandscape = YES;
				yLoc = (kScreenH-kWidth-kLocX);
				xLoc = (kScreenW-kHeight-kLocY);
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
				break;
			}
			case UIDeviceOrientationPortraitUpsideDown: {
				isLandscape = NO;
				yLoc = (kScreenH-kHeight-kLocY);
				xLoc = kLocX;
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(180));
				break;
			}
			case UIDeviceOrientationPortrait:
		default: {
				isLandscape = NO;
				yLoc = kLocY;
				xLoc = (kScreenW-kWidth-kLocX);
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(0));
				break;
			}
		}
		[UIView animateWithDuration:0.3f animations:^{
			[springboardWindow setTransform:newTransform];
			CGRect frame = springboardWindow.frame;
			frame.origin.y = yLoc;
			frame.origin.x = xLoc;
			springboardWindow.frame = frame;
			orientationOld = orientation;
		} completion:nil];
		
	} @catch (NSException * e) {
	}
}
- (void)dalloc
{
	return;
}
- (oneway void)release
{
	return;
}
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	[[[NtSpeed sharedInstance] retain] firstload];	
}
%end

static void screenDisplayStatus(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
    uint64_t state;
    int token;
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    notify_get_state(token, &state);
    notify_cancel(token);
    if(!state) {
		isBlackScreen = YES;
		oldSpeed = 0;
    } else {
		isBlackScreen = NO;
	}
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {		
		NSDictionary *TweakPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		Enabled = (BOOL)[[TweakPrefs objectForKey:@"Enabled"]?:@YES boolValue];
		alwaysVisible = (BOOL)[[TweakPrefs objectForKey:@"alwaysVisible"]?:@NO boolValue];
		int newtextColor = (int)[[TweakPrefs objectForKey:@"textColor"]?:@(0) intValue];
		int newkLocX = (int)[[TweakPrefs objectForKey:@"kLocX"]?:@(5) intValue];
		int newkLocY = (int)[[TweakPrefs objectForKey:@"kLocY"]?:@(20) intValue];
		int newkWidth = (int)[[TweakPrefs objectForKey:@"kWidth"]?:@(40) intValue];
		int newkHeight = (int)[[TweakPrefs objectForKey:@"kHeight"]?:@(15) intValue];
		float newkAlpha = (float)[[TweakPrefs objectForKey:@"kAlpha"]?:@(0.5) floatValue];
		float newkAlphaText = (float)[[TweakPrefs objectForKey:@"kAlphaText"]?:@(0.9) floatValue];
		float newkRadius = (float)[[TweakPrefs objectForKey:@"kRadius"]?:@(6) floatValue];
		
		BOOL needUpdateUI = NO;
		if(newkLocX!=kLocX || newkLocY!=kLocY || newkWidth!=kWidth || newkHeight!=kHeight || newkAlpha!=kAlpha || newkRadius!=kRadius || newtextColor!=textColor || newkAlphaText!=kAlphaText) {
			needUpdateUI = YES;
		}
		kLocX = newkLocX;
		kLocY = newkLocY;
		kWidth = newkWidth;
		kHeight = newkHeight;
		kAlpha = newkAlpha;
		kRadius = newkRadius;
		textColor = newtextColor;
		kAlphaText = newkAlphaText;
		if(needUpdateUI && [NtSpeed sharedInstanceExist]) {
			if (NtSpeed* NTShared = [NtSpeed sharedInstance]) {
				[NTShared updateFrame];
			}
		}
	}
}

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenDisplayStatus, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, (CFNotificationSuspensionBehavior)0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.julioverne.ntspeed/Settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	settingsChanged(NULL, NULL, NULL, NULL, NULL);
	%init;
}