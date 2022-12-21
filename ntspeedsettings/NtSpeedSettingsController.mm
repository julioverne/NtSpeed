#import <notify.h>
#import <Social/Social.h>
#import <prefs.h>

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.ntspeed.plist"

@interface NtSpeedSettingsController : PSListController {
	UILabel* _label;
	UILabel* underLabel;
}
- (void)HeaderCell;
@end



@implementation NtSpeedSettingsController
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [NSMutableArray array];
		PSSpecifier* spec;
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                  target:self
											         set:@selector(setPreferenceValue:specifier:)
											         get:@selector(readPreferenceValue:)
                                                  detail:Nil
											        cell:PSSwitchCell
											        edit:Nil];
		[spec setProperty:@"Enabled" forKey:@"key"];
		[spec setProperty:@YES forKey:@"default"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [specifiers addObject:spec];
		
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Always Visible"
                                                  target:self
											         set:@selector(setPreferenceValue:specifier:)
											         get:@selector(readPreferenceValue:)
                                                  detail:Nil
											        cell:PSSwitchCell
											        edit:Nil];
		[spec setProperty:@"alwaysVisible" forKey:@"key"];
		[spec setProperty:@NO forKey:@"default"];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Text Color"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:PSListItemsController.class
											  cell:PSLinkListCell
											  edit:Nil];
		[spec setProperty:@"textColor" forKey:@"key"];
		[spec setProperty:@0 forKey:@"default"];
		[spec setValues:@[@0, @1, @2, @3, @4, @5] titles:@[@"White", @"Black", @"Red", @"Green", @"Blue", @"Gray"]];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Width"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Width" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Width"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kWidth" forKey:@"key"];
		[spec setProperty:@(40) forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@([[UIScreen mainScreen] bounds].size.width) forKey:@"max"];
		[spec setProperty:@NO forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kWidth" forKey:@"key"];
		[spec setProperty:@(40) forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Height"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Height" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Height"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kHeight" forKey:@"key"];
		[spec setProperty:@(15) forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@([[UIScreen mainScreen] bounds].size.height) forKey:@"max"];
		[spec setProperty:@NO forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kHeight" forKey:@"key"];
		[spec setProperty:@(15) forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Location X"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Location X" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Location X"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kLocX" forKey:@"key"];
		[spec setProperty:@(5) forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@([[UIScreen mainScreen] bounds].size.width) forKey:@"max"];
		[spec setProperty:@NO forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kLocX" forKey:@"key"];
		[spec setProperty:@(5) forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Location Y"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Location Y" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Location Y"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kLocY" forKey:@"key"];
		[spec setProperty:@(20) forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@([[UIScreen mainScreen] bounds].size.height) forKey:@"max"];
		[spec setProperty:@NO forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kLocY" forKey:@"key"];
		[spec setProperty:@(20) forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Radius"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Radius" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Radius"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kRadius" forKey:@"key"];
		[spec setProperty:@6 forKey:@"default"];
		[spec setProperty:@0 forKey:@"min"];
		[spec setProperty:@50 forKey:@"max"];
		[spec setProperty:@YES forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kRadius" forKey:@"key"];
		[spec setProperty:@6 forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Alpha Background"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Alpha Background" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Alpha Background"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kAlpha" forKey:@"key"];
		[spec setProperty:@(0.5) forKey:@"default"];
		[spec setProperty:@(0.0) forKey:@"min"];
		[spec setProperty:@(1.0) forKey:@"max"];
		[spec setProperty:@YES forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kAlpha" forKey:@"key"];
		[spec setProperty:@(0.5) forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Alpha Text"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Alpha Text" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Alpha Text"
                                              target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
                                              detail:Nil
											  cell:PSSliderCell
											  edit:Nil];
		[spec setProperty:@"kAlphaText" forKey:@"key"];
		[spec setProperty:@(0.9) forKey:@"default"];
		[spec setProperty:@(0.0) forKey:@"min"];
		[spec setProperty:@(1.0) forKey:@"max"];
		[spec setProperty:@YES forKey:@"isContinuous"];
		[spec setProperty:@YES forKey:@"showValue"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:nil
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"kAlphaText" forKey:@"key"];
		[spec setProperty:@(0.9) forKey:@"default"];
		[specifiers addObject:spec];

		
		spec = [PSSpecifier emptyGroupSpecifier];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Reset Settings"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(reset);
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Developer"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Developer" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Follow julioverne"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(twitter);
		[spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
		[spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"NtSpeed © 2021" forKey:@"footerText"];
        [specifiers addObject:spec];
		_specifiers = [specifiers copy];
	}
	return _specifiers;
}
- (void)twitter
{
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]];
	} else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]];		
	} else {
		[app openURL:[NSURL URLWithString:@"https://mobile.twitter.com/ijulioverne"]];
	}
}
- (void)love
{
	SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twitter setInitialText:@"#NtSpeed by @ijulioverne is cool!"];
	if (twitter != nil) {
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
	}
}
- (void)reset
{
	[@{} writeToFile:@PLIST_PATH_Settings atomically:YES];
	[self reloadSpecifiers];
	[self showPrompt];
	notify_post("com.julioverne.ntspeed/Settings");
}

