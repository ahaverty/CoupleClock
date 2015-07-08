#define PLIST_PATH @"/var/mobile/Library/Preferences/com.ahaverty.coupleclock.plist"

@interface SBStatusBarStateAggregator : NSObject
-(void)_updateTimeItems;
-(NSDictionary *)coupleclock_getSettings;
@end

void coupleclock_settingsDidUpdate(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSystemClockDidChangeNotification object:nil userInfo:nil];
}

NSDateFormatter *dateFormatter;

%group CoupleClock
	%hook SBStatusBarStateAggregator
	
		%new
		- (NSDictionary *) coupleclock_getSettings {
			NSDictionary *settings;
			settings = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
			return settings;
		}
	
		- (id)init {
			self = %orig;

			if (self) {
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTimeItems) name:NSSystemClockDidChangeNotification object:nil];
				CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, coupleclock_settingsDidUpdate, CFSTR("coupleclock_settingsupdated_notification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
			}
			
			return self;
		}

		- (void)_updateTimeItems {
			NSDictionary *settings2 = [self coupleclock_getSettings];
			
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			[dateFormatter setDateFormat:@"HH:mm"];
			NSString *defaultDateString = [dateFormatter stringFromDate:[NSDate date]];
			[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:settings2[@"kTimeZone"]]];
			NSString *secondDateString = [dateFormatter stringFromDate:[NSDate date]];
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%@' - '%@'",defaultDateString,secondDateString]];
			MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter") = dateFormatter;
			dateFormatter = nil;
			
			%orig;
		}
	%end
%end

%ctor {
	%init(CoupleClock);
}