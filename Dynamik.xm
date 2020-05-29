#import <Cephei/HBPreferences.h>
#import "DynamikClasses.h"
#import "NSTask.h"

#define LD_DEBUG NO

  /*
   * Preference variables
   */
  static int wallpaperMode;
  static NSDate *fireTime;
  NSString *subreddit;
  BOOL parallax;
  BOOL timerEnabled;
  BOOL nsfwFilter;
  BOOL highQualityFilter;
  int numberOfPostsGrabbed;

  /*
   * Global variables
   */
  BOOL dynamikInitalAlertShown;
  BOOL savedInitalWallpaper;
  int timerInterval;
  NSString *currentImageURL;
  NSString *currentShownImageURL;
  PCSimpleTimer *timer;
  SBHomeScreenViewController *HomeScreenViewController;

  extern "C" CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

  /*
  * Shows inital alert after install. Allows user to save current wallpapers if they want
  * Thanks! - Lacertosus' "Stellae" (https://github.com/LacertosusRepo)
  */
%hook SpringBoard
  -(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;

    NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist"];
    dynamikInitalAlertShown = [[saveddata objectForKey:@"dynamikInitalAlertShown"] boolValue];

    if(!dynamikInitalAlertShown) {
      [saveddata setObject:[NSNumber numberWithBool:1] forKey:@"dynamikInitalAlertShown"];
      [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist" atomically:YES];

      UIAlertController *dynamikInitalAlert = [UIAlertController alertControllerWithTitle:@"Dynamik" message:@"Thanks for installing Dynamik! Would you like to backup your wallpaper(s) to your photo library?" preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Sure!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"]) {
          NSData *homeData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"];
          CFArrayRef homeArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)homeData, NULL, 1, NULL);
          NSArray *homeArray = (__bridge NSArray*)homeArrayRef;
          UIImage *homeWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(homeArray[0])];
          UIImageWriteToSavedPhotosAlbum(homeWallpaper, nil, nil, nil);
          CFRelease(homeArrayRef);

        } if([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"]) {
          NSData *lockData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"];
          CFArrayRef lockArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)lockData, NULL, 1, NULL);
          NSArray *lockArray = (__bridge NSArray*)lockArrayRef;
          UIImage *lockWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(lockArray[0])];
          UIImageWriteToSavedPhotosAlbum(lockWallpaper, nil, nil, nil);
          CFRelease(lockArrayRef);
        }
      }];
      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleCancel handler:nil];

      [dynamikInitalAlert addAction:confirmAction];
      [dynamikInitalAlert addAction:cancelAction];
      [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:dynamikInitalAlert animated:YES completion:nil];
    }
  }
%end

  /*
   * Main chunk of it all. Creates timer on init, gets the current time and fire time and converts them to NSDates with time only.
   * Once the timer fires it calls setRedditWallpaper, invalidates the timer and creates another checking if the current time is
   * within an hour of the fireTime.
   */
%hook SBHomeScreenViewController
%property (nonatomic, retain) PCSimpleTimer *apolloTimer;

  -(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
    [self createTimer];
    return HomeScreenViewController = %orig;
  }

%new
  /*
   * Thank you Tateu, very cool!
   * https://github.com/tateu/TimerExample/blob/master/Tweak.xm
   */
  -(void)createTimer {
    if (timerEnabled) {
      if(LD_DEBUG) {
        timerInterval = 30;
      } else {
        timerInterval = 1800;
      }

      if(timer) {
        [timer invalidate];
        [self.apolloTimer invalidate];

        timer = nil;
        self.apolloTimer = nil;
      }

      timer = [[%c(PCSimpleTimer) alloc] initWithTimeInterval:timerInterval serviceIdentifier:@"com.jeffresc.dynamik" target:self selector:@selector(setRedditWallpaper) userInfo:nil];
      timer.disableSystemWaking = NO;
      [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
      self.apolloTimer = timer;

      if(LD_DEBUG) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
      }
    }
  }

