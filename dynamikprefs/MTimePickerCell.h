#import "Preferences/PSTableCell.h"

@interface MTimePickerCell : PSTableCell {
	UIDatePicker *timePicker;
}
@end


@implementation MTimePickerCell
	NSString *preferencesFile = @"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist";

	-(void)layoutSubviews {
			timePicker = [[UIDatePicker alloc] init];
			timePicker.datePickerMode = UIDatePickerModeTime;
			timePicker.backgroundColor = [UIColor clearColor];
      timePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      timePicker.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);

			NSMutableDictionary * preferences = [NSMutableDictionary dictionaryWithContentsOfFile:preferencesFile];
			NSDate *fireTime = [preferences objectForKey:@"fireTime"];
			if(fireTime == nil) {
				NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
				NSDate *defaultTime = [[NSCalendar currentCalendar] dateFromComponents:components];
				timePicker.date = defaultTime;
			} else {
				timePicker.date = fireTime;
			}

      [timePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
      [self addSubview:timePicker];
	}

  -(void)timeChanged:(UIDatePicker *)sender {
		NSMutableDictionary * preferences = [NSMutableDictionary dictionaryWithContentsOfFile:preferencesFile];
		NSDate *timePickerDate = sender.date;
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:timePickerDate];
		NSDate *dateToSave = [[NSCalendar currentCalendar] dateFromComponents:components];

		[preferences setObject:dateToSave forKey:@"fireTime"];
		[preferences writeToFile:preferencesFile atomically:YES];
  }
@end
