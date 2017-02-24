#import <dlfcn.h>
#import <objc/runtime.h>
#include <sys/sysctl.h>
#import <substrate.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <net/if.h>

#undef HBLogError
#define HBLogError(...)
#define NSLog(...)

static int kWidth = 40;
static int kHeight = 15;

static float kScreenW;
static float kScreenH;

static __strong NSString* kBs = @"%ldB/s";
static __strong NSString* kKs = @"%.1fK/s";
static __strong NSString* kMs = @"%.2fM/s";
static __strong NSString* kGs = @"%.3fG/s";


NSString *bytesFormat(long bytes)
{
	@autoreleasepool {
		if(bytes < 1024) {
			return [NSString stringWithFormat:kBs, bytes];
		} else if(bytes >= 1024 && bytes < 1024 * 1024) {
			return [NSString stringWithFormat:kKs, (double)bytes / 1024];
		} else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
			return [NSString stringWithFormat:kMs, (double)bytes / (1024 * 1024)];
		} else {
			return [NSString stringWithFormat:kGs, (double)bytes / (1024 * 1024 * 1024)];
		}
	}
}

long getBytesTotal() 
{
	@autoreleasepool {
		struct ifaddrs *ifa_list = 0, *ifa;
		if (getifaddrs(&ifa_list) == -1) {
			return 0;
		}
		uint32_t iBytes = 0;
		uint32_t oBytes = 0;
		for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
			if (AF_LINK != ifa->ifa_addr->sa_family) {
				continue;
			}
			if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) {
				continue;
			}
			if (ifa->ifa_data == 0) {
				continue;
			}
			struct if_data *if_data = (struct if_data *)ifa->ifa_data;
			iBytes += if_data->ifi_ibytes;
			oBytes += if_data->ifi_obytes;
		}
		freeifaddrs(ifa_list);
		return iBytes + oBytes;
	}
}

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end
@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface NtSpeed : NSObject
{
	UIWindow* springboardWindow;
	UILabel *label;
}
@property (nonatomic, strong) UIWindow* springboardWindow;
@property (nonatomic, strong) UILabel *label;
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
+ (void)notifyOrientationChange;
- (void)firstload;
- (void)orientationChanged;
@end

static void orientationChanged()
{
	[NtSpeed notifyOrientationChange];
}

static long oldSpeed;
static UIDeviceOrientation orientationOld;

@implementation NtSpeed
@synthesize springboardWindow, label;
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
		[NSTimer scheduledTimerWithTimeInterval:1 target:_sharedObject selector:@selector(update) userInfo:nil repeats:YES];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, 0);
		CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return _sharedObject;
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
	if([NtSpeed sharedInstanceExist]) {
		if (NtSpeed* NTShared = [NtSpeed sharedInstance]) {
			[NTShared orientationChanged];
		}
	}
}
- (void)firstload
{
	return;
}
-(id)init
{
	self = [super init];
	if(self != nil) {
		@try {
			springboardWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
			springboardWindow.windowLevel = 9999999999;
			[springboardWindow setHidden:NO];
			springboardWindow.alpha = 1;
			[springboardWindow _setSecure:YES];
			[springboardWindow setUserInteractionEnabled:NO];
			springboardWindow.layer.cornerRadius = 6;
			springboardWindow.layer.masksToBounds = YES;
			springboardWindow.layer.shouldRasterize  = NO;
			
			UIView* backView = [UIView new];
			backView.frame = CGRectMake(0, 0, springboardWindow.frame.size.width, springboardWindow.frame.size.height);
			backView.backgroundColor = [UIColor colorWithWhite: 0.50 alpha:1];
			backView.alpha = 0.5f;
			[(UIView *)springboardWindow addSubview:backView];
			
			UIView* content = [UIView new];
			content.alpha = 0.9f;
			content.frame = CGRectMake(4, 0, springboardWindow.frame.size.width-8, springboardWindow.frame.size.height);
			label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, content.frame.size.width, content.frame.size.height)];
			[self update];
			label.numberOfLines = 1;
			label.textColor = [UIColor whiteColor];
			label.baselineAdjustment = YES;
			label.adjustsFontSizeToFitWidth = YES;
			label.adjustsLetterSpacingToFitWidth = YES;
			label.textAlignment = NSTextAlignmentCenter;
			[content addSubview:label];
			[(UIView *)springboardWindow addSubview:content];
			
			[self orientationChanged];
			
		} @catch (NSException * e) {
			
		}
	}
	return self;
}
- (void)update
{
	@autoreleasepool {
		long nowData = getBytesTotal();
		if(!oldSpeed) {
			oldSpeed = nowData;
		}		
		if(label&&springboardWindow) {
			long speed = nowData-oldSpeed;
			[springboardWindow setHidden:speed==0?YES:NO];
			label.text = bytesFormat(speed);
		}
		oldSpeed = nowData;
	}
}
- (void)orientationChanged
{
	UIDeviceOrientation orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
	if(orientation == orientationOld) {
		return;
	}
	BOOL isLandscape;
	__block CGAffineTransform newTransform;
	__block int xLoc;
	__block int yLoc;
	#define DegreesToRadians(degrees) (degrees * M_PI / 180)
	switch (orientation) {
	case UIDeviceOrientationLandscapeRight: {			
			isLandscape = YES;
			yLoc = 5;
			xLoc = 20;
			newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
			break;
		}
	case UIDeviceOrientationLandscapeLeft: {
			isLandscape = YES;
			yLoc = (kScreenH-kWidth-5);
			xLoc = (kScreenW-kHeight-20);
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			isLandscape = NO;
			yLoc = (kScreenH-kHeight-20);
			xLoc = 5;
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(180));
			break;
		}
		case UIDeviceOrientationPortrait:
	default: {
			isLandscape = NO;
			yLoc = 20;
			xLoc = (kScreenW-kWidth-5);
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
}
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	[[NtSpeed sharedInstance] firstload];	
}
%end

%ctor
{
	kScreenW = [[UIScreen mainScreen] bounds].size.width;
	kScreenH = [[UIScreen mainScreen] bounds].size.height;
	%init;
}
