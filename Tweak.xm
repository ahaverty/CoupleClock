#define PLIST_PATH @"/var/mobile/Library/Preferences/com.ahaverty.coupleclock.plist"

@interface SBStatusBarStateAggregator : NSObject
-(void)_updateTimeItems;
-(NSDictionary *)coupleClockGetSettings;
-(NSDateFormatter *)coupleClockGetCustomTime;
@end

void coupleclock_settingsDidUpdate(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
	[NSThread sleepForTimeInterval:0.5f];	//Added delay due to update time method running faster than plist file was saving
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.ahaverty.coupleclock/update.time" object:nil userInfo:nil];
}

NSDateFormatter *styleFormatter;
NSDateFormatter *primaryClockFormatter;
NSDateFormatter *secondClockFormatter;

%group CoupleClock
	%hook SBStatusBarStateAggregator
	
		%new
		-(NSDictionary *) coupleClockGetSettings {
			return [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
		}
		
		%new
		-(NSDateFormatter *)coupleClockGetCustomTime {
			NSString *timeStyle = @"HH:mm";
			NSDictionary *settings = [self coupleClockGetSettings];
			NSDate *currentDate = [NSDate date];

			styleFormatter = [[NSDateFormatter alloc] init];
			
			primaryClockFormatter = [[NSDateFormatter alloc] init];
			secondClockFormatter = [[NSDateFormatter alloc] init];
			
			[primaryClockFormatter setTimeStyle:NSDateFormatterNoStyle];
			[primaryClockFormatter setDateFormat:timeStyle];	//add settings for customizing format
			[secondClockFormatter setDateFormat:timeStyle];	//add settings for customizing format
			[secondClockFormatter setTimeZone:[NSTimeZone timeZoneWithName:settings[@"secondaryTimeZone"]]];
			
			NSString *primaryDateString = [primaryClockFormatter stringFromDate:currentDate];
			NSString *secondaryDateString = [secondClockFormatter stringFromDate:currentDate];
			
			[styleFormatter setDateFormat:[NSString stringWithFormat:@"'%@' - '%@'", primaryDateString, secondaryDateString]];	//add setting for customizing divider character
			return styleFormatter;
		}
		
	
		-(id)init {
			self = %orig;

			if (self) {
				
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTimeItems) name:@"com.ahaverty.coupleclock/update.time" object:nil];
				
				CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
												NULL,
												coupleclock_settingsDidUpdate,
												CFSTR("com.ahaverty.coupleclock/preferences.changed"),
												NULL,
												CFNotificationSuspensionBehaviorCoalesce);
			}
			
			return self;
		}

		-(void)_updateTimeItems {
			
			//TODO settings to toggle
			if (self) {
				MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter") = [self coupleClockGetCustomTime];
			}
			
			%orig;
		}
	%end
%end

%ctor {
	%init(CoupleClock);
}