- (void)showPrompt
{
	if(objc_getClass("UIAlertController")!=nil) {
		UIAlertController* alert = [objc_getClass("UIAlertController") alertControllerWithTitle:self.title message:@"An Respring is Requerid for this option." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [objc_getClass("UIAlertAction") actionWithTitle:@"Respring" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			system("killall backboardd SpringBoard");
		}];
		[alert addAction:defaultAction];
		UIAlertAction* defaultActionCancel = [objc_getClass("UIAlertAction") actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
		[alert addAction:defaultActionCancel];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		UIAlertView *alert = [[objc_getClass("UIAlertView") alloc] initWithTitle:self.title message:@"An Respring is Requerid for this option." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
		alert.tag = 55;
		[alert show];
	}
}

- (void)reloadSpec
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_reloadSpec) object:nil];
	[self performSelector:@selector(_reloadSpec) withObject:nil afterDelay:0.5f];
}

- (void)_reloadSpec
{
	[self reloadSpecifiers];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	@autoreleasepool {
		NSMutableDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		
		NSString* keyVal = [specifier identifier];
		id val = value;
		
		if([keyVal hasSuffix:@".0"]) {
			keyVal = [keyVal substringToIndex:[keyVal length]-2];
			val = @([(NSString*)val doubleValue]);
		}
		
		[CydiaEnablePrefsCheck setObject:val forKey:keyVal];
		[CydiaEnablePrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.ntspeed/Settings");
		if ([[specifier properties] objectForKey:@"PromptRespring"]) {
			[self showPrompt];
		}
		
		[self reloadSpec];
	}
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 55 && buttonIndex == 1) {
        system("killall backboardd SpringBoard");
    }
}
- (id)readPreferenceValue:(PSSpecifier*)specifier
{
	@autoreleasepool {
		
		NSString* keyVal = [specifier identifier];
		
		if([keyVal hasSuffix:@".0"]) {
			keyVal = [keyVal substringToIndex:[keyVal length]-2];
		}
		
		NSDictionary *CydiaEnablePrefsCheck = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings];
		return CydiaEnablePrefsCheck[keyVal]?:[[specifier properties] objectForKey:@"default"];
	}
}
- (void)_returnKeyPressed:(id)arg1
{
	[super _returnKeyPressed:arg1];
	[self.view endEditing:YES];
}

- (void)HeaderCell
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		[_label setText:self.title];
		[_label setBackgroundColor:[UIColor clearColor]];
		//_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"See Active Network Speed"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;
		
		[headerView addSubview:_label];
		[headerView addSubview:underLabel];
		
	[_table setTableHeaderView:headerView];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(increaseAlpha)
                                   userInfo:nil
                                    repeats:NO];
				
	}
}
- (void) loadView
{
	[super loadView];
	self.title = @"NtSpeed";	
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.09 green:0.99 blue:0.99 alpha:1.0];
	UIButton *heart = [[UIButton alloc] initWithFrame:CGRectZero];
	[heart setImage:[[UIImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forState:UIControlStateNormal];
	[heart sizeToFit];
	[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heart];
	[self HeaderCell];
}
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}				
@end