%new
  -(void)setRedditWallpaper {
    NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist"];
    fireTime = [saveddata objectForKey:@"fireTime"];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *fireTimeComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:fireTime];
    fireTimeComponents.hour = fireTimeComponents.hour + 1;
    NSDate *fireTimeGate = [calendar dateFromComponents:fireTimeComponents];

		NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
		NSDate *currentDate = [calendar dateFromComponents:components];

    if((([currentDate compare:fireTime] == NSOrderedDescending) && ([currentDate compare:fireTimeGate] == NSOrderedAscending))) {
      CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.dynamik-runCommand"), nil, nil, true);
    }
    if (![self.apolloTimer isValid]) {
      [self createTimer];
    }
    if(LD_DEBUG) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
  }
%end

/*
 * Runs the update command using dynamikcli
 */
static void runUpdateCommand() {
  // Set locationFlag
  char locationFlag;
  switch (wallpaperMode) {
    case 0:
      locationFlag = 'b';
      break;
    case 1:
      locationFlag = 'h';
      break;
    case 2:
      locationFlag = 'l';
      break;
  }

  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/usr/bin/dynamikcli"];
  NSArray *arr = [NSArray arrayWithObjects:@"-s", subreddit, @"-m", [@(numberOfPostsGrabbed) stringValue], [NSString stringWithFormat:@"-%c", locationFlag], (parallax ? @"-p" : @""), (nsfwFilter ? @"-n" : @""), (highQualityFilter ? @"-q" : @""), nil];
  [task setArguments:arr];
  [task launch];
}

  /*
   * Saves the current wallpapers based on where the image is currently applied to
   *
   * wallpaperMode: 1 = homescreen, 2 = lockscreen, 0 = both
   */
static void saveImage() {
  if((wallpaperMode == 1 || wallpaperMode == 0) && [[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"]) {
    NSData *homeData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"];
    CFArrayRef homeArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)homeData, NULL, 1, NULL);
    NSArray *homeArray = (__bridge NSArray*)homeArrayRef;
    UIImage *homeWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(homeArray[0])];
    UIImageWriteToSavedPhotosAlbum(homeWallpaper, nil, nil, nil);
    CFRelease(homeArrayRef);

  } if((wallpaperMode == 2 || wallpaperMode == 0) && [[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"]) {
    NSData *lockData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"];
    CFArrayRef lockArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)lockData, NULL, 1, NULL);
    NSArray *lockArray = (__bridge NSArray*)lockArrayRef;
    UIImage *lockWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(lockArray[0])];
    UIImageWriteToSavedPhotosAlbum(lockWallpaper, nil, nil, nil);
    CFRelease(lockArrayRef);
  }
}

  /*
   * Loads my preferences. If saveddata plist has less objects than there are suppossed to be, it is reset.
   */
static void loadPrefs() {
  // Preferences
  HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.jeffresc.dynamikprefs"];
  wallpaperMode = [([file objectForKey:@"wallpaperMode"] ?: @(2)) intValue];
  subreddit = [([file objectForKey:@"subreddit"] ?: @("SpacePorn")) stringValue];;
  parallax = [([file objectForKey:@"parallax"] ?: @(NO)) boolValue];
  timerEnabled = [([file objectForKey:@"timerEnabled"] ?: @(NO)) boolValue];
  nsfwFilter = [([file objectForKey:@"nsfwFilter"] ?: @(YES)) boolValue];
  highQualityFilter = [([file objectForKey:@"highQualityFilter"] ?: @(YES)) boolValue];;
  numberOfPostsGrabbed = [([file objectForKey:@"numberOfPostsGrabbed"] ?: @(5)) intValue];
  // Saved data
  NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist"];
  if(!saveddata || [saveddata count] < 4) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    NSDate *defaultTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    saveddata = [[NSMutableDictionary alloc] init];
    [saveddata setObject:defaultTime forKey:@"fireTime"];
    [saveddata setObject:@"" forKey:@"currentShownImageURL"];
    [saveddata setObject:@"" forKey:@"currentImageURL"];
    [saveddata setObject:[NSNumber numberWithBool:0] forKey:@"dynamikInitalAlertShown"];
    [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.dynamiksaveddata.plist" atomically:YES];
  }
}

  /*
   * Setup notifications
   */
%ctor {
  @autoreleasepool {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)runUpdateCommand, CFSTR("com.jeffresc.dynamik-runCommand"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)saveImage, CFSTR("com.jeffresc.dynamikprefs-saveImage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.jeffresc.dynamikprefs-loadPrefs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  }
}
