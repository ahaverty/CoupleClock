#import <Preferences/Preferences.h>

@interface CoupleClockSettingsListController: PSListController {
}
@end

@implementation CoupleClockSettingsListController

-(NSArray *)timeZones {
	return [NSTimeZone knownTimeZoneNames];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CoupleClockSettings" target:self] retain];
	}
	
	return _specifiers;
}
@end