static NSDictionary *settings = nil;

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.ahaverty.coupleclock.plist"

@interface SBStatusBarStateAggregator : NSObject
-(void)_updateTimeItems;
@end

void coupleclock_settingsDidUpdate(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {

	if (settings) {
		settings = nil;
	}
	
	settings = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];

	[[NSNotificationCenter defaultCenter] postNotificationName:NSSystemClockDidChangeNotification object:nil userInfo:nil];
}

NSDateFormatter *dateFormatter;

%group CoupleClock
	%hook SBStatusBarStateAggregator
	
		-(id)init {
			self = %orig;

			if (self) {
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTimeItems) name:NSSystemClockDidChangeNotification object:nil];
				CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, coupleclock_settingsDidUpdate, CFSTR("coupleclock_settingsupdated_notification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
			}

			return self;
		}

		-(void)_updateTimeItems {
		
			dateFormatter = [[NSDateFormatter alloc] init];
			
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			
			[dateFormatter setDateFormat:@"HH:mm"];
			
			NSString *defaultDateString = [dateFormatter stringFromDate:[NSDate date]];
			
			[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:settings[@"kTimeZone"]]];
			
			NSString *secondDateString = [dateFormatter stringFromDate:[NSDate date]];
			
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%@' - '%@'",defaultDateString,secondDateString]];
			
			MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter") = dateFormatter;
			dateFormatter = nil;

			%orig;
		}
	%end
%end

%ctor {

	settings = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	%init(CoupleClock);

}